local analog = alias['adcVal']
local temp = alias['temp']
local B = 4450.0 --K
local R25 = 100000.0 -- Ohms
  
local function ntcTherm (rMeasured, beta, r25)
  local To = 298.15
  local r_inf = r25 * math.exp(-beta / To)
  return beta / math.log(rMeasured / r_inf)
end

local function celsius (tempK)
  return tempK - 273.15
end

local function fahrenheit (tempK)
  return (celsius(tempK) * 9.0/5) + 32
end

while true do
  local ts1 = analog.wait()
  local analogvalue = analog[ts1]
  -- Convert Analog Voltage to Resistance
  local rPullup = 100000.0
  local adcScale = 1023
  local Rmeasured = rPullup * analogvalue / (adcScale - analogvalue)
  local tempK = ntcTherm(Rmeasured,B,R25)
  local tempF = fahrenheit(tempK)
  temp.value = tempF
end