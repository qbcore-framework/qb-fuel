Shared = {
    FuelPrice = 100, -- Fuel price.
    FuelPriceMultiplier = 3.0, -- Price multiplier for refueling.
    NearestFuelBlips = true, -- Show nearest fuel stations on the map.
    FuelDecor = '_FUEL_LEVEL', -- Decorator for fuel level.

    FuelStations = { -- List of gas stations to create fuel pumps.
        {
            poly = {
                vec2(-48.36742401123, -1762.4582519531),
                vec2(-70.000930786133, -1742.7271728516),
                vec2(-91.775726318359, -1752.2790527344),
                vec2(-92.827590942383, -1758.8845214844),
                vec2(-65.74178314209, -1781.5811767578)
            },
            minZ = 28.275011062622,
            maxZ = 29.637718200684,
            blip = vec3(-65.13, -1764.86, 29.18)
        },
    },

    Blacklist = { -- List of vehicle models that are blacklisted from being spawned.
        'neon',
        'iwagen',
        'imorgon',
        'tezeract',
        'bmx',
        'tribike3',
        'fixter',
        'cruiser',
        'scorcher',
        'tribike2',
        'tribike',
    },

    Consumption = { -- Fuel consume based on RPM
        [1.0] = 1.3,
        [0.9] = 1.1,
        [0.8] = 0.9,
        [0.7] = 0.8,
        [0.6] = 0.7,
        [0.5] = 0.5,
        [0.4] = 0.3,
        [0.3] = 0.2,
        [0.2] = 0.1,
        [0.1] = 0.1,
        [0.0] = 0.0
    },

    VehicleClass = { -- Multipliers for fuel consume based on vehicle class.
        [0] = 1.0,  -- Compacts
        [1] = 1.0,  -- Sedans
        [2] = 1.0,  -- SUVs
        [3] = 1.0,  -- Coupes
        [4] = 1.0,  -- Muscle
        [5] = 1.0,  -- Sports Classics
        [6] = 1.0,  -- Sports
        [7] = 1.0,  -- Super
        [8] = 1.0,  -- Motorcycles
        [9] = 1.0,  -- Off-road
        [10] = 1.0, -- Industrial
        [11] = 1.0, -- Utility
        [12] = 1.0, -- Vans
        [13] = 0.0, -- Cycles
        [14] = 1.0, -- Boats
        [15] = 1.0, -- Helicopters
        [16] = 1.0, -- Planes
        [17] = 1.0, -- Service
        [18] = 1.0, -- Emergency
        [19] = 1.0, -- Military
        [20] = 1.0, -- Commercial
        [21] = 1.0  -- Trains
    }
}