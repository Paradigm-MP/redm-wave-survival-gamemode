AgentProfileEnum = immediate_class(Enum)

function AgentProfileEnum:__init()
    self:EnumInit()

    -- when adding an entry here, make sure to update self.agent_profiles in cActorManager
    self.BasicEnemy = 1
    self:SetDescription(self.BasicEnemy, "Basic Enemy")

    self.Dutch = 2
    self:SetDescription(self.Dutch, "Dutch")

    self.BasicRobot = 3
    self:SetDescription(self.BasicRobot, "Basic Robot")

    self.RobotBoss = 4
    self:SetDescription(self.BasicRobot, "Robot Boss")

    self.SwampFreak = 5
    self:SetDescription(self.SwampFreak, "Swamp Freak")

    self.SwampFreakBoss = 6
    self:SetDescription(self.SwampFreakBoss, "Swamp Freak Boss")

    self.Vampire = 7
    self:SetDescription(self.Vampire, "Vampire")

    self.Wolf = 8
    self:SetDescription(self.Wolf, "Wolf")

    self.Undead = 9
    self:SetDescription(self.Undead, "Undead")
end

function AgentProfileEnum:GetClassFromEnum(agent_profile_enum)
    local mapping = {
        [self.BasicEnemy] = BasicEnemy,
        [self.Dutch] = Dutch,
        [self.BasicRobot] = BasicRobot,
        [self.RobotBoss] = RobotBoss,
        [self.SwampFreak] = SwampFreak,
        [self.Vampire] = Vampire,
        [self.Wolf] = Wolf,
        [self.Undead] = Undead
        --[self.SwampFreakBoss] = SwampFreakBoss
    }

    if mapping[agent_profile_enum] then
        return mapping[agent_profile_enum]
    else
        print("Error: attempted to get class for agent profile enum that is not mapped in AgentProfileEnum")
        return nil
    end
end

AgentProfileEnum = AgentProfileEnum()