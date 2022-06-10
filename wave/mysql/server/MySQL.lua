MySQLWrapper = immediate_class()


function MySQLWrapper:__init()

    MySQL.ready(function ()
        self:Ready()
    end)

    -- Ensure that the mysql-async resource is started
    self:EnsureMySqlAsyncResource()
end

function MySQLWrapper:EnsureMySqlAsyncResource()
    local state = GetResourceState('mysql-async')

    -- Start the resource now that we are ready for events
    if state == "stopped" then
        print("MySQL wrapper is ready, starting mysql-async resource now...")
        StartResource('mysql-async')
    elseif state ~= "started" then
        error("Something went wrong with mysql-async resource. Try restarting to fix the problem.")
    else
        self:Ready()
    end
end

function MySQLWrapper:Ready()
    self.ready = true
    Events:Fire("mysql/Ready") -- Let other modules know that MySQL is ready
    print(Colors.Console.Green .. "MySQL ready!" .. Colors.Console.Default)
end

-- SQL.Execute("UPDATE player SET name=@name WHERE id=@id", {['@id'] = 10, ['@name'] = 'foo'}, function(data) end)
function MySQLWrapper:Execute(query, params, callback)
    MySQL.Async.execute(query, params, function(rowsChanged)
        callback(rowsChanged)
    end)
end

-- SELECT ... where id=@id ... (see above)
function MySQLWrapper:Fetch(query, params, callback)
    MySQL.Async.fetchAll(query, params, function(data)
        callback(data)
    end)
end

SQL = MySQLWrapper()