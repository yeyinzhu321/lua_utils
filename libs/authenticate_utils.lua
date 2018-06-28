--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 06/12/2017
-- Time: 20:33
-- To change this template use File | Settings | File Templates.
--
local cookie_utils = require 'cookie_utils'
local post_uri_prefix = config_props.authenticate_config.url_pre_fix .. config_props.authenticate_config.url_suffix
local mobile_server_prefix = config_props.mobile_server.server_prefix

local _M = {}

--[[
-- 获取 access_token date
--]]
function _M.get_accesstoken_date(self, invalid_at)
    return date_utils:string_to_date(invalid_at)
end

--[[
-- 判断是否联通号
-- --]]
function _M.is_unicom(self, mobile)
    local start_time = date_utils:get_current_timestamp_ms()
    local reqts = date_utils:date_to_string('yyyyMMddHHmmss')
    local request_params = {
        reqts = reqts, -- 请求发起时间戳，格式yyyyMMddHHmmss
        channel = '113000004', -- 发起方渠道编码,由手厅提供
        mobile = mobile, -- 手机号码
        transid = reqts .. new_uuid:uuid_number(), -- 渠道编码+yyyymmddhh24miss+6位不重复序列
        busiCode = '110002', -- 业务编码，由手厅提供（110002）
        sign = aec_utils.encrypt_fun(mobile), -- 签名,内网访问，做简单加密 ：只加密手机号码AES对称加密，秘钥由手厅提供
    }

    local result = http_utils:post(mobile_server_prefix .. config_props.mobile_server.is_unicom, request_params)

    local continue_time = date_utils:get_current_timestamp_ms() - start_time
    local tmp_log_tab = {
        log_param1 = mobile,
        log_param2 = ' 登录手厅，调用接口[判断是否联通号],耗时:',
        log_param3 = continue_time,
    }
    log_utils:info(tmp_log_tab)

    local status = result.status
    status = tostring(status)
    if status == '200' then
        local r_body = result.body
        if r_body then
            if typeof(r_body) == 'string' then
                r_body = cjson.decode(r_body)
            end

            if r_body.flag == '0' then
                return true
            end
        end
    end

    return false
end

--[[
-- 获取用户手机卡信息
-- --]]
function _M.get_number_info(self, mobile)
    local start_time = date_utils:get_current_timestamp_ms()
    local reqts = date_utils:date_to_string('yyyyMMddHHmmss')

    local request_params = {
        reqts = reqts, -- 请求发起时间戳，格式yyyyMMddHHmmss
        channel = 'YH100002', -- 发起方渠道编码,由手厅提供
        mobile = mobile, -- 手机号码
        transid = reqts .. new_uuid:uuid_number(), -- 渠道编码+yyyymmddhh24miss+6位不重复序列
        busiCode = '110003', -- 业务编码，由手厅提供（110003）
        sign = aes_utils.encrypt_fun(mobile), -- 签名,内网访问，做简单加密 ：只加密手机号码AES对称加密，秘钥由手厅提供
        signVersion = '2.0',
    }

    local result = http_utils:post(mobile_server_prefix .. config_props.mobile_server.get_num_info, request_params)

    local continue_time = date_utils:get_current_timestamp_ms() - start_time
    local tmp_log_tab = {
        log_param1 = mobile,
        log_param2 = ' 登录手厅，调用接口[获取用户手机卡信息],耗时:',
        log_param3 = continue_time,
    }
    log_utils:info(tmp_log_tab)

    if result then
        local status = result.status
        status = tostring(status)
        if status == '200' then
            local r_body = result.body

            if typeof(r_body) == 'string' then
                if string_utils:contains(r_body, 'DOCTYPE') or string_utils:contains(r_body, 'html') then
                    return nil
                end

                r_body = cjson.decode(r_body)
            end

            return r_body
        end
    else
        return nil
    end

    return nil
end

