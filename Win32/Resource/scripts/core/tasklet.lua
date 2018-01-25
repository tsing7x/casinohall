
package.preload[ "tasklet" ] = function( ... )
---
-- tasklet库，更多同步操作见@{network.http2} @{network.socket2}
-- @module tasklet
-- @usage
-- local tasklet = require('tasklet')
--
-- @usage
-- -- run dynamic animations sequeucely.
-- local Am = require('animation')
-- tasklet.spawn(function()
--     while true do
--         tasklet.animate(Am.prop('x', 0, 100), Am.updator(sprite))
--         tasklet.sleep(0.5)
--         tasklet.animate(Am.prop('x', 100, 0), Am.updator(sprite))
--     end
-- end)
--
-- @usage
-- -- cancel a tasklet
-- local Http = require('network.http2')
-- tasklet.spawn(function()
--     local sprite = ...
--     local loading = tasklet.spawn(function()
--         while true do
--             sprite.rotation = sprite.rotation + tasklet.sleep(0.1)
--         end
--     end)
--     local rsp = http.request{url = 'http://www.boyaa.com'}
--     tasklet.cancel(loading)
-- end)
local M = {}

local function resume_task(task, ...)
    if task.paused then
        task.pending_args = {...}
        return
    end
    local success
    success, task.action = coroutine.resume(task.coroutine, ...)
    if not success then
        print_string(debug.traceback(task.coroutine, task.action))
    elseif task.action then
        task.action(function(...)
            resume_task(task, ...)
        end)
        return
    end
end

---
-- 启动微线程。
-- @function [parent=#tasklet] spawn
-- @param #function fn
-- @param ... 传给fn的参数。
-- @usage
-- tasklet.spawn(function(arg1, arg2)
--     while true do
--         local dt = tasklet.sleep(0.1)
--         sprite.x = sprite.x + dt * 10
--     end
-- end, arg1, arg2)
function M.spawn(fn, ...)
    local co = coroutine.create(fn)
    local task = {
        coroutine = co,
    }
    resume_task(task, ...)
end
---
-- 停止微线程。
-- @function [parent=#tasklet] cancel
function M.cancel(task)
    if not task.action then
        return 'invalid task status'
    end
    if type(task.action) == 'table' and task.action.cancel then
        task.action:cancel()
    end
    task.paused = true
    task.action = nil
end

---
-- 暂停微线程。
-- @function [parent=#tasklet] pause
function M.pause(task)
    assert(task.action, 'invalid task status')
    if type(task.action) == 'table' and task.action.pause then
        task.action:pause()
    else
        task.paused = true
    end
end

---
-- 恢复微线程。
-- @function [parent=#tasklet] resume
function M.resume(task)
    assert(task.action, 'invalid task status')
    if type(task.action) == 'table' and task.action.resume then
        task.action:resume()
    else
        resume_task(task, unpack(task.pending_args))
    end
end

---
-- 在微线程中执行，暂停 n 秒
-- @function [parent=#tasklet] sleep
-- @param #number n
function M.sleep(n)
    -- sleep action
    return coroutine.yield(setmetatable({
        _handler = nil,
        cancel = function(self)
            if self._handler then
                self._handler:cancel()
            end
        end,
        pause = function(self)
            if self._handler then
                self._handler.paused = true
                return true
            end
            return false
        end,
        resume = function(self)
            if self._handler then
                self._handler.paused = false
                return true
            end
            return false
        end,
    }, {
        __call = function(self, callback)
            self._handler = Clock.instance():schedule_once(callback, n)
        end
    }))
end

---
-- 在微线程中同步执行一个动画，动画结束时才返回。
-- @function [parent=#tasklet] animate
-- @param #action action 要执行的action
-- @param #function updator updator
function M.animate(action, updator)
    local Am = require('animation')
    return coroutine.yield(setmetatable({
        _anim = Am.Animator(action, updator, kAnimNormal),
        cancel = function(self)
            self._anim.on_stop = nil
            self._anim:stop()
            self._anim = nil
        end,
        pause = function(self)
            if self._anim then
                return self._anim:pause()
            end
            return false
        end,
        resume = function(self)
            if self._anim then
                return self._anim:resume()
            end
            return false
        end,
    }, {
        __call = function(self, callback)
            self._anim.on_stop = callback
            self._anim:start()
        end
    }))
end

return M

end
        
local name = ...
if name == "tasklet" then
    return package.preload[ "tasklet" ]()
end

