# qb-fuel
- This script adds a fuel system to your FiveM server. Players must refuel their vehicles regularly, adding strategy and resource management to their gameplay.

# Configuration:
- Adjust the settings in the script's configuration file to customize the fuel system according to your preferences. You can modify fuel consumption rates, refueling costs, and other parameters to tailor the experience to your server's needs.

# Exports:
- This fuel system script provides two exports that you can utilize in your FiveM server scripts:

1. **`exports['qb-fuel']:GetFuel(vehicle)`:**
   - Description: Retrieves the current fuel level of the specified vehicle.
   - Parameters:
     - `vehicle`: The vehicle entity to retrieve the fuel level from.

2. **`exports['qb-fuel']:SetFuel(vehicle, fuel)`:**
   - Description: Sets the fuel level of the specified vehicle.
   - Parameters:
     - `vehicle`: The vehicle entity to set the fuel level for.
     - `fuel`: The desired fuel level to set for the vehicle as a percentage, ranging from 0 to 100.

# License

    QBCore Framework
    Copyright (C) 2021 Joshua Eger

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>
