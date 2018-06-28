--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 30/11/2017
-- Time: 10:30
-- To change this template use File | Settings | File Templates.
--
local _M = {}

--[[
-- log configuration
-- --]]
local log_config = {
    test = {
        log_level_info = {
            info = 'INFO',
            error = 'ERROR',
            debug = 'DEBUG',
        },
        log_file_info = {
            log_ip = '10.30.11.14',
            log_file_path = '/app/sinova/logs/mobile_login/',
            info_log_name = 'info.log',
            error_log_name = 'error.log',
        },
    },
    pre = {
        log_level_info = {
            info = 'INFO',
            error = 'ERROR',
            debug = 'DEBUG',
        },
        log_file_info = {
            log_ip = '127.0.0.1',
            log_file_path = '/app/sinova/logs/mobile_login/',
            info_log_name = 'info.log',
            error_log_name = 'error.log',
        },
    },
    pro = {
        log_level_info = {
            info = 'INFO',
            error = 'ERROR',
            debug = 'DEBUG',
        },
        log_file_info = {
            log_ip = '127.0.0.1',
            log_file_path = '/app/sinova/logs/mobile_login/',
            info_log_name = 'info.log',
            error_log_name = 'error.log',
        },
    },
}

local constant = {
    redis_expire_time = 7 * 24 * 60 * 60,
    appId_enc_key = '4225dbbfbef551f9f26ebecafa66c30b',
    appId_enc_iv = 'cbdc248b31ff0470c3869105a0ba7f67',
    redis_expire_time_unit =  24 * 60 * 60,
}

local activity_redis_config = {
    test = {
        offline_spread_config = {
            mobile_cluster_config = {
            -- 10.143.131.63:6378 single
                { ip = '10.143.131.63', port = 6378 },
            },
            mobile_cluster_name = 'offlineSpreadJedisClusterNodes',
            mobile_cluster_keepalive_timeout = 60000, --redis connection pool idle timeout
            mobile_cluster_keepalive_cons = 1000, --redis connection pool size
            mobile_cluster_connection_timout = 1000, --timeout while connecting
            mobile_cluster_max_redirection = 5, --maximum retry attempts for redirection
        },

        paid_share_config = {
            mobile_cluster_config = {
            -- 10.143.131.63:6391-6396 cluster
                { ip = '10.143.131.63', port = 6391 },
                { ip = '10.143.131.63', port = 6392 },
                { ip = '10.143.131.63', port = 6393 },
                { ip = '10.143.131.63', port = 6394 },
                { ip = '10.143.131.63', port = 6395 },
                { ip = '10.143.131.63', port = 6396 },
            },
            mobile_cluster_name = 'paidShareJedisClusterNodes',
            mobile_cluster_keepalive_timeout = 60000, --redis connection pool idle timeout
            mobile_cluster_keepalive_cons = 1000, --redis connection pool size
            mobile_cluster_connection_timout = 1000, --timeout while connecting
            mobile_cluster_max_redirection = 5, --maximum retry attempts for redirection
        }
    },

    pre = {
        offline_spread_config = {
            mobile_cluster_config = {
                { ip = '132.46.115.11', port = 6388 },
                { ip = '132.46.115.11', port = 6389 },

                { ip = '132.46.115.12', port = 6388 },
                { ip = '132.46.115.12', port = 6389 },

                { ip = '132.46.115.13', port = 6388 },
                { ip = '132.46.115.13', port = 6389 },

                { ip = '132.46.115.14', port = 6388 },
                { ip = '132.46.115.14', port = 6389 },
            },
            mobile_cluster_name = 'offlineSpreadJedisClusterNodes',
            mobile_cluster_keepalive_timeout = 60000, --redis connection pool idle timeout
            mobile_cluster_keepalive_cons = 1000, --redis connection pool size
            mobile_cluster_connection_timout = 1000, --timeout while connecting
            mobile_cluster_max_redirection = 5, --maximum retry attempts for redirection
        },

        paid_share_config = {
            mobile_cluster_config = {
            -- 132.38.1.205-207:6379-6380 cluster
                { ip = '132.38.1.205', port = 6379 },
                { ip = '132.38.1.205', port = 6380 },

                { ip = '132.38.1.206', port = 6379 },
                { ip = '132.38.1.206', port = 6380 },

                { ip = '132.38.1.207', port = 6379 },
                { ip = '132.38.1.207', port = 6380 },
            },
            mobile_cluster_name = 'paidShareJedisClusterNodes',
            mobile_cluster_keepalive_timeout = 60000, --redis connection pool idle timeout
            mobile_cluster_keepalive_cons = 1000, --redis connection pool size
            mobile_cluster_connection_timout = 1000, --timeout while connecting
            mobile_cluster_max_redirection = 5, --maximum retry attempts for redirection
        }
    },

    pro = {
        offline_spread_config = {
            mobile_cluster_config = {
                { ip = '132.46.115.11', port = 6388 },
                { ip = '132.46.115.11', port = 6389 },

                { ip = '132.46.115.12', port = 6388 },
                { ip = '132.46.115.12', port = 6389 },

                { ip = '132.46.115.13', port = 6388 },
                { ip = '132.46.115.13', port = 6389 },

                { ip = '132.46.115.14', port = 6388 },
                { ip = '132.46.115.14', port = 6389 },
            },
            mobile_cluster_name = 'offlineSpreadJedisClusterNodes',
            mobile_cluster_keepalive_timeout = 60000, --redis connection pool idle timeout
            mobile_cluster_keepalive_cons = 1000, --redis connection pool size
            mobile_cluster_connection_timout = 1000, --timeout while connecting
            mobile_cluster_max_redirection = 5, --maximum retry attempts for redirection
        },

        paid_share_config = {
            mobile_cluster_config = {
            -- 132.38.1.205-207:6379-6380
                { ip = '132.38.1.205', port = 6379 },
                { ip = '132.38.1.205', port = 6380 },

                { ip = '132.38.1.206', port = 6379 },
                { ip = '132.38.1.206', port = 6380 },

                { ip = '132.38.1.207', port = 6379 },
                { ip = '132.38.1.207', port = 6380 },
            },
            mobile_cluster_name = 'paidShareJedisClusterNodes',
            mobile_cluster_keepalive_timeout = 60000, --redis connection pool idle timeout
            mobile_cluster_keepalive_cons = 1000, --redis connection pool size
            mobile_cluster_connection_timout = 1000, --timeout while connecting
            mobile_cluster_max_redirection = 5, --maximum retry attempts for redirection
        }
    },
}

