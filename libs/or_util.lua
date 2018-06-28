--[[
	@module OpenResty工具类库
]]

--[[
	判断response状态是否是200
	@res 响应
]]
local function is_ok(res)
	return res.status == ngx.HTTP_OK;
end

local function out(content)
	ngx.say(content)
end

--获取当前系统时间精确到ms
local function get_mill_sec()
	return date_utils:get_current_timestamp_ms() * 1000;
end

--获取当前系统时间精确到s
local function get_time()
	return date_utils:get_current_timestamp();
end

local _M = {  
   is_ok = is_ok,
   out = out,
   get_mill_sec = get_mill_sec,
   get_time = get_time,
}

return _M
