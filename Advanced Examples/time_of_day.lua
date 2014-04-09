-- This script will wait on an unused dataport and every 60 
-- seconds will check to see what time of day it is.  Since this checks
-- about every 60 seconds, it will look at the hour and the minute of the
-- day.  Assume this is based on a specific timezone, but could use UTC 

local timer = alias['timer'] -- unused dataport
debug('starting scheduled script')

settimezone("America/Chicago") 


debug(string.format('Current Date/Time (MY TZ): %s',date())) 
local timeval = date('*t') -- get timedate table by specifying format as table

while true do
  local ts1 = timer.wait(now+60) -- unblock every 60 seconds
  local timeval = date('*t') -- get the current date/time
  if timeval.hour == 12 and timeval.min == 0 then
    local message = string.format('It is time to do something! %s ',date())
    debug(string.format(message))
  end
end


debug('done')
