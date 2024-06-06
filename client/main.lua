-- local Variables

local Target = exports['qb-target']
local Input = exports['qb-input']

-- Events

RegisterNetEvent('qb-fuel:client:refuelVehicle', function(price, payment)
    local ped = PlayerPedId()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local money = QBCore.Functions.GetPlayerData().money

    if not IsVehicleValid(vehicle) then
        QBCore.Functions.Notify('No vehicle nearby.', 'error')
        return
    end

    if money[payment] < price then
        QBCore.Functions.Notify('You don\'t have enough money', 'error')
        return
    end

    TaskTurnPedToFaceEntity(ped, vehicle, 5000)
    Wait(2000)
    QBCore.Functions.RequestAnimDict('amb@world_human_security_shine_torch@male@base')

    TaskPlayAnim(ped, 'amb@world_human_security_shine_torch@male@base', 'base', 8.0, 1.0, -1, 1, 0, 0, 0, 0)
    getRefuel = true

    QBCore.Functions.Progressbar('refueling_', 'Refueling....', math.random(8000, 10000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        StopAnimTask(ped, 'amb@world_human_security_shine_torch@male@base', 'base', 3.0)
        getRefuel = false
        SetFuel(vehicle, 100)
        TriggerServerEvent('qb-fuel:server:removePayment', price, payment, GetPlayerServerId(PlayerId()))
    end, function()
        StopAnimTask(ped, 'amb@world_human_security_shine_torch@male@base', 'base', 3.0)
        getRefuel = false
        QBCore.Functions.Notify('Refueling Cancelled', 'error')
    end)
end)

RegisterNetEvent('qb-fuel:client:takeNozzle', function()
    if getNozzle then return end

    local ped = PlayerPedId()
    local nozzle = 'prop_cs_fuel_nozle'

    QBCore.Functions.RequestAnimDict('anim@am_hold_up@male')
    TaskPlayAnim(ped, 'anim@am_hold_up@male', 'shoplift_high', 2.0, 8.0, 1000, 50, 0, 0, 0, 0)

    QBCore.Functions.LoadModel(nozzle)
    nozzleProp = CreateObject(nozzle, 1.0, 1.0, 1.0, 1, 1, 0)

    if DoesEntityExist(nozzleProp) then
        getNozzle = true
        AttachEntityToEntity(nozzleProp, ped, GetPedBoneIndex(ped, 18905), 0.13, 0.04, 0.01, -42.0, -115.0, -63.42, 0, 1,
            0, 1, 0, 1)
    end
end)

RegisterNetEvent('qb-fuel:client:returnNozzle', function()
    if not getNozzle then return end

    getNozzle = false

    if nozzleProp then
        DeleteObject(nozzleProp)
        nozzleProp = nil
    end
end)

RegisterNetEvent('qb-fuel:client:openRefuelMenu', function()
    local vehicle = QBCore.Functions.GetClosestVehicle()

    if not IsVehicleValid(vehicle) then
        QBCore.Functions.Notify('No vehicle nearby.', 'error')
        return
    end

    local fuel = GetVehicleFuelLevel(vehicle)
    local price = RoundNumber(Shared.FuelPrice - fuel) * Shared.FuelPriceMultiplier

    if fuel < 90 then
        TriggerServerEvent('qb-fuel:server:openFuelMenu', price)
    else
        QBCore.Functions.Notify('Vehicle fuel tank is above 90%, you can\'t refuel.', 'error')
    end
end)

RegisterNetEvent('qb-fuel:client:openFuelMenu', function(price)
    local playerData = QBCore.Functions.GetPlayerData()
    local money = playerData.money

    local input = Input:ShowInput({
        header = 'Fuel Station',
        submitText = 'Accept Charge: $' .. price,
        inputs = {
            {
                text = 'Payment Methods',
                name = 'type',
                type = 'select',
                options = {
                    { value = 'cash', text = 'Cash' },
                    { value = 'bank', text = 'Bank' }
                }
            }
        },
    })

    if input then
        local payment = input.type
        local availableFunds = money[payment] or 0

        if availableFunds >= price then
            TriggerEvent('qb-fuel:client:refuelVehicle', price, payment)
        else
            QBCore.Functions.Notify('You don\'t have enough money', 'error')
        end
    else
        QBCore.Functions.Notify('Input not received.', 'error')
    end
end)

RegisterNetEvent('qb-fuel:client:addVehFuel', function(fuel)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if not IsPedInAnyVehicle(ped) then
        QBCore.Functions.Notify('You must be inside a vehicle to use this command.', 'error')
        return
    end

    SetFuel(veh, fuel)
    QBCore.Functions.Notify('Added ' .. fuel .. ' units of fuel to the vehicle.', 'error')
end)

-- Threads

if Shared.NearestFuelBlips then
    CreateThread(UpdateClosestStationBlip)
else
    CreateThread(CreateStationBlips)
end

CreateThread(function()
    PopulateBlacklist()
    while true do
        Wait(1000)
        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped) then
            local veh = GetVehiclePedIsIn(ped)
            if not IsVehicleBlacklisted(veh) and GetPedInVehicleSeat(veh, -1) == ped then
                SetFuelConsume(veh)
            end
        else
            getConsume = false
        end
    end
end)

CreateThread(function()
    Target:AddTargetBone(boneModels, {
        options = {
            {
                type = 'client',
                event = 'qb-fuel:client:openRefuelMenu',
                icon = 'fas fa-gas-pump',
                label = 'Refuel Vehicle',
                canInteract = function()
                    return checkStation and getNozzle
                end
            }
        },
        distance = 2.5
    })

    Target:AddTargetModel(propModels, {
        options = {
            {
                type = 'client',
                event = 'qb-fuel:client:takeNozzle',
                icon = 'fas fa-gas-pump',
                label = 'Take Nozzle',
                canInteract = function()
                    local ped = PlayerPedId()
                    return not IsPedInAnyVehicle(ped) or not getNozzle
                end
            },
            {
                type = 'client',
                event = 'qb-fuel:client:returnNozzle',
                icon = 'fas fa-gas-pump',
                label = 'Return Nozzle',
                canInteract = function()
                    return getNozzle and not getRefuel
                end
            }
        },
        distance = 2.5
    })

    for k, gasStation in ipairs(Shared.FuelStations) do
        stationZones[k] = PolyZone:Create(gasStation.poly, {
            name = 'FuelStation' .. k,
            minZ = gasStation.minZ,
            maxZ = gasStation.maxZ,
            debugPoly = false
        })

        stationZones[k]:onPlayerInOut(function(inside)
            if inside then
                checkStation = true
            else
                checkStation = false
            end
        end)
    end
end)