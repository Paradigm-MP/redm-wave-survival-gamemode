ObjectEditor = class()

function ObjectEditor:__init()
    self.active = false -- If the object editor is active or not
    self.move_speed = 1 -- Move speed
    self.rot_speed = 10 -- rot speed
    self.selected_object = nil -- Current selected object
    self.rotation_active = false
    self.display_object_data = false

    self.edit_object_ids = 1 -- Keep track of object unique ids for undoing
    self.edit_history = {} -- History of actions for undo
    self.can_select_obj = true
    self.can_select_obj_timer = false

    self.help_text = 
    "/oe - Toggle object editor mode on/off<br>" ..
    "/spawn [object_name] - Spawn an object at your position<br>" ..
    "/tr - Toggle rotation mode on/off (makes keys rotate or move object)<br>" ..
    "Arrow keys - Move/rotate object<br>" ..
    "N,B keys - Move object up or down (or rotate if in rotate mode)<br>" ..
    "R - Select the object that you are looking at<br>" ..
    "J - Delete selected object<br>" ..
    "U - Undo<br>" ..
    "/speed [number] - Sets move/rotation speed to the amount inputted<br>" ..
    "/dup - Duplicate a selected object<br>" ..
    "/col - Toggle LocalPlayer collision<br>" ..
    "/toggledata - Toggle display of object data (besides just selected one)<br>" ..
    "/save [filename] - Saves all spawned objects to a json file<br>" ..
    "/load [filename] - Loads all objects from a json file<br>" ..
    "/deleteall - Deletes all spawned objects"
    
    Events:Subscribe("LocalPlayerChat", function(args) self:LocalPlayerChat(args) end)

    KeyPress:Subscribe(Control.Reload)
    KeyPress:Subscribe(Control.GameMenuUp)
    KeyPress:Subscribe(Control.GameMenuDown)
    KeyPress:Subscribe(Control.GameMenuLeft)
    KeyPress:Subscribe(Control.GameMenuRight)
    KeyPress:Subscribe(Control.AimInAir) -- U
    KeyPress:Subscribe(Control.OpenSatchelMenu) -- B
    KeyPress:Subscribe(Control.PushToTalk) -- N
    KeyPress:Subscribe(Control.OpenJournal) -- J
    Events:Subscribe("KeyDown", function(args) self:KeyUp(args) end)
    
    Network:Subscribe("object-editor/load_objects", function(args) self:LoadObjects(args) end)
end

