--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 01/12/2017
-- Time: 10:25
-- To change this template use File | Settings | File Templates.
--
local _M = {}
local producer = require "resty.kafka.producer"

function _M.write_msg(self, logfile, msg)
    local fd = io.open(logfile, 'a+')
    if fd == nil then
        return
    end
    fd:write(msg)
    fd:flush()
    fd:close()
end

function _M.info(self, msg_tab)
    local msg = ''
    if msg_tab and typeof(msg_tab) == 'table' then
        local index = 0
        local c = 0
        for k in pairs(msg_tab) do
            k = tostring(k)
            index = ngx.re.find(k, '([0-9]+)', 'jo')
            local tmp_k = string.sub(k, index, #k)
            tmp_k = tonumber(tmp_k)
            if tmp_k then
                if c < tmp_k then
                    c = tmp_k
                end
            end
        end
        index = c
        for i = 1, index do
            local tmp_v = msg_tab['log_param' .. i]
            if string_utils:is_blank(tmp_v) then
                tmp_v = ''
            end

            msg = msg .. tmp_v
        end
    end

    if string_utils:is_blank(msg) then
        msg = ''
    end

    local realIp = (client_ip and { client_ip } or { '' })[1]
    local ua = (client_http_user_agent and { client_http_user_agent } or { '' })[1]
    local server_name = (server_name and { server_name } or { '' })[1]
    local time = ngx.localtime()
    local line
    if ua then
        line = time .. ' [' .. realIp .. '] ' .. 'INFO' .. ' ' .. ua .. ' ' .. server_name .. ' ' .. msg
    else
        line = time .. ' [' .. realIp .. '] ' .. 'INFO' .. ' ' .. server_name .. ' ' .. msg
    end

    if config_props.log_record_type_config.log_record_type == '01' then
        self:write_to_kafka('info', line)
    else
        line = line .. '\n'
        local filename = config_props.log_config_file.log_file_path .. config_props.log_config_file.info_log_name
        self:write_msg(filename, line)
    end
end

function _M.error(self, msg_tab)
    local msg = ''
    if msg_tab and typeof(msg_tab) == 'table' then
        local index = 0
        local c = 0
        for k in pairs(msg_tab) do
            k = tostring(k)
            index = ngx.re.find(k, '([0-9]+)', 'jo')
            local tmp_k = string.sub(k, index, #k)
            tmp_k = tonumber(tmp_k)
            if tmp_k then
                if c < tmp_k then
                    c = tmp_k
                end
            end
        end
        index = c
        for i = 1, index do
            local tmp_v = msg_tab['log_param' .. i]
            if string_utils:is_blank(tmp_v) then
                tmp_v = ''
            end

            msg = msg .. tmp_v
        end
    end

    if string_utils:is_blank(msg) then
        msg = ''
    end

    local realIp = (client_ip and { client_ip } or { '' })[1]
    local ua = (client_http_user_agent and { client_http_user_agent } or { '' })[1]
    local server_name = (server_name and { server_name } or { '' })[1]
    local time = ngx.localtime()
    local line
    if ua then
        line = time .. ' [' .. realIp .. '] ' .. 'INFO' .. ' ' .. ua .. ' ' .. server_name .. ' ' .. msg 
    else
        line = time .. ' [' .. realIp .. '] ' .. 'INFO' .. ' ' .. server_name .. ' ' .. msg 
    end

    if config_props.log_record_type_config.log_record_type == '01' then
        self:write_to_kafka('error', line)
    else
        line = line .. '\n'
        local filename = config_props.log_config_file.log_file_path .. config_props.log_config_file.error_log_name
        self:write_msg(filename, line)
    end
end

function _M:write_to_kafka(log_type, message)
    local broker_list = {
        {host = "132.46.115.98", port = 9081 },
    }

    local bp = producer:new(broker_list, { producer_type = 'async' })

    if string_utils:is_blank(log_type) then
        log_type = 'info'
    end

    local topic = 'mobloginTopicN'
    if string_utils:equals_ignore_case('error', log_type) then
        topic = 'mobloginTopicNErr'
    end

    local ok, err = bp:send(topic, nil, message)
    if err then
        ngx.log(ngx.ERR, 'kafka:', err)
        return
    end
end

return _M
