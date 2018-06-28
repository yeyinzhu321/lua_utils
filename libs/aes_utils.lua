--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 29/11/2017
-- Time: 16:03
-- To change this template use File | Settings | File Templates.
--
local aes = require "resty.aes"
local md5 = require 'md5'
local MBkey = 'f6b0d3f905bf02939b4f6d29f257c2ab'
local MBiv = '1a42eb4565be8628a807403d67dce78d'

--[[
-- URL encode 转换
-- --]]
local function escape(s)
    return string.gsub(s, "([^A-Za-z0-9_])", function(c) return string.format("%%%02x", string.byte(c)) end)
end

--[[
-- URL decode
-- --]]
local function unescape(s)
    return string.gsub(s, "%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end)
end

--[[
-- 字符串转数组
-- --]]
local function hexdecode(str)
    str = escape(str)
    --return (str:gsub('..', function (cc)
    --    return string.char(tonumber(cc, 16))
    --end))
    local hex = ""
    for i = 1, string.len(str) - 1, 2 do
        local doublebytestr = string.sub(str, i, i+1)
        local n = tonumber(doublebytestr, 16)
        if 0 == n then
            hex = hex .. '\00'
        else
            hex = hex .. string.format("%c", n)
        end
    end
    
    return hex
end

--[[
-- 数组转字符串
-- --]]
local function hexencode(hex)
    --return (str:gsub('.', function (c)
    --    return string.format('%02X', string.byte(c))
    --end))

    hex = unescape(hex)

    local str = ""
    for i = 1, string.len(hex) do
        local charcode = tonumber(string.byte(hex, i, i))
        str = str .. string.format("%02X", charcode)
    end
    
    return str
end

--[[
-- 解密
-- --]]
local function decrypt_fun(str)
    if string_utils:is_blank(str) then
        return nil
    end
    local tkey = hexdecode(MBkey)
    local tiv = hexdecode(MBiv)
    local aes_128_cbc_with_iv, err = aes:new(tkey, nil, aes.cipher(128, "cbc"), { iv = tiv })
    if err then
        return nil
    end
    local encrypted = hexdecode(str)
    local tt = aes_128_cbc_with_iv:decrypt(encrypted)
    return tt
end

--[[
-- 加密
-- --]]
local function encrypt_fun(str)
    if string_utils:is_blank(str) then
        return nil
    end

    if typeof(str) ~= 'string' then
        str = '' .. str
    end

    local tkey = hexdecode(MBkey)
    local tiv = hexdecode(MBiv)
    local aes_128_cbc_with_iv, err = aes:new(tkey, nil, aes.cipher(128, 'cbc'), { iv = tiv })
    if err then
        return nil
    end

    return string.lower(hexencode(aes_128_cbc_with_iv:encrypt(str)))
end

--[[
-- 使用特定的 key iv 解密
-- --]]
local function decrypt_fun_with_key_iv(str, key, iv)
    local tkey = hexdecode(key)
    local tiv = hexdecode(iv)
    local aes_128_cbc_with_iv, err = aes:new(tkey, nil, aes.cipher(128, "cbc"), { iv = tiv })
    if err then
        return nil
    end
    local encrypted = hexdecode(str)
    local tt = aes_128_cbc_with_iv:decrypt(encrypted)
    return tt
end

--[[
-- 使用特定的 key iv 加密
-- --]]
local function encrypt_fun_with_key_iv(str, key, iv)
    if typeof(str) ~= 'string' then
        str = '' .. str
    end

    local tkey = hexdecode(key)
    local tiv = hexdecode(iv)
    local aes_128_cbc_with_iv, err = aes:new(tkey, nil, aes.cipher(128, 'cbc'), { iv = tiv })
    if err then
        return nil
    end

    return string.lower(hexencode(aes_128_cbc_with_iv:encrypt(str)))
end

--[[
-- ecs 加密
-- --]]
local function encrypt_ecs_fun(str)
    local key = ngx.decode_base64('RyiQwkaIB2AMvmpJk5RG1g==')
    key = key:gsub("^%s*(.-)%s*$", "%1")

    str = hexdecode(str)

    local aes_128, err = aes:new(key)
    if err then
        return nil
    end

    local encrypted = aes_128:encrypt(str)

    return ngx.escape_uri(ngx.encode_base64(encrypted))
end

--[[
-- ecs 解密
-- --]]
local function decrypt_ecs_fun(str)
    str = ngx.unescape_uri(str)
    local key = ngx.decode_base64('RyiQwkaIB2AMvmpJk5RG1g==')
    local aes_128, err = aes:new(key)
    if err then
        return nil
    end

    str = ngx.decode_base64(str)

    str = aes_128:decrypt(str)

    return hexencode(str)
end
--[[
-- 加密使用 md5
-- --]]
local function encrypt_md5_fun(str)
    if typeof(str) ~= 'string' then
        str = '' .. str
    end

    local tkey = hexdecode(MBkey)
    local tiv = hexdecode(MBiv)
    local aes_128_cbc_with_iv, err = aes:new(tkey, nil, aes.cipher(128, 'cbc'), { iv = tiv })
    if err then
        return nil
    end

    local md5_str = md5.sumhexa(str)

    return string.lower(hexencode(aes_128_cbc_with_iv:encrypt(md5_str)))
end



local aes_utils = {
    decrypt_fun = decrypt_fun,
    hexencode = hexencode,
    hexdecode = hexdecode,
    encrypt_fun = encrypt_fun,
    encrypt_ecs_fun = encrypt_ecs_fun,
    decrypt_ecs_fun = decrypt_ecs_fun,
    escape = escape,
    unescape = unescape,
    encrypt_md5_fun = encrypt_md5_fun,
    encrypt_fun_with_key_iv = encrypt_fun_with_key_iv,
    decrypt_fun_with_key_iv = decrypt_fun_with_key_iv,
}

return aes_utils
