--[[ This script shows how to parse through data from history.
  ]]

local starttime = now-(24*60*60) -- Start 24 Hours Ago
local endttime = now 
 
mydataport.last = starttime
while done == false do
	local ts = mydataport.wait(endtime)
	if ts ~= nil then
		local value = mydataport[ts] -- value at this timestamp

		-- do something with each value here.
	else
		done = true
	end
end