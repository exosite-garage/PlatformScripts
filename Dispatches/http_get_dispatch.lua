-- This script make a HTTP GET request and prints out the response
-- API Synxtax-> status,resp=dispatch.http(url, request_type, body, content_type,headers,timeout)


local url = "https://m2.exosite.com/timestamp"
local headers = nil
local content_type = nil --not used for 'GET requests'
local timeout = 7

local status,resp=dispatch.http(url, "get", nil, content_type,headers,timeout)

if status then
  if ("204" == tostring(resp['status'])) then
    debug(string.format('Get Request Success\r\n Status: %s\r\n',tostring(resp['status'])))
    debug(string.format('Headers: %s\r\n',tostring(resp['headers'])))
  elseif 
    ("200" == tostring(resp['status'])) then
    debug(string.format('Get Request Success\r\n Status: %s\r\n', tostring(resp['status'])))
    --debug(string.format('Headers: %s\r\n',tostring(resp['headers'])))
    debug(string.format('Body: %s \r\n', tostring(resp['body'])))
  else
    debug(string.format('Get Request failed! Status Code: %s\r\n',tostring(resp['status'])))
    --debug(string.format('Headers: %s\r\n',tostring(resp['headers'])))
    debug(string.format('Body: %s \r\n', tostring(resp['body'])))
  end
else
  debug("Failed to access API.  Response: " .. resp)
  if resp == 'limit' then debug('HTTP Dispatch Resouce Limit met') end
end

debug('done')
