local init = function ()
    SetFuelConsumptionState(true)
    SetFuelConsumptionRateMultiplier(Config.GlobalFuelConsumptionMultiplier)

    DisplayBlips()
end

DisplayBlips = function ()
    for _, station in ipairs(Config.GasStations) do
        local blip = AddBlipForCoord(station.x, station.y, station.z)
        SetBlipSprite(blip, Config.Blip.Sprite)
        SetBlipColour(blip, Config.Blip.Color)
        SetBlipScale(blip, Config.Blip.Scale)
        SetBlipDisplay(blip, Config.Blip.Display)
        SetBlipAsShortRange(blip, Config.Blip.ShortRange)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Blip.Text)
        EndTextCommandSetBlipName(blip)
    end
end

SetUpTarget = function ()
    for _, hash in pairs(Config.PumpModels) do
        exports['qb-target']:AddTargetModel(hash, {
            options = {
                {
                    num = 1,
                    event = 'qb-fuel:client:openFuelMenu',
                    icon = 'fa-solid fa-gas-pump',
                    label = 'Echar Gasolina',
                },
                {
                    num = 2,
                    type = 'server',
                    event = 'qb-fuel:server:buyJerryCan',
                    icon = 'fa-solid fa-jar',
                    label = 'Comprar Bidón de Gasolina $' .. Config.JerryCanCost,
                },
                {
                    num = 3,
                    type = 'server',
                    event = 'qb-fuel:server:refillJerryCan',
                    icon = 'fa-solid fa-arrows-rotate',
                    label = 'Rellenar Bidón de Gasolina $' .. Config.JerryCanCost,
                }
            },
            distance = 1.5
        })
    end
end

-- ====================|| INITIALIZATION || ==================== --

init()