--[[
-- redis cluster configuration
-- --]]
local redis_config = {
    test = {
        redis_host = '10.143.131.63',
        redis_port = 6391,
        exception_code_redis_host = '10.143.131.63',
        exception_code_redis_port = 6378,
        exception_cluster_config = {
            { ip = '10.143.131.63', port = 6378 },
        },
        exception_cluster_config1 = {
            { ip = '10.20.34.16', port = 6379 },
            { ip = '10.20.34.17', port = 6379 },
        --{ ip = '132.38.1.229', port = 6379 },
        --{ ip = '132.38.1.236', port = 6379 },
        },
        exception_cluster_name = 'exceptionJedisClusterNodes',
        exception_cluster_keepalive_timeout = 60000, --redis connection pool idle timeout
        exception_cluster_keepalive_cons = 1000, --redis connection pool size
        exception_cluster_connection_timout = 1000, --timeout while connecting
        exception_cluster_max_redirection = 5, -- maximum retry attempts for redirection
        mobile_cluster_config = {
            { ip = '10.143.131.63', port = 6391 },
            { ip = '10.143.131.63', port = 6392 },
            { ip = '10.143.131.63', port = 6393 },
            { ip = '10.143.131.63', port = 6394 },
            { ip = '10.143.131.63', port = 6395 },
            { ip = '10.143.131.63', port = 6396 },
        },
        mobile_cluster_name = 'jedisClusterNodes',
        mobile_cluster_keepalive_timeout = 60000, --redis connection pool idle timeout
        mobile_cluster_keepalive_cons = 1000, --redis connection pool size
        mobile_cluster_connection_timout = 1000, --timeout while connecting
        mobile_cluster_max_redirection = 5, --maximum retry attempts for redirection
    },
    pre = {
        redis_host = '127.0.0.1',
        redis_port = 6379,
        exception_code_redis_host = '10.143.131.63',
        exception_code_redis_port = 6378,
        exception_cluster_config = {
            { ip = '10.20.34.16', port = 6379 },
            { ip = '10.20.34.17', port = 6379 },
        },
        exception_cluster_config1 = {
            { ip = '10.20.34.16', port = 6379 },
            { ip = '10.20.34.17', port = 6379 },
        --{ ip = '132.38.1.229', port = 6379 },
        --{ ip = '132.38.1.236', port = 6379 },
        },
        exception_cluster_name = 'exceptionJedisClusterNodes',
        exception_cluster_keepalive_timeout = 60000, --redis connection pool idle timeout
        exception_cluster_keepalive_cons = 1000, --redis connection pool size
        exception_cluster_connection_timout = 1000, --timeout while connecting
        exception_cluster_max_redirection = 5, -- maximum retry attempts for redirection
        mobile_cluster_config = {
        --132.46.115.11-14:6380-6387
            { ip = '132.46.115.11', port = 6380 },
            { ip = '132.46.115.11', port = 6381 },
            { ip = '132.46.115.11', port = 6382 },
            { ip = '132.46.115.11', port = 6383 },
            { ip = '132.46.115.11', port = 6384 },
            { ip = '132.46.115.11', port = 6385 },
            { ip = '132.46.115.11', port = 6386 },
            { ip = '132.46.115.11', port = 6387 },

            { ip = '132.46.115.12', port = 6380 },
            { ip = '132.46.115.12', port = 6381 },
            { ip = '132.46.115.12', port = 6382 },
            { ip = '132.46.115.12', port = 6383 },
            { ip = '132.46.115.12', port = 6384 },
            { ip = '132.46.115.12', port = 6385 },
            { ip = '132.46.115.12', port = 6386 },
            { ip = '132.46.115.12', port = 6387 },

            { ip = '132.46.115.13', port = 6380 },
            { ip = '132.46.115.13', port = 6381 },
            { ip = '132.46.115.13', port = 6382 },
            { ip = '132.46.115.13', port = 6383 },
            { ip = '132.46.115.13', port = 6384 },
            { ip = '132.46.115.13', port = 6385 },
            { ip = '132.46.115.13', port = 6386 },
            { ip = '132.46.115.13', port = 6387 },

            { ip = '132.46.115.14', port = 6380 },
            { ip = '132.46.115.14', port = 6381 },
            { ip = '132.46.115.14', port = 6382 },
            { ip = '132.46.115.14', port = 6383 },
            { ip = '132.46.115.14', port = 6384 },
            { ip = '132.46.115.14', port = 6385 },
            { ip = '132.46.115.14', port = 6386 },
            { ip = '132.46.115.14', port = 6387 },
        },
        mobile_cluster_name = 'jedisClusterNodes',
        mobile_cluster_keepalive_timeout = 60000, --redis connection pool idle timeout
        mobile_cluster_keepalive_cons = 1000, --redis connection pool size
        mobile_cluster_connection_timout = 1000, --timeout while connecting
        mobile_cluster_max_redirection = 5, --maximum retry attempts for redirection
    },
    pro = {
        redis_host = '127.0.0.1',
        redis_port = 6379,
        exception_code_redis_host = '10.143.131.63',
        exception_code_redis_port = 6378,
        exception_cluster_config = {
        -- 132.38.1.205-207:6379-6380
            { ip = '132.38.1.205', port = 6379 },
            { ip = '132.38.1.205', port = 6380 },

            { ip = '132.38.1.206', port = 6379 },
            { ip = '132.38.1.206', port = 6380 },

            { ip = '132.38.1.207', port = 6379 },
            { ip = '132.38.1.207', port = 6380 },
        },
        exception_cluster_config1 = {
        --{'10.20.34.16', 6379 },
        --{'10.20.34.17', 6379 },

            { ip = '132.38.1.229', port = 6379 },
            { ip = '132.38.1.236', port = 6379 },
        },
        exception_cluster_name = 'exceptionJedisClusterNodes',
        exception_cluster_keepalive_timeout = 60000, --redis connection pool idle timeout
        exception_cluster_keepalive_cons = 1000, --redis connection pool size
        exception_cluster_connection_timout = 1000, --timeout while connecting
        exception_cluster_max_redirection = 5, -- maximum retry attempts for redirection
        mobile_cluster_config = {
            --132.46.115.11-14:6380-6387
            { ip = '132.46.115.11', port = 6380 },
            { ip = '132.46.115.11', port = 6381 },
            { ip = '132.46.115.11', port = 6382 },
            { ip = '132.46.115.11', port = 6383 },
            { ip = '132.46.115.11', port = 6384 },
            { ip = '132.46.115.11', port = 6385 },
            { ip = '132.46.115.11', port = 6386 },
            { ip = '132.46.115.11', port = 6387 },

            { ip = '132.46.115.12', port = 6380 },
            { ip = '132.46.115.12', port = 6381 },
            { ip = '132.46.115.12', port = 6382 },
            { ip = '132.46.115.12', port = 6383 },
            { ip = '132.46.115.12', port = 6384 },
            { ip = '132.46.115.12', port = 6385 },
            { ip = '132.46.115.12', port = 6386 },
            { ip = '132.46.115.12', port = 6387 },

            { ip = '132.46.115.13', port = 6380 },
            { ip = '132.46.115.13', port = 6381 },
            { ip = '132.46.115.13', port = 6382 },
            { ip = '132.46.115.13', port = 6383 },
            { ip = '132.46.115.13', port = 6384 },
            { ip = '132.46.115.13', port = 6385 },
            { ip = '132.46.115.13', port = 6386 },
            { ip = '132.46.115.13', port = 6387 },

            { ip = '132.46.115.14', port = 6380 },
            { ip = '132.46.115.14', port = 6381 },
            { ip = '132.46.115.14', port = 6382 },
            { ip = '132.46.115.14', port = 6383 },
            { ip = '132.46.115.14', port = 6384 },
            { ip = '132.46.115.14', port = 6385 },
            { ip = '132.46.115.14', port = 6386 },
            { ip = '132.46.115.14', port = 6387 },
        },
        mobile_cluster_name = 'jedisClusterNodes',
        mobile_cluster_keepalive_timeout = 60000, --redis connection pool idle timeout
        mobile_cluster_keepalive_cons = 1000, --redis connection pool size
        mobile_cluster_connection_timout = 1000, --timeout while connecting
        mobile_cluster_max_redirection = 5, --maximum retry attempts for redirection
    },
}

