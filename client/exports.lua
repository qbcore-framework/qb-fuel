local newExports = function (funcName, func)
    AddEventHandler(('__cfx_export_LegacyFuel_%s'):format(funcName), function(setCB)
        setCB(func)
    end)
    exports(funcName, func)
end

local SetFuel = function (vehicle, fuel)
    if not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle) then return end
    if fuel < 0 then fuel = 0 end
    if fuel > 100 then fuel = 100 end

    NetworkRequestControlOfEntity(vehicle)
    SetVehicleFuelLevel(vehicle, fuel + 0.0)
    if Config.SyncFuelBetweenPlayers then Entity(vehicle).state:set('qb-fuel', fuel + 0.0, true) end
end

newExports('SetFuel', SetFuel)

local GetFuel = function (vehicle)
    if not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle) then return end

    return GetVehicleFuelLevel(vehicle)
end

newExports('GetFuel', GetFuel)

if Config.SyncFuelBetweenPlayers then

    AddStateBagChangeHandler("qb-fuel", nil, function(bagName, _, value)
        local entity = GetEntityFromStateBagName(bagName)
        if entity == 0 then return end
        if not DoesEntityExist(entity) or not IsEntityAVehicle(entity) then return end
        SetVehicleFuelLevel(entity, value + 0.0)
    end)

    AddEventHandler("gameEventTriggered", function(event, data)
        if event ~= "CEventNetworkPlayerEnteredVehicle" then return end
        local player, vehicle = data[1], data[2]
        local playerPed = PlayerPedId()
        if player ~= 128 or GetPedInVehicleSeat(vehicle, -1) ~= playerPed then return end

        CreateThread(function ()
            while DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == playerPed do
                if IsVehicleEngineOn(vehicle) then
                    Entity(vehicle).state:set('qb-fuel', GetVehicleFuelLevel(vehicle) + 0.0, true)
                end
                Wait(Config.FuelSyncTime*1000)
            end
        end)
    end)

    AddEventHandler('onResourceStart', function(resourceName)
        if resourceName ~= GetCurrentResourceName() then return end

        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= playerPed then return end

        CreateThread(function ()
            while DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == playerPed do
                if IsVehicleEngineOn(vehicle) then
                    local fuel = GetVehicleFuelLevel(vehicle)
                    Entity(vehicle).state:set('qb-fuel', fuel + 0.0, true)
                end
                Wait(Config.FuelSyncTime*1000)
            end
        end)
    end)
end