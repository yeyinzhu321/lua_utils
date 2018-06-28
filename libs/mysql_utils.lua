local mysql = require "resty.mysql"
local function connect()
    local db, err = mysql:new()
    if not db then
        return false
    end
    db:set_timeout(1000)

    local ok, err, errno, sqlstate = db:connect{
        host = "127.0.0.1",
        port = 3306,
        database = "ngx_test",
        user = "root",
        password = "000000",
        max_packet_size = 1024 * 1024
    }

    if not ok then
        local tmp_log_tab = {
            log_param1 = 'mysql_utils.connect occur exception:',
            log_param2 = err,
        }
        log_utils:info(tmp_log_tab)

        return false
    end

    return db
end

local mysql_utils = {
    connect = connect,
}
return mysql_utils