--[[
-- push redis configuration
--]]
local notice_redis_config = {
    test = {
        notice_cluster_config = {
            {
                redis_host = '10.20.34.16',
            --redis_host = '132.38.1.229',
                redis_port = 6379
            },
            {
            --redis_host = '10.20.34.17',
                redis_host = '132.38.1.236',
                redis_port = 6379
            },
        },
    },
    pre = {
        notice_cluster_config = {
            {
                redis_host = '10.20.34.16',
            --redis_host = '132.38.1.229',
                redis_port = 6379
            },
            {
                redis_host = '10.20.34.17',
            --redis_host = '132.38.1.236',
                redis_port = 6379
            },
        },
    },
    pro = {
        notice_cluster_config = {
            {
            --redis_host = '10.20.34.16',
                redis_host = '132.38.1.229',
                redis_port = 6379
            },
            {
            --redis_host = '10.20.34.17',
                redis_host = '132.38.1.236',
                redis_port = 6379
            },
        },
    },
}

--[[
-- authenticate configuration
-- --]]
local authenticate_config = {
    test = {
        app_code = 'ECS-YH',
        app_secret = 'kdgvy7WZTW5RMSKde93O3Z86',
        redirect_url = 'uop:oauth2.0:token',
        url_pre_fix = 'http://10.143.131.53:11001',
        url_suffix = '/oauth2/',
        retry_time = 1,
    },
    pre = {
        app_code = 'ECS-YH',
        app_secret = 'kdgvy7WZTW5RMSKde93O3Z86',
        redirect_url = 'uop:oauth2.0:token',
        url_pre_fix = 'http://132.46.110.67:7080',
        url_suffix = '/oauth2/',
        retry_time = 1,
    },
    pro = {
        app_code = 'ECS-YH',
        app_secret = 'kdgvy7WZTW5RMSKde93O3Z86',
        redirect_url = 'uop:oauth2.0:token',
    --url_pre_fix = 'http://132.46.110.67:7080',
        url_pre_fix = 'http://127.0.0.1:8039',
        url_suffix = '/oauth2/',
        retry_time = 1,
    },
}

--[[
-- mobileService userInfo api
--]]
local mobile_server = {
    test = {
        server_prefix = 'http://10.30.11.14:8001',
        is_unicom = '/mobileServiceClient-test/api/isUnicom.htm', --判断联通号码
        is_bili = '/mobileServiceClient-test/api/isBili.htm', --判断bili卡
        get_num_info = '/mobileServiceClient-test/api/getNumInfo.htm', -- 获取用户信息
        is_tencent_card = '/mobileServiceClient-test/api/isTencentCard.htm', -- 判断腾讯王卡
    },
    pre = {
        server_prefix = 'http://10.142.195.54:8010',
        is_unicom = '/mobileService/api/isUnicom.htm', --判断联通号码
        is_bili = '/mobileService/api/isBili.htm', --判断bili卡
        get_num_info = '/mobileService/api/getNumInfo.htm', -- 获取用户信息
        is_tencent_card = '/mobileService/api/isTencentCard.htm', -- 判断腾讯王卡
    },
    pro = {
    --server_prefix = 'http://132.46.115.16:8007/mobileService/api',
        server_prefix = 'http://127.0.0.1:8038',
        is_unicom = '/mobileService/api/isUnicom.htm', --判断联通号码
        is_bili = '/mobileService/api/isBili.htm', --判断bili卡
        get_num_info = '/mobileService/api/getNumInfo.htm', -- 获取用户信息
        is_tencent_card = '/mobileService/api/isTencentCard.htm', -- 判断腾讯王卡
    },
}

--[[
-- 2I 判断
--]]
local wo_and2i_judge_config = {
    test = {
        url_pre_fix = 'http://client.10010.com',
        wo_or_2I_url = '/mobileService/api/checkWoAndTowICard.htm'
    },
    pre = {
    --url_pre_fix = 'http://client.10010.com/mobileService/api',
        url_pre_fix = 'http://10.142.195.52:8002',
        wo_or_2I_url = '/mobileService/api/checkWoAndTowICard.htm'
    },
    pro = {
    --url_pre_fix = 'http://10.142.195.52:8002/mobileService/api',
    --url_pre_fix = 'http://132.46.115.104:8002/mobileService/api',
        url_pre_fix = 'http://127.0.0.1:8038',
        wo_or_2I_url = '/mobileService/api/checkWoAndTowICard.htm'
    }
}

