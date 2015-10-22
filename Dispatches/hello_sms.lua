-- This script will send every new value from the dataport of
-- your choice over an SMS text message.

--------------- Configure These Variables ---------------------
local dataport_alias = 'my_dataport' -- the dataport to monitor
local user_number = '+1xxxyyyzzzz' -- be sure to use correct country code
---------------------------------------------------------------

debug("The script has been started.")

while true do
  local ts = dataport_alias.wait()
  dispatch.sms(user_number, 'Dataport Value: '..tostring(dataport_alias[ts]))
  debug("Triggered: "..tostring(dataport_alias[ts]))
end
