GamePlayUI = class()

function GamePlayUI:__init()
    self.ui = UI:Create({name = "gameplayui", path = "gameplay/client/ui/html/index.html", visible = false})
    self.round_finish_ui = UI:Create({name = "gameplayui_roundfinish", path = "gameplay/client/ui/html/round_finish.html", visible = false})

    HUD:HideComponent(HudComponent.actionWheelItems)

    HUD:SetDisplayRadar(false)
    --SetMinimapHideFow(true)

    Events:Subscribe("LocalPlayerHealthChanged", function(args) self:LocalPlayerHealthChanged(args) end)
end

function GamePlayUI:GetUI()
    return self.ui
end

function GamePlayUI:GameEnd()
    Citizen.CreateThread(function()
        Citizen.Wait(3000)
        BlackScreen:Show(2000)
        IconManager:Clear()
        self:HideSurviveUntil()
        self:HideBoss()

        Citizen.Wait(2000)
        self.ui:Hide()
        self:ShowRoundFinish(GameManager:GetCurrentRound())
        IconManager:Clear()

        Citizen.Wait(5000)
        self:HideRoundFinish()

        Citizen.Wait(1000)
        LobbyManager:Reset()
        BlackScreen:Hide(1000)

        Citizen.Wait(1000)
        LobbyManager:GetUI():BringToFront()
    end)

end

function GamePlayUI:ShowRoundFinish(round)
    Citizen.CreateThread(function()
        self.round_finish_ui:Show()
        self.round_finish_ui:BringToFront()
        Citizen.Wait(100)
        self.round_finish_ui:CallEvent('gameplayui/gamefinish/show', {round = round})
    end)
end

function GamePlayUI:HideRoundFinish(round)
    self.round_finish_ui:CallEvent('gameplayui/gamefinish/hide')
    Citizen.SetTimeout(1000, function()
        self.round_finish_ui:Hide()
    end)
end

-- Called when the player joins a game
function GamePlayUI:GameStart()
    self:UpdatePoints()
    self.ui:Show()
    self.ui:SendToBack()

    self.ui:CallEvent('gameplayui/game/difficulty', {difficulty = GameManager.map.difficulty})
end

function GamePlayUI:StartSpectating(args)
    self.ui:CallEvent('gameplayui/spectate/show', {
        name = (args.player.__type == "Player") and (args.player:GetName()) or ("Actor" .. tostring(args.player:GetUniqueId()))
    })
end

function GamePlayUI:UpdatePlayerHealth(health)
    self.ui:CallEvent('gameplayui/screenicon/updateplayerhealth', {health = health})
end

function GamePlayUI:StopSpectating()
    self.ui:CallEvent('gameplayui/spectate/hide')
end

function GamePlayUI:ShowBoss(name)
    self.ui:CallEvent('gameplayui/boss/show', {text = name})
end

function GamePlayUI:UpdateBossHealth(percent) -- Must be a number between 0 and 100
    self.ui:CallEvent('gameplayui/boss/update', {percent = percent})
end

function GamePlayUI:HideBoss()
    self.ui:CallEvent('gameplayui/boss/hide')
end

function GamePlayUI:ShowSurviveUntil(time)
    self.ui:CallEvent('gameplayui/survive-until/hide')
    self.ui:CallEvent('gameplayui/survive-until/show', {time = time})
end

function GamePlayUI:HideSurviveUntil()
    self.ui:CallEvent('gameplayui/survive-until/hide')
end

function GamePlayUI:ShowOutOfBoundsIndicator(text)
    self.ui:CallEvent('gameplayui/outofbounds/show', {text = text})
end

function GamePlayUI:HideOutOfBoundsIndicator()
    self.ui:CallEvent('gameplayui/outofbounds/hide')
end

function GamePlayUI:ActivatePowerup(name)
    self.ui:CallEvent('gameplayui/powerup/activate', {name = name})
end

function GamePlayUI:AddPowerup(args)
    self.ui:CallEvent('gameplayui/powerup/add', args)
end

function GamePlayUI:ModifyPowerup(args)
    self.ui:CallEvent('gameplayui/powerup/modify', args)
end

function GamePlayUI:UpdatePoints()
    self.ui:CallEvent('gameplayui/update_points', {points = GameManager:GetPoints()})
end

function GamePlayUI:UpdateRound()
    self.ui:CallEvent('gameplayui/update_round', {round = GameManager:GetCurrentRound()})
    if GameManager:GetWaveType() == WaveTypeEnum.SurviveUntil then
        GamePlayUI:ShowSurviveUntil(GameManager:GetSurviveUntilTime())
    else
        GamePlayUI:HideSurviveUntil()
    end
end

function GamePlayUI:LocalPlayerHealthChanged(args)
    local current_ui_health = args.new_health - 100
    if current_ui_health < 0 then current_ui_health = 0 end

    local max_ui_health = LocalPlayer.base_health - 100

    GamePlayUI:UpdatePlayerHealth((current_ui_health / max_ui_health) * 100)
end

GamePlayUI = GamePlayUI()