--[[
-- client address configuration
-- --]]
local client_server_config = {
    test = {
        client_domain = '211.94.67.58',
        client_port = '80',
        client_server = 'mobileServiceDevelop',
    },
    pre = {
        client_domain = 'm.client.10010.com',
        client_port = '80',
        client_server = 'mobileService',
    },
    pro = {
        client_domain = 'm.client.10010.com',
        client_port = '80',
        client_server = 'mobileService',
    },
}

--[[
-- kafka configuration
-- --]]
local kafka_server_config = {
    test = {
        server_ip = '127.0.0.1',
        server_topic = 'test',
        message_key = 'test',
    },
    pre = {
        server_ip = '127.0.0.1',
        server_topic = 'test',
        message_key = 'test',
    },
    pro = {
        server_ip = '127.0.0.1',
        server_topic = 'test',
        message_key = 'test',
    },
}

--[[
-- switch config
-- --]]
local switchs = {
    test = {
        limit_bind_counts = 5,
        login_limit_switch = '0',
        service_limit_enable = true,
        enable_login_cache = false, -- 登录缓存开启与否 true: 开启 false: 关闭
    },
    pre = {
        limit_bind_counts = 5,
        login_limit_switch = '1',
        service_limit_enable = true,
        enable_login_cache = true, -- 登录缓存开启与否 true: 开启 false: 关闭
    },
    pro = {
        limit_bind_counts = 5,
        login_limit_switch = '0', -- appId 校验开关 0  关闭 1 打开
        service_limit_enable = true,
        enable_login_cache = true, -- 登录缓存开启与否 true: 开启 false: 关闭
    }
}

