local input1 = alias['input1'] -- data to evaluate
local notification_list = alias['notification_list'] -- JSON formatted string of notification info (who, when, etc)

local alert_log = alias['alert_log'] --holds a log of alert history from this script, could be displayed in UI 
local alert_status = alias['alert_status'] -- Human readable string specifying alert satus
local notification_state = alias['notification_state'] -- integer -> 1 (active) or  0 (cleared)



local alert_log_string = ''

local function log(new_message)
  debug(new_message)
  alert_log_string = alert_log_string .. '\r\n' .. tostring(new_message)
end

-- If dataport hasn't been set up yet to write the notification list to
local notification_object = {}

local function refresh_notification_info()
  local notification_list_string = notification_list.value

  -- FOR DEVELOPMENT, JUST EDIT THIS STRING, OTHERWISE COMMENT IT OUT
  --[[[
  notification_list_string = [[ 
    [ 
      { "tier":1,
        "time":0,
        "contacts":
        [
         {"name":"User 1","email":"user1@example.com"}
        ,{"name":"User 2","email":"user2@example.com"}
        ]
      },
      { "tier":2,
        "time":600,
        "contacts":
        [
         {"name":"User 3","email":"user3@example.com"}
        ,{"name":"User 4","email":"user4@example.com"}
        ]
      }
    ]
  ]]

  -- END DEVELOPMENT STRING FOR NOTIFICATION DATA

  notification_object = json.decode(notification_list_string)
  if notification_object == nil then
    debug('notification list is not json')
    log.value ='notification list syntax incorrect'
  end

end

--
local function send_new_notifications (tier_group)
  for i,contact in ipairs(tier_group['contacts']) do
    log('send message to '..contact['name'] )
    if contact['email'] ~= nil then
      local subject = string.format('ALERT, Tier %d', tier_group['tier'])
      local message = string.format( 
[[
Hello %s, there is an alert condition
Start Time: %s
Alert Tier Level %d

To clear, go to https://<MYSBUDOMAIN>.exosite.com
]]
          ,contact['name']
          ,date('%c',alert_state_time),
          tier_group['tier']
        )
      local status,resp = email(contact['email'],subject,message)
      if not status then
        log('failed to send email, reason: '..tostring(resp))
      end
    end
    if contact['phone'] ~= nil then
      local message = string.format( 
[[
Alert, Start Time: %s,Tier Level %d
]]
          ,date('%c',alert_state_time),
          tier_group['tier']
        )
      local status,resp = sms(contact['phone'],message)
      if not status then
        log('failed to send sms, reason: '..tostring(resp))
      end
    end
  end
  
  
end

--
-- Condition (alert) check (this can be as advanced as you need)
--
-- Conditional Variables
--
local last_value = nil

-- Conditional Function
local function check_for_condition (value,timestamp)
  local condition = false

  if value > 20 then 
    condition = true
  else
    condition = false
  end
  last_value = value
  return condition
end



local alert_state = false
local alert_state_time = 0
local last_notification_time = 0 -- sent time timestamp
local last_notification_tier = 0 -- tier level
local notification_cleared = false --used to clear alert

refresh_notification_info()

debug('notification groups: '.. #notification_object)
while true do
  local ts1 = input1.wait(now+60) --check every 60 seconds even no new data 

  if ts1 ~= nil then
    --evaluate new data
    if check_for_condition(input1[ts1],ts1) then
      if alert_state == false then 
        alert_state_time = ts1
        alert_state = true
        notification_cleared = false
        notification_state.value = 1
        log('new alert condition')
        alert_status[ts1] = 'Active'
      end
    else -- Condition is not true anymore
      --reset alert / notification variables
      log('reset alert state')
      alert_state = false
      alert_status[ts1] = '--'
      notification_cleared = false
      notification_state.value = 1
      last_notification_tier = 0
      last_notification_time = 0
    end
  else
    --can't evaluate new data, only time
    --log('no new data')
  end

  if notification_state.value == 0 then
    notification_cleared = true
  else 
    notification_cleared = false
  end

  if alert_state then
    if ts1 == nil then ts1 = now end 
    if not notification_cleared then --see if cleared
      -- look to see if we should send to a new notificaiton group
      refresh_notification_info()
      for i,tier_group in ipairs(notification_object) do
        --debug('checking tier group '..tostring(tier_group['tier']))
        if tier_group['tier'] == last_notification_tier+1 then
          --debug('check to send to tier group'..tostring(tier_group['tier']))
          if ts1 - alert_state_time > tier_group['time'] then
            log('send alerts to tier group '..tier_group['tier'])
            send_new_notifications(tier_group)
            last_notification_tier = last_notification_tier+1
          else
            --not time yet
            --debug('not time for tier_group '..tostring(tier_group['tier']))
          end
        end
      end
    else
      --log('alert has been cleared, holding any new notifications')
    end
  end

  if alert_log_string ~= '' then
    alert_log[ts1] = alert_log_string
    alert_log_string = ''
  end

  
end