--[[
认证新增一批品牌，通过所传品牌和网别，转义为自助对应的网别
@param brand       品牌
@param product_type 产品类型
@return 网别
--]]
function _M.change_product_type_2_netType(self, brand, product_type)
    if not brand then
        return product_type
    end

    -- 先判断4G新增品牌
    -- 以下品牌确认为4G移网用户，不需要用户类型判断
    if brand == 'FMLY' or brand == 'HYYY' or brand == 'VPDN' or brand == 'WV02' or brand == 'WV03' then
        return '11'
    end

    -- 4G01 4G后付费无线上网卡 4G05 4G预付费无线上网卡
    if '4G01' == brand or '4G05' == brand then
        return '15'
    end

    -- GZDH 公众电话 4G固话 QYDH 企业电话 4G固话
    if 'GZDH' == brand or 'QYDH' == brand then
        return '12'
    end

    -- GZKD 公众宽带 4G宽带 QYKD 企业宽带 4G宽带
    if 'GZKD' == brand or 'QYKD' == brand then
        -- 03:宽带（ADSL）
        if '03' == product_type then
            return '13'
        end

        -- 04:宽带（LAN）
        if '04' == product_type then
            return '14'
        end

        -- 防止返回用户类型不对，转换成老品牌
        brand = 'A'
    end

    -- IVPN品牌为 移网和固网 需通过用户类型判断 转换成老品牌
    if 'IVPN' == brand or '4G00' == brand then
        brand = 'A'
    end

    if 'B' == brand then
        return '15'
    end

    if '01' == product_type or '11' == product_type then
        --noinspection Duplicates
        if '8' == brand then
            return '10'
        elseif '9' == brand then
            return '02'
        elseif 'A' == brand then
            return '11'
        else
            return '01'
        end
    end

    if 'A' == brand then
        if '02' == product_type then
            return '12'
        end

        if '03' == product_type then
            return '13'
        end

        if '04' == product_type then
            return '14'
        end
    else
        if '02' == product_type then
            return '03'
        end

        if '03' == product_type then
            return '04'
        end

        if '04' == product_type then
            return '05'
        end

        if '08' == product_type then
            return '06'
        end
    end

    if '06' == product_type or '16' == product_type then
        --noinspection Duplicates
        if '8' == brand then
            return '10'
        elseif '9' == brand then
            return '02'
        elseif 'A' == brand then
            return '11'
        else
            return '01'
        end
    end

    return product_type
end

--[[
是否需要查询用户付费类型
@param user
--]]
function _M.is_query_pay_type(self, user_info_bean)
    if not user_info_bean then
        return false
    elseif '01' == user_info_bean.productType then
        if string_utils:is_blank(user_info_bean.payType) then
            return true
        end
    end

    return false
end

--[[
-- 获取过期时间
-- --]]
function _M.get_effective_time(self, user_info_bean)
    if user_info_bean and user_info_bean.invalid_at then
        local t_valid_time = cookie_utils.get_cookies_value('invalid_at')
        if string_utils:is_not_blank(t_valid_time) then
            t_valid_time = aes_utils.decrypt_fun(t_valid_time)
        end

        local time = 24 * 60 * 60

        if string_utils:is_not_blank(t_valid_time) then
            if typeof(t_valid_time) == 'string' then
                t_valid_time = tonumber(t_valid_time)
            end

            time = (t_valid_time - date_utils:get_current_timestamp()) / 1000
        end

        return tonumber(time)
    end

    return nil
end

--[[
完善用户信息，目前主要获取用户姓名和付费类型
@param user 当前用户对象
@param location 登录类型
--]]

function _M.complete_user_info(self, user_info, location)
    local _tmp = {}
    if not user_info then
        return _tmp
    end
    if user_info.netType == '01' or user_info.net_type == '02' then
        local user_info_bean_from_cache = ngx.ctx.user_info_from_redis

        if user_info_bean_from_cache and typeof(user_info_bean_from_cache) ~= 'userdata' then
            local user_info_bean = user_info_bean_from_cache.userInfoBean

            if user_info_bean and typeof(user_info_bean) ~= 'userdata' then
                user_info.net_type = user_info_bean.netType
                user_info.pay_type = user_info_bean.payType
                user_info.userType = user_info_bean.netType
            end
        end
    end

    if user_info and user_info.province_code then
        user_info.province_name = config_pros.pro_tabs['pc_' .. user_info.province_code]
    else
        user_info.province_name = ''
    end

    if user_info and user_info.city_code then
        user_info.city_name = config_pros.city_tabs['cc_' .. user_info.city_code]
    else
        user_info.city_name = ''
    end

    --付费类型为空抓取付费类型
    if self:is_query_pay_type(user_info) then
        local key = user_info.user_mobile .. '_paytype'

        -- 先取缓存，不存在调用接口
        local json_str = redis_cluster_utils:get_val_by_key(key)
        if not json_str and typeof(json_str) == 'string' then
            local tmp_tab = cjson.decode(json_str)

            local tmp_log_tab = {
                log_param1 = '号码:',
                log_param2 = user_info.user_mobile,
                log_param3 = ',付费类型取缓存信息:',
                log_param4 = tmp_tab.payType,
            }
            log_utils:info(tmp_log_tab)

            user_info.payType = tmp_tab.payType
        end

        if string_utils:is_blank(user_info.payType) then
            local query_pay_type = ''
            local user_info_bean_from_cache = ngx.ctx.user_info_from_redis

            if user_info_bean_from_cache and typeof(user_info_bean_from_cache) ~= 'userdata' then
                local user_info_bean = user_info_bean_from_cache.userInfoBean

                if user_info_bean and typeof(user_info_bean) ~= 'userdata' then
                    query_pay_type = user_info_bean.payType

                end
            end

            if string_utils:is_not_blank(query_pay_type) then
                user_info.payType = query_pay_type

                --写入缓存
                local expire_time = self:get_effective_time(user_info)-- 获取
                redis_cluster_utils:set_val_by_key(key, query_pay_type, expire_time)
            end
        end
    end

    if user_info.net_type == '11' or user_info.net_type == '12' or user_info.net_type == '13' or
            user_info.net_type == '14' or user_info.net_type == '15' then
        if string_utils:is_blank(user_info.pay_type) then
            user_info.pay_type = '2'
        end
    end

    return user_info
