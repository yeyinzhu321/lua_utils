--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 15/12/2017
-- Time: 10:59
-- To change this template use File | Settings | File Templates.
--
local ck = require 'resty.cookie'
local cookie = ck:new()
local _M = {}

function _M.add_cookie(self, key, value)
    local ok, err = cookie:set({
        key = key,
        value = value,
        --path = "/",
        --secure = true,
        --httponly = true,
        --max_age = -1
    })

    if not ok then
        local tmp_log_tab = {
            log_param1 = 'cookie_utils.add_cookie() occur exception：',
            log_param2 = err,
        }
        log_utils:error(tmp_log_tab)
        return false
    end

    return true
end

function _M.add_cookie_with_domain(self, key, value, domain)
    local ok, err = cookie:set({
        key = key,
        value = value,
        --path = "/",
        domain = domain,
        --secure = true,
        --httponly = true,
        --max_age = -1
    })

    if not ok then
        local tmp_log_tab = {
            log_param1 = 'cookie_utils.add_cookie_with_domain() occur exception：',
            log_param2 = err,
        }
        log_utils:error(tmp_log_tab)

        return false
    end

    return true
end

return _M
