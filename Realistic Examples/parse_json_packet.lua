local packet = alias['packet']
local temp = alias['analogTemp']
local photo = alias['photo'] 
local signal = alias['signal']
local meta = json.decode(alias[''].meta)

if meta.timezone then
  settimezone(meta.timezone)
end

local mylocale = "en_US.utf8"
setlocale(mylocale)

while true do
  local ts1 = packet.wait()
  local packetval = packet[ts1]
  headline('FILLINXMPPADDRESS',"Packet",string.format(packetval))
  local data = json.decode(packetval)
  if data then
    if data.analogTemp then
      temp.value = data.analogTemp
    end
    if data.photo then
      photo.value = data.photo
    end
    if data.signal then
      signal.value = data.signal
    end
  end
end

