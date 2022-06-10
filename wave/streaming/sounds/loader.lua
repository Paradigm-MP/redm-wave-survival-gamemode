-- Loads all the custom sounds

RequestScriptAudioBank('dlc_zombies/zombies', 0)
RequestScriptAudioBank('dlc_zombies2/zombies2', 0)
RequestScriptAudioBank('dlc_zombies3/zombies3', 0)


--[[
Zombies sounds:

zombies:

    audioName: zombies_zombie .. i (i is 1-15)
    audioRef: dlc_zombies_sounds .. i (i is 1-15)

    audioName: zombies_zombie .. i (i is 16-31)
    audioRef: dlc_zombies2_sounds .. i (i is 16-31)

    audioName: zombies_zombie .. i (i is 32-38)
    audioRef: dlc_zombies3_sounds .. i (i is 32-38)

hits:
    audioName: zombies_hit .. i (i is 1-15)
    audioRef: dlc_zombies3_hit .. i (i is 1-15)

death:
    audioName: zombies_death .. i (i is 1-12)
    audioRef: dlc_zombies3_death .. i (i is 1-12)

mysterybox:
    audioName: zombies_mysterybox
    audioRef: dlc_zombies_mysterybox

teddybear:
    audioName: zombies_teddybear
    audioRef: dlc_zombies_sounds_teddybear

pack_a_punch:
    audioName: zombies_pack_a_punch
    audioRef: dlc_zombies_pack_a_punch

]]