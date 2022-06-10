GameDatabase = class()

--[[
    Class for dealing with persistent data in mysql
]]
function GameDatabase:__init()

    Events:Subscribe("mysql/Ready", function() self:InitDatabase() end)
end

function GameDatabase:InitDatabase()
    local await = true

    Citizen.CreateThread(function()

        for _, db in pairs(GameDBConfig.tables) do

            await = true
            SQL:Execute("CREATE TABLE IF NOT EXISTS " .. db, nil, function(changed)
                if changed > 0 then
                    print("Created table " .. db:sub(1, db:find(" ") - 1) .. " because it did not exist.")
                end
                await = false
            end)

            while await do
                Wait(10)
            end
        end

        -- Game database is ready to be used
        Events:Fire("gamedatabase/ready")
    end)
end

GameDatabase = GameDatabase()