end

--[[
-- 判断当前登录用户是否可以刷新accesstoken，依据为距离失效不足5分钟
-- 此函数主要目的是对于活跃用户，在过期前5分钟提前刷token，保持后续访问通畅。
-- 距离失效不足5分钟返回true。
-- --]]
function _M.is_accesstoken_refreshable(self, user_info)
    if not user_info and typeof(user_info) ~= 'table' then
        local tmp_log_tab = {
            log_param1 = 'authenticate_utils.is_accesstoken_refreshable 传递参数为空.',
        }
        log_utils:error(tmp_log_tab)

        return false
    else
        local invalid_time
        if not user_info.invalid_at then
            invalid_time = date_utils:string_to_date(user_info.a_invalid_at)
        else
            invalid_time = date_utils:string_to_date(user_info.invalid_at)
        end

        if not invalid_time then
            return true
        end

        if os.difftime(invalid_time, date_utils:get_current_timestamp()) <= 300 then
            return true
        end

        return false
    end
end

--[[
-- 判断accesstoken是否失效方法，提前10秒定为真实失效，返回true代表为有效，返回false代表失效
-- --]]
function _M.is_accesstoken_valid(self, user_info)
    if not user_info and typeof(user_info) ~= 'table' then
        local tmp_log_tab = {
            log_param1 = 'authenticate_utils:is_accesstoken_valid 传递参数为空或者不正确.',
        }
        log_utils:error(tmp_log_tab)

        return false
    else
        local invalid_time
        if not user_info.invalid_at then
            invalid_time = date_utils:string_to_date(user_info.a_invalid_at)
        else
            invalid_time = date_utils:string_to_date(user_info.invalid_at)
        end

        if not invalid_time then
            return true
        end

        if os.difftime(invalid_time, date_utils:get_current_timestamp()) <= 10 then
            return false
        end

        return true
    end
end

--[[
-- 判断refreshtoken是否失效方法，返回true代表为有效，返回false代表失效，距离失效时间不足60 * 5秒(5 分钟)的认为失效。
-- --]]
function _M.is_refreshtoken_valid(self, user_info)
    if not user_info and typeof(user_info) ~= 'table' then
        local tmp_log_tab = {
            log_param1 = 'authenticate_utils:is_refreshtoken_valid 传递参数为空或者不正确.',
        }
        log_utils:error(tmp_log_tab)

        return false
    else
        local invalid_time = date_utils:string_to_date(user_info.re_invalid_at)
        if os.difftime(invalid_time, date_utils:get_current_timestamp()) > 60 * 5 then
            return true
        end

        return false
    end
end

--[[
-- 刷新 access_token
-- --]]
function _M.refresh_access_token(self, user_info, channel_code)
    if not user_info and typeof(user_info) ~= 'table' then
        local tmp_log_tab = {
            log_param1 = 'authenticate_utils:refresh_access_token 传递参数为空或者不正确.',
        }
        log_utils:error(tmp_log_tab)

        return nil
    end

    local request_params = {
        app_code = config_props.authenticate_config.app_code,
        app_secret = config_props.authenticate_config.app_secret,
        grant_type = 'refresh_token',
        refresh_token = user_info.refresh_token,
        user_custid = user_info.user_custid,
        real_ip = client_ip,
        channel_code = channel_code,
    }

    local new_access_token = http_utils:post(post_uri_prefix .. 'new_refresh', request_params)
    if not new_access_token then
        return nil
    end

    return cjson.decode(new_access_token.body)
end

