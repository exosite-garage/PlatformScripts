-- Tests:
-- 1) Test over-writing a value at a time-stamp
-- 2) Test setting value at timestamp to nil (single flush)
--

local input = alias['input']

local timestamp = now

-- typical record of a value at a timestamp
input[timestamp] = 1
debug('call status: '..input.status) -- status of call is ok
debug('value:'.. input[timestamp])   -- read back value is 1

-- This will not work, you can not overwrite a value at same timestamp if value exists
input[timestamp] = 2
debug('call status: '..input.status) -- status of call is invalid
debug('value:'.. input[timestamp])   -- read back value is still 1
 
-- This should flush the value at the specific timestamp
input[timestamp] = nil  
debug('call status: '..input.status)  -- status of call is ok
debug('value:'.. tostring(input[timestamp]))  -- read back value is nil as expected

-- This now should work because the value at timestamp was flushed
input[timestamp] = 3 
debug('call status: '..input.status) -- status of call is ok
debug('value:'.. input[timestamp])   -- read back value is 3


debug('done')
