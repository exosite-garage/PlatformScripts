--[[  The alias.wait() function has an optional "Expire" parameter. We can use
      this to create a sort of "delay" function in platform scripts. However,
      note that scripts run _after_ the wait expires, not _when_ it expires,
      usually within a few seconds.

      We need to wait on a datasource that never gets written to,
			but that _does_ exist.
	]]

local timer = alias['timer'] -- Never written to, otherwise will expire early.

while true do
  -- Do Something
  debug("Hello!")
  
  -- Wait on datasource that does not exist,
  -- but timeout at now plus 60 seconds.
  timer.wait(now+60)
end