--[[
-- city code map city name
--]]
_M.city_tabs = {
    cc_843 = '渭南',
    cc_101 = '呼和浩特',
    cc_476 = '台州',
    cc_919 = '辽阳',
    cc_704 = '海西洲',
    cc_513 = '陵水',
    cc_114 = '阿拉善盟',
    cc_711 = '宜昌',
    cc_316 = '黄山',
    cc_160 = '莱芜',
    cc_791 = '娄底',
    cc_194 = '晋城',
    cc_765 = '许昌',
    cc_770 = '周口',
    cc_181 = '唐山',
    cc_822 = '南充',
    cc_558 = '韶关',
    cc_354 = '淮安',
    cc_753 = '新余',
    cc_156 = '东营',
    cc_746 = '浏阳',
    cc_990 = '黑河',
    cc_188 = '石家庄',
    cc_798 = '山南',
    cc_971 = '哈尔滨',
    cc_905 = '通化',
    cc_718 = '鄂州',
    cc_108 = '呼伦贝尔',
    cc_910 = '沈阳',
    cc_732 = '文山',
    cc_440 = '常州',
    cc_727 = '恩施',
    cc_525 = '汕尾',
    cc_921 = '盘锦',
    cc_844 = '咸阳',
    cc_514 = '琼中',
    cc_113 = '兴安盟',
    cc_716 = '襄阳',
    cc_311 = '宣城',
    cc_106 = '乌海',
    cc_501 = '海口',
    cc_304 = '六安',
    cc_703 = '德令哈',
    cc_172 = '泰安',
    cc_777 = '南阳',
    cc_370 = '宁波',
    cc_796 = '永州',
    cc_193 = '大同',
    cc_594 = '梧州',
    cc_940 = '大连',
    cc_158 = '济宁',
    cc_825 = '德阳',
    cc_748 = '郴州',
    cc_741 = '长沙',
    cc_346 = '连云港',
    cc_754 = '鹰潭',
    cc_151 = '滨州',
    cc_556 = '中山',
    cc_976 = '佳木斯',
    cc_813 = '攀枝花',
    cc_588 = '贺州',
    cc_508 = '万宁',
    cc_893 = '石河子',
    cc_917 = '营口',
    cc_886 = '中卫',
    cc_318 = '亳州',
    cc_720 = '衡水',
    cc_735 = '迪庆',
    cc_130 = '天津',
    cc_885 = '固原',
    cc_901 = '长春',
    cc_890 = '乌鲁木齐',
    cc_709 = '玉树州',
    cc_914 = '本溪',
    cc_736 = '西双版纳',
    cc_723 = '随州',
    cc_350 = '徐州',
    cc_757 = '上饶',
    cc_152 = '威海',
    cc_742 = '株洲',
    cc_540 = '深圳',
    cc_994 = '双鸭山',
    cc_789 = '安顺',
    cc_810 = '成都',
    cc_981 = '大庆',
    cc_768 = '商丘',
    cc_199 = '朔州',
    cc_988 = '牡丹江',
    cc_795 = '怀化',
    cc_190 = '太原',
    cc_597 = '钦州',
    cc_387 = '南平',
    cc_774 = '鹤壁',
    cc_819 = '眉山',
    cc_826 = '广元',
    cc_847 = '商洛',
    cc_528 = '梅州',
    cc_922 = '葫芦岛',
    cc_105 = '巴彦淖尔',
    cc_502 = '三亚',
    cc_307 = '淮南',
    cc_670 = '河源',
    cc_517 = '昌江',
    cc_110 = '北京',
    cc_715 = '黄石',
    cc_312 = '滁州',
    cc_897 = '喀什',
    cc_309 = '巢湖',
    cc_469 = '丽水',
    cc_906 = '辽源',
    cc_724 = '荆门',
    cc_849 = '汉中',
    cc_526 = '揭阳',
    cc_731 = '保山',
    cc_533 = '潮阳',
    cc_745 = '岳阳',
    cc_828 = '甘孜',
    cc_750 = '南昌',
    cc_155 = '潍坊',
    cc_599 = '北海',
    cc_802 = '阿里',
    cc_389 = '三明',
    cc_817 = '宜宾',
    cc_787 = '遵义',
    cc_380 = '福州',
    cc_773 = '濮阳',
    cc_182 = '秦皇岛',
    cc_395 = '漳州',
    cc_792 = '邵阳',
    cc_197 = '临汾',
    cc_590 = '防城港',
    cc_759 = '抚州',
    cc_821 = '遂宁',
    cc_840 = '宝鸡',
    cc_510 = '广州',
    cc_712 = '荆州',
    cc_102 = '包头',
    cc_505 = '文昌',
    cc_300 = '马鞍山',
    cc_707 = '黄南州',
    cc_358 = '南通',
    cc_827 = '巴中',
    cc_170 = '济南',
    cc_775 = '济源',
    cc_818 = '自贡',
    cc_989 = '绥化',
    cc_794 = '张家界',
    cc_191 = '晋中',
    cc_760 = '郑州',
    cc_516 = '乐东',
    cc_111 = '锡林郭勒盟',
    cc_714 = '黄冈',
    cc_909 = '延边',
    cc_104 = '鄂尔多斯',
    cc_503 = '儋州',
    cc_306 = '阜阳',
    cc_701 = '海东',
    cc_853 = '六盘水',
    cc_846 = '铜川',
    cc_722 = '神农架',
    cc_520 = '湛江',
    cc_330 = '无锡',
    cc_445 = '泰州',
    cc_891 = '昌吉',
    cc_678 = '顺德',
    cc_915 = '丹东',
    cc_884 = '石嘴山',
    cc_900 = '哈密',
    cc_769 = '平顶山',
    cc_198 = '忻州',
    cc_995 = '大兴安岭',
    cc_788 = '黔南',
    cc_811 = '雅安',
    cc_743 = '湘潭',
    cc_756 = '宜春',
    cc_153 = '临沂',
    cc_898 = '伊犁',
    cc_820 = '达州',
    cc_871 = '定西',
    cc_895 = '巴州',
    cc_894 = '吐鲁番',
    cc_758 = '萍乡',
    cc_835 = '巫山',
    cc_360 = '杭州',
    cc_899 = '克拉玛依',
    cc_362 = '湖州',
    cc_793 = '湘西',
    cc_196 = '运城',
    cc_591 = '南宁',
    cc_570 = '惠州',
    cc_708 = '果洛州',
    cc_772 = '三门峡',
    cc_183 = '廊坊',
    cc_103 = '乌兰察布盟',
    cc_504 = '琼海',
    cc_301 = '蚌埠',
    cc_480 = '泉州',
    cc_511 = '澄迈',
    cc_852 = '黔西南',
    cc_713 = '江汉',
    cc_314 = '淮北',
    cc_841 = '西安',
    cc_700 = '西宁',
    cc_706 = '海北洲',
    cc_874 = '武威',
    cc_865 = '玉溪',
    cc_879 = '白银',
    cc_961 = '甘南',
    cc_960 = '陇南',
    cc_877 = '天水',
    cc_730 = '德宏',
    cc_931 = '酒泉',
    cc_876 = '嘉峪关',
    cc_725 = '天门',
    cc_848 = '安康',
    cc_875 = '张掖',
    cc_930 = '金昌',
    cc_883 = '吴忠',
    cc_468 = '衢州',
    cc_907 = '白城',
    cc_873 = '庆阳',
    cc_872 = '平凉',
    cc_896 = '阿克苏',
    cc_870 = '兰州',
    cc_912 = '鞍山',
    cc_992 = '七台河',
    cc_878 = '临夏',
    cc_816 = '内江',
    cc_384 = '龙岩',
    cc_850 = '贵阳',
    cc_951 = '博乐',
    cc_598 = '河池',
    cc_973 = '齐齐哈尔',
    cc_954 = '克州',
    cc_751 = '吉安',
    cc_154 = '日照',
    cc_953 = '阿勒泰',
    cc_744 = '衡阳',
    cc_343 = '镇江',
    cc_955 = '和田',
    cc_952 = '塔城',
    cc_799 = '林芝',
    cc_519 = '屯昌',
    cc_518 = '白沙',
    cc_800 = '昌都',
    cc_991 = '鸡西',
    cc_386 = '宁德',
    cc_189 = '承德',
    cc_861 = '红河',
    cc_747 = '益阳',
    cc_340 = '南京',
    cc_308 = '铜陵',
    cc_867 = '昭通',
    cc_506 = '东方',
    cc_752 = '赣州',
    cc_157 = '枣庄',
    cc_550 = '江门',
    cc_726 = '潜江',
    cc_801 = '那曲',
    cc_593 = '柳州',
    cc_166 = '青岛',
    cc_863 = '丽江',
    cc_733 = '临沧',
    cc_596 = '百色',
    cc_531 = '潮州',
    cc_869 = '普洱',
    cc_109 = '通辽',
    cc_864 = '楚雄',
    cc_911 = '铁岭',
    cc_880 = '银川',
    cc_866 = '曲靖',
    cc_904 = '松原',
    cc_719 = '咸宁',
    cc_512 = '临高',
    cc_862 = '大理',
    cc_710 = '武汉',
    cc_317 = '池州',
    cc_860 = '昆明',
    cc_507 = '五指山',
    cc_868 = '景洪',
    cc_705 = '海南洲',
    cc_851 = '毕节',
    cc_830 = '资阳',
    cc_538 = '云浮',
    cc_786 = '黔东南',
    cc_842 = '延安',
    cc_829 = '阿坝',
    cc_186 = '邯郸',
    cc_814 = '乐山',
    cc_815 = '泸州',
    cc_823 = '广安',
    cc_184 = '张家口',
    cc_776 = '信阳',
    cc_349 = '宿迁',
    cc_173 = '德州',
    cc_763 = '焦作',
    cc_192 = '阳泉',
    cc_785 = '铜仁',
    cc_174 = '聊城',
    cc_601 = '来宾',
    cc_180 = '沧州',
    cc_161 = '烟台',
    cc_790 = '拉萨',
    cc_195 = '长治',
    cc_592 = '桂林',
    cc_996 = '伊春',
    cc_535 = '清远',
    cc_812 = '凉山',
    cc_589 = '贵港',
    cc_568 = '茂名',
    cc_908 = '白山',
    cc_560 = '汕头',
    cc_764 = '新乡',
    cc_200 = '吕梁',
    cc_755 = '九江',
    cc_150 = '淄博',
    cc_185 = '邢台',
    cc_740 = '景德镇',
    cc_450 = '苏州',
    cc_565 = '阳江',
    cc_766 = '漯河',
    cc_771 = '驻马店',
    cc_734 = '怒江',
    cc_367 = '金华',
    cc_536 = '肇庆',
    cc_721 = '十堰',
    cc_913 = '抚顺',
    cc_303 = '芜湖',
    cc_993 = '鹤岗',
    cc_313 = '宿州',
    cc_302 = '安庆',
    cc_903 = '四平',
    cc_620 = '珠海',
    cc_509 = '定安',
    cc_892 = '奎屯',
    cc_363 = '嘉兴',
    cc_916 = '锦州',
    cc_107 = '赤峰',
    cc_470 = '温州',
    cc_305 = '合肥',
    cc_702 = '格尔木',
    cc_515 = '保亭',
    cc_610 = '香港',
    cc_717 = '孝感',
    cc_310 = '上海',
    cc_845 = '榆林',
    cc_728 = '仙桃',
    cc_918 = '阜新',
    cc_761 = '洛阳',
    cc_430 = '扬州',
    cc_920 = '朝阳',
    cc_902 = '吉林',
    cc_365 = '绍兴',
    cc_824 = '绵阳',
    cc_749 = '常德',
    cc_530 = '佛山',
    cc_762 = '开封',
    cc_348 = '盐城',
    cc_831 = '重庆',
    cc_767 = '安阳',
    cc_159 = '菏泽',
    cc_390 = '厦门',
    cc_797 = '日喀则',
    cc_364 = '舟山',
    cc_595 = '玉林',
    cc_600 = '崇左',
    cc_385 = '莆田',
    cc_580 = '东莞',
    cc_187 = '保定'
}

