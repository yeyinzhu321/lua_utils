--[[
    @module 字符串工具类
]]
local _M = {}

--判断@body是否为空串
function _M:is_blank(body)
    if not body then
        return true
    elseif body == nil then
        return true
    elseif body == ngx.null then
        return true
    else
        if typeof(body) == 'table' then
            body = cjson.encode(body)
        else
            body = tostring(body)
        end
        
        if #body < 1 then
            return true
        else
            return false
        end
    end
end

--判断@body是否不为空串
function _M:is_not_blank(body)
    return not self:is_blank(body)
end

--[[
-- 判断字符串是否包含某个字符串
--]]
function _M:contains(str, contains_str)
    if not str or not contains_str then
        return false
    else
        local find_res = ngx.re.find(str, contains_str, 'jo')
        if self:is_blank(find_res) then
            return false
        else
            return true
        end
    end
end

--判断两个字符串是否相等(区别大小写)
function _M:equals(str1, str2)
    if typeof(str1) ~= 'string' or typeof(str2) ~= 'string' then
        if typeof(str1) == 'number' or typeof(str2) == 'number' then
            str1 = tostring(str1)
            str2 = tostring(str2)
            if str2 == str1 then
                return true
            end
            return false
        end
    end

    if not str1 and not str2 then
        return true
    end

    if not str1 and str2 then
        return false
    end

    if str1 and not str2 then
        return false
    end

    if str1 and str2 then
        if str1 == str2 then
            return true
        else
            return false
        end
    end
end

--判断两个字符串不相等(区分大小写)
function _M:not_equals(str1, str2)
    return not self:equals(str1, str2)
end

--判断两个字符串不相等(不区分大小写)
function _M:not_equals_ignore_case(str1, str2)
    return not self:equals_ignore_case(str1, str2)
end

--判断两个字符串是否相等(不区别大小写)
function _M:equals_ignore_case(str1, str2)
    if typeof(str1) ~= 'string' or typeof(str2) ~= 'string' then
        if typeof(str1) == 'number' or typeof(str2) == 'number' then
            str1 = string.lower(tostring(str1))
            str2 = string.lower(tostring(str2))
            if str2 == str1 then
                return true
            end
            return false
        end
    end

    str1 = string.lower(tostring(str1))
    str2 = string.lower(tostring(str2))

    if not str1 and not str2 then
        return true
    end

    if not str1 and str2 then
        return false
    end

    if str1 and not str2 then
        return false
    end

    if str1 and str2 then
        if str1 == str2 then
            return true
        else
            return false
        end
    end
end

--判断@str是否以@pre开头
function _M:starts_with(str, pre)
    if str == nil or pre == nil then
        return false
    end

    return ngx.re.find(str, pre) == 1
end

