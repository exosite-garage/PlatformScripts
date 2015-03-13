local count = alias['count']
local timer = alias['timer']


-- HELPER FUNCTIONS

-- Reference replacement for string.gsub which is not available in the OnePlatform Lua environment
-- Note: This may not fit all string.gsub needs, may need to be updated for specific needs
local function gsub(s ,p ,r)
  local parts = {}
  local match = {}
  local nextm
  nextm = function(s)
    local repl = function(f ,l ,...)
      if nil ~= f then
        match[#match + 1] = nil == ... and {string.sub(s,f,l)} or {...}
        parts[#parts + 1] = string.sub(s,1,f-1)
        parts[#parts + 1] = #match
        nextm(string.sub(s,l+1))
      else
        parts[#parts + 1] = s
      end
    end
    repl(string.find(s,p))
  end
  nextm(s)
  local rtype = type(r)
  if rtype == "string" then
    for k,v in ipairs(parts) do
      if "number" == type(v) then
        local repl = function(c) return c == "%" and "%" or match[v][tonumber(c)] end
        local rep = gsub(r ,"%%([%d%%])" ,repl)
        parts[k] = nil ~= rep and tostring(rep) or match[v][1]
      end
    end
  elseif rtype == "table" then
    for k,v in ipairs(parts) do
      if "number" == type(v) then
        local rep = r[match[v][1]]
        parts[k] = nil ~= rep and tostring(rep) or match[v][1]
      end
    end
  elseif rtype == "function" then
    for k,v in ipairs(parts) do
      if "number" == type(v) then
        local rep = r(match[v][1])
        parts[k] = nil ~= rep and tostring(rep) or match[v][1]
      end
    end
  end
  return table.concat(parts)
end



-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
-- licensed under the terms of the LGPL2
-- character table string
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding
local function base64_enc(data)

    data = gsub(data,'.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'

    data = gsub(data,'%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1]

    return data
end

-- decoding
local function base64_dec(data)
    data = gsub(data, '[^'..b..'=]', '')
    data = gsub(data,'.', function(x)
          if (x == '=') then return '' end
          local r,f='',(b:find(x)-1)
          for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
          return r;
        end) 
    data = gsub(data,'%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end)
    return data
end



local function http_get()
  -- Typical HTTP based APIs require authorization.  This example assumes using 
  -- 'Basic Authorization', https://en.wikipedia.org/wiki/Basic_access_authentication
  --
  -- API ENDPOINT
  local api_endpoint = 'https://example.something.com/api/v2/search.json?query=status:hold'
  -- AUTH VARIABLES
  local user_email = "email@address"
  local api_token = "fZPaltiTX2vOnMF3m4MFjcEce621ZKZhK5FFLDV8" 
  -- Need to base64 encode the auth header value
  local encoded_auth_string = base64_enc(user_email.."/token:"..api_token)

  local url = string.format(api_endpoint)
  local content_type = "application/json;"
  local headers = {
        ['User-Agent']="onep script,information_script",
        ['Authorization']="Basic "..encoded_auth_string
      }
  local body = nil
  local status,resp=dispatch.http(url, "get", body, content_type,headers)
 
  if status then
    if resp ~= nil and ("200" == tostring(resp['status'])) then
      --local client_cik = resp['body']
      debug(string.format('success '))
      --debug(tostring(resp['body']))
      local json_object = json.decode(resp['body'])
      if json_object.count then
        debug('count:'.. tostring(json_object.count))
        count.value = json_object.count
      else
        debug('no count found')
      end
      return true
    else
      if resp ~= nil then debug(string.format('failed! Response Code: %s', resp['status']))
      else   debug(string.format('failed!'))
      end
      return nil
    end
  else
    debug("Failed to access API.  Response: " .. resp)
    if resp == 'limit' then debug('HTTP Dispatch Resouce Limit met') end
    return nil
  end

end


-- MAIN CODE

debug('starting scheduled script')
settimezone("America/Chicago") 

debug(string.format('Current Date/Time (MY TZ): %s',date())) 
local timeval = date('*t') -- get timedate table by specifying format as table

http_get() -- try on start

while true do
  local ts1 = timer.wait(now+60) -- unblock every 60 seconds
  local timeval = date('*t') -- get the current date/time
  if timeval.min == 3 then
    local message = string.format('It is time to do something! %s ',date())
    debug(string.format(message))
    http_get()
  end
end

debug('done')