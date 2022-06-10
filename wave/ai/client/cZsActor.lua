WaveSurvivalActor = class(Actor)
--[[
    Represents the lowest-level, most re-usable NPC code that can be re-used across
    the zombie-wave gamemode
]]

function WaveSurvivalActor:WaveSurvivalActorInitialize()
    -- ZsActor init logic goes here
end

function WaveSurvivalActor:InitializeWaveSurvivalActorGeneric()
    self:InitializeActorFromWaveSurvivalActor()
    self:WaveSurvivalActorInitialize()
end

function WaveSurvivalActor:InitializeWaveSurvivalActorFromZombie()
    self:InitializeActorFromWaveSurvivalActor()
    self:WaveSurvivalActorInitialize()
end


function WaveSurvivalActor:InitializeWaveSurvivalActorFromBasicEnemy()
    self:InitializeActorFromWaveSurvivalActor()
    self:WaveSurvivalActorInitialize()
end

function WaveSurvivalActor:InitializeWaveSurvivalActorFromBasicFriendly()
    self:InitializeActorFromWaveSurvivalActor()
    self:WaveSurvivalActorInitialize()
end

function WaveSurvivalActor:InitializeWaveSurvivalActorFromBasicRobot()
    self:InitializeActorFromWaveSurvivalActor()
    self:WaveSurvivalActorInitialize()
end


function WaveSurvivalActor:InitializeWaveSurvivalActorFromRobotBoss()
    self:InitializeActorFromWaveSurvivalActor()
    self:WaveSurvivalActorInitialize()
end