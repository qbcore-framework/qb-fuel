local newExports = function (funcName, func)
    AddEventHandler(('__cfx_export_LegacyFuel_%s'):format(funcName), function(setCB)
        setCB(func)
    end)
    exports(funcName, func)
end

SetFuel = function (vehicle, fuel)
    if not DoesEntityExist(vehicle) then return end
    if not IsEntityAVehicle(vehicle) then return end
    if fuel < 0 then fuel = 0 end
    if fuel > 100 then fuel = 100 end
    SetVehicleFuelLevel(vehicle, fuel + 0.0)
end

newExports('SetFuel', SetFuel)

GetFuel = function (vehicle)
    if not DoesEntityExist(vehicle) then return end
    if not IsEntityAVehicle(vehicle) then return end
    return GetVehicleFuelLevel(vehicle)
end

newExports('GetFuel', GetFuel)