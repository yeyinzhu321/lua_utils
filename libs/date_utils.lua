--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 06/12/2017
-- Time: 20:40
-- To change this template use File | Settings | File Templates.
--
local _M = {}

--[[
-- transfer the input param whose type is string to date
-- --]]
function _M:string_to_date (date_str)
    if not date_str then
        return nil
    end

    local Y = string.sub(date_str , 1, 4)
    local M = string.sub(date_str , 6, 7)
    local D = string.sub(date_str , 9, 10)

    local hour = string.sub(date_str, 12, 13)
    local min = string.sub(date_str, 15, 16)
    local sec = string.sub(date_str, 18, 19)

    return os.time({year=Y, month=M, day=D, hour=hour, min=min, sec=sec})
end

function _M:string_to_date1 (date_str)
    if not date_str then
        return nil
    end

    local Y = string.sub(date_str , 1, 4)
    local M = string.sub(date_str , 5, 6)
    local D = string.sub(date_str , 7, 8)

    local hour = string.sub(date_str, 9, 10)
    local min = string.sub(date_str, 11, 12)
    local sec = string.sub(date_str, 13, 14)

    return os.time({year=Y, month=M, day=D, hour=hour, min=min, sec=sec})
end

--[[
-- format the given input param with the given pattern
-- --]]
function _M:date_to_string(pattern, time)
    if not time then
        time = date_utils:get_current_timestamp()
    end

    if pattern == 'yyyy-MM-dd HH:mm:ss' then
        return os.date('%Y-%m-%d %X', time)
    elseif pattern == 'yyyyMMddHHmmss' then
        return os.date('%Y%m%d%H%M%S', time)
    elseif pattern == 'yyyyMMdd HHmm' then
        os.date('%Y-%m-%d %H:%M', time)
    else
        return os.date('%Y-%m-%d', time)
    end
end

--[[
-- transfer the input string param to timestamp
-- --]]
function _M:str_to_timestamp(paramStr)
    local iteratorFunc = string.gmatch(paramStr, "%d+")
    local date_str_table = {}
    local i = 1
    for r in iteratorFunc do
        date_str_table[i] = r
        i = i + 1
    end

    return os.time({
        year = date_str_table[1],
        month = date_str_table[2],
        day = date_str_table[3],
        hour = date_str_table[4],
        min = date_str_table[5],
        sec = date_str_table[6],
    })
end

--[[
-- get current timestamp(use nginx api)
--]]
function _M:get_current_timestamp()
    ngx.update_time()
    return ngx.time()
end

--[[
-- get current timestamp(use nginx api)
--]]
function _M:get_current_timestamp_ms()
    ngx.update_time()
    return ngx.now()
end



return _M
