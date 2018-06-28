--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 30/11/2017
-- Time: 10:28
-- To change this template use File | Settings | File Templates.
--
local _M = {}
local config = {
    name = config_props.redis_config.exception_cluster_name, --rediscluster name
    serv_list = config_props.redis_config.mobile_cluster_config, --redis cluster node list(host and port),
    keepalive_timeout = config_props.redis_config.exception_cluster_timeout, --redis connection pool idle timeout
    keepalive_cons = config_props.redis_config.exception_cluster_keepalive_cons, --redis connection pool size
    connection_timout = config_props.redis_config.exception_cluster_connection_timout, --timeout while connecting
    max_redirection = config_props.redis_config.exception_cluster_max_redirection, --maximum retry attempts for redirection
}

local un_config = {
    name = config_props.un_exception_message_config.exception_message_config.mobile_cluster_name, --rediscluster name
    serv_list = config_props.un_exception_message_config.exception_message_config.mobile_cluster_config, --redis cluster node list(host and port),
    keepalive_timeout = config_props.un_exception_message_config.exception_message_config.mobile_cluster_keepalive_timeout, --redis connection pool idle timeout
    keepalive_cons = config_props.un_exception_message_config.exception_message_config.mobile_cluster_keepalive_cons, --redis connection pool size
    connection_timout = config_props.un_exception_message_config.exception_message_config.mobile_cluster_connection_timout, --timeout while connecting
    max_redirection = config_props.un_exception_message_config.exception_message_config.mobile_cluster_max_redirection, --maximum retry attempts for redirection
}

function _M.new(self)
    if config_props.exception_message_switch == 'un' then
        self.red_c = rediscluster:new(un_config)
    else
        self.red_c = rediscluster:new(config)
    end
    return setmetatable(_M, { __index = self })
end

--[[
-- 获取 redis 连接
-- --]]
function _M.get_redis_conn(self)
    if not self.red_c then
        self:new()
    end

    return self.red_c
end

function _M.get_val_by_key(self, key)
    local red = self.red_c
    if not red then
        self:new()
        red = self.red_c
        if not red then
            local tmp_log_tab = {
                log_param1 = '获取 redis 失败.',
            }
            log_utils:error(tmp_log_tab)

            return nil
        end
    end

    local res, err = red:get(key)
    if not res then
        local tmp_log_tab = {
            log_param1 = '获取 redis key 值出错:',
            log_param2 = err
        }
        log_utils:error(tmp_log_tab)

        return nil
    end

    if typeof(res) == 'userdata' then
        return nil
    end

    if typeof(res) == 'string' then
        return res
    end

    if typeof(res) == 'table' then
        return cjson.decode(res)
    end
end

--[[
-- redis 设置值(如果没有 expire_time,不传即可)
-- --]]
function _M.set_val_by_key(self, key, value, expire_time)
    local red = self.red_c
    if not red then
        self:new()
        red = self.red_c
        if not red then
            local tmp_log_tab = {
                log_param1 = '获取 redis 失败.',
            }
            log_utils:error(tmp_log_tab)

            return nil
        end
    end

    if expire_time and expire_time ~= '' then
        local ok, err = red:set(key, value)
        if not ok then
            if not err then
                err = ''
            end

            local tmp_log_tab = {
                log_param1 = 'redis_cluster_utils.set_val_by_key 有过期时间,发生异常:',
                log_param2 = err,
            }
            log_utils:error(tmp_log_tab)

            return false
        end

        red:expire(key, expire_time)
    else
        local ok, err = red:set(key, value)
        if not ok then
            local tmp_log_tab = {
                log_param1 = 'redis_cluster_utils.set_val_by_key 发生异常:',
                log_param2 = err,
            }
            log_utils:error(tmp_log_tab)

            return false
        end
    end

    return true
end

--[[
-- delete key
--]]
function _M.del_val_by_key(self, key)
    local red = self.red_c
    if not red then
        self:new()
        red = self.red_c
        if not red then
            local tmp_log_tab = {
                log_param1 = '获取 redis 失败.',
            }
            log_utils:error(tmp_log_tab)

            return false
        end
    end

    local ok, err = red:del(key)
    if not ok then
        local tmp_log_tab = {
            log_param1 = 'redis_cluster_utils.del_val_by_key 发生异常:',
            log_param2 = err,
        }
        log_utils:error(tmp_log_tab)

        return false
    end

    return true
end

