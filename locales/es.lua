local Translations = {
    progress = {
        refueling = 'Repostando Vehículo...',
    },
    success = {
        refueled = 'Vehículo repostado',
    },
    error = {
        no_money = 'No tienes suficiente dinero',
        no_vehicle = 'No se encontró ningún vehículo cerca',
        no_vehicles = 'No hay vehículos cerca',
        no_jerrycan = 'No tienes un bidón de gasolina',
        vehicle_full = 'El vehículo ya está lleno de gasolina',
        no_fuel_can = 'No tienes gasolina en el bidón',
    },
    target = {
        put_fuel = 'Echar gasolina',
        buy_jerrycan = 'Comprar Bidón de Gasolina $%{price}',
        refill_jerrycan = 'Rellenar Bidón de Gasolina $%{price}',
        refill_fuel = 'Rellenar Gasolina',
    }
}

if GetConvar('qb_locale', 'en') == 'es' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end