--[[
-- 获取用户信息
-- --]]
function _M.get_user_info(self, access_token, channel_code, mobile)
    --rsp_code, -- 返回编码
    --rsp_desc, -- 错误编码
    --access_token, -- access token
    --brand, -- 品牌
    --cert_addr, -- 证件地址
    --cert_num, -- 证件号码
    --cert_type, -- 证件类型
    --city_code, -- 归属地市编码
    --credit_vale, -- 信用度
    --cust_lvl, -- 客户分级说明
    --cust_sex, -- 客户性别,0-女，1-男
    --invalid_at, -- access token的过期时间，其格式是“yyyy-MM-dd HH:mm:ss”
    --is_inuser, -- 智能网用户判断，当前只针对手机用户， 0000非智能网用户
    --land_lvl, -- 通话级别
    --last_stat_date, -- 用户最后状态变更时间
    --manager_contact, -- 客户经理联系方式
    --manager_name, -- 客户经理
    --net_type, -- 网别（01:2G，02:3G，10：上网卡）
    --open_date, -- 入网时间；yyyymmddhh24miss
    --package_id, -- 产品编码（主产品中文名称）
    --package_name, -- 产品名称
    --pay_type, -- 用户付费类型（1：预付费，2：后付费）
    --product_id, -- 用户号码
    --product_type, -- 号码类型
    --province_code, -- 归属省份编码
    --re_invalid_at, -- refresh_token的过期时间
    --refresh_token, -- refresh_token
    --roam_stat, -- 漫游状态
    --simcard, -- SIM/UIM卡号
    --status, -- 用户状态说明；比如：正常、注销等
    --subscrb_type, -- 用户类型
    --subscrbid, -- 用户编码
    --tel_area_code, -- 区号
    --user_custid, -- 用户在客户中心的custid
    --user_nick, -- 客户名称
    --user_type_status, --
    --vpn_name, -- 所属虚拟网名称
    --user_id, -- 用户账户
    --login_type, -- 用户登录类型

    --[[
    -- group_info
    -- con_member_info:[]
    -- group_id
    -- group_type
    -- main_card_flag
    -- main_member_info : []
    -- main_num_flag
    -- product_id
    -- product_name
    -- --]]

    local get_user_info_start_time = date_utils:get_current_timestamp_ms()

    local request_params = {
        app_code = config_props.authenticate_config.app_code,
        app_secret = config_props.authenticate_config.app_secret,
        grant_type = 'userinfo',
        access_token = access_token,
        real_ip = client_ip,
        channel_code = channel_code,
    }

    local tmp_log_tab = {
        log_param1 = '登录用户 ',
        log_param2 = mobile,
        log_param3 = ' ' .. date_utils:date_to_string('yyyy-MM-dd HH:mm:ss'),
        log_param4 = ' 请求认证 userinfo 接口开始.',
    }
    log_utils:info(tmp_log_tab)

    local user_info = http_utils:post(post_uri_prefix .. 'user_info', request_params)
    if not user_info then
        return nil
    end

    local tmp_log_tab1 = {
        log_param1 = '登录用户 ',
        log_param2 = mobile,
        log_param3 = ' ' .. date_utils:date_to_string('yyyy-MM-dd HH:mm:ss'),
        log_param4 = ' 请求认证 userinfo 接口结束.',
    }
    log_utils:info(tmp_log_tab1)

    local tmp_log_tab2 = {
        log_param1 = '登录用户 ',
        log_param2 = mobile,
        log_param3 = ' 请求认证 userinfo 接口耗时:',
        log_param4 = (date_utils:get_current_timestamp_ms() - get_user_info_start_time),
    }
    log_utils:info(tmp_log_tab2)

    return cjson.decode(user_info.body)
end

--[[
-- 获取绑定关系
-- --]]
function _M.get_bind_info(self, bind_param_tab, mobile)
    local get_bind_info_start_time = date_utils:get_current_timestamp_ms()
    if bind_param_tab and typeof(bind_param_tab == 'table') then
        local tmp_log_tab = {
            log_param1 = '登录用户 ',
            log_param2 = mobile,
            log_param3 = ' ' .. date_utils:date_to_string('yyyy-MM-dd HH:mm:ss'),
            log_param4 = ' 请求认证 bindinfo 接口开始.',
        }
        log_utils:info(tmp_log_tab)

        local user_info = http_utils:post(post_uri_prefix .. 'user_info', bind_param_tab)
        if not user_info then
            return nil
        end

        local tmp_log_tab1 = {
            log_param1 = '登录用户 ',
            log_param2 = mobile,
            log_param3 = ' ' .. date_utils:date_to_string('yyyy-MM-dd HH:mm:ss'),
            log_param4 = ' 请求认证 bindinfo 接口结束.',
        }
        log_utils:info(tmp_log_tab1)

        local tmp_log_tab2 = {
            log_param1 = '登录用户 ',
            log_param2 = mobile,
            log_param3 = ' 请求认证 bindinfo 接口耗时: ',
            log_param4 = date_utils:get_current_timestamp() - get_bind_info_start_time
        }
        log_utils:info(tmp_log_tab2)

        return cjson.decode(user_info.body)
    else
        local tmp_log_tab = {
            log_param1 = 'authenticate_utils.get_bind_info occur exception : receive the param bind_param_tab is not table, its type is ',
            log_param2 = typeof(bind_param_tab),
        }
        log_utils:error(tmp_log_tab)

        return nil
    end
end

