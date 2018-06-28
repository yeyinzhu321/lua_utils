--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 30/11/2017
-- Time: 10:28
-- To change this template use File | Settings | File Templates.
--
local _M = {}
local config = {
    name = config_props.redis_config.mobile_cluster_name, --rediscluster name
    serv_list = config_props.redis_config.mobile_cluster_config, --redis cluster node list(host and port),
    keepalive_timeout = config_props.redis_config.mobile_cluster_timeout, --redis connection pool idle timeout
    keepalive_cons = config_props.redis_config.mobile_cluster_keepalive_cons, --redis connection pool size
    connection_timout = config_props.redis_config.mobile_cluster_connection_timout, --timeout while connecting
    max_redirection = config_props.redis_config.mobile_cluster_max_redirection, --maximum retry attempts for redirection
}

function _M.new(self)
    self.red_c = rediscluster:new(config)
    return setmetatable(_M, {__index = self})
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
            if not err then err = '' end
            local tmp_log_tab = {
                log_param1 = 'redis_cluster_utils.set_val_by_key 有过期时间,发生异常',
                log_param2 = err
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
                log_param2 = err
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
                log_param2 = err
            }
            log_utils:error(tmp_log_tab)

            return false
        end
    end


    local ok, err = red:del(key)
    if not ok then
        local tmp_log_tab = {
            log_param1 = 'redis_cluster_utils.del_val_by_key 发生异常',
            log_param2 = err
        }
        log_utils:error(tmp_log_tab)

        return false
    end

    return true
end

return _M

