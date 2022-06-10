-- executes class instances of the first frame
Citizen.CreateThread(function()

    print(string.format(
        "%s\n-------------------------\n\n" ..
        "%sInitializing NAPI...\n" ..
        "%s\n-------------------------\n%s", 
        Colors.Console.LightBlue,
        Colors.Console.LightBlue,
        Colors.Console.LightBlue,
        Colors.Console.Default
    ))

    if __collect_inits then
        -- do not collect inits beyond the initial frame & do not collect nested init's
        __collect_inits = false

        -- wait until we're ready to do networking (only runs on the Client)
        -- doesnt return true in redm? disabled for now
        --[[
        if IsClient then
            while not NetworkIsSessionStarted() do
                Wait(0)
            end
        end
        ]]

        if IsClient then
            Citizen.CreateThread(function()
                -- disables base-game peds spawning
                SetPedNonCreationArea(-9999.0, -9999.0, -9999.0, 9999.0, 9999.0, 9999.0)

                while true do
                    Wait(0)
                    --SetPedDensityMultiplierThisFrame(0) -- native does not exist
                    SetScenarioPedDensityMultiplierThisFrame(0.0)
                    --SetScenarioPedDensityMultiplierThisFrame(0)
                    SetVehicleDensityMultiplierThisFrame(0)
                    SetRandomVehicleDensityMultiplierThisFrame(0)
                    SetParkedVehicleDensityMultiplierThisFrame(0)
                end
            end)
        end

        if IsClient then
            Wait(6000)
        end

        -- immediate classes first
        for index, immediate_class_data in ipairs(__immediate_list) do
            local instance = immediate_class_data[1]
            local immediate_init = immediate_class_data[2]

            immediate_init()
            -- inits created inside of the immediate_class __init will immediately come into existance
        end
        
        -- execute and wait on the load_first classes
        for index, load_first_data in ipairs(__load_first) do
            local instance = load_first_data[1]
            local load_first_function = load_first_data[2]

            load_first_function()
            -- inits created inside of the load_first_function will immediately come into existance
        end

        -- wait for the load_first_function's to mark completion
        local all_loaded_first_complete = false

        while not all_load_first_complete do
            all_load_first_complete = true
            for index, load_first_data in ipairs(__load_first) do
                local instance = load_first_data[1]
                --local load_first_function = load_first_data[2]

                if not instance.__loadFirstCompleted then
                    all_load_first_complete = false
                    break
                end
            end

            Wait(50)
        end

        -- execute the inits in the order we received them
        for index, init_function_data in ipairs(__init_list) do
            local init_function = init_function_data[2]

            init_function()
            -- inits created inside of the init_function (nested inits) will immediately come into existance as instances
        end

        ---------
        -- Execute the postLoads
        ---------

        for index, immediate_class_data in ipairs(__immediate_list) do
            local instance = immediate_class_data[1]

            if instance.__postLoad then
                instance.__postLoad()
            end
            -- inits created inside of the immediate_class __postLoad will immediately come into existance
        end

        for index, init_function_data in ipairs(__init_list) do
            local instance = init_function_data[1]

            if instance.__postLoad then
                instance.__postLoad()
            end
        end

        if IsClient then
            Network:Send("api/ClientReady")
            Events:Fire("ClientReady")
        end

        __load_first = nil
        __init_list = nil
        __immediate_list = nil
    end
    
    print(string.format(
        "%s\n-------------------------\n\n" ..
        "%sNAPI initialized successfully!\n" ..
        "%s\n-------------------------\n%s", 
        Colors.Console.LightBlue,
        Colors.Console.Green,
        Colors.Console.LightBlue,
        Colors.Console.Default
    ))

end)