function ObjectEditor:LoadObjects(args)
    for _, obj in pairs(args.data) do
        self:SpawnObject({
            model = obj.model,
            position = vector3(obj.pos.x, obj.pos.y, obj.pos.z),
            rotation = vector3(obj.rot.x, obj.rot.y, obj.rot.z)
        })
    end

    self.selected_object = nil

    Chat:Print({
        text = tostring(#args.data) .. " objects loaded from server!",
        style = "bold",
        color = Colors.Green
    })
end

function ObjectEditor:KeyUp(args)
    if not self.active then return end
    if args.key == Control.GameMenuUp then
        self:MoveObject(vector3(0, 1, 0))
    elseif args.key == Control.GameMenuDown then
        self:MoveObject(vector3(0, -1, 0))
    elseif args.key == Control.GameMenuLeft then
        self:MoveObject(vector3(-1, 0, 0))
    elseif args.key == Control.GameMenuRight then
        self:MoveObject(vector3(1, 0, 0))
    elseif args.key == Control.ReplayShowhotkey and self.selected_object ~= nil then
        self:AddToUndoHistory("delete", self.selected_object)
        self.selected_object:Destroy()
        self.selected_object = nil
    elseif args.key == Control.PushToTalk then
        self:MoveObject(vector3(0, 0, 1))
    elseif args.key == Control.InteractHorseBrush then
        self:MoveObject(vector3(0, 0, -1))
    elseif args.key == Control.ReplayScreenshot then
        self:Undo()
    elseif args.key == Control.Reload then
        self:SelectObject()
    end
end

function ObjectEditor:Undo()
    if #self.edit_history == 0 then
        Chat:Print({
            text = "Nothing to undo!"
        })
        return
    end

    local move = table.remove(self.edit_history)
    local obj = self:FindObjectByEditId(move.id)

    if move.action == "move/rotate" and obj ~= nil then -- Object was moved, so move it back
        obj:SetPosition(move.pos)
        obj:SetRotation(move.rot)
        self.selected_object = obj
    elseif move.action == "create" and obj ~= nil then -- Object was created, so delete it
        obj:Destroy()
    elseif move.action == "delete" then -- Object was deleted, so recreate it
        self:SpawnObject({
            model = move.model,
            position = move.pos,
            rotation = move.rot
        }, function(object)
            object:SetValue("ObjectEditorId", move.id)
            self.selected_object = object
        end)
    end
end

function ObjectEditor:FindObjectByEditId(id)
    for _, object in pairs(Objects) do
        if object:GetValue("ObjectEditorId") == id then
            return object
        end
    end
end

function ObjectEditor:AddToUndoHistory(action, object)
    local data = {
        action = action,
        object = object,
        pos = object:GetPosition(),
        rot = object:GetRotation(),
        model = object:GetModel()
    }

    if action == "create" then
        object:SetValue("ObjectEditorId", self.edit_object_ids)
        self.edit_object_ids = self.edit_object_ids + 1
    end

    data.id = object:GetValue("ObjectEditorId")

    table.insert(self.edit_history, data)
end

function ObjectEditor:MoveObject(dir)
    if self.selected_object then
        if not self.rotation_active then
            self.selected_object:SetPosition(self.selected_object:GetPosition() + dir * self.move_speed)
        else
            self.selected_object:SetRotation(self.selected_object:GetRotation() + dir * self.rot_speed)
        end
        self:AddToUndoHistory("move/rotate", self.selected_object)
    end
end

function ObjectEditor:SelectObject()
    local raycast = Physics:Raycast(Camera:GetPosition(), Camera:GetPosition() + Camera:GetRotation() * 100)

    if raycast.hit then
        self.selected_object = ObjectManager:FindObjectByEntityId(raycast.entity) or self.selected_object
    end
end

function ObjectEditor:LocalPlayerChat(args)
    if args.text == "/oe" then
        self.active = not self.active
        Chat:Print({
            text = self.active and "Toggled Object Editor Mode On" or "Toggled Object Editor Mode Off",
            color = Colors.Green,
            style = "bold"
        })
        self:PrintHelpText()

        if self.active then
            self.render_event = Events:Subscribe("Render", function(args) self:Render(args) end)
        else
            self.render_event:Unsubscribe()
        end
    end

    if not self.active then return end

    local split = split(args.text, " ")

    if split[1] == "/spawn" and split[2] then
        local raycast = Physics:Raycast(
            Camera:GetPosition(), 
            Camera:GetPosition() + Camera:GetRotation() * 100, 
            nil, 
            LocalPlayer:GetPed():GetEntity())
        self:SpawnObject({model = split[2], position = raycast.position})
    elseif split[1] == "/speed" and split[2] then
        if self.rotation_active then
            self.rot_speed = tonumber(split[2])
        else
            self.move_speed = tonumber(split[2])
        end
        Chat:Print({
            text = "Set " .. (self.rotation_active and " rotation " or " move ") .. "speed to " .. 
                (self.rotation_active and self.rot_speed or self.move_speed),
            style = "bold",
            color = Colors.Green
        })
    elseif split[1] == "/tr" then
        self.rotation_active = not self.rotation_active
        Chat:Print({
            text = "Switched to object " .. (self.rotation_active and "rotation" or "move") .. " mode",
            style = "bold",
            color = Colors.Yellow
        })
    elseif split[1] == "/deleteall" then
        ObjectManager:RemoveAllObjects()
        Chat:Print({
            text = "All objects deleted!",
            style = "bold",
            color = Colors.Red
        })
        self.selected_object = nil
        self.edit_history = {}
    elseif split[1] == "/save" and split[2] then
        Network:Send("object-editor/save", {data = self:SerializeAllObjects(), file = split[2]})
    elseif split[1] == "/load" and split[2] then
        Network:Send("object-editor/load", {file = split[2]})
    elseif split[1] == "/help" then
        self:PrintHelpText()
    elseif split[1] == "/dup" and self.selected_object then
        self:SpawnObject({
            model = self.selected_object:GetModel(), 
            position = self.selected_object:GetPosition(), 
            rotation = self.selected_object:GetRotation()
        })
    elseif split[1] == "/pos" then
        print(LocalPlayer:GetPosition())
    elseif split[1] == "/toggledata" then
        self.display_object_data = not self.display_object_data
    elseif split[1] == "/forward" then
        LocalPlayer:SetPosition(LocalPlayer:GetPosition() + Camera:GetRotation() * 3)
    end
end

function ObjectEditor:SerializeAllObjects()
    local data = {}

    for id, object in pairs(Objects) do
        if object:GetValue("ObjectEditorId") then
            local pos = object:GetPosition()
            local rot = object:GetRotation()
            table.insert(data, {
                model = object:GetModel(),
                pos = {x = pos.x, y = pos.y, z = pos.z},
                rot = {x = rot.x, y = rot.y, z = rot.z}
            })
        end
    end

    return data
end

function ObjectEditor:SpawnObject(args, cb)
    args.isNetwork = true
    args.kinematic = true
    args.callback = function(obj)
        self.selected_object = obj
        self:AddToUndoHistory("create", self.selected_object)
    end
    if cb then cb(Object(args)) else Object(args) end
end

function ObjectEditor:Render(args)
    if self.display_object_data then
        for id, object in pairs(Objects) do
            self:RenderObjectData(object)
        end
    elseif self.selected_object then
        self:RenderObjectData(self.selected_object)
    end

    
    local raycast = Physics:Raycast(Camera:GetPosition(), Camera:GetPosition() + Camera:GetRotation() * 100, nil, LocalPlayer:GetPed():GetEntity())
    local pos = raycast.position + raycast.normal * 0.2
    --Render:HighlightCoords(pos, HighlightCoordsColors.Green)
end

function ObjectEditor:RenderObjectData(object)
    local pos = object:GetPosition()
    local pos_2d = Render:WorldToScreen(pos)
    local rot = object:GetRotation()
    local color = object:Equals(self.selected_object) and Colors.Yellow or Colors.White
    local text = object:GetModel() .. "\n" ..
        string.format("pos: %.2f, %.2f, %.2f", pos.x, pos.y, pos.z) .. "\n" ..
        string.format("rot: %.2f, %.2f, %.2f", rot.x, rot.y, rot.z)
    Render:DrawText(pos_2d, text, color, 0.3, 0)
end

function ObjectEditor:PrintHelpText()
    Chat:Print({
        text = self.help_text,
        color = Colors.Yellow,
        style = "bold"
    })
end

if IsTest then
    ObjectEditor = ObjectEditor()
end