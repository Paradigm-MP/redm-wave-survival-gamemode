LobbyManager = class()

function LobbyManager:__init()

    Filter:Clear() -- Just in case there's a lingering filter
    self.ui = UI:Create({name = "lobby", path = "lobby/client/html/index.html"})
    self.cam_pos = vector3(-302, 789, 128)

    Network:Subscribe("lobby/queue/sync/full", function(args) self:FullQueueSync(args) end)
    Network:Subscribe("lobby/map/sync/full", function(args) self:FullMapSync(args) end)
    Network:Subscribe("lobby/queue/sync/single", function(args) self:SingleQueueSync(args) end)
    Network:Subscribe("lobby/players/sync/full", function(args) self:FullPlayersSync(args) end)
    Network:Subscribe("lobby/players/sync/single", function(args) self:SinglePlayerSync(args) end)
    Network:Subscribe("lobby/queue/sync/countdown", function(args) self:QueueCountdownSync(args) end)
    Network:Subscribe("lobby/queue/sync/game", function(args) self:QueueGameStatusSync(args) end)
    Network:Subscribe("shop/initial_sync", function(args) self:InitialShopSync(args) end)

    Events:Subscribe("PlayerNetworkValueChanged", function(args) self:PlayerNetworkValueChanged(args) end)

    self.ui:Subscribe('lobby/joinleavebutton', function(data)
        self:PressJoinLeaveButton(data)
    end)

    self.ui:Subscribe('lobby/readyupbutton', function()
        self:PressReadyButton()
    end)

    self.ui:Subscribe('lobby/joinexistinggame', function()
        self:JoinExistingGameButton()
    end)

    self.ui:Subscribe('lobby/ready', function()
        self:UIReady()
    end)

    self.ui:Subscribe('lobby/esc', function()
        self:EscPressed()
    end)

    self.ui:Subscribe('lobby/shop/equip_item', function(args)
        self:PressEquipItemButton(args)
    end)

    self.ui:Subscribe('lobby/shop/buy_item', function(args)
        self:PressBuyItemButton(args)
    end)

    KeyPress:Subscribe(Control.FrontendPause)
    KeyPress:Subscribe(Control.FrontendPauseAlternate)

    Events:Subscribe("KeyUp", function(args) self:KeyUp(args) end)

end

function LobbyManager:InitialShopSync(args)
    self.ui:CallEvent("lobby/shop/sync/shop_items", {data = args.data})
    
    -- In case model is synced before UI is ready
    if LocalPlayer:GetPlayer():GetValue("Model") then
        self:PlayerNetworkValueChanged({
            name = "Model",
            player = LocalPlayer:GetPlayer(),
            val = LocalPlayer:GetPlayer():GetValue("Model")
        })
    end
end

function LobbyManager:PlayerNetworkValueChanged(args)
    if not LocalPlayer:IsPlayer(args.player) then return end

    if args.name == "Money" or args.name == "BoughtShopItems" or args.name == "Model" then
        local data = {name = args.name, val = args.val}
        if old_val ~= nil then data.old_val = args.old_val end

        self.ui:CallEvent("lobby/shop/sync/network_val_changed", data)
    end
end

function LobbyManager:PressEquipItemButton(args)
    Network:Send("shop/equip_item", {id = args.id})
end

function LobbyManager:PressBuyItemButton(args)
    Network:Send("shop/buy_item", {id = args.id})
end

function LobbyManager:KeyUp(args)
    if args.key == Control.FrontendPauseAlternate or args.key == Control.FrontendPause then
        self:EscPressed()
    end
end

function LobbyManager:EscPressed()
    if self.ui:GetVisible() then
        self.ui:Hide()
        UI:SetCursor(false)
        --UI:SetFocus(false)
    elseif not GameManager:GetIsGameInProgress() then
        Citizen.CreateThread(function()
            Wait(100)
            if not PauseMenu:IsActive() and not self.ui:GetVisible() then
                self.ui:Show()
                UI:SetCursor(true)
                UI:SetFocus(true)
            end
        end)
    end
end

function LobbyManager:SetCameraPosition()
    Camera:DetachFromPlayer()
    Camera:SetPosition(self.cam_pos)
    Camera:SetRotation(vector3(-10,0,90))
end

function LobbyManager:GetUI()
    return self.ui
end

function LobbyManager:QueueGameStatusSync(args)
    self.ui:CallEvent("lobby/queue/sync/game", args)
end

function LobbyManager:QueueCountdownSync(args)
    self.ui:CallEvent("lobby/queue/sync/countdown", args)
end

-- When the player clicks on JOIN GAME for a game that's already going
function LobbyManager:JoinExistingGameButton()
    Network:Send('lobby/queue/sync/joinexistinggame')
end

function LobbyManager:UIReady()
    Network:Send("lobby/maps/sync/ready")
    self:Reset()
    self:GetUI():BringToFront()
end

-- Resets the UI on load or after a game
function LobbyManager:Reset()
    if not self.ui:GetVisible() then
        self.ui:Show()
    end

    NetworkSetInSpectatorMode(0, 0)

    LocalPlayer:GetPlayer():Freeze(true)
    World:SetTime(12, 0, 0)

    Camera:Reset()
    self:SetCameraPosition()

    -- Must spawn player in order to load world around them for the camera
    LocalPlayer:Spawn({
        pos = self.cam_pos - vector3(0, 0, 30),
        model = "Player_Zero",
        callback = function() 
            LocalPlayer:GetPlayer():Freeze(true)
        end
    })

    RequestCollisionAtCoord(self.cam_pos.x, self.cam_pos.y, self.cam_pos.z)
    UI:SetCursor(true)
    UI:SetFocus(true)
    -- Blur background
    Filter:Apply({
        name = "hud_def_blur",
        amount = 1
    })
end

function LobbyManager:PressReadyButton()
    Network:Send("lobby/queue/sync/ready")
end

function LobbyManager:PressJoinLeaveButton(data)
    local joined = data.joined
    data.joined = nil

    if joined then
        Network:Send("lobby/queue/sync/join", data)
    else
        Network:Send("lobby/queue/sync/leave")
    end
end

function LobbyManager:SinglePlayerSync(args)
    self.ui:CallEvent("lobby/players/sync/single", args)
end

function LobbyManager:FullPlayersSync(args)
    self.players = args
    self.ui:CallEvent("lobby/players/sync/full", args)
end

-- todo: send localplayer server id to ui so we can check if they're queued and modify buttons :)

function LobbyManager:FullQueueSync(args)
    self.queue = args
    self.ui:CallEvent("lobby/queue/sync/full", args)
end

function LobbyManager:GetMapData()
    return self.map_data
end

function LobbyManager:FullMapSync(args)
    self.map_data = args
    self.ui:CallEvent("lobby/map/sync/full", args)
end

function LobbyManager:SingleQueueSync(args)
    self.queue[args.name][args.difficulty] = args.data
    self.ui:CallEvent("lobby/queue/sync/single", args)
end

LobbyManager = LobbyManager()