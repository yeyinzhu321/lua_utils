--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 19/12/2017
-- Time: 12:27
-- To change this template use File | Settings | File Templates.
--
local _M = {}

function _M:new(len)
    if typeof(len) == 'string' then len = tonumber(len) end
    return setmetatable({len = len}, {__index = self})
end

--[[
-- 产生特定位数的 uuid
-- --]]
function _M.uuid(self)
    local template = string.rep('x', self.len)
    --local d = io.open("/dev/urandom", "r"):read(4)
    --math.randomseed(date_utils:get_current_timestamp() + d:byte(1) + (d:byte(2) * 256) + (d:byte(3) * 65536) + (d:byte(4) * 4294967296))

    math.randomseed(date_utils:get_current_timestamp_ms())

    local uuid = string.gsub(template, "x", function (c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%x", v)
    end)

    return uuid
end

--[[
-- 产生特定位数的 uuid (纯数字)
-- --]]
function _M.uuid_number(self)
    --local d = io.open("/dev/urandom", "r"):read(4)
    --math.randomseed(date_utils:get_current_timestamp() + d:byte(1) + (d:byte(2) * 256) + (d:byte(3) * 65536) + (d:byte(4) * 4294967296))

    math.randomseed(date_utils:get_current_timestamp_ms())

    return tostring(math.random()):reverse():sub(1,self.len)
end


return _M