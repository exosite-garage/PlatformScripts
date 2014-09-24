-- This script simply waits until a new value gets written to a 
-- dataport, then pushes that value to the specified url.

--------------- Configure These Variables ---------------------
local dataport_alias = 'device_message'
local url = 'http://198.46.157.16:13579'
---------------------------------------------------------------

local dataport = alias[dataport_alias]

while dataport ~= nil do
  local new_timestamp = dataport.wait()
  
  if new_timestamp ~= nil then
    local new_value = dataport[new_timestamp]
    local body = string.format('%s=%s', dataport_alias, new_value)
    debug(string.format('Sending Message: %s', body, date()))
    dispatch.http(url,
                  "post",
                  body,
                  "application/x-www-form-urlencoded"
                 )
  else
    break
  end
end

debug("Reached End of Program; Are you sure the dataport alias exists?")
