-- Events

RegisterNetEvent('qb-fuel:server:openFuelMenu', function(price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    local amount = math.ceil(price)

    local menuData = {
        {
            header = 'Fuel Station',
            txt = 'Total Charge: $' .. price,
            params = {
                event = 'qb-fuel:client:openFuelMenu',
                args = amount
            }
        }
    }

    TriggerClientEvent('qb-menu:client:openMenu', src, menuData)
end)

RegisterNetEvent('qb-fuel:server:removePayment', function(price, payment)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    if Player.Functions.RemoveMoney(payment, price, 'refueling') then
        QBCore.Functions.Notify(src, ('You paid $%s from your %s'):format(price, payment), 'success')
    end
end)

-- Commands

QBCore.Commands.Add('setfuel', 'Set fuel to the vehicle', {{ name = 'Amount', help = 'Amount of fuel to add' }}, true, function(source, args)
    local src = source
    local amount = tonumber(args[1])

    if not amount then
        QBCore.Functions.Notify(src, 'Fuel amount must be a number.', 'error')
        return
    end

    if amount > 100 then
        QBCore.Functions.Notify(src, 'The fuel amount must be 100 or less.', 'error')
        return
    end

    TriggerClientEvent('qb-fuel:client:addVehFuel', src, amount)
end, 'admin')