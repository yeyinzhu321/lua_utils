--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 30/11/2017
-- Time: 10:28
-- To change this template use File | Settings | File Templates.
--
local redis = require 'resty.redis'
local _M = {}

function _M.new(self, redis_host, redis_port)
    if not redis_host and not redis_port then
        redis_host = config_props.redis_config.redis_host
        redis_port = config_props.redis_config.redis_port
    end

    _M.redis_host = redis_host
    _M.redis_port = redis_port

    return setmetatable(_M, { __index = self })
end

--[[
-- 获取 redis 连接
-- --]]
function _M.get_redis_conn(self, redis_host, redis_port)
    local red = redis:new()
    if not red then
        return nil, 'redis:new() err'
    end

    local ok, err = red:connect(redis_host, redis_port)
    if not ok then
        local tmp_log_tab = {
            log_param1 = '获取 redis 失败.',
        }
        log_utils:error(tmp_log_tab)

        return nil, err
    end

    return red, 'success'
end

function _M.get_val_by_key(self, key)
    local red = _M:connect_redis()
    if not red then
        local tmp_log_tab = {
            log_param1 = 'redis_utils.get_val_by_key redis connection failed.',
        }
        log_utils:error(tmp_log_tab)
        return nil
    end
    local res, err = red:get(key)
    if not res then
        local tmp_log_tab = {
            log_param1 = '获取 redis key 值出错:',
            log_param2 = err
        }
        log_utils:error(tmp_log_tab)

        local ok, err = red:set_keepalive(10000, 100)
        if not ok then
            local tmp_log_tab = {
                log_param1 = 'redis_utils.get_val_by_key failed to set keepalive:',
                log_param2 = err,
            }
            log_utils:error(tmp_log_tab)

            return
        end

        return nil
    end

    local ok, err = red:set_keepalive(10000, 100)

    if not ok then
        local tmp_log_tab = {
            log_param1 = 'redis_utils.get_val_by_key failed to set keepalive:',
            log_param2 = err,
        }
        log_utils:error(tmp_log_tab)

        return
    end

    if typeof(res) == 'userdata' then
        return nil
    elseif typeof(res) == 'string' then
        return res
    elseif typeof(res) == 'table' then
        return cjson.encode(res)
    else
        return res
    end
end

function _M.connect_redis(self)
    local red = redis:new()
    if not red then
        local tmp_log_tab = {
            log_param1 = '获取 redis 失败.',
        }
        log_utils:error(tmp_log_tab)

        return nil
    end

    local ok, err = red:connect(self.redis_host, self.redis_port)
    if not ok then
        ngx.say("failed to connect: ", err)
        return nil
    end

    return red
end

--[[
-- redis 设置值(如果没有 expire_time,不传即可)
-- --]]
function _M.set_val_by_key(self, key, value, expire_time)
    local red = _M:connect_redis()
    if not red then
        local tmp_log_tab = {
            log_param1 = 'redis_utils.set_val_by_key redis connection failed.',
        }
        log_utils:error(tmp_log_tab)

        return nil
    end
    if expire_time and expire_time ~= '' then
        local ok, err = red:set(key, value)
        if not ok then
            if not err then err = '' end
            local tmp_log_tab = {
                log_param1 = 'redis_utils.set_val_by_key 有过期时间,发生异常',
                log_param2 = err,
            }
            log_utils:error(tmp_log_tab)

            local ok, err = red:set_keepalive(10000, 100)
            if not ok then
                local tmp_log_tab = {
                    log_param1 = 'redis_utils.get_val_by_key failed to set keepalive:',
                    log_param2 = err,
                }
                log_utils:error(tmp_log_tab)

                return
            end
            return false
        end

        red:expire(key, expire_time)
    else
        local ok, err = red:set(key, value)
        if not ok then
            local tmp_log_tab = {
                log_param1 = 'redis_utils.set_val_by_key 发生异常:',
                log_param2 = err,
            }
            log_utils:error(tmp_log_tab)

            local ok, err = red:set_keepalive(10000, 100)
            if not ok then
                local tmp_log_tab = {
                    log_param1 = 'redis_utils.get_val_by_key failed to set keepalive:',
                    log_param2 = err,
                }
                log_utils:error(tmp_log_tab)

                return
            end
            return false
        end
    end

    local ok, err = red:set_keepalive(10000, 100)
    if not ok then
        local tmp_log_tab = {
            log_param1 = 'redis_utils.get_val_by_key failed to set keepalive:',
            log_param2 = err,
        }
        log_utils:error(tmp_log_tab)

        return
    end
    return true
end

return _M