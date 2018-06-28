--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 12/01/2018
-- Time: 10:30
-- To change this template use File | Settings | File Templates.
--

local _M = {}

function _M.get_client_ip(self)
    local IP = ngx.var.http_x_forwarded_for
    --IP  = ngx.var.remote_addr
    if IP == nil then
        IP = ngx.req.get_headers()["x-forwarded-for"]
    end
    if IP == nil then
        IP = "unknown"
    end
    return IP
end

return _M