--[[
    字符串拆分
    @s 源字符串
    @delim 拆分标识符
]]
function _M:split(s, delim)
    if typeof(delim) ~= "string" or string.len(delim) <= 0 then
        return {}
    end

    local start = 1
    local t = {}
    while true do
        local pos = string.find(s, delim, 1, true)
        if not pos then
            break
        end

        table.insert(t, string.sub(s, start, pos - 1))
        s = string.sub(s, pos + 1, #s)
        table.insert(t, s)
    end

    return t
end

--[[
    随机生成长度为length的字符串
]]
function _M:rand(length)
    local strs = {
        "A", "H", "O", "U", "a", "g", "m", "s", "y", "4",
        "B", "I", "P", "V", "b", "h", "n", "t", "z", "5",
        "C", "J", "Q", "W", "c", "i", "o", "u", "0", "6",
        "D", "K", "R", "X", "d", "j", "p", "v", "1", "7",
        "E", "L", "S", "Y", "e", "k", "q", "w", "2", "8",
        "F", "M", "T", "Z", "f", "l", "r", "x", "3", "9",
        "G", "N"
    }

    local r = ''
    math.randomseed(date_utils:get_current_timestamp() + os.clock() * 100000000)
    for i = 1, length, 1 do
        r = r .. strs[math.random(1, #strs)]
    end
    return r
end

--[[
    判断字符串str与正则表达式reg是否匹配
]]
function _M:match_regx(str, reg)
    local r = { string.match(str, reg) }
    if #r < 1 or r == nil then
        return nil
    end
    return r
end

--[[
-- url 拼接字符串(get 请求)
--]]
function _M:concat_uri_str(_table)
    local result = ''
    local n = 0
    for k, v in pairs(_table) do
        if n == 0 then
            result = k .. '=' .. v
        else
            result = result .. '&' .. k .. '=' .. v
        end
        n = n + 1
    end

    return result
end

--[[
-- 用给定的字符串替换源字符串中的某个串
--]]
function _M:replace_with_given_pattern(original_str, search_pattern_str, replace_pattern_str)
    if self:is_blank(original_str) then
        return nil
    end

    if self:is_blank(search_pattern_str) then
        return original_str
    end

    return ngx.re.gsub(original_str, search_pattern_str, replace_pattern_str)
end

--[[
-- 查找给定字符串中最后一个字符的位置
-- --]]
function _M:find_last(original_str, pattern)
    local i = original_str:match(".*" .. pattern .. "()")
    if i == nil then
        return nil
    else
        return i - 1
    end
end

--[[
-- 查找字符串是否以给定的字符串结尾
-- --]]
function _M:ends_with_str(original_str, end_str)
    local start_index, end_index = ngx.re.find(original_str, end_str)
    if self:is_blank(start_index) then
        return false
    else
        if end_index ~= #original_str then
            return false
        else
            return true
        end
    end
end

--[[
-- 查找字符串是否以给定的字符串结尾(忽略大小写)
-- --]]
function _M:ends_with_ignore_case_str(original_str, end_str)
    original_str = string.lower(original_str)
    end_str = string.lower(end_str)
    return self:ends_with_str(original_str, end_str)
end

--[[
-- 为空的时候返回默认值
--]]
function _M:get_default_val(original_str)
    if self:is_blank(original_str) then
        original_str = ''
    end

    return original_str
end

--[[
-- 拼接 log 日志字符串
--]]
function _M:concat_str_from_tab(msg_tab)
    local msg = ''
    if msg_tab and typeof(msg_tab) == 'table' then
        for k, v in pairs(msg_tab) do
            local tmp_v = v
            if self:is_blank(tmp_v) then
                tmp_v = ''
            end

            msg = msg .. tmp_v
        end
    end

    return msg
end

--[[
-- 处理 java 返回的 json 数据不正常的情况,比如下面的字段没有带",lua 中 cjson 解析的时候有问题
-- {rsp_code:"0000",rsp_desc:"正常/成功"}
--]]
function _M:handle_exception_java_json(java_json_str)
    local json_str = java_json_str
    local json_arr = string_utils:split(json_str, ',')
    local result_str = ''
    if json_arr then
        for k, v in pairs(json_arr) do
            local tmp_str = ''
            if k == 1 then
                tmp_str = string.sub(v, 2, ngx.re.find(v, ':', 'jo') - 1)
            else
                tmp_str = string.sub(v, 1, ngx.re.find(v, ':', 'jo') - 1)
            end

            if not string_utils:contains(tmp_str, '"') then
                if k == 1 then
                    result_str = result_str .. '{"' .. tmp_str .. '":' .. string.sub(v, ngx.re.find(json_str, ':', 'jo') +1, #v) .. ','
                else
                    result_str = result_str .. '"' .. tmp_str .. '":' .. string.sub(v, ngx.re.find(json_str, ':', 'jo'), #v) .. ','
                end
            else
                result_str = result_str .. v .. ','
            end
        end

        result_str = string.sub(result_str, 1, #result_str - 1)
    end

    return result_str
end


return _M