--[[
-- 组装 user_info 对象
-- --]]
function _M.assemble_user_info(self, user_info, login_type, decrypt_mobile)
    if not user_info and typeof(user_info) ~= 'table' then
        return nil
    else
        local product_id = user_info.product_id
        local user_mobile

        if product_id and string.find(product_id, '%-') then
            local pattern_index = string.find(product_id, '%-')
            user_mobile = string.sub(product_id, pattern_index + 1)
        else
            user_mobile = product_id
        end
        local userNumberWithNoCode
        local code = user_info.tel_area_code
        if string_utils:is_blank(code) then
            userNumberWithNoCode = user_info.product_id
        end

        -- 统一认证新增品牌，做网别转义
        local net_type = self:change_product_type_2_netType(user_info.brand, user_info.product_type)
        if not net_type then
            net_type = ''
        end

        if user_info and user_info.net_type and user_info.net_type == '11' then
            if user_info and user_info.pay_type and user_info.pay_type == '1' then
                user_info.pay_type = '2'
            end
        end

        local user_info_table = {
            brand = user_info.brand, -- 品牌标识： 1-世界风 2-如意通 3-新势力 4-新时空 5-联通商务 6-其他 7-亲情1+
            -- 8-无线上网卡 9-沃 99-网站用户
            city_code = user_info.city_code, -- 城市代码
            province_code = user_info.province_code,
            open_date = user_info.open_date, -- 入网时间；yyyymmddhh24miss
            product_id = user_info.package_id, -- 产品编码
            product_name = user_info.package_name, -- 产品名称
            productType = user_info.product_type, -- 号码类型
            user_mobile = decrypt_mobile, -- 用户手机号码
            u_mobile = decrypt_mobile,
            packageName = user_info.package_name, -- 套餐名称
            packageId = user_info.package_id, -- 套餐ID
            --01：2G 02：3G 03：固定电话 04：宽带（ADSL） 05：宽带（LAN） 06：小灵通 07：WLAN业务
            netType = net_type, -- 网别
            --01：2G；02：3G；03：固定电话；04：宽（ADSL）；05：宽带（LAN）；06：小灵通；07：WLAN业务；08：融合；09：集团；10 上网卡
            userType = user_info.net_type, -- 用户类型
            --[[
            -- 扩展网别，菜单类型定义 1、正常用户网别情况下，menuType=netType
            2、若需要定义个别用户类型的菜单，如沃家庭、20元套餐等，需增加扩展
            定义规范：100开始，增加幅度为10
            String WO = '1001' --沃家庭 100

            String Family = '1101' --亲情号码 沃派36元
            String OCS20 = '1201' --OCS20元
            --]]
            menuType = '', -- 菜单类型
            code = code, -- 区号
            userNumberWithNoCode = userNumberWithNoCode, -- 不带区号的服务号码
            ocsflag = '1', --OCS用户标记，0为OCS用户，1为普通用户
            payType = user_info.pay_type, --付费类型，00为后付费，01为预付费
            customId = user_info.custID, --客户ID
            customName = user_info.cust_name, -- 客户名称
            woisflag = false, -- 是否为沃家庭 true为沃家庭用户,false为非沃家庭用户
            familyNumber = false, -- 是否为亲情号 true为亲情号,false为非亲情号
            registration_name = '', -- 用于存储网站注册用户名称
            nikename = '',
            secrutyLevel = '20', --安全级别
            meOrder = nil, --已开通密令的业务编号，多个业务用“,”分隔如：'0088,0099'
            userNumbetType = '', -- 号码类型
            groupFlag = '', --是否集团客户
            error_code = '', -- 调用省分接口异常时，该字段的值为其错误编码，正常时，该字段的值为空
            groupInfo = user_info.group_info,
            cert_num = user_info.cert_num, --证件号码
            --证件类型 01：15位身份证 02：18位身份证 03：驾驶证 04：军官证 05：教师证 06：学生证 07：营业执照 08：护照 99：其它
            cert_type = user_info.cert_type,
            --判断当日是否用户的生日，0：非生日，1：是生日
            isBirthday = '',
            loginType = login_type,
            subscrbid = '', -- 用户编码
            subscrb_stat = '', -- 用户状态；编码见附录B

            land_lvl = '', -- 通话级别；编码见附录D
            roam_stat = '', -- 漫游状态；编码见附录C
            Simcard = '', -- SIM/UIM卡号
            vpn_name = '', -- 所属虚拟网名称
            credit_vale = '', -- 信用度
            subscrb_type = '', -- 用户类型；编码见附录A
            last_stat_date = '', -- 用户最后状态变更时间YYYYMMDDHH24MISS
            billingType = '', -- 计费类型
            broadbandCode = '', -- 宽带编码
            vipLev = '', -- VIP级别名称
            expireTime = '', -- 失效时间

            --
            --productNamexN(当前产品别名名称)、
            productNamexN = user_info.productNamexN,

            --productTypeN(当前产品套餐类型编码)、
            productTypeN = user_info.productTypeN,

            --companyIdN(当前产品企业编码)、
            companyIdN = user_info.companyIdN,

            --productNamexF(下月产品别名名称)、
            productNamexF = user_info.productNamexF,

            --productTypeF(下月产品套餐类型编码)、
            productTypeF = user_info.productTypeF,

            --companyIdF(下月产品企业编码)
            companyIdF = user_info.companyIdF,
        }

        user_info_table = self:complete_user_info(user_info_table, user_info_table.login_type)

        return user_info_table
    end
end