--[[
-- pro code map pro name
--]]
_M.pro_tabs = {
    pc_098 = '中国联通总部',
    pc_071 = '湖北',
    pc_070 = '青海',
    pc_074 = '湖南',
    pc_010 = '内蒙古',
    pc_075 = '江西',
    pc_011 = '北京',
    pc_076 = '河南',
    pc_013 = '天津',
    pc_079 = '西藏',
    pc_017 = '山东',
    pc_081 = '四川',
    pc_018 = '河北',
    pc_083 = '重庆',
    pc_019 = '山西',
    pc_084 = '陕西',
    pc_022 = '澳门',
    pc_085 = '贵州',
    pc_030 = '安徽',
    pc_086 = '云南',
    pc_031 = '上海',
    pc_087 = '甘肃',
    pc_034 = '江苏',
    pc_088 = '宁夏',
    pc_036 = '浙江',
    pc_089 = '新疆',
    pc_038 = '福建',
    pc_090 = '吉林',
    pc_050 = '海南',
    pc_091 = '辽宁',
    pc_051 = '广东',
    pc_097 = '黑龙江',
    pc_059 = '广西',
}

--推送服务请求地址（测试环境10.143.131.53:8001）（生产环境10.20.34.19:8001
local client_push = {
    test = {
    --推送服务请求地址（测试环境10.143.131.53:8001）（生产环境10.20.34.19:8001）
        url = 'http://10.143.131.53:8001/pushweb/push',
    --推送服务请求参数
        paramXmlKey = 'message',
    --PUSH0000:注册; PUSH0002:消息推送,PUSH0001:用户绑定;
        clientPushOperation = 'PUSH0000,PUSH0002,PUSH0001',
    --来源地
        procId = 'yh',
    --加密前源
        srcCode = 'UUID',
    -- 加密随机各数
        aesIndex = 11,
    -- 单次从队列中取出推送信息的个数
        len = 20,
    -- 推送线程沉睡时间 10秒
        time = 100,
    --推送队列名称
        PUSH_SERVICE_QUEUE = 'push_service_str',
    },
    pre = {
    --推送服务请求地址（测试环境10.143.131.53:8001）（生产环境10.20.34.19:8001）
        url = 'http://10.143.131.53:8001/pushweb/push',
    --推送服务请求参数
        paramXmlKey = 'message',
    --PUSH0000:注册; PUSH0002:消息推送,PUSH0001:用户绑定;
        clientPushOperation = 'PUSH0000,PUSH0002,PUSH0001',
    --来源地
        procId = 'yh',
    --加密前源
        srcCode = 'UUID',
    -- 加密随机各数
        aesIndex = 11,
    -- 单次从队列中取出推送信息的个数
        len = 20,
    -- 推送线程沉睡时间 10秒
        time = 100,
    --推送队列名称
        PUSH_SERVICE_QUEUE = 'push_service_str',
    },
    pro = {
    --推送服务请求地址（测试环境10.143.131.53:8001）（生产环境10.20.34.19:8001）
        url = 'http://10.10.134.13/pushweb/push',
    --推送服务请求参数
        paramXmlKey = 'message',
    --PUSH0000:注册; PUSH0002:消息推送,PUSH0001:用户绑定;
    --clientPushOperation = 'PUSH0000,PUSH0002,PUSH0001',
        clientPushOperation = 'PUSH0001',
    --来源地
        procId = 'yh',
    --加密前源
        srcCode = 'UUID',
    -- 加密随机各数
        aesIndex = 11,
    -- 单次从队列中取出推送信息的个数
        len = 20,
    -- 推送线程沉睡时间 10秒
        time = 100,
    --推送队列名称
        PUSH_SERVICE_QUEUE = 'push_service_str',
    }
}

local aes_str = {
    AES0 = 'CfAaVIBblv+0ZpR4tL96fw==',
    AES1 = 'ng3qqXjlHhjV7AyQ07Wd6Q==',
    AES2 = '1JHdO8EfZz9H6lHir+klAQ==',
    AES3 = 'fha8y/FXu9WA3XJRTiiHkA==',
    AES4 = 'aGYYxBVCoiz6J/PlmKAjIQ==',
    AES5 = 'n5sniU+su4J0s4OqorWhkQ==',
    AES6 = '8CtdIe4aN53MJaWVwSPZBg==',
    AES7 = 'u+D1kao8M8dnxmo6lVgnIg==',
    AES8 = 'EXrTBaCCXBqN0/WMpLvPkA==',
    AES9 = 'paAX4WcC5cK7n2Z14C70aw==',
    AESA = 'wrong number!',
}

