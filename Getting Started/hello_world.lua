--[[ This is a script that doesn't do anything useful, but that simply show the
	 general format of platform scripts.

     This script waits on a datasource named 'test_datasource' and prints a
     debug message with anything that is written to that datasource.
  ]]

local datasource = alias['Test']

while true do
	-- This function waits until a new value is written to the datasource
	-- and returns the timestamp of the datapoint.
	local datapoint_timestamp = datasource.wait()

	-- Get the datapoint.
	local datapoint = datasource[datapoint_timestamp]

	-- Print it to the debug log.
	debug(string.format("Got Datapoint: %s", datapoint))
end