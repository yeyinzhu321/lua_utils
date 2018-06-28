--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 29/11/2017
-- Time: 09:56
-- To change this template use File | Settings | File Templates.
--
local rsa = require 'resty.rsa'

local PUBLIC_KEY = [[
-----BEGIN PUBLIC KEY-----
-----END PUBLIC KEY-----
]]

local PRIV_KEY = [[-----BEGIN PRIVATE KEY-----
-----END PRIVATE KEY-----]]

--[[
-- URL encodeURI 转换
-- --]]
local function escape(s)
    return string.gsub(s, '([^A-Za-z0-9_])', function(c) return string.format('%%%02x', string.byte(c)) end)
end

--[[
-- URL decodeURI
-- --]]
local function unescape(s)
    return string.gsub(s, '%%(%x%x)', function(hex) return string.char(tonumber(hex, 16)) end)
end

--[[
-- 公钥加密
-- --]]
local function encrypt(msg, pub_key)
    if typeof(msg) ~= 'string' then
        msg = '' .. msg
    end

    if not pub_key then pub_key = PUBLIC_KEY end

    if string_utils:is_blank(msg) then
        local tmp_log_tab = {
            log_param1 = 'rsa_utils.encrypt() may get one nil value.',
        }
        log_utils:error(tmp_log_tab)

        return nil
    end

    local pub, err = rsa:new({ public_key = pub_key, key_type = rsa.KEY_TYPE.PKCS8,})
    if not pub then
        local tmp_log_tab = {
            log_param1 = 'rsa_utils.encrypt() new rsa err:',
            log_param2 = err,
        }
        log_utils:error(tmp_log_tab)

        return nil
    end

    return ngx.encode_base64(pub:encrypt(msg))
end

--[[
-- 私钥解密
-- --]]
local function decrypt(msg, pri_key)
    if string_utils:is_blank(msg) then
        local tmp_log_tab = {
            log_param1 = 'rsa_utils.decrypt() may get one nil value.',
        }
        log_utils:error(tmp_log_tab)

        return nil
    end

    if not pri_key then pri_key = PRIV_KEY end

    msg = unescape(msg)

    local e_msg = string_utils:replace_with_given_pattern(msg, '\\s', '')

    local priv, err = rsa:new({ private_key = pri_key, key_type = rsa.KEY_TYPE.PKCS8,})
    if not priv then
        local tmp_log_tab = {
            log_param1 = 'rsa_utils.decrypt() decrypt failed, err:',
            log_param2 = err,
        }
        log_utils:error(tmp_log_tab)

        return nil
    end
    return priv:decrypt(ngx.decode_base64(e_msg))
end

--[[
-- 私钥加密
-- --]]
local function encrypt_with_privatekey(pri_key, msg)
    if not pri_key then
        pri_key = PRIV_KEY
    end

    local priv, err = rsa:new({
        private_key = pri_key,
        key_type = rsa.KEY_TYPE.PKCS8,
        crypt = 'encrypt',})
    if not priv then
        local tmp_log_tab = {
            log_param1 = 'rsa_utils.encrypt_with_privatekey() private_key new rsa failed, err:',
            log_param2 = err,
        }
        log_utils:error(tmp_log_tab)

        return
    end

    local encrypted, err = priv:encrypt(msg)
    if not encrypted then
        local tmp_log_tab = {
            log_param1 = 'rsa_utils.encrypt_with_privatekey() encrypt failed, err:',
            log_param2 = err,
        }
        log_utils:error(tmp_log_tab)

        return
    end
    
    encrypted = ngx.encode_base64(encrypted)
    
    return encrypted
end

--[[
-- 公钥解密
-- --]]
local function decrypt_with_publickey(pub_key, msg)
    if not pub_key then
        pub_key = PUBLIC_KEY
    end

    local pub, err = rsa:new({
        public_key = pub_key,
        key_type = rsa.KEY_TYPE.PKCS8,
        crypt = 'decrypt',})
    if not pub then
        local tmp_log_tab = {
            log_param1 = 'rsa_utils.decrypt_with_publickey() public_key new rsa failed, err:',
            log_param2 = err,
        }
        log_utils:error(tmp_log_tab)

        return
    end

    local decrypted, err = pub:decrypt(ngx.decode_base64(msg))
    if not decrypted then
        local tmp_log_tab = {
            log_param1 = 'rsa_utils.decrypt_with_publickey() failed, err:',
            log_param2 = err,
        }
        log_utils:error(tmp_log_tab)

        return
    end
    
    return decrypted
end

local rsa_utils = {
    encrypt = encrypt,
    decrypt = decrypt,
    encrypt_with_privatekey = encrypt_with_privatekey,
    decrypt_with_publickey = decrypt_with_publickey,
    escape = escape,
    unescape = unescape,
}

return rsa_utils
