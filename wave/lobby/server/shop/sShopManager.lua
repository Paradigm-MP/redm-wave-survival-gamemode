LobbyShopManager = class()

local item_ids = 0
local function GenerateItemId()
    item_ids = item_ids + 1
    return item_ids
end

function LobbyShopManager:__init()

    self.shop_items = {}
    self.DEFAULT_ITEMS = "Player_Zero|0,"

    self:LoadShopItems()

    Network:Subscribe("shop/buy_item", function(args) self:BuyItem(args) end)
    Network:Subscribe("shop/equip_item", function(args) self:EquipItem(args) end)

    Events:Subscribe("gamedatabase/ready", function() self:GameDatabseReady() end)
end

function LobbyShopManager:HandlePlayerModel(player, model)
    for _, item_data in pairs(self.shop_items) do
        local item_name = self:GetItemName(item_data)
        if item_name == model then
            return model
        end
    end

    -- Invalid model, reset to default
    return self.DEFAULT_ITEMS
end

function LobbyShopManager:GetItemName(item_data)
    return item_data.model .. "|" .. tostring(item_data.outfit)
end

function LobbyShopManager:EquipItem(args)
    
    if not args.id then return end -- Invalid data sent
    args.id = tonumber(args.id)

    local item_to_equip = self.shop_items[args.id]
    if not item_to_equip then return end -- Item not found
    local item_name = self:GetItemName(item_to_equip)

    if not self:PlayerOwnsItem(args.player, item_to_equip) then return end -- Don't own it

    if args.player:GetValue("Model") == item_name then return end -- Already equipped

    args.player:SetNetworkValue("Model", item_name)
    PlayerStatsManager:SavePlayerToDB(args.player) -- Save equipped model to DB

end

function LobbyShopManager:BuyItem(args)
    -- Called when a player tries to buy an item from the shop
    -- args: id of item and player
    if not args.id then return end -- Invalid data sent
    args.id = tonumber(args.id)

    local item_to_buy = self.shop_items[args.id]
    if not item_to_buy then return end -- Item not found
    local item_name = self:GetItemName(item_to_buy)

    local money = args.player:GetValue("Money")
    if money < item_to_buy.cost then return end -- Not enough money

    local bought_items = args.player:GetValue("BoughtShopItems")
    if self:PlayerOwnsItem(args.player, item_to_buy) then return end -- Don't own it

    -- All good, now purchase the item!
    table.insert(bought_items, {
        model = item_to_buy.model,
        outfit = item_to_buy.outfit
    })
    args.player:SetNetworkValue("BoughtShopItems", bought_items)
    args.player:SetNetworkValue("Money", money - item_to_buy.cost)

    self:SavePlayerToDB(args.player)
end

-- Called by GameManager when a player earns money in a game
function LobbyShopManager:PlayerAddIngameMoney(player, amount)
    local new_amount = amount
    local old_money = player:GetValue("Money")

    player:SetNetworkValue("Money", old_money + new_amount)
    self:SavePlayerToDB(player)
end

function LobbyShopManager:LoadShopItems()
    local data = JSONUtils:LoadJSON("lobby/server/shop/shop_items.json")
    for _, item_data in pairs(data.items.skins) do
        if item_data.enabled == true then
            local id = GenerateItemId()
            item_data.cost = item_data.cost * 100 -- Convert to cents
            item_data["id"] = id -- Assign each item a unique id 
            self.shop_items[id] = item_data
        end
    end
end

function LobbyShopManager:PlayerReady(player)
    local query = "SELECT * FROM shop WHERE unique_id=@uniqueid"
    local params = {["@uniqueid"] = player:GetUniqueId()}
    SQL:Fetch(query, params, function(result)
        if result and result[1] then
            self:InitPlayerShopValues(player, result[1])
        else
            self:InitPlayerShopValues(player, {
                money = 0,
                bought_items = self.DEFAULT_ITEMS
            })
            self:SavePlayerToDB(player)
        end
    end)

    Network:Send("shop/initial_sync", player, {data = self.shop_items})
end


function LobbyShopManager:SavePlayerToDB(player)
    
    local cmd = "INSERT INTO shop (unique_id, money, bought_items)"..
        "VALUES(@uniqueid, @money, @bought_items) "..
        "ON DUPLICATE KEY UPDATE money=@money, bought_items=@bought_items"
    local params = 
    {
        ["@uniqueid"] = player:GetUniqueId(),
        ["@money"] = player:GetValue("Money"),
        ["@bought_items"] = self:SerializeBoughtItems(player:GetValue("BoughtShopItems"))
    }

    SQL:Execute(cmd, params, function(rows)
        -- saved!
    end)
end

function LobbyShopManager:ParseBoughtItems(items)
    local final_table = {}
    local items_table = split(items, ",")
    for _, item_str in pairs(items_table) do
        local item_split = split(item_str, "|")
        table.insert(final_table, {
            model = item_split[1],
            outfit = item_split[2]
        })
    end
    return final_table
end

function LobbyShopManager:SerializeBoughtItems(items)
    local str = ""
    for _, item in pairs(items) do
        if item.model and item.outfit then
            str = str .. item.model .. "|" .. item.outfit .. ","
        end
    end
    return str
end

function LobbyShopManager:PlayerOwnsItem(player, item)
    for _, item_data in pairs(player:GetValue("BoughtShopItems")) do
        if tostring(item_data.model) == tostring(item.model) and tonumber(item_data.outfit) == tonumber(item.outfit) then
            return true
        end 
    end
    return false
end

function LobbyShopManager:InitPlayerShopValues(player, data)
    player:SetNetworkValue("Money", data.money)

    -- If they have info from the old shop, clear it
    if string.find(data.bought_items, "Default,") or string.len(data.bought_items) == 0 then
        data.bought_items = self.DEFAULT_ITEMS
    end

    player:SetNetworkValue("BoughtShopItems", self:ParseBoughtItems(data.bought_items))
end

function LobbyShopManager:GameDatabseReady()
    -- load things, or not :)
end

LobbyShopManager = LobbyShopManager()