--[[
-- third interface http config
--]]
local third_interface_http_config = {
    test = {
        http_timeout_ms = 3000, -- ms
        http_timeout_sec = 3, -- sec
    },

    pre = {
        http_timeout_ms = 3000, -- ms
        http_timeout_sec = 3, -- sec
    },

    pro = {
        http_timeout_ms = 5000, -- ms
        http_timeout_sec = 5, -- sec
    },
}

--[[
-- UNIFIED NOTICE: exception message get machine config from
--]]
local un_exception_message_config = {
    test = {
        exception_message_config = {
            mobile_cluster_config = {
            -- 10.143.131.63:6391-6393 cluster

                { ip = '132.38.0.34', port = 6379 },

            --{ ip = '10.143.131.63', port = 6391 },
            --{ ip = '10.143.131.63', port = 6392 },
            --{ ip = '10.143.131.63', port = 6393 },
            },
            mobile_cluster_name = 'unExceptionMessageJedisClusterNodes',
            mobile_cluster_keepalive_timeout = 60000, --redis connection pool idle timeout
            mobile_cluster_keepalive_cons = 1000, --redis connection pool size
            mobile_cluster_connection_timout = 1000, --timeout while connecting
            mobile_cluster_max_redirection = 5, --maximum retry attempts for redirection
        }
    },
    pre = {
        exception_message_config = {
            mobile_cluster_config = {
            -- 10.143.131.63:6391-6393 cluster
                { ip = '10.20.15.19', port = 6379 },

            --{ ip = '10.143.131.63', port = 6391 },
            --{ ip = '10.143.131.63', port = 6392 },
            --{ ip = '10.143.131.63', port = 6393 },
            },
            mobile_cluster_name = 'unExceptionMessageJedisClusterNodes',
            mobile_cluster_keepalive_timeout = 60000, --redis connection pool idle timeout
            mobile_cluster_keepalive_cons = 1000, --redis connection pool size
            mobile_cluster_connection_timout = 1000, --timeout while connecting
            mobile_cluster_max_redirection = 5, --maximum retry attempts for redirection
        }
    },
    pro = {
        exception_message_config = {
            mobile_cluster_config = {
            --10.20.48.12-15 6388-6389
            --10.20.48.12 ---132.38.1.68
            --10.20.48.13 ---132.38.1.69
            --10.20.48.14 ---132.38.1.70
            --10.20.48.15--- 132.38.1.71

            --{ip = '132.38.1.68', port = 6388},
            --{ip = '132.38.1.68', port = 6389},
            --
            --{ip = '132.38.1.69', port = 6388},
            --{ip = '132.38.1.69', port = 6389},
            --
            --{ip = '132.38.1.70', port = 6388},
            --{ip = '132.38.1.70', port = 6389},
            --
            --{ip = '132.38.1.71', port = 6388},
            --{ip = '132.38.1.71', port = 6389},

            --{ip = '132.38.0.34', port = 6379},
                { ip = '127.0.0.1', port = 6378 },
            },
            mobile_cluster_name = 'unExceptionMessageJedisClusterNodes',
            mobile_cluster_keepalive_timeout = 60000, --redis connection pool idle timeout
            mobile_cluster_keepalive_cons = 1000, --redis connection pool size
            mobile_cluster_connection_timout = 1000, --timeout while connecting
            mobile_cluster_max_redirection = 5, --maximum retry attempts for redirection
        }
    },
}

--[[
-- ecs error code
--]]
local ecs_error_code = {
    ECS000000001 = '自助接口返回JSON转译错误',
    ECS000000002 = '业务访问限制超出限制次数',
    ECS000000003 = '服务层调用外围系统超时',
    ECS000000004 = '自助服务返回JSON为空',
    ECS000000005 = '自助服务返回编码为空',
    ECS000000006 = '服务层-业务出账期限制',
    YH3107020110 = '订单号为空',
    YH3107000033 = '请求参数业务编码无匹配',
    ECS000000006 = '积分商城请求参数加密错误',
    ECS000000007 = '积分商城MD5加密错误',
    ECS000000008 = '积分商城请求超时',
    ECS000000009 = '积分商城返回数据解析错误',
    ECS000000010 = '支付实名认证请求参数加密错误',
    ECS000000011 = '支付实名认证MD5加密错误',
    ECS000000012 = '支付实名认证请求超时',
    ECS000000013 = '支付实名认证返回数据解析错误',
    ECS000000014 = '服务层调用外围系统网络异常',
    ECS000000015 = '服务层调用外围系统IO异常',
}

--[[
-- current active environment var
-- --]]
_M.active_env = 'pro'

--[[
-- get exception message switch
--]]
_M.exception_message_switch = 'un'

--[[
-- write log type
-- 01 'kafka'
-- 02 'local file'
--]]
local log_record_type_config = {
    test = {
        log_record_type = '02'
    },
    pre = {
        log_record_type = '02'
    },
    pro = {
        log_record_type = '01'
    }
}

