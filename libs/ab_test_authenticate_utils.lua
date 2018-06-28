--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 06/12/2017
-- Time: 20:33
-- To change this template use File | Settings | File Templates.
--
local cookie_utils = require 'cookie_utils'
local post_uri_prefix = config_props.authenticate_config.url_pre_fix .. config_props.authenticate_config.url_suffix

local function get_accesstoken_date(invalid_at)
    return date_utils:string_to_date(invalid_at)
end

--[[
-- 判断是否联通号
-- --]]
local function is_unicom(mobile)
    --[[local reqts = date_utils:date_to_string('yyyyMMddHHmmss')
    local request_params = {
        reqts = reqts, -- 请求发起时间戳，格式yyyyMMddHHmmss
        channel = '113000004', -- 发起方渠道编码,由手厅提供
        mobile = mobile, -- 手机号码
        transid = reqts .. new_uuid:uuid_number(), -- 渠道编码+yyyymmddhh24miss+6位不重复序列
        busiCode = '110002', -- 业务编码，由手厅提供（110002）
        sign = aec_utils.encrypt_fun(mobile), -- 签名,内网访问，做简单加密 ：只加密手机号码AES对称加密，秘钥由手厅提供
    }

    local result = http_utils:post(mobile_server_prefix .. config_props.mobile_server.is_unicom, request_params)
    local r_body = result.body
    if r_body then
        if typeof(r_body) == 'string' then
            r_body = cjson.decode(r_body)
        end

        if r_body.flag == '0' then return true end
    end]]

    return true
end

--[[
-- 获取用户手机卡信息
-- --]]
local function get_number_info(mobile)
    --[[local reqts = date_utils:date_to_string('yyyyMMddHHmmss')

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
    local r_body = result.body

    if r_body then
        if typeof(r_body) == 'string' then
            r_body = cjson.decode(r_body)
        end
    end]]

    -- 返回信息
    local r_body = {
        netType = '11',
        rspCode = '0000',
        provinceCode = '011',
        cityCode = '110',
        rspts = '20180117175653',
        payType = '2',
        busiCode = '110003',
        transid = '20180117095731367571',
        productName = '腾讯大王卡',
        productId = '90063345',
        mobile = '17611421727'
    }

    return r_body
end

--[[
认证新增一批品牌，通过所传品牌和网别，转义为自助对应的网别
@param brand       品牌
@param product_type 产品类型
@return 网别
--]]
local function change_product_type_2_netType(brand, product_type)
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
local function is_query_pay_type(user_info_bean)
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
local function get_effective_time(user_info_bean)
    if user_info_bean and user_info_bean.invalid_at then
        local t_valid_time = cookie_utils.get_cookies_value('invalid_at')
        if string_utils:is_not_blank(t_valid_time) then
            t_valid_time = aes_utils.decrypt_fun(t_valid_time)
        end

        local time = 24 * 60 * 60

        if string_utils:is_not_blank(t_valid_time) then
            if typeof(t_valid_time) == 'string' then t_valid_time = tonumber(t_valid_time) end

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

local function complete_user_info(user_info, location)
    local _tmp = {}
    if not user_info then return _tmp end

    local number_info = get_number_info(user_info.u_mobile)
    if number_info then
        user_info.net_type = number_info.netType
        user_info.pay_type = number_info.payType
        user_info.userType = number_info.netType
    end

    user_info.province_name = config_pros.pro_tabs['pc_' .. user_info.province_code]
    user_info.city_name = config_pros.city_tabs['cc_' .. user_info.city_code]

    --付费类型为空抓取付费类型
    if is_query_pay_type(user_info) then
        local key = user_info.user_mobile .. '_paytype'

        -- 先取缓存，不存在调用接口
        local jsonstr = redis_cluster_utils:get_val_by_key(key)
        if not jsonstr and typeof(jsonstr) == 'string' then
            local tmp_tab = cjson.decode(jsonstr)

            local tmp_log_tab = {
                param1 = '号码:',
                param2 = user_info.user_mobile,
                param3 = '付费类型取缓存信息:',
                param1 = tmp_tab.payType,
            }

            log_utils:info(tmp_log_tab)

            user_info.payType = tmp_tab.payType
        end

        if string_utils:is_blank(user_info.payType) then
            local user_number_info = get_number_info(user_info.u_mobile)
            local query_pay_type = user_number_info.payType

            if query_pay_type then
                user_info.payType = query_pay_type.payType

                --写入缓存
                local expire_time = get_effective_time(user_info) -- 获取 invi
                redis_cluster_utils:set_val_by_key(key, cjson.encode(query_pay_type), expire_time)
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
local function is_accesstoken_refreshable(user_info)
    --[[if not user_info and typeof(user_info) ~= 'table' then
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

        if os.difftime(date_utils:get_current_timestamp(), invalid_time) <= 300 then
            return true
        end

        return false
    end]]

    return false
