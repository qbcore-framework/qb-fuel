NewExports = function (funcName, func)
    AddEventHandler(('__cfx_export_LegacyFuel_%s'):format(funcName), function(setCB)
        setCB(func)
    end)
    exports(funcName, func)
end

SetFuel = function (vehicle, fuel)
    if not DoesEntityExist(vehicle) then return end
    if not IsEntityAVehicle(vehicle) then return end
    if not fuel < 0 or fuel > 100 then return end
    SetVehicleFuelLevel(vehicle, fuel)
end

GetFuel = function (vehicle)
    if not DoesEntityExist(vehicle) then return end
    if not IsEntityAVehicle(vehicle) then return end
    return GetVehicleFuelLevel(vehicle)
end