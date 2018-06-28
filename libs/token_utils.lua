--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 19/12/2017
-- Time: 15:54
-- To change this template use File | Settings | File Templates.
--
local jwt = require 'jwt'

local _M = {
    type = 'JWT',
    alg = 'HS512',
    randomStr = new_uuid:uuid(),
    key = '4b0d3f90bf029239b4f32saf57c2ab',
    exp = 604800,
}

function _M.new(self)
    return setmetatable(_M, { __index = self })
end

--[[
-- 生成 token
-- --]]
function _M.create_token(self, login_user)
    local tmp_str = 'yh' .. self.randomStr .. date_utils:get_current_timestamp()
    return jwt:sign(self.key, {
        header = { typ = self.type, alg = self.alg},
        payload = { token = {loginUser = login_user, randomStr = tmp_str}, iat = date_utils:get_current_timestamp(), exp = date_utils:get_current_timestamp() + self.exp}
    })
end

--[[
-- 解析 token
-- --]]
function _M.parse_token(self, token)
    return jwt:verify(self.key, token).payload.token
end

return _M



