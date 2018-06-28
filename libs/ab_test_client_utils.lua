--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 29/11/2017
-- Time: 15:02
-- To change this template use File | Settings | File Templates.
--
local authenticate_utils = require 'ab_test_authenticate_utils'

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
        result = rsa_utils.decrypt(password)
        --对于自动更新客户端用户，客户端保存的密码为旧的对称加密密码，需要尝试旧的解密方式
        if string_utils:is_blank(result) then
            result = aes_utils.decrypt_fun(password)
        end
    else
        result = aes_utils.decrypt_fun(password)
    end

    if string_utils:is_blank(result) then
        return nil
    end

    --对于4.0以后的版本 密码后加了6位随机数
    if result and #result >= 12 then
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
        return nil
    end

    if string_utils:equals_ignore_case('iphone_c', string_utils:split(version)[1]) then
        return '113000004'
    elseif string_utils:equals_ignore_case('android', string_utils:split(version)[1]) then
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
    if typeof(deviceId) ~= 'string' then deviceId = tostring(deviceId) end

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
    if not mobile then mobile = '' end
    if not deviceId then deviceId = '' end
    if not client_type then client_type = '' end
    if not client_version then client_version = '' end

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
        user_info.ProvinceName = user_info_bean.province_name -- 省份名称
        user_info.CityCode = user_info_bean.city_code -- 地市编码
        user_info.CityName = user_info_bean.city_name -- 地市名称
        user_info.NetType = user_info_bean.net_type -- 网别
        user_info.PayType = user_info_bean.pay_type -- 付费类型
        user_info.UserMobile = user_info_bean.user_mobile -- 手机号码
        user_info.Brand = user_info_bean.brand -- 品牌
        user_info.FamilyNumber = user_info_bean.familyNumber -- 是否为沃家庭
        user_info.OpenDate = user_info_bean.open_date-- 入网时间
        user_info.BillingType = user_info_bean.billingType-- 计费类型
        user_info.VipLev = user_info_bean.vipLev-- VIP级别
        user_info.UserType = user_info_bean.userType-- 用户类型
        user_info.Ocsflag = user_info_bean.ocsflag-- OCS用户标记
        user_info.Woisflag = user_info_bean.woisflag -- 是否为沃家庭

        req_body.userInfo = user_info
    end

    push_req.reqBody = req_body

    return cjson.encode(push_req)
end

--[[
-- 推送服务调用
-- --]]
function _M.push_server(self, user_info_bean, version, deviceId, device_model, push_platform, platform_token)
    if user_info_bean.login_type == '05' then return end
    local red_conn, get_message = redis_cluster_utils:get_redis_conn()

    local mobile = user_info_bean.user_mobile

    if not platform_token then platform_token = '' end
    if not push_platform then push_platform = '' end
    if not device_model then device_model = '' end
    if not deviceId then deviceId = '' end

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
    local new_refresh_token = authenticate_utils.refresh_access_token(user_info_bean_from_cache)
    if not new_refresh_token then
        local tmp_log_tab = {
            log_param1 = 'client_utils.get_response 获取缓存,access_token 即将过期,refresh_token 未失效,刷新 access_token 失败',
        }
        log_utils:info(tmp_log_tab)

    else
        --[[
        -- 刷新成功,更新 redis 缓存
        -- --]]
        user_info_from_cache = authenticate_utils.package_redis_cache_user_info(new_refresh_token, mobile, password, version, isRemberedPwd, keyVersion,
                decrypt_mobile, login_type)

        if user_info_bean_from_cache then
            --[[
            -- redis 设置缓存 LA:手机号
            -- --]]
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

    return user_info_from_cache
end


function _M.tmp_authenticate_request(premature, userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
                                     isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type)
    _M:authenticate_request(userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
            isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type)
end

