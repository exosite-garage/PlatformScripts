-- Example functions to encode a Lua Table for 
-- x-www-form-urlencoded content type
--

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

local function hex(ch)
	return string.format("%%%02x", string.byte(ch))
end

local function urlencode(str)
	return gsub(str, "[^%w_%-%.]", hex)
end

local function encode_query(t)
	local parts = {}

	for k,v in pairs(t) do
		parts[#parts + 1] = urlencode(k) .. "=" .. urlencode(v)
	end
	return table.concat(parts ,"&")
end

--example use:
local my_table = {key1="hello world",key2="M&M's are _great_!"}
debug(encode_query(my_table))

-- this would print out:
-- key1=hello%20world&key2=M%26M%27s%20are%20_great_%21


