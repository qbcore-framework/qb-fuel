-- ====================|| VARIABLES || ==================== --

QBCore = exports["qb-core"]:GetCoreObject()

-- ====================|| EVENTS || ==================== --

QBCore.Functions.CreateCallback('qb-fuel:server:refillVehicle', function (src, cb, litres)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local finalPrice = litres * Config.FuelPrice
    if Player.PlayerData.money.cash >= finalPrice then
        cb(Player.Functions.RemoveMoney('cash', finalPrice, 'refuel-vehicle'))
    else
        cb(false)
    end
end)

RegisterServerEvent('qb-fuel:server:buyJerryCan', function ()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.Functions.RemoveMoney('cash', Config.JerryCanCost, 'buy-jerry-can') then
        Player.Functions.AddItem(Config.JerryCanItem, 1, nil, { fuel = Config.JerryCanLitre })
    end
end)

RegisterServerEvent('qb-fuel:server:refillJerryCan', function ()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local jerryCan = Player.Functions.GetItemByName(Config.JerryCanItem)
    if not jerryCan then return Player.Functions.Notify('No tienes un bidón de gasolina', 'error') end

    Player.Functions.RemoveMoney('cash', Config.JerryCanRefillCost, 'refill-jerry-can')
    jerryCan.info.fuel = Config.JerryCanLitre
    Player.Functions.SetItem(jerryCan.slot, jerryCan)
end)
