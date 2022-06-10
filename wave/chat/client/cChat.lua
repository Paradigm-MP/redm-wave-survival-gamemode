Chat = class(ChatUtility)

function Chat:__init()
    self.max_characters = 1000
    self.my_name = ''
    self.open = false

    SetTextChatEnabled(false)

    self.ui = UI:Create({
        name = "chat", 
        path = "chat/client/ui/index.html",
        css = {
            ["left"] = "10px",
            ["bottom"] = "25%",
            ["width"] = "525px",
            ["height"] = "335px"
        },
        visible = false
    })

    self.ui:Subscribe('chat/input_state', function(args)
        self:InputStateChanged(args)
    end)

    self.ui:Subscribe('chat/submit_message', function(args)
        self:SubmitMessage(args)
    end)

    self.ui:Subscribe('chat/ui_ready', function()
        self:UIReady()
    end)

    Network:Subscribe('chat/message', function(args)
        self:AddMessage(args)
    end)

    Network:Subscribe('chat/init_config', function(args)
        self:InitializeConfig(args)
    end)

    Network:Subscribe('chat/store_name', function(args)
        self:StoreName(args)
    end)

    Network:Subscribe('chat/add_player', function(args)
        self:AddPlayer(args)
    end)

    Network:Subscribe('chat/remove_player', function(args)
        self:RemovePlayer(args)
    end)

    Network:Subscribe('chat/init_players', function(args)
        self:InitializePlayers(args)
    end)

    Events:Subscribe('LocalPlayerChat', function(args)
        self:LocalPlayerChat(args)
    end)

    KeyPress:Subscribe(Control.MpTextChatAll)

    Events:Subscribe('KeyUp', function(args)
        self:KeyUp(args)
    end)
end

function Chat:Debug(args)
    if IsTest then self:Print(args) end
end

function Chat:Print(args)
    if type(args) == 'string' then
        args = {text = args}
    end

    assert(type(args) == 'table', 'Chat:Print failed: args was not a table or string')
    assert(args.text ~= nil, "Chat:Print failed: no text was included")
    self:AddMessage(self:FormatMessage(args))
end

-- KeyUp needed when no NUI has focus
function Chat:KeyUp(args)
    if args.key == Control.MpTextChatAll then
        self.ui:CallEvent('chat/start_typing')
    end
end

function Chat:InputStateChanged(args)
    self.open = args.state
    UI:SetCursor(self.open)
    if self.open then
        self.ui:BringToFront()
        UI:SetFocus(true)
    else
        UI:SetFocus(false)
    end
    Events:Fire('ChatInputStateChanged', args)
end

function Chat:SubmitMessage(args)
    local returns = Events:Fire('LocalPlayerChat', {text = args.msg, channel = args.channel})
    if sequence_contains(returns, false) then return end -- Return false to LocalPlayerChat to stop msg from sending

    args.msg = args.msg:sub(1, self.max_characters)
    Network:Send('chat/player_send_msg', {message = args.msg, channel = args.channel})
end

function Chat:UIReady()
    self.ui:Show()
    self.ui:BringToFront()
    Network:Send('chat/ui_ready')
    Events:Fire('ChatReady')
end

function Chat:AddMessage(args)
    self.ui:CallEvent('chat/add_message', args)
    self.ui:BringToFront()
end

function Chat:InitializeConfig(config)
    self.config = config
    self.max_characters = config.max_characters;
    self.ui:CallEvent('chat/init_config', config)
end


function Chat:LocalPlayerChat(args)
    if args.text == '/clear' then
        self.ui:CallEvent('chat/clear_chat')
        return false
    end
end

function Chat:StoreName(args)
    self.my_name = args.name
    self.ui:CallEvent('chat/store_name', args)
end

function Chat:AddPlayer(args)
    if args.id ~= LocalPlayer:GetPlayer():GetId() then
        self.ui:CallEvent('chat/add_player', args)
    end
end

function Chat:RemovePlayer(args)
    self.ui:CallEvent('chat/remove_player', args)
end

-- ########### TODO: fix players not being added/removed right because @ing doesn't always work right

function Chat:InitializePlayers(data)
    for _, player_data in pairs(data) do
        if player_data.id ~= LocalPlayer:GetPlayer():GetId() then
            self.ui:CallEvent('chat/add_player', player_data)
        end
    end
end

Chat = Chat()