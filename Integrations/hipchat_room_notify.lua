-- This script posts a message to a HipChat room using HTTP POST dispatch
-- hipchat.com
-- To use:
-- 1) You must have a HipChat account with a Room setup
-- 2) You must set up a Auth Token for the Room and get the Room ID
-- 3) Create an Exosite Platform Script and insert this code.
-- 4) Debug output will tell you if successful or not.
-- 
-- For more information on HipChat API: https://www.hipchat.com/docs/apiv2/method/send_room_notification
--

local function notify_hipchat_room(message)
  --POST /v2/room/myroom/notification
  --     Authorization: Bearer 12345678
  --     Host: api.hipchat.com
  -- 
  local ROOM_AUTH_TOKEN = "<AUTH_TOKEN_HERE>"
  local ROOM_ID = "<ROOM_ID_HERE>" --Note, this could also be the room name, replace spaces of course

  local url = "https://api.hipchat.com/v2/room/" .. ROOM_ID .. "/notification"
  local headers = {['Authorization']="Bearer ".. ROOM_AUTH_TOKEN}
  local content_type = "application/json"
  local body = string.format('{"message": "%s", "color":"gray", "notify":true}',message)

  local status,resp=dispatch.http(url, "post", body, content_type,headers)

  if status then
    if ("204" == tostring(resp['status'])) then
      debug(string.format('hipcat notify Success: ', resp['body']))
    else
      debug(string.format('hipchat notify failed! Response Code: %s', resp['status']))
    end
  else
    debug("Failed to access API.  Response: " .. resp)
    if resp == 'limit' then debug('HTTP Dispatch Resouce Limit met') end
  end
end


notify_hipchat_room("This is a test from Lua Script at "..date())

