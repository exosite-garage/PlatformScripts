local motorevent = alias['eventmotoron']
local onoffswitch = alias['onoff']
local log = alias['log']
local AUTORUN = (8*60*60) -- seconds to auto start again
debug('starting script')
local status
local autoRunTimer = 0  -- seconds
while true do
  local ts1 = motorevent.wait(now+60) -- check every 60 seconds if motor hasn't changed states
  status = motorevent[ts1]
  if ts1 ~= nil then
    autoRunTimer = 0  -- restart counter
    debug("event change")
    if status == 0 then log.value = "Detected Motor Stop, start counter" end
  else
    if status == 1 then
      debug("running")
      autoRunTimer = 0 -- don't start counter while it is running.
    else
      autoRunTimer = autoRunTimer + 60   -- update counter with the check time value of 60 seconds
      local text = string.format("not running, auto-start in %.2f hours", ((AUTORUN-autoRunTimer)/3600))
      debug(text)
    end
  end
  if (autoRunTimer > AUTORUN) then
    onoffswitch.value = 1  -- set the data source that will tell the controller to turn on the relay
    debug("auto start!")
    log.value = "Auto Start Motor"
  end
end

