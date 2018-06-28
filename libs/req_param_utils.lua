--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 25/12/2017
-- Time: 10:59
-- To change this template use File | Settings | File Templates.
--
local _M = {}

function _M.get_login_req_params(self)
    local result_tab = {}
    local request_method = ngx.var.request_method
    local args
    if "GET" == request_method then
        args = ngx.req.get_uri_args()
    elseif "POST" == request_method then
        args = ngx.req.get_post_args()
    end

    for key, val in pairs(args) do
        if typeof(val) == 'string' then
            result_tab[key] = val
        end
    end

    local req_params = ngx.encode_args(result_tab)

    local tmp_log_tab = {
        log_param1 = 'login_req key:',
        log_param2 = req_params,
    }
    log_utils:info(tmp_log_tab)

    return result_tab
end

return _M