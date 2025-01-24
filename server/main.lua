-- ====================|| VARIABLES || ==================== --

QBCore = exports["qb-core"]:GetCoreObject()

-- ====================|| EVENTS || ==================== --

QBCore.Functions.CreateCallback('qb-fuel:server:refillVehicle', function (src, cb, litres)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not litres then return end

    local finalPrice = litres * Config.FuelPrice
    if Player.PlayerData.money[Config.MoneyType] >= finalPrice then
        cb(Player.Functions.RemoveMoney(Config.MoneyType, finalPrice, 'refuel-vehicle'))
    else
        cb(false)
    end
end)

RegisterServerEvent('qb-fuel:server:buyJerryCan', function ()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.Functions.RemoveMoney(Config.MoneyType, Config.JerryCanCost, 'buy-jerry-can') then
        Player.Functions.AddItem('weapon_petrolcan', 1, nil, { fuel = Config.JerryCanLitre, ammo = Config.JerryCanLitre })
    end
end)

RegisterServerEvent('qb-fuel:server:refillJerryCan', function ()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local jerryCan = Player.Functions.GetItemByName('weapon_petrolcan')
    if not jerryCan then return Player.Functions.Notify(Lang:t('error.no_jerrycan'), 'error') end

    if Player.Functions.RemoveMoney(Config.MoneyType, Config.JerryCanRefillCost, 'refill-jerry-can') then
        jerryCan.info.fuel = Config.JerryCanLitre
        jerryCan.info.ammo = Config.JerryCanLitre
        Player.Functions.RemoveItem('weapon_petrolcan', 1, jerryCan.slot)
        Player.Functions.AddItem('weapon_petrolcan', 1, nil, jerryCan.info)
    end
end)

RegisterServerEvent('qb-fuel:server:setCanFuel', function (fuel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local jerryCan = Player.Functions.GetItemByName('weapon_petrolcan')
    if not jerryCan then return Player.Functions.Notify(Lang:t('error.no_jerrycan'), 'error') end

    jerryCan.info.fuel = fuel
    jerryCan.info.ammo = fuel
    Player.Functions.RemoveItem('weapon_petrolcan', 1, jerryCan.slot)
    Player.Functions.AddItem('weapon_petrolcan', 1, nil, jerryCan.info)
end)
