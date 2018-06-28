--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 02/01/2018
-- Time: 11:33
-- To change this template use File | Settings | File Templates.
--
local producer = require 'resty.kafka.producer'

local _M = {}

local broker_list = {
    { host = '127.0.0.1', port = 9092 },
}

function _M.new(self,sync_type)
    local bp = producer:new(broker_list, { producer_type = sync_type })

    return setmetatable({producer = bp}, {__index = self})
end

function _M.send(self,topic,message_key, msg)
    local realIp = config_props.log_config_file.log_ip
    local ua = ngx.var.http_user_agent
    local servername = ngx.var.server_name
    local time = ngx.localtime()

    local line
    if ua then
        line = time .. ' [' .. realIp .. '] ' .. 'INFO' .. ' ' .. ua .. ' ' .. servername .. ' ' .. msg .. '\n'
    else
        line = time .. ' [' .. realIp .. '] ' .. 'INFO' .. ' ' .. servername .. ' ' .. msg .. '\n'
    end

    local producer = self.producer

    if not producer then
        producer = self:new('async')
    end

    if producer then
        producer:send(topic,message_key, line)
    end
end

return _M