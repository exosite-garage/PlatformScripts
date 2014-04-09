local dev_name = alias[''].name

local meta = json.decode(alias[''].meta) -- decode meta from client
local dev_tz = meta.timezone
local dev_location = meta.location
local dev_acttime = meta.activetime
local dev_type = meta.device.type

debug(string.format('Device Name: %s',dev_name))
debug(string.format('Device Timezone: %s',dev_tz))
debug(string.format('Device Loc: %s',dev_location))
debug(string.format('Device Activation Time: %s',dev_acttime))
debug(string.format('Device Device Type: %s',dev_type