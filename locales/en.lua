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
        no_nozzle = 'There is no vehicle with the nozzle attached nearby',
        too_far = 'You are too far from the pump, the nozzle has been returned',
        wrong_side = 'The vehicle tank is on the other side',
    },
    target = {
        put_fuel = 'Put fuel',
        get_nozzle = 'Get nozzle',
        buy_jerrycan = 'Buy Jerry Can $%{price}',
        refill_jerrycan = 'Refill Jerry Can $%{price}',
        refill_fuel = 'Refill Fuel',
        nozzle_put = 'Attach Nozzle',
        nozzle_remove = 'Remove Nozzle',
        return_nozzle = 'Return Nozzle',
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})