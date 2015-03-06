-- EXAMPLE PORTAL USAGE vs LIMIT REPORT
-- For the client, compare limits vs used resources and 
-- send email report.  Note that this will get the usage 
-- for the client including it's child clients.
--


local EMAIL = "YOUR EMAIL HERE"
local SUBJECT = "PORTAL USAGE REPORT"

local EMAIL_REPORT = "PORTAL USAGE REPORT\r\n"
EMAIL_REPORT = EMAIL_REPORT .. string.format("%9s: %10s of %10s\r\n","param","used","limit")

-- GET INFO ABOUT THIS CLIENT IN ONE PLATFORM
local success ,info = manage.info({alias = ""} ,{"description","usage"})
if success then
  -- CHECK WE HAVE THE CLIENT'S LIMITS
  if info['description']['limits'] ~= nil then
    --debug('got description info')
    --for i,l in pairs(info['description']['limits']) do
    --  debug(i..':'..l)
    --end
    -- CHECK WE HAVE THE CLIENT'S USAGE
    if info['usage'] ~= nil then
      --debug('got usage info')
      for k,used in pairs(info['usage']) do
        --debug(k..':'..used)
        EMAIL_REPORT = EMAIL_REPORT .. string.format("%9s: %10d of ",k,used)
        if info['description']['limits'][k] ~= nil then
          if info['description']['limits'][k] ~= 'inherit' then
            local limit = tonumber(info['description']['limits'][k])
            EMAIL_REPORT = EMAIL_REPORT .. string.format("%10d ",limit)
            --debug('limit: '..tostring(limit))
            if limit <= tonumber(used) then
              debug(string.format('WARNING: %s - Limit %d : Used %d',k,limit,used))
              EMAIL_REPORT = EMAIL_REPORT .. string.format(" -> WARNING")
            else
              debug(string.format('OK     : %s - Limit %d : Used %d',k,limit,used))
            end
          else
            EMAIL_REPORT = EMAIL_REPORT .. string.format("inherited ")
          end
        else
          debug('limit does not exist')
        end
        EMAIL_REPORT = EMAIL_REPORT .. "\r\n"
      end
    end
  else
    debug("failed to get self description limits")
  end
else
  debug("failed to get self info")
end
debug('done')
-- SEND REPORT
email(EMAIL,SUBJECT,EMAIL_REPORT)

