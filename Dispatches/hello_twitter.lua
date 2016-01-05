-- This script will send every new value written to a single
-- datasource of your choice to twitter.

--------------- Configure These Variables ---------------------
local datasource_alias = 'my_datasource'
local tweetauth =  {
     oauth_consumer_key = '',
     oauth_consumer_secret = '',
     oauth_token = '',
     oauth_token_secret = ''
} --You'll need both a developer and user credential.
---------------------------------------------------------------

local message
local datasource = alias[datasource_alias]

debug("Script Started")
dispatch.tweet(tweetauth, "Script Started at "..date("%c", now))

while true do 
  datasource.wait()
  message = datasource.name..': '..datasource.value..' at '..date("%c", datasource.timestamp) 
  -- Timestamp is added to prevent twitter from filtering "duplicate" tweets.
  dispatch.tweet(tweetauth, message)
  debug(message)
end
