--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 20/11/2017
-- Time: 09:24
-- To change this template use File | Settings | File Templates.
--
local http = require "resty.http"

local red, httpc

local function OpSms(user_id)
    httpc = http.new()

    local request_uri = "http://10.143.131.53:11001/oauth2/OpSms"

    local param_table = {
        user_id = user_id,        
        app_code = 'ECS-YH',
        app_secret = 'kdgvy7WZTW5RMSKde93O3Z86',
        channel_code = '113000004',
        -- real_ip = '127.0.0.1',
        req_time = date_utils:get_current_timestamp(),
    }

    local request_params = ngx.encode_args(param_table)

    local res, err = httpc:request_uri(request_uri, {
        method = "POST",
        body = request_params,
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        }
    })

    return res.body
end

--[[
-- get new authenticate information
-- --]]
local function new_auth(user_id, user_pwd,user_type, pwd_type)
    httpc = http.new()

    local request_uri = "http://10.143.131.53:11001/oauth2/new_auth"

    if string_utils:is_blank(user_type) then user_type = '01' end

    if string_utils:is_blank(pwd_type) then pwd_type = '01' end

    local param_table = {
        --user_id = '15618385713',
        --user_id = '17611421727',
        --user_pwd = '211314',
        
        --验证省份为空的问题
        --user_id = '16604725070',
        --user_pwd = '302861',

        --验证pay_type 为 1 的用户(net_type == 11 and pay_type == 1 变成 pay_type = 2)
        --user_id = '15509608966',
        --user_pwd = '139741',

        --
        -- user_id = '17600265313',
        -- user_pwd = '090807',
        user_id = user_id,
        user_pwd = user_pwd,
        app_code = 'ECS-YH',
        app_secret = 'kdgvy7WZTW5RMSKde93O3Z86',
        display = 'native',
        redirect_uri = 'uop:oauth2.0:token',
        user_type = user_type,
        pwd_type = pwd_type,
        response_type = 'code',
        area_code = '010',
        req_time = date_utils:get_current_timestamp(),
    }

    local request_params = ngx.encode_args(param_table)

    local res, err = httpc:request_uri(request_uri, {
        method = "POST",
        body = request_params,
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        }
    })

    return res.body
end

--[[
-- get user information
-- --]]
local function get_user_info()
    httpc = http.new()
    local request_uri = "http://10.143.131.53:11001/oauth2/user_info"
    --red = connectRedisUtil.connectRedis()
    --
    --local userInfo, err = red:get("user_17611421727")
    --if not userInfo then
    --    ngx.say('get one bad redis cache : ', err)
    --    return
    --end
    --
    --local result = cjson.decode(userInfo)
    --local diffNum = os.difftime(date_utils:str_to_timestamp(result.invalid_at), date_utils:get_current_timestamp())
    --if diffNum <= 0 then
    --    --ngx.say('access_token is invalid')
    --
    --    --[[
    --    -- delete the invalid key
    --     ]]
    --    --local ok, err = red.del("user_17611421727")
    --    --if not ok then
    --    --    ngx.say('del failed : ', err)
    --    --    return
    --    --end
    --
    --    --[[
    --    -- as the access_token is invalid, so we try to get new one.
    --     ]]
    --    new_auth()
    --
    --    userInfo, err = red:get("user_17611421727")
    --    if not userInfo then
    --        ngx.say('get one bad redis cache : ', err)
    --        return
    --    end
    --end

    --local access_token = result.access_token;
    local access_token = 'lybzvd9if0a2388691970cc03fa127c29e5cc0defpxfajmc'

    local request_param_table = {
        app_code = "ECS-YH",
        app_secret = "kdgvy7WZTW5RMSKde93O3Z86",
        grant_type = "userinfo",
        access_token = access_token,
    }

    local request_params = ngx.encode_args(request_param_table)

    local res, err = httpc:request_uri(request_uri, {
        method = "POST",
        body = request_params,
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        }
    })

    if not res then
        ngx.say("failed to request: ", err)
        return
    end

    ngx.status = res.status

    return res.body
end

local http_authenticate = {
    new_auth = new_auth,
    getUserInfo = get_user_info,
    OpSms = OpSms,
}

return http_authenticate