-- Script that looks for other scripts in child clients in error state
-- EXAMPLE ONE PLATFORM SCRIPT
-- This script typically would be run at a 'Portal' level for applications 
-- built using the Exosite Portals application / API.  
-- This scripts runs and look at every device in the portal and then examine the status of each 
-- script to look for error conditions.  All scripts found with errors will be reported via email
-- and restarted
--
-- This scripts runs at the portal level.
--


--------------------------------------------------------------------------------
-- Look for a dataport called 'timer' at this parent client level, if not found, create it
-- 'timer' is used to determine when to run this script by waiting for it with a timeout.  
-- 'timer' never has data written to it so it will timeout and run after a blocking wait call.
if not manage.lookup("aliased" ,"timer") then
  local description = {format = "integer",name = "script timer",retention = {count = 1 ,duration = "infinity"},visibility = "private"}
  local success ,rid = manage.create("dataport" ,description)
  if not success then
    debug("error initializing timer dataport: "..rid or "")
    return
  end
  manage.map("alias" ,rid ,"timer")
end
local timer = alias['timer']

if not timer.timestamp then
  timer.value = 30
end

-- Restarts a scripting by saving the old code, uploading a short string, and then re-uploading the old code.
local function restart_script(rid)
  local status, result = manage.info(rid, 
      {"description"})

  if status then
    debug("restarting script " .. rid)
    -- save script code
    local script_code = result.description.rule.script
    
    local status, result = manage.update(rid,
      {rule = {script = "...restarting..."}})

    local status, result = manage.update(rid,
      {rule = {script = script_code}})
    --local status, result = manage.info(rid, {"description"})
    --debug(tostring(result.description.rule.script))
  
  else debug("Restart failed: Response: " .. result)

  end
end


debug('starting')
settimezone("America/Chicago") 
debug('current time:'..date())

local email_address = 'email@example.com'

local first_run = true
while true do
  local timeval = date('*t') -- get the current date/time
  -- the configuration of these timeval comparisons  will change what times this script will execute.
  if first_run == true or (timeval.hour == 7 or timeval.hour == 15) and timeval.min == 0 then
    debug(string.format('Current Date/Time: %d:%d',timeval.hour,timeval.min)) 
    debug('time to check for error scripts')
    first_run = false
    local error_scripts = {}
    local checked_count = 0

    -- check for scripts owned by this portal
    debug("Should look for Portal level scripts")
    local success ,result = manage.listing({"datarule"} ,{"owned"})
    if success then
        debug(string.format('found %d datarules',#result['datarule']))
        for _ ,datarule_rid in ipairs(result['datarule']) do
            -- debug(rule_rid)
            local success, info = manage.info(datarule_rid,{"description","basic"})
            if success then
                if info['description']['format'] == 'string' then
                  --found script
                  checked_count = checked_count + 1
                    if info['basic']['status'] == 'error' then
                      local script_name = info['description']['name']
                      local script_rid = datarule_rid
                      debug('found script with error')

                      debug(string.format('Portal Script: %s',script_name))
                      table.insert(error_scripts,{device=alias[''].name,script=script_name,rid=datarule_rid})

                      restart_script(script_rid)
                    end
                end
            end
        end
    else 
        debug("Error getting portal datarules")
        debug(result)
    end
    debug("done getting portal level scripts")




    -- get list of devices owned by this portal
    local success ,result = manage.listing({"client"} ,{"owned"})
    if success then
      debug(string.format('found %d devices',#result['client']))
      for _ ,device_rid in ipairs(result['client']) do
        -- for device, get each datarule (script)
        local device_client = alias[{rid=device_rid}]
        --debug(string.format('getting portals for user: %s',device_client.name))
        local success ,result = device_client.manage.listing({"datarule"} ,{"owned"})
        if success then
          for _ ,datarule_rid in ipairs(result['datarule']) do
            -- for each datarule, check if script or not
            local success,info = device_client.manage.info( datarule_rid,{"description","basic"})
            if success then
              if info['description']['format'] == 'string' then
                --found script
                checked_count = checked_count + 1
                if info['basic']['status'] == 'error' then
                  local script_name = info['description']['name']
                  local device_name = device_client.name
                  local script_rid = datarule_rid
                  debug('found script with error')

                  debug(string.format('Device: %s, Script: %s',device_name,script_name))
                  table.insert(error_scripts,{device=device_client.name,script=script_name,rid=datarule_rid})

                  restart_script(script_rid)
                  
                end
              end
            end
          end
        end
      end
    else
      debug("failed to list clients")
    end
    debug(string.format('found %d error scripts out of %d checked',#error_scripts, checked_count))
    
    if #error_scripts > 0 or (timeval.hour == 7 and timeval.wday == 2) then
      local reported = string.format('START\r\nFound %d Scripts In Error State\r\n---',#error_scripts)
      for i,values in ipairs(error_scripts) do
        reported = reported..'\r\n---\r\n'..json.encode(values)
      end
      reported = reported..'\r\n---\r\nEND'
      local portal_name = alias[''].name
      local email_subject = string.format('Script Report for %s, Errors:%d',portal_name,#error_scripts or 0)
      email(email_address,email_subject,reported)
    end
  end
  timer.wait(now + 1800)
end