ui_page 'ui/index.html'

client_scripts {
    -- api module, nothing should precede this module
    'api/shared/overloads.lua',
    'api/shared/utilities/*.lua',
    'api/shared/object-oriented/class.lua', -- no class instances on initial frame before this file
    'api/shared/object-oriented/shGetterSetter.lua', -- getter_setter, getter_setter_encrypted
    'api/shared/standalone-data-structures/*', -- Enum, IdPool
    'api/shared/math/*.lua',
    '**/shared/enums/*Enum.lua', -- load all Enums
    '**/client/enums/*Enum.lua',
    'api/shared/Events.lua',
    'api/client/cNetwork.lua',
    'api/shared/ValueStorage.lua',
    'api/client/TypeCheck.lua',
    'api/client/AssetRequester.lua',
    'api/shared/Timer.lua',
    'api/client/cEntity.lua',
    'api/client/cPlayer.lua',
    'api/client/cPlayers.lua',
    'api/client/cPlayerManager.lua',
    'api/client/Ped.lua',
    'api/client/Physics.lua',
    'api/client/LocalPlayer.lua',
    'api/shared/Color.lua',
    'api/client/Render.lua',
    'api/client/Camera.lua',
    'api/client/ObjectManager.lua',
    'api/client/Object.lua',
    'api/client/ScreenEffects.lua',
    'api/client/World.lua',
    'api/client/Sound.lua',
    'api/client/Light.lua',
    'api/client/ParticleEffect.lua',
    'api/client/Filter.lua',
    'api/client/Explosion.lua',
    'api/client/PauseMenu.lua',
    'api/client/Hud.lua',
    'api/client/Keypress.lua',
    'api/client/Prompt.lua',
    'api/client/Imap.lua',
    'api/client/Marker.lua',
    'api/client/Texture.lua',
    'api/client/apitest.lua',
    'api/client/localplayer_behaviors/*.lua',
    'gameplay/client/localplayer_behaviors/*.lua',
    'api/client/weapons/*.lua',
    -- ui
    'ui/ui.lua',
    -- events module
    'events/client/cDefaultEvents.lua',
    'events/shared/shTick.lua',
    -- sounds
    'stream/sounds/loader.lua',
    -- NPC stuff
    'ai/shared/shEnemyWeapons.lua',
    'api/client/ai/agent-configs/*.lua', -- load all the agent ped configurations
    'api/client/ai/agent-behaviors/*.lua', -- load all the agent behaviors
    'api/client/ai/cActor.lua', -- old: 'ai/client/cActor.lua',
    'ai/client/cZsActor.lua',
    'ai/client/cZombie.lua',
    'ai/client/agent-profiles/*.lua',
    'api/client/ai/cActorManager.lua',
    'ai/client/test.lua',
    -- discord rich presence
    'discordrichpresence/client/client.lua',
    -- logo
    'logo/client/discord.lua',
    -- lobby
    'lobby/client/cLobbyManager.lua',
    -- game
    'gameplay/shared/shConfig.lua',
    'gameplay/client/cSpawnStrategy.lua',
    'gameplay/client/spawning_strategies/*.lua',
    'gameplay/client/cSpawnManager.lua',
    'gameplay/client/cGameManager.lua',
    'gameplay/client/ui/cGamePlayUI.lua',
    'gameplay/client/ui/cIconManager.lua',
    'gameplay/client/ui/cScreenIcon.lua',
    'gameplay/client/pickups/*.lua',
    'gameplay/client/powerups/*.lua',
    'api/client/spectate/*.lua', -- spectate mode
    -- pausemenu edits
    'gameplay/client/cPauseMenu.lua',
    -- blackscreen
    'blackscreen/client/BlackScreen.lua',
    -- chat
    'chat/shared/shChatUtility.lua',
    'chat/client/cChat.lua',
    -- tips
    'tips/client/Tips.lua',
    -- object editor
    'object-editor/client/cObjectEditor.lua',
    -- anticheat
    'anticheat/client/*.lua',
    -- LOAD LAST
    'api/shared/object-oriented/LOAD_ABSOLUTELY_LAST.lua'
}

