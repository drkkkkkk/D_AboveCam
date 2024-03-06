local isAboveCamActive = false
local aboveCam = -1

RegisterCommand(Config.AboveCommand, function()
    local player = GetPlayerPed(-1)
    
    if IsPedInAnyVehicle(player, false) then
        if not isAboveCamActive then
            isAboveCamActive = true
            local vehicle = GetVehiclePedIsIn(player, false)
            aboveCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
            AttachCamToEntity(aboveCam, vehicle, 0.0, 0.0, 50.0, true)
            SetCamActive(aboveCam, true)
            RenderScriptCams(true, false, 0, true, true)
            PanCamToSky(aboveCam)
        else
            TriggerEvent("chatMessage", "SYSTEM", {255, 0, 0}, "You are already in /abovecam.")
        end
    else
        TriggerEvent("chatMessage", "SYSTEM", {255, 0, 0}, "You need to be in a vehicle to use /abovecam.")
    end
end, false)

RegisterCommand(Config.ResetCommand, function()
    if isAboveCamActive then
        PanCamToCar(aboveCam)
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(aboveCam, true)
        isAboveCamActive = false
    else
        TriggerEvent("chatMessage", "SYSTEM", {255, 0, 0}, "You are not currently in /abovecam.")
    end
end, false)

function PanCamToSky(cam)
    local duration = 2000
    local startTime = GetGameTimer()
    local startPitch = GetCamRot(cam, 2)
    
    Citizen.CreateThread(function()
        while isAboveCamActive do
            local elapsed = GetGameTimer() - startTime
            local progress = elapsed / duration
            local pitch = Lerp(startPitch.x, -90.0, progress)
            
            SetCamRot(cam, pitch, 0.0, 0.0, true)
            
            Citizen.Wait(0)
            
            if progress >= 1.0 then
                break
            end
        end
    end)
end

function PanCamToCar(cam)
    local duration = 2000
    local startTime = GetGameTimer()
    local startPitch = GetCamRot(cam, 2)
    
    Citizen.CreateThread(function()
        while not isAboveCamActive do
            local elapsed = GetGameTimer() - startTime
            local progress = elapsed / duration
            local pitch = Lerp(startPitch.x, 0.0, progress)
            
            SetCamRot(cam, pitch, 0.0, 0.0, true)
            
            Citizen.Wait(0)
            
            if progress >= 1.0 then
                break
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isAboveCamActive then
            local player = GetPlayerPed(-1)
            local vehicle = GetVehiclePedIsIn(player, false)
            
            if DoesEntityExist(vehicle) and not IsEntityDead(vehicle) then
                local x, y, z = table.unpack(GetEntityCoords(vehicle, false))
                SetCamCoord(aboveCam, x, y, z + 50.0)
                
                if IsControlJustReleased(0, 75) then  -- F key
                    TaskWarpPedIntoVehicle(player, vehicle, -1)
                end
            else
                -- Vehicle is not present, reset the camera
                TriggerEvent("resetcam")
            end
        end
    end
end)

function Lerp(a, b, t)
    return a + (b - a) * t
end
