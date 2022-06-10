ObjectEditor = class()

function ObjectEditor:__init()
    Network:Subscribe("object-editor/save", function(args) self:SaveObjects(args) end)
    Network:Subscribe("object-editor/load", function(args) self:LoadObjects(args) end)
end

function ObjectEditor:SaveObjects(args)
    if not args.data then return end
    JSONUtils:SaveJSON(args.data, "object-editor/server/saved-files/" .. args.file .. ".json")
    Chat:Send({
        player = args.player,
        text = "<b>Saved " .. tostring(#args.data) .. " objects to object-editor/server/saved-files/" .. args.file .. ".json</b>",
        color = Colors.Green
    })
end

function ObjectEditor:LoadObjects(args)
    if not args.file then return end
    local obj = JSONUtils:LoadJSON("object-editor/server/saved-files/" .. args.file .. ".json")
    if not obj then return end
    Network:Send("object-editor/load_objects", args.player, {data = obj})
end

ObjectEditor = ObjectEditor()