--[[
-- 封装缓存 userInfo 对象
-- --]]
function _M.package_redis_cache_user_info(self, resp_result, mobile, password, version, isRemberedPwd, keyVersion,
                                          decrypt_mobile, login_type)
    local broad_type = string_utils:get_default_val(resp_result.broad_type)
    local channel_code = self:get_channel_code(version)

    --[[
    -- 通过 access_token 获取用户信息
    -- --]]
    local user_info = self:get_user_info(resp_result.access_token, channel_code, decrypt_mobile)
    if not user_info then
        local tmp_log_tab = {
            log_param1 = 'authenticate_utils.package_redis_cache_user_info 通过 access_token 获取用户信息失败',
        }
        log_utils:error(tmp_log_tab)

        return nil
    else
        if typeof(user_info) ~= 'userdata' then
            local tmp_log_tab = {
                log_param1 = 'authenticate_utils.package_redis_cache_user_info 通过 access_token 获取用户信息为:',
                log_param2 = (type(user_info) == 'table' and { cjson.encode(user_info) } or { tostring(user_info) })[1]
            }
            log_utils:info(tmp_log_tab)
        end
    end

    local redis_cache_user_info = {}
    local user_info_bean = self:assemble_user_info(user_info, login_type, decrypt_mobile)

    if user_info_bean then
        user_info_bean.broad_type = broad_type
    end

    if login_type ~= '05' then
        redis_cache_user_info.userInfoBean = user_info_bean
        redis_cache_user_info.UserInfoBeanList = {}
    else
        --[[
        -- 获取绑定关系
        -- --]]
        local switch_number_model = {
            app_code = config_props.authenticate_config.app_code,
            app_secret = config_props.authenticate_config.app_secret,
            grant_type = 'bindship',
            access_token = resp_result.access_token,
            user_custid = resp_result.user_custid,
            real_ip = client_ip,
            channel_code = channel_code,
        }

        local userinfobean_list = {}
        local bind_result = self:get_bind_info(switch_number_model, decrypt_mobile)
        if bind_result.rsp_code == '0000' then
            local product_list = bind_result.productlist
            local have_default = false
            if product_list and #product_list > 0 then
                for k, v in pairs(product_list) do
                    local tmp_tab = {}

                    if typeof(v) == 'table' then
                        tmp_tab.province_code = v.province_code --省份编码
                        tmp_tab.brand = v.brand -- 品牌
                        tmp_tab.productType = v.product_type -- 号码类型
                        tmp_tab.city_code = v.city_code -- 地市编码
                        tmp_tab.user_mobile = v.user_mobile -- 号码
                        tmp_tab.product_id = v.package_id -- 产品编码
                        tmp_tab.netType = v.net_type -- 网别（01:2G，02:3G，10：上网卡）
                        tmp_tab.payType = v.pay_type -- 用户付费类型（1：预付费，2：后付费）
                        tmp_tab.userType = v.net_type -- 号码类型
                        if v and v.net_type and v.net_type == '11' then
                            if v and v.pay_type and v.pay_type == '1' then
                                tmp_tab.payType = '2'
                            end
                        end
                        local tel_area_code = v.tel_area_type -- 区号
                        tmp_tab.code = tel_area_code

                        --[[
                        -- 如没有区号，就保存下来手机号码
                        -- --]]
                        if string_utils:is_blank(tel_area_code) then
                            tmp_tab.userNumberWithNoCode = decrypt_mobile
                        end

                        tmp_tab.customId = v.custID -- 用户在客户中心的custid
                        tmp_tab.customName = v.cust_name -- 客户姓名
                        tmp_tab.nikename = v.cust_name -- 客户姓名

                        tmp_tab.packageId = v.package_id -- 套餐id
                        tmp_tab.packageName = v.package_name -- 套餐名称
                        tmp_tab.product_name = v.package_name -- 产品名称和套餐名称

                        tmp_tab.secrutyLevel = '20'
                        tmp_tab.open_date = v.open_date -- 入网时间
                        tmp_tab.meOrder = nil
                        tmp_tab.groupInfo = v.group_info -- 用户群组信息

                        if v.default_flag == '00' then
                            have_default = true
                        end

                        tmp_tab.error_code(v.error_code)

                        tmp_tab.broad_type = broad_type

                        -- add new columns
                        -- productNamexN 当前产品别名名称
                        tmp_tab.productNamexN = v.productNamexN

                        --productTypeN(当前产品套餐类型编码)、
                        tmp_tab.productTypeN = v.productTypeN

                        --companyIdN(当前产品企业编码)、
                        tmp_tab.companyIdN = v.companyIdN

                        --productNamexF(下月产品别名名称)、
                        tmp_tab.productNamexF = v.productNamexF

                        --productTypeF(下月产品套餐类型编码)、
                        tmp_tab.productTypeF = v.productTypeF

                        --companyIdF(下月产品企业编码)
                        tmp_tab.companyIdF = v.companyIdF

                        userinfobean_list[k] = tmp_tab
                    end
                end

                if have_default then
                    redis_cache_user_info.userInfoBean = userinfobean_list[1]
                end

                redis_cache_user_info.UserInfoBeanList = userinfobean_list
            end
        end
    end

    --[[
    -- 封装对象
    -- --]]
    redis_cache_user_info.isSuccess = true
    redis_cache_user_info.code = resp_result.rsp_code
    redis_cache_user_info.desc = resp_result.rsp_desc
    redis_cache_user_info.access_token = resp_result.access_token
    redis_cache_user_info.a_invalid_at = resp_result.invalid_at
    redis_cache_user_info.refresh_token = resp_result.refresh_token
    redis_cache_user_info.re_invalid_at = resp_result.re_invalid_at
    redis_cache_user_info.user_custid = resp_result.user_custid
    redis_cache_user_info.user_id = resp_result.user_id
    redis_cache_user_info.user_nick = resp_result.user_nick
    redis_cache_user_info.bind_custid = ''
    redis_cache_user_info.last_login_time = resp_result.invalid_at
    redis_cache_user_info.login_type = resp_result.login_type
    redis_cache_user_info.default_flag_index = ''
    redis_cache_user_info.login_user = decrypt_mobile
    redis_cache_user_info.user_head_img = (user_info and { user_info.user_head_img } or { '' })[1]
    redis_cache_user_info.todayDate = os.date('%Y-%m-%d', date_utils:get_current_timestamp())
    redis_cache_user_info.version = version
    redis_cache_user_info.loginUserEncrypt = mobile
    redis_cache_user_info.passwordEncrypt = password
    redis_cache_user_info.isRemberPwd = isRemberedPwd
    redis_cache_user_info.keyVersion = keyVersion

    return redis_cache_user_info
