-- Global config for gameplay elements
--[[GameplayConfig =
{
    Weapons = 
    {
        Melee = 
        {
            Weapon.Knife,
            Weapon.KnuckleDuster,
            Weapon.Unarmed,
            Weapon.Nightstick,
            Weapon.Bat,
            Weapon.Golfclub,
            Weapon.Crowbar,
            Weapon.Bottle,
            Weapon.Dagger,
            Weapon.Hatchet,
            Weapon.Machete,
            Weapon.Flashlight,
            Weapon.Switchblade,
            Weapon.Poolcue,
            Weapon.Pipewrench,
            Weapon.Battleaxe
        },
        Thrown = 
        {
            Weapon.Proxmine,
            Weapon.Bzgas,
            Weapon.Smokegrenade,
            Weapon.Molotov,
            Weapon.Fireextenguisher,
            Weapon.Petrolcan,
            Weapon.Snowball,
            Weapon.Flare,
            Weapon.Ball
        },
        Pistol = 
        {
            Weapon.Revolver,
            Weapon.Pistol,
            Weapon.Pistol_MK2,
            Weapon.CombatPistol,
            Weapon.APPistol,
            Weapon.Pistol50,
            Weapon.SNSPistol,
            Weapon.HeavyPistol,
            Weapon.VintagePistol,
            Weapon.MarksmanPistol
        },
        MG = 
        {
            Weapon.MicroSMG,
            Weapon.MiniSMG,
            Weapon.SMG,
            Weapon.SMG_MK2,
            Weapon.AssaultSMG,
            Weapon.CombatPDW,
            Weapon.MG,
            Weapon.CombatMG,
            Weapon.CombatMG_MK2,
            Weapon.Gusenberg
        },
        AR = 
        {
            Weapon.AssaultRifle,
            Weapon.AssaultRifle_MK2,
            Weapon.CarbineRifle,
            Weapon.CarbineRifle_MK2,
            Weapon.AdvancedRifle,
            Weapon.SpecialCarbine,
            Weapon.BullpupRifle,
            Weapon.CompactRifle
        },
        Sniper = 
        {
            Weapon.SniperRifle,
            Weapon.HeavySniper,
            Weapon.HeavySniper_MK2,
            Weapon.MarksmanRifle
        },
        Shotgun = 
        {
            Weapon.PumpShotgun,
            Weapon.SawnoffShotgun,
            Weapon.BullpupShotgun,
            Weapon.AssaultShotgun,
            Weapon.Musket,
            Weapon.HeavyShotgun,
            Weapon.DoubleBarrelShotgun,
            Weapon.Autoshotgun
        },
        Heavy = 
        {
            Weapon.GrenadeLauncher,
            Weapon.RPG,
            Weapon.Minigun,
            Weapon.Firework,
            Weapon.Railgun,
            Weapon.HomingLauncher,
            Weapon.GrenadeLauncherSmoke,
            Weapon.CompactLauncher
        }
    }
}]]

-- All tables that we're using
GameDBConfig = 
{
    tables = 
    {
        "player_data (unique_id VARCHAR(50) PRIMARY KEY, name VARCHAR(30), model VARCHAR(30), time_online INTEGER, kills INTEGER, " ..
        "deaths INTEGER, last_login_ip VARCHAR(20), level INTEGER, exp INTEGER, games_played INTEGER, last_online VARCHAR(20))",
        "bans (unique_id VARCHAR(50) PRIMARY KEY, ban_date VARCHAR(10), reason BLOB)",
        "map_scores (id INTEGER PRIMARY KEY AUTO_INCREMENT, map_name VARCHAR(30), player_data BLOB, wave INTEGER)",
        "shop (unique_id VARCHAR(50) PRIMARY KEY, money INTEGER, bought_items BLOB)"
    }
}