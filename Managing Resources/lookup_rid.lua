--[[  This script looks up the device's RID and stores it in the dataport
      with alias `devrid`.
  ]]

local device_rid
if not manage.lookup("aliased" ,"devrid") then
  local description = {
    format = "string"
   ,name = "Device RID"
   ,retention = {count = 1 ,duration = "infinity"}
   ,visibility = "private"
  }
  local success ,rid = manage.create("dataport" ,description)
  if not success then
    debug("error initializing rid dataport: "..rid or "")
    return
  end
  manage.map("alias" ,rid ,"devrid")
end
while true do
  device_rid = alias['devrid']
  if nil ~= device_rid then
    break
  end
end
debug(string.format('device_rid: %s' ,device_rid))
local success ,rid = manage.lookup('aliased' ,'')
if true == success then
  debug(string.format('device rid: %s' ,rid))
  while device_rid.value ~= rid do
    device_rid.value = rid
  end
  debug('device rid written successfully')
else
  debug('device rid lookup failed')
end