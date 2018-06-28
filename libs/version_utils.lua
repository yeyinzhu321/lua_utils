--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 29/11/2017
-- Time: 15:43
-- To change this template use File | Settings | File Templates.
--
local function is_android_version(version)
    if string_utils:is_blank(version) then
        return false
    end

    if string.find(version, 'android') == nil then
        return false
    else
        return true;
    end
end

local function is_iphone_version(version)
    if string_utils:is_blank(version) then
        return false
    end

    if string.find(version, 'iphone_c') == nil then
        return false
    else
        return true;
    end
end

local function is_before_iphone_version(version, compare_version)
    if string_utils:is_blank(version) then
        return false
    end

    if "iphone_c" == version then
        return false
    end

    if string.find(version, 'iphone_c') == nil then
        return false
    end

    local find_result = string.find(version, '@')
    local version_result = ''
    if find_result == nil then
        return false
    else
        version_result = string.sub(version, find_result + 1, string.len(version))
    end

    if version_result > compare_version then
        return false
    else
        return true
    end
end

local function is_before_android_version(version, compare_version)
    if string_utils:is_blank(version) then
        return false
    end

    if "android" == version then
        return false
    end

    if string.find(version, 'android') == nil then
        return false
    end

    local find_result = string.find(version, '@')
    local version_result = ''
    if find_result == nil then
        return false
    else
        version_result = string.sub(version, find_result + 1, string.len(version))
    end

    if version_result > compare_version then
        return false
    else
        return true
    end
end

local function is_after_iphone_version(version, compare_version)
    if string_utils:is_blank(version) then
        return false
    end

    if "iphone_c" == version then
        return false
    end

    if string.find(version, 'iphone_c') == nil then
        return false
    end

    local find_result = string.find(version, '@')
    local version_result = ''
    if find_result == nil then
        return false
    else
        version_result = string.sub(version, find_result + 1, string.len(version))
    end

    if version_result >= compare_version then
        return true
    else
        return false
    end
end

local function is_after_android_version(version, compare_version)
    if string_utils:is_blank(version) then
        return false
    end

    if "android" == version then
        return false
    end

    if string.find(version, 'android') == nil then
        return false
    end

    local find_result = string.find(version, '@')
    local version_result = ''
    if find_result == nil then
        return false
    else
        version_result = string.sub(version, find_result + 1, string.len(version))
    end

    if version_result >= compare_version then
        return true
    else
        return false
    end
end

local function is_after_android1_4(version)
    return is_after_android_version(version, '1.4')
end

local function is_after_android1_5(version)
    return is_after_android_version(version, '1.5')
end

local function is_after_android2_4(version)
    return is_after_android_version(version, '2.4')
end

local function is_after_android3_0(version)
    return is_after_android_version(version, '3.0')
end

local function is_after_android4_0(version)
    return is_after_android_version(version, '4.0')
end

local function is_after_android5_0(version)
    return is_after_android_version(version, '5.0')
end

local function is_after_android5_5(version)
    return is_after_android_version(version, '5.5')
end

local function is_after_android5_6(version)
    return is_after_android_version(version, '5.6')
end

local function is_after_android5_42(version)
    return is_after_android_version(version, '5.42')
end

local function is_after_android5_51(version)
    return is_after_android_version(version, '5.51')
end

--[[
-- iphone 判断
-- --]]
local function is_after_iphone1_5(version)
    return is_after_iphone_version(version, '1.5')
end

local function is_after_iphone1_6(version)
    return is_after_iphone_version(version, '1.6')
end

local function is_after_iphone1_7(version)
    return is_after_iphone_version(version, '1.7')
end

local function is_after_iphone1_8(version)
    return is_after_iphone_version(version, '1.8')
end

local function is_after_iphone2_4(version)
    return is_after_iphone_version(version, '2.4')
end

local function is_after_iphone3_0(version)
    return is_after_iphone_version(version, '3.0')
end

local function is_after_iphone4_0(version)
    return is_after_iphone_version(version, '4.0')
end

local function is_after_iphone5_0(version)
    return is_after_iphone_version(version, '5.0')
end

local function is_after_iphone5_2(version)
    return is_after_iphone_version(version, '5.2')
end

local function is_after_iphone5_5(version)
    return is_after_iphone_version(version, '5.5')
end

local function is_after_iphone5_6(version)
    return is_after_iphone_version(version, '5.6')
end

local function is_after_iphone5_42(version)
    return is_after_iphone_version(version, '5.42')
end

local function is_after_iphone5_51(version)
    return is_after_iphone_version(version, '5.51')
end

local function get_version_number(version)
    if version then
        local find_result = string.find(version, '@')
        local version_result = ''
        if find_result == nil then
            return version_result
        else
            version_result = string.sub(version, find_result + 1, string.len(version))
        end

        return version_result
    end

    return ''
end

local version_utils = {
    is_android_version = is_android_version,
    is_iphone_version = is_iphone_version,

    is_after_iphone_version = is_after_iphone_version,
    is_after_android_version = is_after_android_version,
    is_before_android_version = is_before_android_version,
    is_before_iphone_version = is_before_iphone_version,

    is_after_android1_4 = is_after_android1_4,
    is_after_android1_5 = is_after_android1_5,
    is_after_android2_4 = is_after_android2_4,
    is_after_android3_0 = is_after_android3_0,
    is_after_android4_0 = is_after_android4_0,
    is_after_android5_0 = is_after_android5_0,
    is_after_android5_5 = is_after_android5_5,
    is_after_android5_6 = is_after_android5_6,
    is_after_android5_42 = is_after_android5_42,
    is_after_android5_51 = is_after_android5_51,

    is_after_iphone1_5 = is_after_iphone1_5,
    is_after_iphone1_6 = is_after_iphone1_6,
    is_after_iphone1_7 = is_after_iphone1_7,
    is_after_iphone1_8 = is_after_iphone1_8,
    is_after_iphone2_4 = is_after_iphone2_4,
    is_after_iphone3_0 = is_after_iphone3_0,
    is_after_iphone4_0 = is_after_iphone4_0,
    is_after_iphone5_0 = is_after_iphone5_0,
    is_after_iphone5_2 = is_after_iphone5_2,
    is_after_iphone5_5 = is_after_iphone5_5,
    is_after_iphone5_6 = is_after_iphone5_6,
    is_after_iphone5_42 = is_after_iphone5_42,
    is_after_iphone5_51 = is_after_iphone5_51,

    get_version_number = get_version_number,
}

return version_utils

