SpawnStrategy = class()

function SpawnStrategy:InitializeSpawnStrategy()
    self.delegations = Deque()
end

function SpawnStrategy:AcceptDelegation(delegation_data)
    self.delegations:PushRight(delegation_data)
end

function SpawnStrategy:PopNextDelegation()
    return self.delegations:PopLeft()
end

function SpawnStrategy:HasDelegations()
    return self.delegations:GetCount() > 0
end

function SpawnStrategy:ClearDelegations()
    self.delegations:ClearValues()
end