local ecs_config_params = {
    test = {
        serviceAddress = 'http://132.46.120.28:8888/ssp-gateway-release', -- 服务地址
        timeOut = '10000000', --超时时间
        signKey= 'bhgjDQRazK4bNAof1F0jnyITv0TmGdvENrHC9+eIWG0k5KKpg1Ag9DMXMdOyuB5d9NWX/dLNxKZ5FBX/UCOBNQ==',-- hmacmd5 加密key
        signType = 'hmac', -- 加密类型
        rsaKey = 'MIIBVgIBADANBgkqhkiG9w0BAQEFAASCAUAwggE8AgEAAkEAjSww8T8YtScn8zgjufcpPOFP5A2v8pnbKfVTGv225P2C1AIgtjYVbU+2RWr5IjfSZxm7lTkx6nDirj1Pg59uEwIDAQABAkEAi/1yWwhSm/DEMO9Oni51+iUDcAYSn+Pp7OWVD4LgRpmUEBt+2Pldo0bJzIsDF+86TUymXycFV1GDA8ZGUBo2YQIhAMe+AnEKxjDX+29Q0H1O0Gzujaj/4l3ebj6NkH6Kk+h/AiEAtO8k9H5LCxcdrP+1cec3fK2y5gYm7QMcvaoNmhEikG0CIQDB/0YXzMMZhWxrfS5Bxl6grkFgNscBLJwenRgOD0IAuQIga7Ig3ArEXkCPIGdAOCE5bNPzNWmaB9+fXuF2oSrr2O0CIQCnIZTaJ/4EUTv5DXdRyeuWZkvLgtsZOl8dc9foQhvPuw==', -- rsa 私钥
        rsaPubKey = 'MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAI0sMPE/GLUnJ/M4I7n3KTzhT+QNr/KZ2yn1Uxr9tuT9gtQCILY2FW1PtkVq+SI30mcZu5U5Mepw4q49T4OfbhMCAwEAAQ==', -- rsa 公钥
        aesKey = 'IRQ50Zz8HqByTo+waEICjw==', -- aes 加密 key
        ECSUrlNum = '0',
        moreLVSflag = 0,
        AES = '0.0.1',
        HMAC= '0.0.1',
        RSA = '0.0.1',
    },
    pre = {
        serviceAddress = 'http://132.46.120.28:8888/ssp-gateway-release', -- 服务地址
        timeOut = '10000000', --超时时间
        signKey= 'bhgjDQRazK4bNAof1F0jnyITv0TmGdvENrHC9+eIWG0k5KKpg1Ag9DMXMdOyuB5d9NWX/dLNxKZ5FBX/UCOBNQ==',-- hmacmd5 加密key
        signType = 'hmac', -- 加密类型
        rsaKey = 'MIIBVgIBADANBgkqhkiG9w0BAQEFAASCAUAwggE8AgEAAkEAjSww8T8YtScn8zgjufcpPOFP5A2v8pnbKfVTGv225P2C1AIgtjYVbU+2RWr5IjfSZxm7lTkx6nDirj1Pg59uEwIDAQABAkEAi/1yWwhSm/DEMO9Oni51+iUDcAYSn+Pp7OWVD4LgRpmUEBt+2Pldo0bJzIsDF+86TUymXycFV1GDA8ZGUBo2YQIhAMe+AnEKxjDX+29Q0H1O0Gzujaj/4l3ebj6NkH6Kk+h/AiEAtO8k9H5LCxcdrP+1cec3fK2y5gYm7QMcvaoNmhEikG0CIQDB/0YXzMMZhWxrfS5Bxl6grkFgNscBLJwenRgOD0IAuQIga7Ig3ArEXkCPIGdAOCE5bNPzNWmaB9+fXuF2oSrr2O0CIQCnIZTaJ/4EUTv5DXdRyeuWZkvLgtsZOl8dc9foQhvPuw==', -- rsa 私钥
        rsaPubKey = 'MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAI0sMPE/GLUnJ/M4I7n3KTzhT+QNr/KZ2yn1Uxr9tuT9gtQCILY2FW1PtkVq+SI30mcZu5U5Mepw4q49T4OfbhMCAwEAAQ==', -- rsa 公钥
        aesKey = 'IRQ50Zz8HqByTo+waEICjw==', -- aes 加密 key
        ECSUrlNum = '0',
        moreLVSflag = 0,
        AES = '0.0.1',
        HMAC= '0.0.1',
        RSA = '0.0.1',
    },
    pro = {
        serviceAddress = 'http://132.46.120.28:8888/ssp-gateway-release', -- 服务地址
        timeOut = '10000000', --超时时间
        signKey= 'bhgjDQRazK4bNAof1F0jnyITv0TmGdvENrHC9+eIWG0k5KKpg1Ag9DMXMdOyuB5d9NWX/dLNxKZ5FBX/UCOBNQ==',-- hmacmd5 加密key
         signType = 'hmac', -- 加密类型
        rsaKey = 'MIIBVgIBADANBgkqhkiG9w0BAQEFAASCAUAwggE8AgEAAkEAjSww8T8YtScn8zgjufcpPOFP5A2v8pnbKfVTGv225P2C1AIgtjYVbU+2RWr5IjfSZxm7lTkx6nDirj1Pg59uEwIDAQABAkEAi/1yWwhSm/DEMO9Oni51+iUDcAYSn+Pp7OWVD4LgRpmUEBt+2Pldo0bJzIsDF+86TUymXycFV1GDA8ZGUBo2YQIhAMe+AnEKxjDX+29Q0H1O0Gzujaj/4l3ebj6NkH6Kk+h/AiEAtO8k9H5LCxcdrP+1cec3fK2y5gYm7QMcvaoNmhEikG0CIQDB/0YXzMMZhWxrfS5Bxl6grkFgNscBLJwenRgOD0IAuQIga7Ig3ArEXkCPIGdAOCE5bNPzNWmaB9+fXuF2oSrr2O0CIQCnIZTaJ/4EUTv5DXdRyeuWZkvLgtsZOl8dc9foQhvPuw==', -- rsa 私钥
        rsaPubKey = 'MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAI0sMPE/GLUnJ/M4I7n3KTzhT+QNr/KZ2yn1Uxr9tuT9gtQCILY2FW1PtkVq+SI30mcZu5U5Mepw4q49T4OfbhMCAwEAAQ==', -- rsa 公钥
        aesKey = 'IRQ50Zz8HqByTo+waEICjw==', -- aes 加密 key
        ECSUrlNum = '0',
        moreLVSflag = 0,
        AES = '0.0.1',
        HMAC= '0.0.1',
        RSA = '0.0.1',
    }
}

function _M.new(self)
    self.env = self.active_env
    self.exception_message_switch = self.exception_message_switch
    _M.redis_config = redis_config[self.env]
    _M.log_config_level = log_config[self.env].log_level_info
    _M.log_config_file = log_config[self.env].log_file_info
    _M.authenticate_config = authenticate_config[self.env]
    _M.client_server_config = client_server_config[self.env]
    _M.kafka_server_config = kafka_server_config[self.env]
    _M.switchs = switchs[self.env]
    _M.mobile_server = mobile_server[self.env]
    _M.client_push = client_push[self.env]
    _M.aes_str = aes_str
    _M.third_interface_http_config = third_interface_http_config[self.env]
    _M.ecs_error_code = ecs_error_code
    _M.constant = constant
    _M.activity_redis_config = activity_redis_config[self.env]
    _M.wo_and2i_judge_config = wo_and2i_judge_config[self.env]
    _M.notice_redis_config = notice_redis_config[self.env]
    _M.un_exception_message_config = un_exception_message_config[self.env]
    _M.log_record_type_config = log_record_type_config[self.env]
    _M.ecs_config_params = ecs_config_params[self.env]

    return setmetatable(_M, { __index = self })
end

return _M
