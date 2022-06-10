Chat = class(ChatUtility)

function Chat:__init()

    Network:Subscribe('chat/player_send_msg', function(args) self:PlayerSendMessage(args) end)
    Events:Subscribe('PlayerQuit', function(args) self:PlayerQuit(args) end)
    Network:Subscribe('chat/ui_ready', function(args) self:ChatReady(args) end)
end

function Chat:ChatReady(args)
    Network:Send('chat/init_config', args.player, ChatConfig)

    local name = args.player:GetName()

    Network:Send('chat/store_name', args.player:GetId(), {name = name})
    Network:Send('chat/init_players', args.player:GetId(), self:GetAllPlayersSyncData(args.player:GetId()))
    Network:Broadcast('chat/add_player', self:GetPlayerSyncData(args.player))

end

function Chat:GetAllPlayersSyncData(id)
    local data = {}
    for _, player in pairs(sPlayers:GetPlayers()) do
        if id ~= player:GetId() then
            table.insert(data, self:GetPlayerSyncData(player))
        end
    end
    return data
end

function Chat:GetPlayerSyncData(player)
    return {id = player:GetId(), name = player:GetName()}
end

function Chat:PlayerQuit(args)
    Network:Broadcast('chat/remove_player', {name = args.player:GetName()})
end

--[[
    Called when a player submits a message after pressing enter.

    args (in table):
    
        player
        message (string) - the message that the player sent
        channel
]]
function Chat:PlayerSendMessage(args)
    args.text = trim(args.message)

    if args.channel == nil or not sequence_contains(ChatConfig.default_channels, args.channel) then
        print(args.player:GetName() .. ' sent a message on an invalid channel: ' .. args.channel)
        return
    end

    if args.message[1] == '/' then
        Events:Fire('ChatCommand', {
            player = args.player,
            text = args.text,
            channel = args.channel
        })
        return
    end

    local returns = Events:Fire('ChatMessage', {
        player = args.player,
        text = args.text,
        channel = args.channel
    });

    -- Chat message blocked by another module
    if sequence_contains(returns, false) then return end

    for k,v in pairs(returns) do
        if type(v) == 'string' then
            args.text = v
        end
    end

    -- If there is a message, now send it
    if string.len(args.message) > 0 then
        print('[chat] ' .. args.player:GetName() .. ': ' .. args.text)

        if channel == "Local" then
            local pos = player:GetPosition()

            for id, p in pairs(sPlayers:GetPlayers()) do
                if #(pos - p:GetPosition()) < ChatConfig.local_distance then
                    Network:Send('chat/message', p:GetId(), self:FormatMessage(args));
                end
            end
        else
            Network:Broadcast('chat/message', self:FormatMessage(args));
        end

    end
end

--[[/**
* Sends a message to a player.
* 
* @param {Player} player - Player to send the message to.
* @param {string} message - Message to send to the player.
* @param {RGB} color - Color of the message in RGB format. Optional.
* @param {object} args - Additional arguments, such as timeout or channel.
*/
send(target, message, color, args) 
{
   const msg = JSON.stringify(FormatMessage(message, null, color, args));
   jcmp.events.CallRemote('chat_message', target, msg);
},]]
-- Send a message to a specific player
function Chat:Send(args)
    assert(type(args) == 'table', 'Chat:Send failed: args was not a table or string')
    assert(args.text ~= nil, "Chat:Send failed: no message was included")
    assert(args.player ~= nil, "Chat:Send failed: no target player specified")

    local player = args.player
    args.player = nil
    Network:Send('chat/message', player, self:FormatMessage(args))
end

--[[/**
* Broadcasts a message to all players.
* 
* @param {string} message - Message to be sent.
* @param {RGB} color - Color of the message in RGB format. Optional.
* @param {object} args - Additional arguments, such as timeout, channel, style, or use_name.
*/
broadcast(message, color, args)
{
   const msg = JSON.stringify(FormatMessage(message, null, color, args));
   jcmp.events.CallRemote('chat_message', null, msg);
},]]
-- Broadcast a message to all players
function Chat:Broadcast(args)
    assert(type(args) == 'table', 'Chat:Broadcast failed: args was not a table or string')
    assert(args.text ~= nil, "Chat:Broadcast failed: no text was included")

    Network:Broadcast('chat/message', self:FormatMessage(args))
end


Chat = Chat()