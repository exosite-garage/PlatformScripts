--[[ Example Exosite One Platform Lua Script to find average
     of a data source over 24 hour period.
  ]]

--
-- Constants --
--
local period = 24*60*60 -- want to go back 24 hours (in seconds)
--
-- Alias Variables --
--
local mydataport = alias['aliasname']   -- data source my data is in
local myaverage = alias['averagealias'] -- data source to put average value into
--
-- Variables --
--
local ts_period_start = now-period
local ts_period_end = now
local func_name = '[main]'
--
-- Functions --
--

-- Func: prettydebug
-- Desc: Call debug with specific format and text
local function prettydebug(text,name)
	if name == nil then name = "main" end
	local debugtext = string.format("[%s] %s",name,text)
	debug(debugtext)
end
-- Func: round
-- Desc: return rounded number to a number of decimal places
local function round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

-- Func: rounds
-- Desc: return rounded number as string to a number of decimal places
local function rounds(num,idp)
  return string.format("%." .. (idp or 0) .. "f", num)
end

-- Func: get_average
-- Desc: return calculated average for data source 
--       over the time period given
local function get_average(alias,p_start,p_end)
    local func_name = 'func_avg'
	local done = false
	local datapts = 0
	local average = 0

	mydataport.last = p_start

	while done == false do
		local ts = mydataport.wait(p_end)
		if ts ~= nil then
			local value = mydataport[ts] -- value at timestamp
			prettydebug(string.format("Found Data Point: timestamp %d, value of %s",ts,rounds(value,2)),func_name)
			average = average + value
			datapts = datapts + 1
		else
			prettydebug(string.format("Found no more values, done with routine"),func_name)
			done = true
		end
	end
	prettydebug(string.format("Found %d points, calculating average...",datapts),func_name)
	if datapts > 0 then
		average = average/datapts
		prettydebug(string.format("Average: %s",rounds(average,2)),func_name)
	return average,datapts
	else
		prettydebug(string.format("No points found, average not calculated"),func_name)
		return nil,0
	end
end

--
-- Main Application Code --
--
prettydebug("Start")
settimezone("UTC") -- use UTC as timezone
prettydebug("Current Timestamp of .last: "..mydataport.last) -- This should print out timestamp of last data value
prettydebug("Current Timestamp: "..now) -- This should print out current timestamp 
prettydebug("Run Average Routine from "..ts_period_start.." to "..ts_period_end)

local avg,pts = get_average(mydataport,ts_period_start,ts_period_end)
if avg ~= nil then
	prettydebug(string.format("Average: %s [time period: %d to %d]",rounds(avg,2),ts_period_start,ts_period_end))
	myaverage[ts_period_end] = round(avg,2) --set the data source holding average calculations, put value at timestamp of period end
else
	prettydebug(string.format("No data points for time period [%d to %d]",ts_period_start,ts_period_end))
end
prettydebug("Done")