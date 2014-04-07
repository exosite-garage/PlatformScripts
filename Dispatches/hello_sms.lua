-- This script will send every new value from the datasource of
-- your choice over an SMS text message.

--------------- Configure These Variables ---------------------
local datasource_alias = 'my_datasource'
local user_number = '8675309'
---------------------------------------------------------------

headline(xmpp_user, "Started", "The script has been started.")
debug("Started")

while true do
  valueToReport.wait()
  sms(usernumber, valueToReport.value)
  debug("Triggered: "..valueToReport.value)
end