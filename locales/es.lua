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
        no_nozzle = 'No hay ningún vehículo con la boquilla puesta cerca',
        too_far = 'Estás demasiado lejos de la bomba, la boquilla ha sido devuelta',
        wrong_side = 'El tanque del vehículo está en el otro lado',
    },
    target = {
        put_fuel = 'Echar gasolina',
        get_nozzle = 'Coger boquilla',
        buy_jerrycan = 'Comprar Bidón de Gasolina $%{price}',
        refill_jerrycan = 'Rellenar Bidón de Gasolina $%{price}',
        refill_fuel = 'Rellenar Gasolina',
        nozzle_put = 'Poner boquilla',
        nozzle_remove = 'Quitar boquilla',
        return_nozzle = 'Devolver boquilla',
    }
}

if GetConvar('qb_locale', 'en') == 'es' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end