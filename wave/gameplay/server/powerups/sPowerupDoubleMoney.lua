PowerupDoubleMoney = class()

function PowerupDoubleMoney:__init()
    self.active = false
end

function PowerupDoubleMoney:IsActive()
    return self.active
end

function PowerupDoubleMoney:Activate(args)
    -- Serverside function for getting downed players up
    self.active = true
end

function PowerupDoubleMoney:Deactivate()
    self.active = false
end