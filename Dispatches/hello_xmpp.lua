-- This script will send every new value from the datasource of
-- your choice over an xmpp headline.

--------------- Configure These Variables ---------------------
local datasource_alias = 'my_datasource'
local xmpp_user = 'support@exosite.com'
---------------------------------------------------------------

headline(xmpp_user, "Started", "The script has been started.")
debug("Started")

while true do
  valueToReport.wait()
  dispatch.headline(xmpp_user,
           "New Data",
           "New Data: "..valueToReport.value
           )
  debug("Triggered: "..valueToReport.value)
end