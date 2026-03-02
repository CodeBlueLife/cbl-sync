local _weatherState = "EXTRASUNNY"
local _timeHour = 12
local _timeMinute = 0
local _blackoutState = false
local isTransitionHappening = false
local _isStopped = true
local _isStoppedForceTime = 20

local _inCayo = false;
local _inCayoStorm = false;

RegisterNetEvent('cbl:setActiveCharacter', function()
    SYNC.Start();
end)

RegisterNetEvent('cbl:playerLogout', function()
    SYNC.Stop();
end)

SYNC = {
    Start = function(self)
        print("[TRACE] [Sync] Starting Time and Weather Sync")
        _isStopped = false
        
        _weatherState = GlobalState["Sync:Weather"]
        _blackoutState = GlobalState["Sync:Blackout"]
        local timeState = GlobalState["Sync:Time"]
        _timeHour = timeState.hour
        _timeMinute = timeState.minute
        
        SetRainLevel(-1.0)
        SetForceVehicleTrails(false)
        SetForcePedFootstepsTracks(false)
        ForceSnowPass(false)
    end,
    Stop = function(self, hour)
        print("[TRACE] [Sync] Stopping Time and Weather Sync")
        _isStopped = true
        
        if not hour then
            _timeHour = 20
        else
            _isStoppedForceTime = hour
        end
    end,
    IsSyncing = function(self)
        return not _isStopped
    end,
    GetTime = function(self)
        return {
            hour = _timeHour,
            minute = _timeMinute
        }
    end,
    GetWeather = function(self)
        return _weatherState;
    end
}

-- TODO: exports here later
CreateThread(function()
    StartSyncThreads()
end)

function StartSyncThreads()
    CreateThread(function()
        while GlobalState["Sync:Time"] == nil do
            Wait(1)
        end
        
        local hour = 0
        local minute = 0
        while true do
            if not _isStopped then
                local timeState = GlobalState["Sync:Time"]
                _timeHour = timeState.hour
                _timeMinute = timeState.minute
            else
                _timeHour = _isStoppedForceTime
                _timeMinute = 0
            end
            
            Wait(2500)
        end
    end)
    
    CreateThread(function()
        while true do
            NetworkOverrideClockTime(_timeHour, _timeMinute, 0)
            if _blackoutState then
                SetArtificialLightsStateAffectsVehicles(false)
            end
            Wait(50)
        end
    end)
    
    CreateThread(function()
        while true do
            if not _isStopped then
                if _inCayo or _inCayoStorm then
                    local lazyGravity = "THUNDER"
                    if _inCayo then
                        lazyGravity = "EXTRASUNNY"
                    end
                    SetArtificialLightsState(false)
                    
                    ClearOverrideWeather()
                    ClearWeatherTypePersist()
                    SetWeatherTypeOvertimePersist(lazyGravity, 1.0)
                    Wait(1000)
                    
                    SetWeatherTypePersist(lazyGravity)
                    SetWeatherTypeNow(lazyGravity)
                    SetWeatherTypeNowPersist(lazyGravity)
                else
                    _blackoutState = GlobalState["Sync:Blackout"]
                    SetArtificialLightsState(_blackoutState)-- Blackout
                    SetArtificialLightsStateAffectsVehicles(false)
                    
                    if _weatherState ~= GlobalState["Sync:Weather"] then
                        local _prevWeather = _weatherState
                        _weatherState = GlobalState["Sync:Weather"]
                        if not isTransitionHappening then
                            isTransitionHappening = true
                            _weatherState = GlobalState["Sync:Weather"]
                            print("[TRACE] [Sync] Transitioning to Weather: " .. _weatherState)
                            ClearOverrideWeather()
                            ClearWeatherTypePersist()
                            SetWeatherTypeOvertimePersist(_weatherState, 15.0)
                            Wait(15000)
                            print("[TRACE] [Sync] Finished Transitioning to Weather: " .. _weatherState)
                            isTransitionHappening = false
                        end
                        
                        if _weatherState == 'XMAS' or _weatherState == 'BLIZZARD' or _weatherState == 'SNOW' then
                            SetForceVehicleTrails(true)
                            SetForcePedFootstepsTracks(true)
                            ForceSnowPass(true)
                        elseif _prevWeather == 'XMAS' or _prevWeather == 'BLIZZARD' or _prevWeather == 'SNOW' then
                            SetForceVehicleTrails(false)
                            SetForcePedFootstepsTracks(false)
                            ForceSnowPass(false)
                        end
                    end
                    
                    SetWeatherTypePersist(_weatherState)
                    SetWeatherTypeNow(_weatherState)
                    SetWeatherTypeNowPersist(_weatherState)
                end
                
                Wait(750)
            else
                SetRainLevel(0.0)
                SetWeatherTypeNowPersist("EXTRASUNNY")
                Wait(2000)
            end
        end
    end)
end

AddEventHandler('Polyzone:Enter', function(id, point, insideZone, data)
    if id == 'cayo_perico' and not _inCayo then
        _inCayo = true;
        LocalPlayer.state.inCayo = true
        
        SetForceVehicleTrails(false)
        SetForcePedFootstepsTracks(false)
        ForceSnowPass(false)
    end
    
    if id == 'cayo_perico_weather' and not _inCayoStorm then
        _inCayoStorm = true;
        
        SetRainLevel(0.0)
        
        SetForceVehicleTrails(false)
        SetForcePedFootstepsTracks(false)
        ForceSnowPass(false)
    end
end)

AddEventHandler('Polyzone:Exit', function(id, point, insideZone, data)
    if id == 'cayo_perico' and _inCayo then
        _inCayo = false;
        LocalPlayer.state.inCayo = false
    end
    
    if id == 'cayo_perico_weather' and _inCayoStorm then
        _inCayoStorm = false;
        
        SetRainLevel(-1.0)
    end
end)
