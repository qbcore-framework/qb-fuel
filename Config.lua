Config = Config or {}

-- Global Fuel Consumption Multiplier. The fuel consumption of each vehicle is set in the handling
-- file of the vehicle, in the game or in you addon vehicles. The formula (provided by the game) is: 
-- time_step * revolutions_per_minute * vehicle_fuel_consumption_multiplier * global_fuel_consumption_multiplier
Config.GlobalFuelConsumptionMultiplier = 4.5 -- GTAV Default: 1.0
Config.SyncFuelBetweenPlayers = true         -- Sync fuel between players
Config.FuelSyncTime = 10                     -- Time between syncs in seconds

Config.MoneyType = 'cash'       -- Money type to use for the fuel transactions
Config.FuelPrice = 5            -- Price of the fuel per litre

Config.JerryCanCost = 100                                                   -- Cost of the Jerry Can
Config.JerryCanLitre = 40                                                   -- Litres of the Jerry Can
Config.JerryCanRefillCost = Config.FuelPrice * Config.JerryCanLitre         -- Cost of the Jerry Can Rifill

Config.RefillTimePerLitre = 0.5 -- Time in seconds to refill 1 litre of fuel

-- Blip settings for the gas stations
-- see https://docs.fivem.net/docs/game-references/blips/
Config.Blip = {
    Sprite = 361,
    Color = 0,
    Scale = 0.7,
    Display = 4,
    ShortRange = true,
    Text = 'Gas Station'
}

-- All known pump models in game (I think)
Config.PumpModels = {
	-2007231801, 1339433404, 1694452750, 1933174915,
    -462817101, -469694731, -164877493
}

-- All known gas stations in game
Config.GasStations = {
	vector3(49.4187, 2778.793, 58.043),
	vector3(263.894, 2606.463, 44.983),
	vector3(1039.958, 2671.134, 39.550),
	vector3(1207.260, 2660.175, 37.899),
	vector3(2539.685, 2594.192, 37.944),
	vector3(2679.858, 3263.946, 55.240),
	vector3(2005.055, 3773.887, 32.403),
	vector3(1687.156, 4929.392, 42.078),
	vector3(1701.314, 6416.028, 32.763),
	vector3(179.857, 6602.839, 31.868),
	vector3(-94.4619, 6419.594, 31.489),
	vector3(-2554.996, 2334.40, 33.078),
	vector3(-1800.375, 803.661, 138.651),
	vector3(-1437.622, -276.747, 46.207),
	vector3(-2096.243, -320.286, 13.168),
	vector3(-724.619, -935.1631, 19.213),
	vector3(-526.019, -1211.003, 18.184),
	vector3(-70.2148, -1761.792, 29.534),
	vector3(265.648, -1261.309, 29.292),
	vector3(819.653, -1028.846, 26.403),
	vector3(1208.951, -1402.567,35.224),
	vector3(1181.381, -330.847, 69.316),
	vector3(620.843, 269.100, 103.089),
	vector3(2581.321, 362.039, 108.468),
	vector3(176.631, -1562.025, 29.263),
	vector3(176.631, -1562.025, 29.263),
	vector3(-319.292, -1471.715, 30.549),
	vector3(1784.324, 3330.55, 41.253)
}