server_scripts {
    -- api module, nothing should precede this module
    'api/server/sConfig.lua',
    'api/shared/overloads.lua', -- load order position does not matter because this is non-class code
    'api/shared/utilities/*.lua',
    'api/shared/object-oriented/class.lua', -- no class instances on initial frame before this file
    'api/shared/object-oriented/shGetterSetter.lua',
    'api/shared/math/*.lua',
    'api/shared/standalone-data-structures/*', -- Enum, IdPool
    '**/shared/enums/*Enum.lua', -- load all the enums from all the modules
    '**/server/enums/*Enum.lua',
    'api/shared/Color.lua',
    'api/shared/Events.lua',
    'api/server/sNetwork.lua',
    -- mysql enabler
    '@mysql-async/lib/MySQL.lua',
    -- mysql wrapper
    'mysql/server/MySQL.lua',
    'api/shared/ValueStorage.lua',
    'api/shared/Timer.lua',
    'api/server/sPlayer.lua',
    'api/server/sPlayers.lua',
    'api/server/sPlayerManager.lua',
    'api/server/sWorld.lua',
    'api/server/JSONUtils.lua',
    -- events module
    'events/server/sDefaultEvents.lua',
    'events/shared/shTick.lua',
    -- NPC stuff
    'api/shared/ai/shActorCollection.lua', --'ai/server/sActorCollection.lua',
    'ai/shared/shEnemyWeapons.lua',
    'api/server/ai/sActor.lua',
    'ai/server/sZsActor.lua',
    'ai/server/sZombie.lua', -- replace with '*Agent.lua' wildcard or something to load all profiles at once
    'ai/server/agent-profiles/*.lua',
    'api/server/ai/sActorManager.lua',
    'ai/server/sTest.lua',
    -- lobby
    'lobby/server/*.lua',
    'lobby/server/shop/*.lua',
    -- gameplay
    'gameplay/server/config.lua',
    'gameplay/shared/shConfig.lua',
    'gameplay/server/sWaveDelegator.lua',
    'gameplay/server/wave-delegators/*.lua',
    'gameplay/server/*.lua',
    'gameplay/server/powerups/*.lua',
    -- chat
    'chat/server/config.lua',
    'chat/shared/shChatUtility.lua',
    'chat/server/sChat.lua',
    -- object-editor
    'object-editor/server/sObjectEditor.lua',
    -- anticheat
    'anticheat/server/*.lua',
    -- slur
    'cowboy-slur/server/CowboySlur.lua',
    'api/shared/object-oriented/LOAD_ABSOLUTELY_LAST.lua'
}

files {
    -- streaming
	'streaming/sounds/data/dlczombies_sounds.dat54.rel',
	'streaming/sounds/data/dlczombies2_sounds.dat54.rel',
	'streaming/sounds/data/dlczombies3_sounds.dat54.rel',
    'streaming/sounds/dlc_zombies/zombies.awc', -- gameplay, zombie1-15
    'streaming/sounds/dlc_zombies2/zombies2.awc', -- zombie16-31
    'streaming/sounds/dlc_zombies3/zombies3.awc', -- zombie32-38, death1-12, hit1-15
    'stream/*.ytyp',
    'stream/*.ydr',
    -- general ui
    'ui/reset.css',
    'ui/jquery.js',
    'ui/events.js',
    'ui/index.html',
    'ui/fonts/Kirsty.ttf',
    'ui/fonts/KirstyB.ttf',
    'ui/fonts/MainTitles.ttf',
    -- loadscreen module
    'loadscreen/client/html/index.html',
    'loadscreen/client/html/bg.jpg',
    'loadscreen/client/html/style.css',
    'loadscreen/client/html/script.js',
    -- logo ui
    'logo/client/html/index.html',
    'logo/client/html/logo.png',
    -- lobby
    'lobby/client/html/index.html',
    'lobby/client/html/script.js',
    'lobby/client/html/style.css',
    'lobby/client/html/selectmenu.css',
    'lobby/client/html/images/question.png',
    'lobby/client/html/images/*.jpg',
    'lobby/client/html/images/shop/*.JPG',
    'lobby/client/html/sounds/lobbymusic.ogg',
    -- gameplay
    'gameplay/client/ui/html/index.html',
    'gameplay/client/ui/html/script.js',
    'gameplay/client/ui/html/style.css',
    'gameplay/client/ui/html/round_finish.html',
    'gameplay/client/ui/html/round_finish_script.js',
    'gameplay/client/ui/html/round_finish_style.css',
    'gameplay/client/ui/html/*.ogg',
    'gameplay/client/ui/html/imgs/*.png',
    -- blackscreen
    'blackscreen/client/html/index.html',
    'blackscreen/client/html/style.css',
    'blackscreen/client/html/script.js',
    -- tips
    'tips/client/html/index.html',
    'tips/client/html/script.js',
    'tips/client/html/style.css',
    -- chat
    'chat/client/ui/index.html',
    'chat/client/ui/script.js',
    'chat/client/ui/style.css'
}

fx_version 'adamant'
games { 'rdr3', 'gta5' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'