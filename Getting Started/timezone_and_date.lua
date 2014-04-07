-- Set/Get timezone for script, not device, could copy from device
settimezone("America/Chicago") 

-- Log the current date/time, default format.
debug(string.format('Current Date/Time (MY TZ): %s',date())) 

-- Get timedate table by specifying format as table
local timeval = date('*t') 
debug(string.format('Current Day of Month: %d',timeval.day))

-- Set timezone for script as UTC
settimezone("UTC") 
debug(string.format('Current Date/Time (UTC): %s',date()))

-- Log current Unix Timestamp
debug(string.format('Current Unix Time Stamp: %s',now))