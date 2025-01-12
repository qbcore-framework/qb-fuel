local Translations = {
    progress = {
        refueling = 'Refueling...',
    },
    success = {
        refueled = 'Vehicle refueled',
    },
    error = {
        no_money = 'You do not have enough money',
        no_vehicle = 'No vehicle found nearby',
        no_vehicles = 'No vehicles nearby',
        no_jerrycan = 'You do not have a jerry can',
        vehicle_full = 'The vehicle is already full of fuel',
        no_fuel_can = 'You do not have fuel in the jerry can',
    },
    target = {
        put_fuel = 'Put fuel',
        buy_jerrycan = 'Buy Jerry Can $%s',
        refill_jerrycan = 'Refill Jerry Can $%s',
        refill_fuel = 'Refill Fuel',
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})