--
-- Created by IntelliJ IDEA.
-- User: zhuzi
-- Date: 18/12/2017
-- Time: 18:33
-- To change this template use File | Settings | File Templates.
--
local _M = {
    m_rangeMap = {}
}

function _M:new(self)
    return setmetatable(_M, {__index = self})
end

function _M:getRandom()
    --避免时差太小
    math.randomseed(tostring(date_utils:get_current_timestamp()):reverse():sub(1,6))

    --过滤掉前几个劣质随机数
    math.random(self.m_min,self.m_max)
    math.random(self.m_min,self.m_max)
    math.random(self.m_min,self.m_max)

    local tmp = math.random(self.m_min,self.m_max)

    local ret = self.m_rangeMap[tmp]

    if ret == nil then
        ret = tmp
    end

    self.m_rangeMap[tmp] = self.m_max
    self.m_max = self.m_max - 1

    return ret
end

function _M:getRandomNormal()
    --避免时差太小
    math.randomseed(tostring(date_utils:get_current_timestamp()):reverse():sub(1,6))

    --过滤掉前几个劣质随机数
    math.random(self.m_min,self.m_end)
    math.random(self.m_min,self.m_end)
    math.random(self.m_min,self.m_end)

    local ret = math.random(self.m_min,self.m_end)

    local tmp = self.m_rangeMap[ret]

    if tmp == nil then
        self.m_rangeMap[ret] = self.m_max
        self.m_max = self.m_max - 1
    end

    return ret
end

return _M
