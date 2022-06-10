WeaponPickupManager = class()

function WeaponPickupManager:__init()
    self.pickups = {}
    self.spawnableWeapons = {}

    self.CHANCE_TO_SPAWN_WEAPON = 1.0

    self:GenerateSpawnableWeaponsList()

    Network:Subscribe("game/pickup/buy_weapon", function(args) self:PlayerBuyWeapon(args) end)
end

function WeaponPickupManager:GetWeaponPickups()
    return self.pickups
end

function WeaponPickupManager:GenerateSpawnableWeaponsList()
    self.spawnableWeapons = {}

    for weapon_type, weapon in pairs(shGameplayConfig.WeaponData) do
        if weapon.can_spawn then
            table.insert(self.spawnableWeapons, weapon_type)
        end
    end
end

function WeaponPickupManager:RandomizeWeaponPickups()
    self:GenerateSpawnableWeaponsList()

    local spawn_points = deepcopy(GameManager:GetGameInfo().map_data.weaponSpawnPoints)
    math.randomseed(os.time())

    for _, type in pairs(self.spawnableWeapons) do
        if math.random() < self.CHANCE_TO_SPAWN_WEAPON and #spawn_points > 0 then
            self.pickups[type] = {
                pos = table.remove(spawn_points, math.random(1, #spawn_points)).pos,
                type = type,
                cost = shGameplayConfig.WeaponData[type].cost
            }
        end
    end
end

function WeaponPickupManager:PlayerBuyWeapon(args)
    if not GameManager:GetIsGameInProgress() then return end
    if not args.weapon then return end

    local weapon = self:GetWeapon(args.weapon)
    if not weapon then return end
    if not weapon.can_spawn then return end

    if args.player:GetValue("GameMoney") < weapon.cost then return end

    args.player:SetNetworkValue("GameMoney", args.player:GetValue("GameMoney") - weapon.cost)
    Network:Send("game/sync/get_weapon", args.player:GetId(), {
        weapon = args.weapon,
        ammo = weapon.ammo
    })
end

function WeaponPickupManager:GetWeapon(weaponEnum)
    return shGameplayConfig.WeaponData[weaponEnum]
end


WeaponPickupManager = WeaponPickupManager()