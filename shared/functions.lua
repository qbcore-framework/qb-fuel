-- Global Variables

QBCore = exports['qb-core']:GetCoreObject()
stationZones = {}
checkStation = false
getNozzle = false
getRefuel = false
getConsume = false
nozzleProp = nil

propModels = {
    'prop_vintage_pump',
    'prop_gas_pump_old2',
	'prop_gas_pump_old3',
	'prop_gas_pump_1a',
	'prop_gas_pump_1b',
	'prop_gas_pump_1c',
    'prop_gas_pump_1d'
}

boneModels = {
    'engine',
	'petroltank',
    'petroltank_r',
	'petroltank_l',
    'wheel_rr',
	'wheel_rf',
    'seat_dside_r',
	'petrolcap '
}

-- Global Functions

function CreateBlip(position)
    local marker = AddBlipForCoord(position)

    SetBlipAsShortRange(marker, true)
    SetBlipSprite(marker, 361)
    SetBlipColour(marker, 1)
    SetBlipScale(marker, 0.6)
    SetBlipDisplay(marker, 6)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Fuel Station')
    EndTextCommandSetBlipName(marker)

    return marker
end

function CreateStationBlips()
    for _, gasStation in ipairs(Shared.FuelStations) do
        CreateBlip(gasStation.blip)
    end
end

function FindClosestStation()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closestDistance = 1000
    local closestStationCoords

    for _, gasStation in ipairs(Shared.FuelStations) do
        local distance = #(playerCoords - gasStation.blip)

        if distance < closestDistance then
            closestDistance = distance
            closestStationCoords = gasStation.blip
        end
    end

    return closestStationCoords
end

function UpdateClosestStationBlip()
    local currentBlip = nil
    local lastClosestStationCoords = nil

    while true do
        local closestStationCoords = FindClosestStation()

        if closestStationCoords ~= nil then
            if closestStationCoords ~= lastClosestStationCoords then
                if currentBlip ~= nil and DoesBlipExist(currentBlip) then
                    RemoveBlip(currentBlip)
                end

                currentBlip = CreateBlip(closestStationCoords)
                lastClosestStationCoords = closestStationCoords
            end
        else
            lastClosestStationCoords = nil

            if currentBlip ~= nil and DoesBlipExist(currentBlip) then
                RemoveBlip(currentBlip)
                currentBlip = nil
            end
        end

        Wait(10000)
    end
end

function SetFuelConsume(veh)
    if not DecorExistOn(veh, Shared.FuelDecor) then
        SetFuel(veh, math.random(200, 800) / 10)
    elseif not getConsume then
        SetFuel(veh, GetFuel(veh))
        getConsume = true
    end

    if GetIsVehicleEngineRunning(veh) then
        local rpm = RoundNumber(GetVehicleCurrentRpm(veh), 1)
        local fuel = Shared.Consumption[rpm] or 0
        local vehicleClassMultiplier = Shared.VehicleClass[GetVehicleClass(veh)] or 1.0
        local fuelConsumption = fuel * vehicleClassMultiplier / 10

        SetFuel(veh, GetVehicleFuelLevel(veh) - fuelConsumption)
    end

    SetVehicleEngineOn(veh, true, true, true)
end

function IsVehicleBlacklisted(vehicle)
    return Shared.Blacklist[GetEntityModel(vehicle)] or false
end

function PopulateBlacklist()
    DecorRegister(Shared.FuelDecor, 1)

    for _, model in ipairs(Shared.Blacklist) do
        local hashKey = nil
        if type(model) == 'string' then
            hashKey = joaat(model)
        else
            hashKey = tostring(model)
        end

        if type(Shared.Blacklist[hashKey]) ~= 'boolean' then
            Shared.Blacklist[hashKey] = true
        end
    end
end

function RoundNumber(number, decimalPlaces)
    local function calculateMultiplier(places)
        return 10 ^ (places or 0)
    end

    local multiplier = calculateMultiplier(decimalPlaces)
    return math.floor(number * multiplier + 0.5) / multiplier
end

function FindVehicleInDirection(startCoords, endCoords)
    local rayHandle
    local vehicle = 0
    local maxOffset = 100

    for offset = 0, maxOffset do
        rayHandle = CastRayPointToPoint(startCoords.x, startCoords.y, startCoords.z, endCoords.x, endCoords.y, endCoords.z + offset, 10, PlayerPedId(), 0)
        local _, _, _, _, hitVehicle = GetRaycastResult(rayHandle)

        if hitVehicle ~= 0 then
            vehicle = hitVehicle
            break
        end
    end

    if vehicle ~= 0 then
        local vehicleCoords = GetEntityCoords(vehicle)
        local distanceSquared = Vdist2(startCoords.x, startCoords.y, startCoords.z, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z)

        if distanceSquared > 625 then -- 25 squared (25 * 25)
            vehicle = 0
        end
    end

    return vehicle
end

function IsVehicleValid(vehicle)
    return DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle)
end

function GetFuel(veh)
    local fuelLevel = DecorGetFloat(veh, Shared.FuelDecor)

    if type(fuelLevel) == 'number' then
        return fuelLevel
    else
        return nil
    end
end

exports('GetFuel', GetFuel)

function SetFuel(veh, fuelLevel)
    if type(fuelLevel) == 'number' and fuelLevel >= 0 and fuelLevel <= 100 then
        SetVehicleFuelLevel(veh, fuelLevel + 0.0)
        DecorSetFloat(veh, Shared.FuelDecor, GetVehicleFuelLevel(veh))
    end
end

exports('SetFuel', SetFuel)