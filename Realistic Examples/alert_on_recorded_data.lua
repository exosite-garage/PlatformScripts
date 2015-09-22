--[[ Example Exosite One Platform Lua Script to parse data recorded into a dataport's history and send an email if needed. 
  ]]

-- Constants --
local period = 10 -- looking at values that arrived in the last 10 seconds.

-- Alias Variables --
local mydataport = alias['dataportAlias']   -- dataport the data is in
local email_recipient = 'contact@email.com'

-- Functions --
local function evaluateHistory(p_start,p_end)
    local done = false

    mydataport.last = p_start

    while done == false do
        local ts = mydataport.wait(p_end)
        
        if ts ~= nil then
            local value = mydataport[ts] -- value at timestamp
            -- debug("Value is: "..value.." at time: "..ts)

--[[ Change the logic below to match your needs.]]

            if value >= 100 then  -- [[event logic resides here, this tests if the dataport value is greater than '90' and then updates the datarule as needed. ]]
                local bool = email(email_recipient, "The Event Happened!", tostring(value))
                -- debug(""..tostring(bool))
                --debug("Email sent to "..email_recipient..", with the number: "..value)

            else
                done = true
            end
        end
    end
end

            
-- Main Application Code --
debug("Script started.")

local ts_period_start = now-period
local ts_period_end = now

while true do
    evaluateHistory(ts_period_start, ts_period_end)
    ts_period_start = now-period
    ts_period_end = now

end
debug("Script has ended.")
