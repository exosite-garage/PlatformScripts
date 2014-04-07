--[[  This example Watches a dataport and creates new dataports based on
      strings entered. It expects data in a dataport with alias "i" where
      packets are in the format
      `<MAC>,<PAYLOAD>,<RSSI>\r\n<MAC>,<PAYLOAD>,<RSSI>\r\n ...`
      where MAC and PAYLOAD are hex encoded (starting with "0x") and
      rssi is a positive or negative decimal number. From these incoming packets
      it creates new dataports (if needed) named by the MAC address and writes
      the payload and rssi to that dataport.
  ]]

local new_data = alias['i'] -- Incoming Data
local device = alias['']    -- The Device Itself

debug('Script Running')  -- Debug Message

----------------------------------------------------------
--              Local Functions                         --
----------------------------------------------------------

local createDataport = function(alias)
  debug("Creating dataport for: "..alias..".")
  local status, rid = device.manage.create(
      "dataport",
      {
        format = "string",
        name = alias,
        retention = {count = "infinity" ,duration = "infinity"}
      }
    )
  if status == false then
    debug("Error Creating Dataport: "..rid.." Value: "..tostring(status))
  else
    local status, ret = device.manage.map("alias", rid, alias)    
    if status == false then
      debug("Error Mapping Alias to Dataport: "..ret)
    end
  end

  return status
end

----------------------------------------------------------
--              Main                                    --
----------------------------------------------------------

while true do
  local ts1 = new_data.wait()  -- wait for the next packet timestamp
  local val = new_data[ts1]  -- use timestamp to get latest value

  for MAC, payload, rssi in string.gmatch(val, "0x(%w+),0x(%w+),(-?%d+)") do
    if string.len(MAC) == 12 then
      local this_dataport = alias[MAC]
      --debug("Message from "..MAC..".")
      local ret, rid = device.manage.lookup("aliased", MAC)
      if ret == false then
        debug("Needs Dataport:"..rid)
        createDataport(MAC)
        this_dataport = alias[MAC]
      else
        --debug("Has Dataport")
        this_dataport = alias[MAC]
      end
  
      --debug("Writing: "..payload..","..rssi)
      this_dataport.value = payload..","..rssi
    end
  end
end