--[[ This is a script that doesn't do anything useful, but that simply show the
	 general format of platform scripts.

     This script waits on a dataport named 'test_dataport' and prints a
     debug message with anything that is written to that dataport.
  ]]

local dataport = alias['test_datasource']

while true do
	-- This function waits until a new value is written to the dataport
	-- and returns the timestamp of the datapoint.
	local datapoint_timestamp = dataport.wait()

	-- Get the datapoint.
	local datapoint = dataport[datapoint_timestamp]

	-- Print it to the debug log.
	debug(string.format("Got Datapoint: %s", datapoint))
end