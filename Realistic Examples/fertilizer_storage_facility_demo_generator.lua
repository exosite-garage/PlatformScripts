-- This script generates randomized sensor data with a controlled range,
-- and also has the feature to be able to have sensor values "wander"
-- towards defined set points.
-- 
-- Dependencies:
--   * temperature, humidity, and ammonia data sources must be present
--   * set_point data source of type string. Format:
--     {"temperature":<value>,"humidity":<value>,"ammonia":<value>}

local temperature = alias['temperature']
local humidity    = alias['humidity']
local ammonia     = alias['ammonia']

-- How often should data be written? WAIT is measured in seconds.
local WAIT = 10

-- When a new randomized data point is generated, and the set point is lower
-- than the current value, what is the min/max range that should be used as
-- inputs to the random number generator? The absolute value of DMIN should be
-- larger than the absolute value of DMAX. The wider the range, the more
-- variability there will be.
local DMIN = -2 -- Should be negative
local DMAX = 1  -- Should be possitive

-- UMIN and UMAX work the same as DMIN and DMAX, but are only used when the 
-- set point for the data source is higher than the current value. The absolute
-- value of UMIN should be smaller than the absolute value of UMAX. The wider the
-- range, the more variability there will be.
local UMIN = -1
local UMAX = 2

-- Function to generate a random number within a range. If x is 0 and y is 1, the
-- value will be a flow. In all other cases, the number will be an integer within
-- the range {x,y}.
local function rand(x,y)
    return math.random(x,y)  
end

-- Function to generate the next data point as a function of the current data value,
-- and the next data value. The constants DMIN/DMAX and UMIN/UMAX are used to constrain
-- the amount of variability in the samples.
local function new(current,target)
    if current < target then
        return current + rand(UMIN, UMAX)
    else
        return current + rand(DMIN, DMAX)
    end
end

-- Function to convert Fahrenheit to Celsius. This is needed in this script
-- since the values for temperature in this example are written to the platform
-- in Celsius, but converted to Fahrenheit. When the values are subsequently 
-- read from the platform, they are in Fahrenheit. However, it becomes difficult
-- To read/write values to the platform when the units are different.
--
-- Therefore, because this script was developed for an example application that
-- used temperature, this function was needed.
local function f2c(f)
    return (f - 32) * 5/9  
end

-- Now that the script has been initialized, enter the forever busy-wait loop
while true do
  
    -- This is somewhat of a hack, but we'll wait on either the temperature value
    -- to change or the wait period to expire. Since this script is the only thing
    -- that is updating the temperature datasource, it's safe to do it this way.
    local ts1 = temperature.wait(now+WAIT)

    -- Initial local variables with values that are sensible defaults. These are
    -- only used if the value in the set_points data source is missing or corrupt.  
    local t_set = 20 -- 20 degrees C (room temp)
    local h_set = 50 -- 50% relative humidity
    local a_set = 0  -- 0 ppm ammonia present

    -- Read the set_points data source, which is assumed to be of the following
    -- format: {"temperature":<value>,"humidity":<value>,"ammonia":<value>}
    local set_points  = alias['set_points']
    local d = json.decode(set_points.value)

    -- If the value in the set_points datasource was valid, then update the local
    -- set point variables with the values specified. If the values in the set_points
    -- data source are invalid, the defaults for t_set, h_set, and a_set will be used.    
    if d then
        if d.temperature then
            t_set = d.temperature
        end
        if d.humidity then
            h_set = d.humidity
        end
        if d.ammonia then
            a_set = d.ammonia
        end
    end

    -- Set the temperature, humidity, and ammonia data sources with new values
    -- that are randomized, yet moving towards defined set points.
    --
    -- Note that the temperature data source uses the f2c function to convert
    -- Fahrenheit to Celsius prior to generating the next data point. 
    temperature.value = new(f2c(temperature.value), t_set)
    humidity.value = new(humidity.value, h_set)
    ammonia.value = new(ammonia.value, a_set)
  
    debug("Updated values: " .. temperature.value .. ", " .. humidity.value .. ", " .. ammonia.value)
end