--[[
-- appId 用于获取 exception msg
-- --]]
function _M.get_exception_message(self, mobile, exception_code, channel_code, business_code, interface_code)
    exception_code = string_utils:get_default_val(exception_code)
    channel_code = string_utils:get_default_val(channel_code)
    business_code = string_utils:get_default_val(business_code)
    interface_code = string_utils:get_default_val(interface_code)

    local key
    if string_utils:not_equals(exception_code, '0000') then
        if string_utils:equals(exception_code, '7007') then
            if string_utils:contains(exception_code, '@') then
                exception_code = '70071'
            else
                exception_code = '70072'
            end
        end
    end

    if string_utils:is_blank(channel_code) then
        channel_code = ''
    end

    local message
    key = business_code .. '_' .. channel_code .. '_' .. interface_code .. '_' .. exception_code

    local tmp_message_json = exception_message_json:get('errormessage')
    if tmp_message_json then
        message = tmp_message_json[key]
    else
        local tmp_message = self:get_val_by_key('errormessage')
        if typeof(tmp_message) == 'string' then
            local tmp_tab = cjson.decode(tmp_message)
            exception_message_json:set('errormessage', tmp_tab)

            message = (tmp_tab[key] and { tmp_tab[key] } or { '' })[1]
        end

        if typeof(tmp_message) == 'table' then
            exception_message_json:set('errormessage', tmp_message)

            message = (tmp_message[key] and { tmp_message[key] } or { '' })[1]
        end
    end

    message = string_utils:get_default_val(message)

    return message
end


--[[
-- appId 用于获取 exception msg
--]]
function _M.un_get_exception_message(self, mobile, exception_code, channel_code, business_code, interface_code)
    exception_code = string_utils:get_default_val(exception_code)
    channel_code = string_utils:get_default_val(channel_code)
    business_code = string_utils:get_default_val(business_code)
    interface_code = string_utils:get_default_val(interface_code)

    local key
    if string_utils:not_equals(exception_code, '0000') then
        if string_utils:equals(exception_code, '7007') then
            if string_utils:contains(exception_code, '@') then
                exception_code = '70071'
            else
                exception_code = '70072'
            end
        end
    end

    if string_utils:is_blank(channel_code) then
        channel_code = ''
    end

    if config_props.exception_message_switch == 'un' then
        local message
        key = channel_code .. '_' .. business_code .. '_' .. interface_code .. '_' .. exception_code

        local exception_message_server = config_props.un_exception_message_config.exception_message_config.mobile_cluster_config
        local redis_host = exception_message_server[1].ip
        local redis_port = exception_message_server[1].port

        if string_utils:is_blank(redis_host) then redis_host = '127.0.0.1' end
        if string_utils:is_blank(redis_port) then redis_port = 6378 end

        local red_conn, get_message = redis_utils:get_redis_conn(redis_host, redis_port)
        if not red_conn then
            local tmp_log_tab = {
                log_param1 = 'exception_redis_cluster_utils 调用 redis_utils get_redis_conn() 失败:',
                log_param2 = get_message,
            }
            log_utils:error(tmp_log_tab)
        end

        local tmp_message = red_conn:hget('exception_redis', key)

        if typeof(tmp_message) == 'string' then
            local tmp_tab = cjson.decode(tmp_message)

            message = (tmp_tab.exceptionContent and { tmp_tab.exceptionContent } or { '' })[1]
        end

        if typeof(tmp_message) == 'table' then
            message = (tmp_message.exceptionContent and { tmp_message.exceptionContent } or { '' })[1]
        end

        message = string_utils:get_default_val(message)

        --red_conn:se
        local ok, err = red_conn:set_keepalive(10000, 100)
        if not ok then
            local tmp_log_tab = {
                log_param1 = 'exception_redis_cluster_utils failed to set keepalive:',
                log_param2 = err,
            }
            log_utils:error(tmp_log_tab)

            return
        end

        return message
    else
        local message
        key = business_code .. '_' .. channel_code .. '_' .. interface_code .. '_' .. exception_code

        local tmp_message_json = exception_message_json:get('errormessage')
        if tmp_message_json then
            message = tmp_message_json[key]
        else
            local tmp_message = self:get_val_by_key('errormessage')
            if typeof(tmp_message) == 'string' then
                local tmp_tab = cjson.decode(tmp_message)
                exception_message_json:set('errormessage', tmp_tab)

                message = (tmp_tab[key] and { tmp_tab[key] } or { '' })[1]
            end

            if typeof(tmp_message) == 'table' then
                exception_message_json:set('errormessage', tmp_message)

                message = (tmp_message[key] and { tmp_message[key] } or { '' })[1]
            end
        end

        message = string_utils:get_default_val(message)

        return message
    end
end

return _M

