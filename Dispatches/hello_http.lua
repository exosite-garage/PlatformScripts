-- This script simply waits until a new value gets written to a 
-- datasource, then pushes that value to the specified url.

--------------- Configure These Variables ---------------------
local datasource_alias = 'device_message'
local url = 'http://198.46.157.16:13579'
---------------------------------------------------------------

local datasource = alias[datasource_alias]

while datasource ~= nil do
  local new_timestamp = datasource.wait()
  
  if new_timestamp ~= nil then
    local new_value = datasource[new_timestamp]
    local body = string.format('%s=%s', datasource_alias, new_value)
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

debug("Reached End of Program; Are you sure the datasource alias exists?")