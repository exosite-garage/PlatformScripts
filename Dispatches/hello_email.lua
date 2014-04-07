-- This script will send every new value from the datasource of
-- your choice over an email message.

--------------- Configure These Variables ---------------------
local datasource_alias = 'my_datasource'
local email_recipient = 'user@example.com'
---------------------------------------------------------------

headline(xmpp_user, "Started", "The script has been started.")
debug("Started")

while true do
  valueToReport.wait()
  email(email_recipient, "New Data", valueToReport.value)
  debug("Triggered: "..valueToReport.value)
end