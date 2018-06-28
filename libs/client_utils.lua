--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 29/11/2017
-- Time: 15:02
-- To change this template use File | Settings | File Templates.
--
local authenticate_utils = require 'authenticate_utils'
local exception_redis_cluster_utils = require 'exception_redis_cluster_utils'
local rsa_utils = require 'rsa_utils'
local aes_utils = require 'aes_utils'

local _M = {}

--[[
-- validate version,if it is valid or not
--]]
function _M.is_version_error(self, is_remember_pwd, keyVersion)
    --秘钥版本为空，不做判断
    if (string_utils:is_blank(keyVersion)) then
        return false
    end

    --自动登录情况下，如果秘钥版本不为空，且版本不对，返回true
    if is_remember_pwd == 'true' and keyVersion ~= '1' then
        return true
    end

    return false
end

--[[
-- 判断版本是不是在 5.6 之后
--]]
function _M.is_after_5_6(self, version)
    return version_utils.is_after_iphone5_6(version) or version_utils.is_after_android5_6(version)
end

--[[
-- 判断版本是不是在 4 之后
--]]
function _M.is_after4(self, version)
    return version_utils.is_after_iphone4_0(version) or version_utils.is_after_android4_0(version)
end

--[[
-- 解密密码
-- --]]
function _M.decrypt_password(self, version, password, isRemberedPwd, keyVersion)
    --1)、解密密码
    --然后密码判断
    --2)、简单密码过滤
    --3)、密码防暴力拦截

    if self:is_version_error(isRemberedPwd, keyVersion) then
        return nil
    end

    if string_utils:is_blank(password) then
        return nil
    end

    local result = ''
    --5.6版本上线修改加密方式为rsa加密
    if self:is_after_5_6(version) then
        local tmp_pwd = password
        result = rsa_utils.decrypt(password)
        --对于自动更新客户端用户，客户端保存的密码为旧的对称加密密码，需要尝试旧的解密方式
        if string_utils:is_blank(result) then
            result = aes_utils.decrypt_fun(password)
        end
        if result then
            local tmp_ip = client_ip
            if not tmp_ip then
                tmp_ip = ''
            end
            --ngx.log(ngx.ERR, 'client_ip_is:', tmp_ip, 'dec_wd_is:', result, '::', #tostring(result), '===enc_pwd:', tmp_pwd)
        end
    else
        result = aes_utils.decrypt_fun(password)
    end

    if string_utils:is_blank(result) then
        return nil
    end

    --对于4.0以后的版本 密码后加了6位随机数
    --if result and #result >= 12 then
    --    result = string.sub(result, 1, #result - 6)
    --end
    if result and #result >= 12 then
        result = string.sub(result, 1, 6)
    end

    if result and #result > 6 then
        result = string.sub(result, 1, 6)
    end

    return result
end

--[[
-- 解密用户名
-- --]]
function _M.decrypt_mobile(self, version, mobile_no)
    local result = {
        original_mobile = '',
        random_str = ''
    }

    local original_mobile, random_str, tmp_str
    if self:is_after_5_6(version) then
        tmp_str = rsa_utils.decrypt(mobile_no)
        if string_utils:is_blank(tmp_str) then
            tmp_str = aes_utils.decrypt_fun(mobile_no)
        end

        random_str = tmp_str
        if (#tmp_str > 11) then
            original_mobile = string.reverse(string.sub(string.reverse(tmp_str), 7, #tmp_str))
        else
            original_mobile = tmp_str
        end
    else
        tmp_str = aes_utils.decrypt_fun(mobile_no)

        random_str = tmp_str
        if self:is_after4(version) then
            if (#tmp_str > 11) then
                original_mobile = string.reverse(string.sub(string.reverse(tmp_str), 7, #tmp_str))
            else
                original_mobile = tmp_str
            end
        end
    end

    result.original_mobile = original_mobile
    result.random_str = random_str

    return result
end

--[[
-- 获取 channel code
-- --]]
function _M.get_channel(self, version)
    if string_utils:is_blank(version) then
        return '113000001'
    end

    if string_utils:equals_ignore_case('iphone_c', string_utils:split(version, '@')[1]) then
        return '113000004'
    elseif string_utils:equals_ignore_case('android', string_utils:split(version, '@')[1]) then
        return '113000005'
    else
        return '113000001'
    end
end

--[[
-- 判断设备型号
--]]
function _M.judge_deviceId_size(self, client_type, deviceId)
    local is_deviceId_size = false

    if string_utils:is_blank(client_type) or string_utils:is_blank(deviceId) then
        return is_deviceId_size
    end
    if typeof(deviceId) ~= 'string' then
        deviceId = tostring(deviceId)
    end

    local device_size = #deviceId
    if string_utils:equals_ignore_case(client_type, 'iphone_c') then
        if device_size == 64 then
            is_deviceId_size = true
        end
    elseif string_utils:equals_ignore_case(client_type, 'android') then
        is_deviceId_size = true
    else
        is_deviceId_size = false
    end

    return is_deviceId_size
end

--[[
-- 判断传递参数
-- --]]
function _M.judge_client_push_param(self, deviceId, client_type, client_version, mobile)
    if not mobile then
        mobile = ''
    end
    if not deviceId then
        deviceId = ''
    end
    if not client_type then
        client_type = ''
    end
    if not client_version then
        client_version = ''
    end

    local tmp_log_tab = {
        log_param1 = '得到手机号码：{',
        log_param2 = mobile,
        log_param3 = '}，客户端类型：{',
        log_param4 = client_type,
        log_param5 = '}，客户端版本号：{',
        log_param6 = client_version,
        log_param7 = '}，客户端设备号{',
        log_param8 = deviceId,
    }
    log_utils:info(tmp_log_tab)

    if string_utils:is_blank(deviceId) then
        local tmp_log_tab = {
            log_param1 = mobile,
            log_param2 = '||客户端推送中转入的手机设备号出现问题了',
        }
        log_utils:error(tmp_log_tab)

        return false
    elseif not self:judge_deviceId_size(client_type, deviceId) then
        local tmp_log_tab = {
            log_param1 = mobile,
            log_param2 = '||客户端推送中转入的客户端类型出现问题或者设备号出现问题了',
        }
        log_utils:error(tmp_log_tab)

        return false
    elseif string_utils:is_blank(client_version) then
        local tmp_log_tab = {
            log_param1 = mobile,
            log_param2 = '||客户端推送中转入的客户端版本号出现问题',
        }
        log_utils:error(tmp_log_tab)

        return false
    end

    return true
end

--[[
-- 推送参数封装
-- --]]
function _M.client_push_param(self, deviceId, client_type, client_version, user_info_bean,
                              device_model, push_platform, platform_token)
    local push_req = {}
    local req_head = {}
    local req_body = {}

    req_head.procId = config_props.client_push.procId .. uuid_utils:new('32'):uuid()
    req_head.srcCode = config_props.client_push.srcCode

    local index = math.random(config_props.client_push.aesIndex)
    local tmp_aes_str = config_props.aes_str['AES' .. index]
    if not tmp_aes_str then
        index = math.random(config_props.client_push.aesIndex)
        tmp_aes_str = config_props.aes_str['AES' .. index]

        if not tmp_aes_str then
            tmp_aes_str = 'wrong number!'
        end
    end

    local tmp_str = config_props.client_push.srcCode .. tmp_aes_str
    local str1 = aes_utils.encrypt_fun_with_key_iv(tmp_str, '6206c34e2186e752c74e6df32ab8fa5b', '00e5d201c2c2acbff8154861242ba0c4')
    req_head.aesStr = str1
    req_head.aesIndex = index .. ''
    req_head.bipCode = config_props.client_push.clientPushOperation

    push_req.reqHead = req_head

    req_body.deviceId = deviceId
    req_body.phoneModel = device_model
    req_body.pushPlatform = push_platform
    req_body.platformToken = platform_token

    if string_utils:equals_ignore_case(client_type, 'iphone_c') then
        client_type = 'iphone'
    end

    req_body.clientType = string.lower(client_type)
    req_body.clientVersion = client_version

    if user_info_bean then
        local user_info = {}
        user_info.provinceCode = user_info_bean.province_code -- 省份编码
        user_info.provinceName = user_info_bean.province_name -- 省份名称
        user_info.cityCode = user_info_bean.city_code -- 地市编码
        user_info.cityName = user_info_bean.city_name -- 地市名称
        user_info.netType = user_info_bean.netType -- 网别
        user_info.payType = user_info_bean.payType -- 付费类型
        user_info.userMobile = user_info_bean.user_mobile -- 手机号码
        user_info.brand = user_info_bean.brand -- 品牌
        user_info.familyNumber = user_info_bean.familyNumber -- 是否为沃家庭
        user_info.openDate = user_info_bean.open_date-- 入网时间
        user_info.billingType = user_info_bean.billingType-- 计费类型
        user_info.vipLev = user_info_bean.vipLev-- VIP级别
        user_info.userType = user_info_bean.userType-- 用户类型
        user_info.ocsflag = user_info_bean.ocsflag-- OCS用户标记
        user_info.woisflag = user_info_bean.woisflag -- 是否为沃家庭

        req_body.userInfo = user_info
    end

    push_req.reqBody = req_body

    return cjson.encode(push_req)
end

function _M.tmp_push_server(premature, user_info_bean, version, deviceId, device_model, push_platform, platform_token)
    _M:push_server(user_info_bean, version, deviceId, device_model, push_platform, platform_token)
end

--[[
-- 推送服务调用
-- --]]
function _M.push_server(self, user_info_bean, version, deviceId, device_model, push_platform, platform_token)
    if user_info_bean.login_type == '05' then
        return
    end
    local redis_host, redis_port

    local random_num = math.random(1, 2)
    if not random_num then
        random_num = 1
    end
    local push_redis_config = config_props.redis_config.exception_cluster_config1[random_num]
    redis_port = push_redis_config.redis_port
    redis_host = push_redis_config.redis_host

    if string_utils:is_blank(redis_host) then
        if config_props.active_env == 'pro' then
            redis_host = '132.38.1.229'
        else
            redis_host = '10.20.34.16'
        end
    end

    if string_utils:is_blank(redis_port) then
        redis_port = 6379
    end

    local red_conn, get_message = redis_utils:get_redis_conn(redis_host, redis_port)
    if not red_conn then
        local tmp_log_tab = {
            log_param1 = 'client_utils 调用 redis_utils get_redis_conn() 失败:',
            log_param2 = get_message,
        }
        log_utils:error(tmp_log_tab)
    end

    local mobile = user_info_bean.user_mobile

    if not platform_token then
        platform_token = ''
    end
    if not push_platform then
        push_platform = ''
    end
    if not device_model then
        device_model = ''
    end
    if not deviceId then
        deviceId = ''
    end

    if string_utils:is_not_blank(version) then
        local tmp_log_tab = {
            log_param1 = '得到deviceId值：{',
            log_param2 = deviceId,
            log_param3 = '}，手机号码：{',
            log_param4 = mobile,
            log_param5 = '}，手机版本号：{',
            log_param6 = version,
            log_param7 = '}，手机设备型号{',
            log_param8 = device_model,
            log_param9 = '},推送平台{',
            log_param10 = '},推送平台唯一标识{',
            log_param11 = platform_token,
            log_param12 = '}',
        }
        log_utils:info(tmp_log_tab)

        local version_terminal, version_number
        local version_tab = string_utils:split(version, '@')
        version_terminal = version_tab[1]
        version_number = version_tab[2]

        -- 执行客户端推送(入队操作)
        local tmp_log_tab = {
            log_param1 = mobile,
            log_param2 = '||客户端推送中单业务推送相关'
        }
        log_utils:info(tmp_log_tab)

        local str
        if self:judge_client_push_param(deviceId, version_terminal, version_number, mobile) then
            str = self:client_push_param(deviceId, version_terminal, version_number, user_info_bean, device_model, push_platform, platform_token)

            local tmp_log_tab = {
                log_param1 = mobile,
                log_param2 = '||推送服务绑定内容打印：',
                log_param3 = str
            }
            log_utils:info(tmp_log_tab)

            local start_time = date_utils:get_current_timestamp()
            if string_utils:is_not_blank(str) then
                red_conn:lpush(config_props.client_push.PUSH_SERVICE_QUEUE, str)

                local tmp_log_tab = {
                    log_param1 = mobile,
                    log_param2 = '||推送信息入redis耗时：',
                    log_param3 = (date_utils:get_current_timestamp() - start_time),
                    log_param4 = 'ms'
                }
                log_utils:info(tmp_log_tab)
            end
        end

        local ok, err = red_conn:set_keepalive(10000, 100)
        if not ok then
            local tmp_log_tab = {
                log_param1 = 'client_utils failed to set keepalive:',
                log_param2 = err,
            }
            log_utils:error(tmp_log_tab)

        end
    end
end

function _M.tmp_refresh_access_token_and_set_cache(premature, user_info_bean_from_cache, mobile, password, version, isRemberedPwd, keyVersion, decrypt_mobile, login_type)
    _M:refresh_access_token_and_set_cache(user_info_bean_from_cache, mobile, password, version, isRemberedPwd, keyVersion, decrypt_mobile, login_type)
end

--[[
-- refresh access_token,set user info for redis
--]]
function _M.refresh_access_token_and_set_cache(self, user_info_bean_from_cache, mobile, password, version, isRemberedPwd, keyVersion, decrypt_mobile, login_type)
    local user_info_from_cache
    local channel_code = self:get_channel(version)
    local new_refresh_token = authenticate_utils:refresh_access_token(user_info_bean_from_cache, channel_code)
    if not new_refresh_token then
        local tmp_log_tab = {
            log_param1 = 'client_utils.get_response 获取缓存,access_token 即将过期,refresh_token 未失效,刷新 access_token 失败',
        }

        log_utils:info(tmp_log_tab)
    else
        if new_refresh_token.rsp_code == '0000' then
            --[[
            -- 刷新成功,更新 redis 缓存
            -- --]]
            user_info_from_cache = authenticate_utils:package_redis_cache_user_info(new_refresh_token, mobile, password, version, isRemberedPwd, keyVersion,
                    decrypt_mobile, login_type)

            --[[
            -- redis 设置缓存 LA:手机号
            -- --]]
            if user_info_bean_from_cache then
                if cjson and cjson.encode_empty_table_as_object then
                    cjson.encode_empty_table_as_object(false)
                end

                local set_cache_flag = redis_cluster_utils:set_val_by_key('LA:' .. decrypt_mobile, cjson.encode(user_info_from_cache))
                if not set_cache_flag then
                    local tmp_log_tab = {
                        log_param1 = 'client_utils.get_response 刷新 access_token 成功，设置缓存失败,登录账号:',
                        log_param2 = decrypt_mobile,
                    }
                    log_utils:info(tmp_log_tab)
                end
            end
        end
    end

    return user_info_from_cache
end

function _M.tmp_authenticate_request(premature, userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
                                     isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type, deviceOS)
    _M:authenticate_request(userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
            isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type, deviceOS)
end

--[[
-- request authenticate to acquire user data
--]]
function _M.authenticate_request(self, userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
                                 isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type, deviceOS)
    local authenticate_start_time = date_utils:get_current_timestamp_ms()
    local result_json = {}

    local result_flag = true
    local param_deviceOS = ''
    if string_utils:contains(version, '') then
        param_deviceOS = 'ios' .. (deviceOS and { deviceOS } or { '' })[1]
    else
        param_deviceOS = (deviceOS and { deviceOS } or { '' })[1]
    end

    if decrypt_password and typeof(decrypt_password) == 'string' and #decrypt_password > 6 then
        decrypt_password = string.sub(decrypt_password, 1, 6)
    end

    --01（手机）、02（固话）、03（宽带）、05（注册用户）、08（小灵通）
    if string_utils:is_blank(userType) then
        local mobile_match = string.match(decrypt_mobile, '^%d+$')
        if mobile_match then
            if string.len(decrypt_mobile) == 11 then
                userType = '01'
            end
        else
            local reg_str = [[^.{3,}@(?:[a-z0-9](?:[-]?[a-z0-9]+)*\.){1,3}(?:com|org|edu|net|gov|cn|hk|tw|jp|de|uk|fr|mo|eu|sg|kr)$]]
            local match_flag = ngx.re.find(decrypt_mobile, reg_str, 'jo')
            if match_flag then
                userType = '05'
            end
        end
    end

    local post_params = {
        app_code = config_props.authenticate_config.app_code,
        app_secret = config_props.authenticate_config.app_secret,
        real_ip = client_ip,
        channel_code = channel_code,
        user_id = decrypt_mobile,
        user_pwd = decrypt_password,
        display = 'native',
        redirect_uri = config_props.authenticate_config.redirect_url,
        response_type = 'code',
        user_type = userType,
        query_path = 'new_auth',
        area_code = areaCode,
        req_time = date_utils:get_current_timestamp(),
        browser = version,
        operation = param_deviceOS,
    }

    if string_utils:contains(ngx.ctx.request_uri, 'radomLogin') then
        post_params.pwd_type = '02'
    end

    --local tmp_tab = {
    --    log_param1 = 'request authenticate params are:',
    --    log_param2 = decrypt_mobile .. ',',
    --    log_param3 = decrypt_password,
    --}
    --log_utils:info(tmp_tab)

    if post_params.userType == '03' or post_params.userType == '04' then
        post_params.userType = '03'
    end

    if string_utils:is_blank(post_params.userType) then
        local match_flag = ngx.re.find(mobile, '[0-9]+', 'jo')
        if match_flag then
            post_params.userType = '01'
        else
            post_params.userType = '05'
        end
    end

    local post_uri = config_props.authenticate_config.url_pre_fix .. config_props.authenticate_config.url_suffix .. post_params.query_path

    local retry = 0
    local post_result
    local resp_result
    local err
    while (retry < config_props.authenticate_config.retry_time)
    do
        if retry > 0 then
            local tmp_log_tab = {
                log_param1 = '登录用户 ',
                log_param2 = decrypt_mobile,
                log_param3 = ' 认证接口失败后开始重试-第 ',
                log_param4 = retry,
                log_param5 = ' 次 ',
            }
            log_utils:error(tmp_log_tab)
        end

        local tmp_log_tab = {
            log_param1 = '登录用户 ',
            log_param2 = decrypt_mobile,
            log_param3 = ' ' .. date_utils:date_to_string('yyyy-MM-dd HH:mm:ss'),
            log_param4 = ' 请求认证 new_auth 开始.',
        }
        log_utils:info(tmp_log_tab)

        post_result, err = http_utils:post(post_uri, post_params)

        if post_result then
            local tmp_log_tab = {
                log_param1 = '登录用户 ',
                log_param2 = decrypt_mobile,
                log_param3 = '调用认证请求返回的数据为:',
                log_param4 = tostring(post_result.body)
            }
            log_utils:info(tmp_log_tab)

            resp_result = cjson.decode(post_result.body)
            if resp_result.rsp_code ~= '0000' then
                --local tmp_log_tab = {
                --    log_param1 = '登录用户 ',
                --    log_param2 = decrypt_mobile .. ',',
                --    log_param3 = result_err_code_utils:get_val_by_code(resp_result.rsp_code),
                --    log_param4 = '[错误码:',
                --    log_param5 = resp_result.rsp_code,
                --    log_param6 = ']',
                --}
                --log_utils:error(tmp_log_tab)
            else
                break
            end
        end

        retry = retry + 1
    end

    local tmp_log_tab = {
        log_param1 = '登录用户 ',
        log_param2 = decrypt_mobile,
        log_param3 = ' ' .. date_utils:date_to_string('yyyy-MM-dd HH:mm:ss'),
        log_param4 = ' 请求认证 new_auth 结束.',
    }
    log_utils:info(tmp_log_tab)

    --ngx.var.kafka_login_DUTATION_TIME = log_msg_tab.log_param2 -- (认证调用时长)

    if not post_result then
        local tmp_log_tab = {
            log_param1 = '登录用户 ',
            log_param2 = decrypt_mobile .. ',',
            log_param3 = ' 请求失败,',
            log_param4 = err,
        }
        log_utils:error(tmp_log_tab)

        result_json.code = '2'
        result_json.dsc = exception_redis_cluster_utils:un_get_exception_message(decrypt_mobile, '5555', channel_code, business_code, interface_code)

        ngx.ctx.kafka_login_INTERFACE_FAIL_ID = '5555'
        ngx.ctx.kafka_login_FAIL_RESON = '认证异常，请求返回失败'

        return result_flag, result_json
    else
        if resp_result.rsp_code ~= '0000' then
            local tmp_log_tab = {
                log_param1 = '登录用户 ',
                log_param2 = decrypt_mobile .. ',',
                log_param3 = exception_redis_cluster_utils:un_get_exception_message(decrypt_mobile, resp_result.rsp_code, channel_code, business_code, interface_code),
                log_param4 = '[错误码:',
                log_param5 = resp_result.rsp_code,
                log_param6 = ']',
            }
            log_utils:error(tmp_log_tab)

            --if string_utils:contains(resp_result.rsp_code, '7007') or string_utils:contains(resp_result.rsp_code, '7008') then
            --    result_json.code = '2'
            --    result_json.dsc = result_err_code_utils:get_val_by_code(resp_result.rsp_code)
            --elseif string_utils:is_not_blank(config_props.ecs_error_code[resp_result.rsp_code]) then
            --    result_json.code = '1'
            --    result_json.dsc = exception_redis_cluster_utils:un_get_exception_message(decrypt_mobile, resp_result.rsp_code, channel_code, business_code, interface_code)
            --else
            --    result_json.code = '1'
            --    result_json.dsc = exception_redis_cluster_utils:un_get_exception_message(decrypt_mobile, resp_result.rsp_code, channel_code, business_code, interface_code)
            --end
            result_json.code = '1'
            if resp_result and resp_result.rsp_code and tostring(resp_result.rsp_code) == '7237' then
                result_json.dsc = '请输入6位数字服务密码[错误码RZ-7237]'
            else
                result_json.dsc = exception_redis_cluster_utils:un_get_exception_message(decrypt_mobile, resp_result.rsp_code, channel_code, business_code, interface_code)
            end

            ngx.ctx.kafka_login_INTERFACE_FAIL_ID = resp_result.rsp_code
            if string_utils:is_blank(resp_result.rsp_desc) then
                ngx.ctx.kafka_login_FAIL_RESON = '请输入6位数字服务密码'
            else
                ngx.ctx.kafka_login_FAIL_RESON = resp_result.rsp_desc
            end

            return result_flag, result_json
        end
    end

    log_utils:info({
        log_param1 = '登录用户：',
        log_param2 = decrypt_mobile,
        log_param3 = ' 登录成功，请求认证总耗时:',
        log_param4 = (date_utils:get_current_timestamp_ms() - authenticate_start_time),
    })

    local assemble_redis_cache_start_time = date_utils:get_current_timestamp_ms()
    local redis_cache_user_info = authenticate_utils:package_redis_cache_user_info(resp_result, mobile, password, version, isRemberedPwd, keyVersion,
            decrypt_mobile, login_type)

    local tmp_log_tab = {
        log_param1 = '装配用户信息 redis 缓存耗时:',
        log_param2 = (date_utils:get_current_timestamp_ms() - assemble_redis_cache_start_time),
    }
    log_utils:info(tmp_log_tab)

    local set_redis_cache_start_time = date_utils:get_current_timestamp_ms()
    if redis_cache_user_info then
        --[[
        -- redis 设置缓存 LA:手机号
        -- --]]
        if cjson and cjson.encode_empty_table_as_object then
            cjson.encode_empty_table_as_object(false)
        end

        local set_cache_flag
        if string_utils:contains(ngx.ctx.request_uri, 'radomLogin') then
            redis_cache_user_info.login_type = '06'
            set_cache_flag = redis_cluster_utils:set_val_by_key('RAN:RAN:' .. decrypt_mobile, cjson.encode(redis_cache_user_info), 30 * 60)
        else
            set_cache_flag = redis_cluster_utils:set_val_by_key('LA:' .. decrypt_mobile, cjson.encode(redis_cache_user_info))
        end
        if not set_cache_flag then
            local tmp_log_tab = {
                log_param1 = 'client_utils.authenticate_request 设置缓存失败,登录账号: ',
                log_param2 = decrypt_mobile,
            }
            log_utils:error(tmp_log_tab)
        end

        ngx.ctx.user_info_from_redis = redis_cache_user_info

        local tmp_log_tab = {
            log_param1 = '设置 redis 缓存耗时:',
            log_param2 = (date_utils:get_current_timestamp_ms() - set_redis_cache_start_time),
        }
        log_utils:info(tmp_log_tab)
    end

    local tmp_log_tab = {
        log_param1 = 'client_utils.authenticate_request ',
        log_param2 = decrypt_mobile .. ' ',
        log_param3 = '登录成功',
    }
    log_utils:info(tmp_log_tab)

    result_flag = false

    return result_flag, redis_cache_user_info
end

--[[
-- acquire mobileServiceResponse
--]]
function _M.get_response(self, userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
                         isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type, deviceOS)
    --[[
    -- user_type : 默认值是手机；其值为01（手机）、02（固话）、03（宽带adsl）、04（宽带lan）、05（注册用户）、08（小灵通）
    -- --]]
    local flag, result

    if string_utils:contains(ngx.ctx.request_uri, 'radomLogin') then
        flag, result = self:authenticate_request(userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
                isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type, deviceOS)
        return flag, result
    end

    if not config_props.switchs.enable_login_cache then
        flag, result = self:authenticate_request(userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
                isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type, deviceOS)
        return flag, result
    end

    --开始走缓存流程
    local user_info_from_cache = ngx.ctx.user_info_from_redis

    --缓存中有有效数据
    if user_info_from_cache and typeof(user_info_from_cache) ~= 'userdata' and user_info_from_cache.userInfoBean then
        local user_info_bean = user_info_from_cache.userInfoBean
        local user_mobile = user_info_bean.user_mobile
        local province_code = user_info_bean.province_code

        if string_utils:is_blank(province_code) then
            local call_java_start_time = date_utils:get_current_timestamp()

            local number_info = authenticate_utils:get_number_info(user_mobile)

            local tmp_log_tab = {
                log_param1 = '调用 java 获取号码信息接口耗时:',
                log_param2 = date_utils:get_current_timestamp() - call_java_start_time
            }
            log_utils:info(tmp_log_tab)

            if number_info and number_info.provinceCode then
                user_info_from_cache.userInfoBean.province_code = number_info.provinceCode
                redis_cluster_utils:set_val_by_key('LA:' .. decrypt_mobile, cjson.encode(user_info_from_cache))
            else
                local tmp_log_tab = {
                    log_param1 = ' 用户登录信息中没有省份信息，并且没有从缓存中取到号码的省份信息，删除缓存，重新走认证流程',
                }
                log_utils:info(tmp_log_tab)

                redis_cluster_utils:del_val_by_key('LA:' .. decrypt_mobile)
                user_info_from_cache = nil
            end
        end
    end

    if user_info_from_cache then
        if typeof(user_info_from_cache) == 'userdata' or user_info_from_cache.code ~= '0000'
            or (not user_info_from_cache.access_token) or (user_info_from_cache.login_type == '999') then
            redis_cluster_utils:del_val_by_key('LA:' .. decrypt_mobile)
            user_info_from_cache = nil
            ngx.ctx.user_info_from_redis = nil
        end
    end

    -- 缓存中没有数据
    if not user_info_from_cache or typeof(user_info_from_cache) == 'userdata' then
        flag, user_info_from_cache = self:authenticate_request(userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
                isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type, deviceOS)
        return flag, user_info_from_cache
    end

    -- 比对缓存中的数据
    local cache_login_password = user_info_from_cache.passwordEncrypt
    local cache_dec_password
    cache_dec_password = self:password_handle(version, cache_login_password, isRemberedPwd, keyVersion)

    if not cache_dec_password or string_utils:not_equals(decrypt_password, cache_dec_password) then
        redis_cluster_utils:del_val_by_key('LA:' .. decrypt_mobile)

        flag, user_info_from_cache = self:authenticate_request(userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
                isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type, deviceOS)

        return flag, user_info_from_cache
    end

    local log_msg = ''
    if authenticate_utils:is_accesstoken_valid(user_info_from_cache) then
        log_msg = '||用户登录，当日缓存生效中，并且上次access_token生效中，直接返回response'
    else
        local is_refreshtoken_valid_flag = authenticate_utils:is_refreshtoken_valid(user_info_from_cache)
        if is_refreshtoken_valid_flag then
            log_msg = '||用户登录，当日缓存生效中，access_token失效，异步刷新access_token操作，直接返回response'
            -- refresh_token有效，定时的去刷新 access_token

            local ok, err = ngx.timer.at(0, self.tmp_refresh_access_token_and_set_cache,
                    user_info_from_cache, mobile, password, version, isRemberedPwd, keyVersion, decrypt_mobile, login_type)
            if not ok then
                local tmp_log_tab = {
                    log_param1 = 'client_utils.get_response(): sync refresh access_token failed',
                    log_param2 = (err and { err } or { '' })[1]
                }
                log_utils:error(tmp_log_tab)
            end
        else
            -- refresh_token 已经失效，则需要去重新请求认证
            local ok, err = ngx.timer.at(0, self.tmp_authenticate_request,
                    userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
                    isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type, deviceOS)
            if not ok then
                local tmp_log_tab = {
                    log_param1 = 'client_utils.get_response(): sync request authenticate failed',
                    log_param2 = (err and { err } or { '' })[1]
                }
                log_utils:error(tmp_log_tab)
            end
        end
    end

    local tmp_log_tab = {
        log_param1 = decrypt_mobile,
        log_param2 = log_msg
    }
    log_utils:info(tmp_log_tab)

    flag = false

    return flag, user_info_from_cache
    --local log_vo = activity_log:get_logvo_activity('E', 'AC1', '0', 'E', '1', '0001', appId, mobile)
    --activity_log:activity_logs(log_vo, user_info_bean, date_utils:get_current_timestamp())
end

--[[
-- 密码处理
--]]
function _M.password_handle(self, version, password, isRemberedPwd, keyVersion)
    return self:decrypt_password(version, password, isRemberedPwd, keyVersion)
end

--[[
-- 登录账号处理
-- --]]
function _M.mobile_handle(self, version, mobile_no)
    return self:decrypt_mobile(version, mobile_no)
end

--[[
-- 判断账号的有效性
-- --]]
function _M.is_valid_account(self, mobile_no, user_type)
    local result_json = {
        code = '1',
        err_info = 'invalid_00',
    }

    local mobile_match = string.match(mobile_no, '^%d+$')
    if user_type ~= '03' and mobile_match then
        if string.len(mobile_no) ~= 11 then
            result_json.err_info = '请输入11位联通手机号码'
            return result_json
        end
    elseif user_type == '03' then

    else
        local reg_str = [[^.{3,}@(?:[a-z0-9](?:[-]?[a-z0-9]+)*\.){1,3}(?:com|org|edu|net|gov|cn|hk|tw|jp|de|uk|fr|mo|eu|sg|kr)$]]
        local match_flag = ngx.re.find(mobile_no, reg_str, 'jo')
        if not match_flag then
            result_json.err_info = '请输入正确格式的邮箱'
            return result_json
        end
    end

    return result_json
end

return _M
