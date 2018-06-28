--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 01/12/2017
-- Time: 10:19
-- To change this template use File | Settings | File Templates.
--
local http = require 'resty.http'

local _M = {}
--[[
-- get 请求
-- --]]
function _M:get(url, path_prefix, params)
    local _httpc = http.new()
    local start_time = date_utils:get_current_timestamp_ms()
    _httpc:set_timeout(config_props.third_interface_http_config.http_timeout_ms)

    local request_params
    if typeof(params) == 'table' then
        request_params = ngx.encode_args(params)
    else
        request_params = nil
    end

    local path
    if not request_params then
        path = path_prefix
    else
        path = path_prefix .. '?' .. request_params
    end

    local res, err = _httpc:request_uri(url, {
        path = path
    })

    local tmp_log_tab = {
        log_param1 = 'http_utils.get(),url is:',
        log_param2 = url .. path_prefix .. '?' .. (request_params and { request_params } or { '' })[1],
        log_param3 = ',request_continue_time:',
        log_param4 = date_utils:get_current_timestamp_ms() - start_time,
        log_param5 = ',请求失败.'
    }

    if not res then
        log_utils:info(tmp_log_tab)
        return nil, err
    else
        tmp_log_tab.log_param5 = ',请求成功.'
        log_utils:info(tmp_log_tab)
        return res, ''
    end
end

--[[
-- post 请求
-- --]]
function _M:post(url, params)

    local start_time = date_utils:get_current_timestamp_ms()

    local _httpc = http.new()

    _httpc:set_timeout(config_props.third_interface_http_config.http_timeout_ms)

    local request_params
    if typeof(params) == 'table' then
        request_params = ngx.encode_args(params)
    else
        request_params = nil
    end

    local res, err = _httpc:request_uri(url, {
        method = 'POST',
        body = request_params,
        headers = {
            ['Content-Type'] = 'application/x-www-form-urlencoded',
        }
    })

    local tmp_log_tab = {
        log_param1 = 'http_utils.post(),url is:',
        log_param2 = url .. '?' .. (request_params and { request_params } or { '' })[1],
        log_param3 = ',request_continue_time:',
        log_param4 = date_utils:get_current_timestamp_ms() - start_time,
        log_param5 = ',请求失败.',
    }

    if not res then
        log_utils:info(tmp_log_tab)
        return nil, err
    else
        tmp_log_tab.log_param5 = ',请求成功.'
        log_utils:info(tmp_log_tab)
        return res, ''
    end
end

return _M