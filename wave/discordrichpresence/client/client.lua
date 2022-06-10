Citizen.CreateThread(function()
	while true do
        --This is the Application ID (Replace this with you own)
		SetDiscordAppId(605350486677389325)

        --Here you will have to put the image name for the "large" icon.
		SetDiscordRichPresenceAsset('hat')
        
        SetRichPresence('Surviving waves of enemies in the wild west!')

        --(11-11-2018) New Natives:

        --Here you can add hover text for the "large" icon.
        SetDiscordRichPresenceAssetText('RedM Wave Survival')
       
        --Here you will have to put the image name for the "small" icon.
        SetDiscordRichPresenceAssetSmall('paradigm_logo')

        --Here you can add hover text for the "small" icon.
        SetDiscordRichPresenceAssetSmallText('Join us at discord.paradigm.mp')

        --It updates every one minute just in case.
		Citizen.Wait(60000)
	end
end)