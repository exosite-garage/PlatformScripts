-- This example script expects to run at a Portals Vendor level (Subdomain's root hierarchy node client)
-- This script requires a Vendor Token to access the provision management vendor API
-- http://docs.exosite.com/provision/management/
-- 
-- This scripts runs and look at every device in the subdomain hierarchy.  It checks the provisioning status and
-- if it is 'expired', will re-enable it automatically.  Devices currently have their CIK expire after 24 hours
-- if no activation call is made by the device.
--
-- To save on amount of time to run through the tree, any device that was found to already be activated is cached 
-- in a JSON object so it is not checked in the future.
-- 

local VENDOR_TOKEN = '<VENDOR_TOKEN_HERE>'
-- VENDOR TOKEN from <vendorsubdomain>.exosite.com/admin


local function reenable(vendor,model,sn)
  local url = string.format('https://%s.m2.exosite.com/provision/manage/model/%s/%s', vendor,model, sn)
  local body = string.format('enable=true')
  local content_type = "application/x-www-form-urlencoded; charset=utf-8"
  local headers = {
        ['User-Agent']="onep script",
        ['X-Exosite-Token']=VENDOR_TOKEN
      }
  local status,resp=dispatch.http(url, "post", body, content_type,headers)

  if status then
    if ("205" == tostring(resp['status'])) then
      --local client_cik = resp['body']
      debug(string.format('Client Re-Enabled! '))
      return true
    else
      debug(string.format('Client re-enable failed! Response Code: %s', resp['status']))
      return nil
    end
  else
    debug("Failed to access API.  Response: " .. resp)
    if resp == 'limit' then debug('HTTP Dispatch Resouce Limit met') end
    return nil
  end

end

-- Do not modify below this line
--------------------------------------------------------------------------------
if not manage.lookup("aliased" ,"timer") then
  local description = {format = "integer",name = "script timer",retention = {count = 1 ,duration = "infinity"},visibility = "private"}
  local success ,rid = manage.create("dataport" ,description)
  if not success then
    debug("error initializing timer dataport: "..rid or "")
    return
  end
  manage.map("alias" ,rid ,"timer")
end
local timer = alias['timer']

if not timer.timestamp then
  timer.value = 30
end

if not manage.lookup("aliased" ,"dev_act_table_cache") then
  local description = {format = "string",name = "activations cache table",retention = {count = 1 ,duration = "infinity"},visibility = "private"}
  local success ,rid = manage.create("dataport" ,description)
  if not success then
    debug("error initializing timer dataport: "..rid or "")
    return
  end
  manage.map("alias" ,rid ,"dev_act_table_cache")
end

local dev_act_table_cache = alias['dev_act_table_cache']


local cache_list = json.decode(dev_act_table_cache) or {}

debug('starting')

while true do
  -- get list of user accounts in the subdomain
  local success ,result = manage.listing({"client"} ,{"owned"})
  local prev_cache_list = cache_list
  if success then
    for _ ,user_rid in ipairs(result['client']) do
      -- for each user, get list of owned portals
      local user_client = alias[{rid=user_rid}]
      --debug(string.format('getting portals for user: %s',user_client.name))
      local success ,result = user_client.manage.listing({"client"} ,{"owned"})
      if success then
        for _ ,portal_rid in ipairs(result['client']) do
          -- for each portal, get list of owned devices
          local portal_client = alias[{rid=portal_rid}]
          --debug(string.format('getting devices for portal: %s',portal_client.name))
          local success ,result = portal_client.manage.listing({"client"} ,{"owned"})
          if success then
            for _ ,rid in ipairs(result['client']) do
              -- check each device
              if cache_list[rid] == nil or cache_list[rid] ~= 'activated' then
                local success ,info = portal_client.manage.info(rid ,{"basic"})
                if success then
                  local client = alias[{rid = rid}]
                  if cache_list[rid]==nil or info['basic']['status'] ~= cache_list[rid] then
                    debug(string.format('device (%s) activation status change: %s',client.name, info['basic']['status']))
                  end
                  cache_list[rid] = info['basic']['status']
                  if info['basic']['status'] == 'expired' then
                    debug(string.format("device \"%s\" is expired, re-enabling." ,client.name))
                    local client_meta = json.decode(client.meta)
                    local vendor = client_meta['device']['vendor']
                    local model = client_meta['device']['model']
                    local sn = client_meta['device']['sn']
                    if vendor ~= nil and model ~= nil and sn ~= nil then
                      reenable(vendor, model, sn)
                    else
                      debug('provision information error')
                    end
                  end
                  if info['basic']['status'] == 'activated' then
                    -- add to cached list
                    cache_list[rid] = 'activated'
                    debug('caching activated device: ' .. client.name.. ',portal: '..portal_client.name..',owned by: '..user_client.name)
                  end
                end
              else
                --debug('already activated (in cache)')
              end
            end
          end
        end
      end
    end
    if prev_cache_list ~= cache_list then
      dev_act_table_cache.value = json.encode(cache_list) --store cached value in dataport
    end
  else
    debug("failed to list clients")
  end
  timer.wait(now + timer.value)
end