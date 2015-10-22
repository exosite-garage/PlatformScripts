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
  my_data.wait()
  message = my_data.name..': '..my_data.value..' at '..date("%c", my_data.timestamp) 
  -- Timestamp is added to prevent twitter from filtering "duplicate" tweets.
  dispatch.tweet(tweetauth, message)
  debug(message)
end