end

--[[
-- 用户激活是是否满足激活条件
--]]
function _M.is_allow_num(self, user_info)
    local is_allow = false
    local province_code = user_info.province_code
    local net_type = user_info.net_type
    local pay_type = user_info.pay_type
    local product_id = user_info.product_id
    local group = user_info.groupInfo

    if group and string_utils:equals(group.group_type, '05') and string_utils:equals(group.main_card_flag, '1') then
        is_allow = true
    end

    if string_utils:equals(net_type, '01') or string_utils:equals(net_type, '02') then
        if string_utils:equals(province_code, '030') then
            is_allow = true
        end

        if string_utils:equals(province_code, '083') and string_utils:equals(pay_type, '1') then
            is_allow = true
        end
    end

    return is_allow
end

function _M.tmp_record_activity_fun(user_info, channel)
    return _M:record_activity_fun(user_info, channel)
end

function _M.record_activity_fun(self, user_info, channel)
    local start_time = date_utils:get_current_timestamp()
    local is_allow = self:is_allow_num(user_info)

    -- 营业员推广Redis
    local offline_spread_redis = offline_spread_activity:get_redis_conn()

    local paid_share_redis = paid_share_activity:get_redis_conn()

    -- 获取被分享者活动信息
    --[[
    local activity_info = {
        mobileNo = '',
        activityInfo = {
            activityCode = '',        --活动编码
            activityName = '',       --活动名称
            activityAscription = '',  --活动归属
            activityStartTime = '',     --活动开始时间
            activityEndTime = '',       --活动结束时间
            activityDescribe = '',	-- 活动描述
            activityRule = '',		-- 活动规则
            upperLimit = '',
            batchNumber = '',			--奖品批次
            assetsId = '',			--资产ID(主键,用于取数量,下放)
            channel	= '',			--我的系统在资产管理中的渠道
            prizeName = '',           --奖品名称
            prizeRemark = '',        --奖品描述
            prizeCode = '',          --流量包奖品编码
            activateType = '',		-- 发放方式
            activateEndTime = '', 		-- 激活截止时间
        },-- 活动信息
        canTimes = '', -- 可领取次数
        hasTimes = '', -- 已领取次数
        shareJoin = '', -- 关联用户
        shareLogin = '', -- 用户关联成功后是否已登录
        newUserList = {}, -- 拉新用户列表
    }
    --]]

    local paid_share_key = '{' .. user_info.user_mobile .. '}' .. '_user_info'
    local user_activity_info, err = paid_share_redis:get(paid_share_key)
    if not user_activity_info then
        local tmp_log_tab = {
            log_param1 = '登录时从 redis 获取被分享者活动信息出错,',
            log_param2 = err,
        }
        log_utils:error(tmp_log_tab)
    end

    local is_paid_share_result = true

    if not user_activity_info or typeof(user_activity_info) == 'userdata' then
        is_paid_share_result = false
    end

    -- 获取关联的分享者
    local is_share_info = true
    local share_join

    if is_paid_share_result then
        share_join = user_activity_info.shareJoin
    end

    local share_activity_info
    -- 获取分享者活动信息
    if string_utils:is_not_blank(share_join) then
        share_activity_info, err = paid_share_redis:get(paid_share_key)
        if not share_activity_info then
            is_share_info = false
        end
    else
        is_share_info = false
    end

    -- 被分享者已关联且登录标识
    local share_login = true
    if is_share_info and is_paid_share_result then
        share_login = user_activity_info.shareLogin
    end

    if not share_login then
        -- 分享者可领取次数+1
        share_activity_info.canTimes = share_activity_info.canTimes + 1
        -- 被分享者可领取次数+1
        user_activity_info.canTimes = user_activity_info.canTimes + 1
        user_activity_info.shareLogin = true

        --[[
        -- redis set share info
        --]]
        -- set share activity info
        local share_activity_end_time = share_activity_info.activityInfo.activityEndTime
        local tmp_share_time = date_utils:string_to_date(share_activity_end_time)
        local share_end_time = tmp_share_time / 1000
        local tmp_share_activity_info = share_activity_info
        if typeof(share_activity_info) == 'table' then
            tmp_share_activity_info = cjson.decode(tmp_share_activity_info)
        end
        local tmp_share_key = '{' .. share_activity_info.mobileNo .. '}' .. '_user_info'
        paid_share_redis:set(tmp_share_key, tmp_share_activity_info)
        paid_share_redis:expire(tmp_share_key, share_end_time)

        -- set user activity info
        local activity_end_time = user_activity_info.activityInfo.activityEndTime
        local tmp_time = date_utils:string_to_date(activity_end_time)
        local end_time = tmp_time / 1000
        local tmp_activity_info = user_activity_info
        if typeof(user_activity_info) == 'table' then
            tmp_activity_info = cjson.decode(tmp_activity_info)
        end
        local tmp_share_key = '{' .. tmp_activity_info.mobileNo .. '}' .. '_user_info'
        paid_share_redis:set(tmp_share_key, tmp_activity_info)
        paid_share_redis:expire(tmp_share_key, end_time)

        local log_vo = {
            act_code = '40035',
            act_step = (is_allow and { '17' } or { '4' })[1],
            remark3 = share_join,
            location = user_info.loginType,
            user_mobile = user_info.user_mobile,
            access_application = channel,
            states = '1',
            remark1 = user_activity_info.activityInfo.activityCode
        }
        activity_log:activity_logs(log_vo, user_info, start_time)
        -- share logic ending ....

        -- 用户状userStatus格式为冒号分隔的字符串，冒号前为登陆状态，冒号后为流量领取状态（
        -- 0是未登陆和未领取，1是已登录和已领取）
        local user_status = offline_spread_redis:hget('tui_guang_info_status', user_info.user_mobile)

        -- 是推荐用户并且登陆状态是未登录
        local mall_flag = user_status and string_utils:equals(string_utils:split(user_status, ':')[1], '0')

        if mall_flag then
            local spread_save_info = {
                userMobileNum = user_info.user_mobile,
                flowFlag = '0',
                loginFlag = '1',
                loginTime = date_utils:date_to_string('yyyy-MM-dd HH:mm:ss'),
                id = '',
                channelId = '',
                provinceCode = '',
                cityCode = '',
                businessHallName = '',
                businessHallPeopleName = '',
                registerTime = '',
                remark1 = '',
                remark2 = '',
                remark3 = '',
                remark4 = '',
                remark5 = '',
                remark6 = '',
                remark7 = '',
                remark8 = '',
            }

            offline_spread_redis:lpush('update_tui_guang_info', spread_save_info)
            offline_spread_redis:hset('tui_guang_info_status', user_info.user_mobile, '1:0')

            local tmp_log_tab = {
                log_param1 = user_info.user_mobile,
                log_param2 = '放入队列中',
            }
            log_utils:info(tmp_log_tab)

            tmp_log_tab = {
                log_param1 = '判断是否为推荐用户所需时间：',
                log_param2 = (date_utils:get_current_timestamp() - start_time),
                log_param3 = '毫秒',
            }
            log_utils:info(tmp_log_tab)
        end

        -- close redis conn
        paid_share_redis:close()
        offline_spread_redis:close()
    end

    return true
end

function _M.tmp_record_activity(premature, user_info, channel)
    _M:record_activity(user_info, channel)
end

function _M.record_activity(self, user_info, channel)
    local tmp_log_tab = {
        log_param1 = '========是否是推荐用户',
        log_param2 = (user_info and { user_info.user_mobile } or { '' })[1],
        log_param3 = '判断开始--------',
    }
    log_utils:info(tmp_log_tab)
    -- 判断是否是被营业员推荐的用户

    if user_info then
        local ok, record_activity_fun_result = xpcall(self.tmp_record_activity_fun, function(e)
            return e
        end, user_info, channel)

        if not ok then
            local tmp_log_tab = {
                log_param1 = user_info.user_mobile,
                log_param2 = '登录时判断是否推荐用户出错,err is:',
                log_param3 = tostring(e)
            }
            log_utils:error(tmp_log_tab)
        end
    end
end

function _M.get_channel_code(self, version)
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

return _M