--[[
-- request authenticate to acquire user data
--]]
function _M.authenticate_request(self, userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
                                    isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type)
    local authenticate_start_time = date_utils:get_current_timestamp_ms()
    local result_json = {}

    local result_flag = true

    local resp_result = {
        access_token = 'tojaoxovddda0f5f628d3218e11fe63ca28a09a48s78n2aa',
        errorFrom = '',
        invalid_at = '2017-12-07 11:58:25',
        login_type = '01',
        needverify = '',
        re_invalid_at = '2017-12-09 11:28:25',
        refresh_token = 'fyz8othl03a15d0e6d72fd886cd1983da0b740154ulujd5b',
        rsp_code = '0000',
        rsp_desc = '',
        sso_type = '1',
        state = '',
        user_custid = '7017111703659633',
        user_id = '17611421727',
        user_nick = '张国安',
    }

    if resp_result  and resp_result.rsp_code ~= '0000' then
        local tmp_log_tab = {
            log_param1 = '登录用户 ',
            log_param2 = decrypt_mobile .. ',',
            log_param3 = result_err_code_utils:get_val_by_code(resp_result.rsp_code),
            log_param4 = '[错误码:',
            log_param5 = resp_result.rsp_code,
            log_param6 = ']',
        }
        log_utils:error(tmp_log_tab)

        if string_utils:contains(resp_result.rsp_code, '7007') or string_utils:contains(resp_result.rsp_code, '7008') then
            result_json.code = '2'
            result_json.dsc = result_err_code_utils:get_val_by_code(resp_result.rsp_code)
        elseif string_utils:is_not_blank(config_props.ecs_error_code[resp_result.rsp_code]) then
            result_json.code = '1'
            result_json.dsc = exception_redis_cluster_utils:un_get_exception_message(decrypt_mobile, resp_result.rsp_code, channel_code, business_code, interface_code)
        else
            result_json.code = '1'
            result_json.dsc = exception_redis_cluster_utils:un_get_exception_message(decrypt_mobile, resp_result.rsp_code, channel_code, business_code, interface_code)
        end

        return result_flag, result_json
    end

    local assemble_redis_cache_start_time = date_utils:get_current_timestamp_ms()
    local redis_cache_user_info = authenticate_utils.package_redis_cache_user_info(resp_result, mobile, password, version, isRemberedPwd, keyVersion,
            decrypt_mobile, login_type)
    if redis_cache_user_info then

        local set_redis_cache_start_time = date_utils:get_current_timestamp_ms()
        --[[
        -- redis 设置缓存 LA:手机号
        -- --]]
        local set_cache_flag = redis_cluster_utils:set_val_by_key('LA:' .. decrypt_mobile, cjson.encode(redis_cache_user_info))
        if not set_cache_flag then
            local tmp_log_tab = {
                log_param1 = 'app_login.app_login 设置缓存失败,登录账号: ',
                log_param2 = decrypt_mobile .. ',',
            }
            log_utils:error(tmp_log_tab)
        end
    end

    local tmp_log_tab = {
        log_param1 = 'client_utils.authenticate_request ',
        log_param2 = decrypt_mobile .. ' ',
        log_param3 = '登录成功',
    }
    log_utils:info(tmp_log_tab)
    --kafka_utils:send(config_props.kafka_server_config.server_topic, config_props.kafka_server_config.message_key, 'app_login.app_login ' .. decrypt_mobile .. ' 登录成功')

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

    if not config_props.switchs.enable_login_cache then
        flag, result = self:authenticate_request(userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
                isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type)
        return flag, result
    end

    --开始走缓存流程
    local user_info_from_cache = ngx.ctx.user_info_from_redis

    --缓存中有有效数据
    if user_info_from_cache and user_info_from_cache.userInfoBean then
        local user_info_bean = user_info_from_cache.userInfoBean
        local user_mobile = user_info_bean.user_mobile
        local province_code = user_info_bean.province_code
        if string_utils:is_blank(province_code) then
            local prov_code = authenticate_utils.get_number_info(user_mobile)
            if string_utils:is_not_blank(prov_code) then
                user_info_from_cache.userInfoBean.province_code = prov_code
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

    -- 缓存中没有数据
    if not user_info_from_cache then
        flag, user_info_from_cache = self:authenticate_request(userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
                isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type)
        return flag, user_info_from_cache
    end

    -- 比对缓存中的数据
    local cache_dec_mobile = user_info_from_cache.login_user
    local cache_login_password = user_info_from_cache.passwordEncrypt
    local cache_dec_password
    cache_dec_password = self:password_handle(version, cache_login_password, isRemberedPwd, keyVersion)

    if not cache_dec_password or string_utils:not_equals(decrypt_password, cache_dec_password) then
        redis_cluster_utils:del_val_by_key('LA:' .. decrypt_mobile)

        flag, user_info_from_cache = self:authenticate_request(userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
                isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type)
    end


    local log_msg = ''
    if authenticate_utils:is_accesstoken_valid(user_info_from_cache) then
        log_msg = '||用户登录，当日缓存生效中，并且上次access_token生效中，直接返回response'
    else
        local is_refreshtoken_valid_flag = authenticate_utils.is_refreshtoken_valid(user_info_from_cache)
        if is_refreshtoken_valid_flag then
            logMsg = "||用户登录，当日缓存生效中，但是access_token失效，异步刷新access_token操作，直接返回response"
            -- refresh_token有效，定时的去刷新 access_token

            local ok, err = ngx.timer.at(7, self.tmp_refresh_access_token_and_set_cache,
                    user_info_from_cache, mobile, password, version, isRemberedPwd, keyVersion, decrypt_mobile, login_type)
            if not ok then
                return
            end
        else
            -- refresh_token 已经失效，则需要去重新请求认证
            local ok, err = ngx.timer.at(7, self.tmp_authenticate_request,
                    userType, areaCode, decrypt_mobile, decrypt_password, mobile, password, version,
                    isRemberedPwd, keyVersion, channel_code, business_code, interface_code, login_type, deviceOS)
            if not ok then
                return
            end
        end
    end

    local tmp_log_tab = {
        log_param1 = mobile,
        log_param2 = log_msg
    }
    log_utils:info(tmp_log_tab)

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

    local mobile_match = string.match(mobile_no,'^%d+$')
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