local Translations = {
    progress = {
        refueling = 'Voertuig aan het voltanken...',
    },
    success = {
        refueled = 'Voertuig is volgetankt',
    },
    error = {
        no_money = 'Je hebt niet genoeg geld',
        no_vehicle = 'Geen voertuig in de buurt gevonden!',
        no_vehicles = 'Er zijn geen voertuigen in de buurt',
        no_jerrycan = 'Je hebt geen jerrycan met benzine',
        vehicle_full = 'Het voertuig is al volgetankt',
        no_fuel_can = 'Er zit geen benzine in de jerrycan',
        no_nozzle = 'Er is geen voertuig met een aangesloten slang in de buurt',
        too_far = 'Je bent te ver van de pomp, de slang is teruggeplaatst',
        wrong_side = 'De tankdop van het voertuig zit aan de andere kant',
    },
    target = {
        put_fuel = 'Benzine tanken',
        get_nozzle = 'Slang pakken',
        buy_jerrycan = 'Jerrycan kopen $%{price}',
        refill_jerrycan = 'Jerrycan bijvullen $%{price}',
        refill_fuel = 'Benzine bijvullen',
        nozzle_put = 'Slang aansluiten',
        nozzle_remove = 'Slang loskoppelen',
        return_nozzle = 'Slang terugplaatsen',
    }
}

if GetConvar('qb_locale', 'en') == 'nl' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
