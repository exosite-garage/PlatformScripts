-- This script generates exceptional environmental events by periodically
-- writing values to the set_points data source which is subsequently used
-- by the Virtual Sensor Simulator script to create simulated sensor data
-- and guides the randomized sensor values to "wander" towards the set points
-- Defined in this script.
--
-- Dependencies:
--   * A timer data source is required in order to wait for a defined HYSTERESIS
--     interval. It's important that nothing else writes to the timer data source
--     since we are relying on it to *not* change so that the timeout value (which
--     is driven by the HYSTERESIS value) occurs deterministicly.
--   * A set_points data source of type string must be present and is used to record
--     the output of this script. The set_points data source will contain a string of
--     the following format: {"temperature":<value>,"humidity":<value>,"ammonia":<value>}
local timer = alias["timer"]
local set_points = alias["set_points"]

-- Default hysteresis value. Hysteresis in this context is defined as the 
-- number of minutes to wait for the system to stabilize before moving on to the
-- next environmental condition defined in the set_point_arr table.
local HYSTERESIS = 1

-- The following table defines sets of set points that correspond to an environmental
-- event. This script assumes that the following data sources are being simulated:
-- temperature, humidity, and ammonia. Therefore, each set of set points defines new
-- values for temperature, humidity, ammonia, and a hysteresis value defined in minutes
-- that defines how long to wait for the system to stabilize before moving to the next
-- event in the table.
--
-- The format of each set is defined as follows:
-- <condition> = {
--   <temperature (celsius)="">,
--   <relative humidity="" (%)="">,
--   <ammonia (parts="" per="" million)="">,
--   <hysteresis (minutes)=""> }
local set_point_arr = {
  a_norm = { 20, 40, 10, 30 }, -- Normal. No problems.
  c_crit = { 40, 75, 50, 20 }  -- High temp, high humidity, high ammonia. Big problems.
}

-- Now that the script has been initialized, enter a forever busy-wait loop.
while true do
  -- Iterate through all rows in the set_point_arr table. Note that it would be preferable
  -- to sort the table since lua will not guarantee the order of the rows in the result.
  -- However, the ONE Platform lua implementation does not support table.sort.  
  for k, v in pairs(set_point_arr) do

    -- Wait for HYSTERESIS (measured in minutes) before proceeding.
    local ts1 = timer.wait(now+HYSTERESIS*60)

    -- For this row in the table, save the temperature, humidity, and ammonia
    -- set points, and also record a new HYSTERESIS value that we will use to wait
    -- on before proceeding to the next row in the set_point_arr table.
    local t_set = v[1]
    local h_set = v[2]
    local a_set = v[3]
    HYSTERESIS = v[4]

    -- Format the JSON string for the new set points and write it to the set_points
    -- data source.
    local json = string.format("{\"temperature\":%s,\"humidity\":%s,\"ammonia\":%s}", t_set, h_set, a_set)
    set_points.value = json

    -- Print a debug message so we know things are working as expected.    
    debug(k .. " = " .. json .. " for " .. HYSTERESIS .. " minutes")
  end
end