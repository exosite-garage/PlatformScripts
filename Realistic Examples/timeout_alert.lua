-- Simple Timeout Alert

local mydata = alias['ds_alias'] -- alias of the data source to check
local mydevice = alias[''] -- Syntax to get current device
local state = 'ok'
local timeout = 60 -- seconds
local emailbody = ''
local emailsubject = ''
local emailaddr = 'addresshere' -- specify email address as a string
if emailaddr == 'addresshere' then debug('!Need to specify email address!') end
debug('starting check for timeout...')
while true do
  -- Wait from now until timeout period for new data to come in
  local timestamp = mydata.wait(now+timeout)
  -- Check if got new data or if it returned with no data
  if timestamp == nil then 
    -- We timed out waiting for data in this time period
    debug('timed out')
    -- Check to make sure we don't keep sending alert out in this state
    if state == 'ok' then 
      debug('send alert to '..emailaddr)
      emailbody = 'Detected device ['..mydevice.name ..'] timed out at '..date()
      emailsubject = 'Alert: Device Timeout - '..mydevice.name
      local status,reason = email(emailaddr,emailsubject,emailbody)
      if status == false then debug('Email failed, reason: '.. reason) end
    end
      -- Update the state
      state = 'timeout'
  else
    -- We got data in before the wait timed out
    debug('got data')
    -- Check to make sure we don't keep sending alert out in this state
    if state == 'timeout' then
      debug('send alert to'..emailaddr)
      emailbody = 'Detected device ['..mydevice.name ..'] is reporting again at '..date()
      emailsubject = 'Alert: Device Online Again - '..mydevice.name
      local status,reason = email(emailaddr,emailsubject,emailbody)
      if status == false then debug('Email failed, reason: '.. reason) end
    end
    -- Update the state
    state = 'ok'
  end
end