end

--[[
-- 判断accesstoken是否失效方法，提前10秒定为真实失效，返回true代表为有效，返回false代表失效
-- --]]
local function is_accesstoken_valid(user_info)
    --[[if not user_info and typeof(user_info) ~= 'table' then
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

        if os.difftime(date_utils:get_current_timestamp(), invalid_time) <= 10 then
            return false
        end

        return true
    end]]

    return true
end

--[[
-- 判断refreshtoken是否失效方法，返回true代表为有效，返回false代表失效，距离失效时间不足60秒的认为失效。
-- --]]
local function is_refreshtoken_valid(user_info)
    --[[if not user_info and typeof(user_info) ~= 'table' then
        local tmp_log_tab = {
            log_param1 = 'authenticate_utils:is_refreshtoken_valid 传递参数为空或者不正确.',
        }
        log_utils:error(tmp_log_tab)

        return false
    else
        local invalid_time = date_utils:string_to_date(user_info.re_invalid_at)
        if os.difftime(invalid_time, date_utils:get_current_timestamp()) > 60 then
            return true
        end

        return false
    end]]

    return true
end

--[[
-- 刷新 access_token
-- --]]
local function refresh_access_token(user_info)
    if not user_info and typeof(user_info) ~= 'table' then
        local tmp_log_tab = {
            log_param1 = 'authenticate_utils.refresh_access_token 传递参数为空或者不正确.',
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
local function get_user_info(access_token)
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

    --[[local request_params = {
        app_code = config_props.authenticate_config.app_code,
        app_secret = config_props.authenticate_config.app_secret,
        grant_type = 'userinfo',
        access_token = access_token,
    }

    local user_info = http_utils:post(post_uri_prefix .. 'user_info', request_params)
    if not user_info then
        return nil
    end

    return cjson.decode(user_info.body)]]

    local user_info = {
        brand = '4G00',
        broad_band_code = '',
        cert_addr = '河南省焦作市济源市大峪镇堂岭村',
        cert_num = '410881198910276036',
        cert_type = '01',
        city_code = '110',
        credit_vale = '',
        custID = '7017111703659633',
        cust_lvl = '',
        cust_name = '张国安',
        cust_sex = '',
        errorFrom = '',
        group_info = {
            con_member_info = {},
            group_id = '2017110406923990',
            group_type = '00',
            main_card_flag = '',
            main_member_info = {},
            main_num_flag = '1',
            product_id = '90308943',
            product_name = 'TDML卡专属亲情语音产品（单向免费）'
        },
        is_inuser = '0000',
        land_lvl = '',
        last_stat_date = '20170831230325',
        last_visit_city = '110',
        last_visit_ip = '10.143.131.53',
        last_visit_rls = '炎黄iPhone手机商城客户端APP角色',
        last_visit_time = '2017-12-07 11:28:25',
        manager_contact = '',
        manager_name = '',
        needverify = '',
        net_type = '11',
        open_date = '20170831230321',
        package_id = '90063345',
        package_name = '腾讯大王卡',
        pay_type = '2',
        product_id = '17611421727',
        product_type = '01',
        province_code = '011',
        roam_stat = '3',
        rsp_code = '0000',
        rsp_desc = '正常/成功',
        simcard = '8986011781103415025',
        status = '开通',
        subscrb_type = '0',
        subscrbid = '1117083052279798',
        tel_area_code = '',
        user_head_img = '',
        user_type_status = '0000',
        vpn_name = ''
    }

    --ngx.sleep(10)

    return user_info
end

--[[
-- 获取绑定关系
-- --]]
local function get_bind_info(bind_param_tab)
    --[[if bind_param_tab and typeof(bind_param_tab == 'table') then
        local user_info = http_utils:post(post_uri_prefix .. 'user_info', bind_param_tab)
        if not user_info then
            return nil
        end

        return cjson.decode(user_info.body)
    else
        return nil
    end]]


    local bind_info = {
        broad_band_code = '',
        errorFrom = '',
        last_visit_city = '110',
        last_visit_ip = '10.143.131.53',
        last_visit_rls = '炎黄iPhone手机商城客户端APP角色',
        last_visit_time = '2018-01-18 16:37:12',
        needverify = '',
        productlist = {},
        rsp_code = '0000',
        rsp_desc = '',
        user_head_img = ''
    }

    return bind_info
end

--[[
-- 组装 userinfo 对象
-- --]]
local function assemble_user_info(user_info, login_type, decrypt_mobile)
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
        local net_type = change_product_type_2_netType(user_info.brand, user_info.product_type)
        if not net_type then net_type = '' end

        local user_info_table = {
            brand = user_info.brand, -- 品牌标识： 1-世界风 2-如意通 3-新势力 4-新时空 5-联通商务 6-其他 7-亲情1+
            -- 8-无线上网卡 9-沃 99-网站用户
            city_code = user_info.city_code, -- 城市代码
            province_code = user_info.province_code,
            open_date = user_info.open_date, -- 入网时间；yyyymmddhh24miss
            product_id = user_info.package_id, -- 产品编码
            product_name = user_info.package_name, -- 产品名称
            product_type = user_info.product_type, -- 号码类型
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
        }

        user_info_table = complete_user_info(user_info_table, user_info_table.login_type)

        return user_info_table
    end
end

--[[
-- 封装缓存 userInfo 对象
-- --]]
local function package_redis_cache_user_info(resp_result, mobile, password, version, isRemberedPwd, keyVersion,
decrypt_mobile, login_type)
    --[[
    -- 通过 access_token 获取用户信息
    -- --]]
    local user_info = get_user_info(resp_result.access_token)
    if not user_info then
        local tmp_log_tab = {
            log_param1 = 'app_login.package_redis_cache_user_info 通过 access_token 获取用户信息失败',
        }
        log_utils:error(tmp_log_tab)

    end

    local redis_cache_user_info = {}
    local user_info_bean = assemble_user_info(user_info, login_type, decrypt_mobile)

    if login_type ~= '05' then
        redis_cache_user_info.userInfoBean = user_info_bean
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
        }

        local userinfobean_list = {}
        local bind_result = get_bind_info(switch_number_model)
        if bind_result.rsp_code == '0000' then
            local productlist = bind_result.productlist
            local have_default = false
            if productlist and #productlist > 0 then
                for k, v in pairs(productlist) do
                    local tmp_tab = {}

                    if typeof(v) == 'table' then
                        tmp_tab.provice_code = v.province_code --省份编码
                        tmp_tab.brand = v.brand -- 品牌
                        tmp_tab.productType = v.product_type -- 号码类型
                        tmp_tab.city_code = v.city_code -- 地市编码
                        tmp_tab.user_mobile = v.user_mobile -- 号码
                        tmp_tab.product_id = v.package_id -- 产品编码
                        tmp_tab.netType = v.net_type -- 网别（01:2G，02:3G，10：上网卡）
                        tmp_tab.payType = v.pay_type -- 用户付费类型（1：预付费，2：后付费）
                        tmp_tab.userType = v.net_type -- 号码类型
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

                        userinfobean_list[k] = tmp_tab
                    end
                end

                if have_default then
                    redis_cache_user_info.userInfoBean = userinfobean_list[1]
                end

                redis_cache_user_info.uUserInfoBeanList = userinfobean_list
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
    redis_cache_user_info.user_head_img = user_info.user_head_img
    redis_cache_user_info.todayDate = os.date('%Y-%m-%d', date_utils:get_current_timestamp())
    redis_cache_user_info.version = version
    redis_cache_user_info.loginUserEncrypt = mobile
    redis_cache_user_info.passwordEncrypt = password
    redis_cache_user_info.isRemberPwd = isRemberedPwd
    redis_cache_user_info.keyVersion = keyVersion

    return redis_cache_user_info
end

local authenticate_utils = {
    is_unicom = is_unicom,
    get_number_info = get_number_info,
    get_effective_time = get_effective_time,
    complete_user_info = complete_user_info,
    change_product_type_2_netType = change_product_type_2_netType,
    get_accesstoken_date = get_accesstoken_date,
    is_accesstoken_refreshable = is_accesstoken_refreshable,
    is_accesstoken_valid = is_accesstoken_valid,
    is_refreshtoken_valid = is_refreshtoken_valid,
    get_user_info = get_user_info,
    get_bind_info = get_bind_info,
    refresh_access_token = refresh_access_token,
    package_redis_cache_user_info = package_redis_cache_user_info,
}

return authenticate_utils