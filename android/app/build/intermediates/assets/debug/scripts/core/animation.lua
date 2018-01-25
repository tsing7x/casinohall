
package.preload[ "animation" ] = function( ... )
if kAnimNormal == nil then
    -- from core.constants
    kAnimNormal	= 0;
    kAnimRepeat	= 1;
    kAnimLoop	    = 2;
end

---
-- 动画库
-- @module animation
-- @return #table 动画库
local M = {}

---
-- 动画只播放一次不循环.
-- 执行顺序是 action1->end。<br/>![](http://engine.by.com:8080/hosting/data/1465184412645_3186869525794594894.gif)
-- @field [parent=#global] #LoopType kAnimNormal


---
-- 动画一直循环播放.
-- 执行顺序是 action1-> action1->action1-> action1->.....。<br/>![](http://engine.by.com:8080/hosting/data/1465184449161_7383574999654265026.gif)
-- @field [parent=#global] #LoopType kAnimRepeat


---
-- 动画一直循环播放.
-- 动画一直循环播放，执行顺序是 action1-> reverse(action1)-> action1-> reverse(action1)->.....。<br/>![](http://engine.by.com:8080/hosting/data/1465184436048_6717257123053237040.gif)
-- @field [parent=#global] #LoopType kAnimLoop

---
-- 动画中可插值的数据.
-- 可以是(number, @{engine#Point}, @{engine#Color},@{engine#Colorf}, table)
-- @type Value



---
-- 动作描述.
-- 描述了时间从0->1,@{#Value} 的变化。
-- @type Action



---
-- 时间插值函数.
-- 插值是在离散数据的基础上补插连续函数，使得这条连续曲线通过全部给定的离散数据点。插值是离散函数逼近的重要方法，利用它可通过函数在有限个点处的取值状况，估算出函数在其他点处的近似值。<br>
-- 时间插值函数是在动画中的取时间的插值，将时间t经过一个函数的变换映射到t’。通过选用不同时间函数，可以得到不同的动画效果。
-- @type TimeFunc 


local function table_merge(t1, t2)
    for k,v in pairs(t2) do
        t1[k] = v
    end
end

---
-- 判断一个对象是否可以执行函数调用.
-- @function [parent=#animation] callable
-- @param #obj o 
-- @return #boolean 如果不可以执行函数调用则返回false,否则返回true.
function M.callable(o)
    if type(o) == 'function' then
        return true
    elseif type(o) == 'table' then
        local m = getmetatable(o)
        return m ~= nil and m.__call ~= nil
    else
        return false
    end
end

local function interp(v1, v2, f)
    if type(v1) == 'table' then
        local r = {}
        for k,v in pairs(v1) do
            if v2[k] ~= nil then
                r[k] = interp(v, v2[k], f)
            else
                r[k] = v
            end
        end
        return r
    elseif type(v1) == 'userdata' then
        return v1:interpolate(v2, f)
    else
        return v1 + (v2 - v1) * f
    end
end

---
-- 获取动画的播放时间。
-- @function [parent=#animation] get_duration
-- @param #Action item action对象
-- @return #number 当item 的duration属性存在时返回其duration的值，否则返回1.
function M.get_duration(item)
    if type(item) == 'table' and item.duration ~= nil then
        return item.duration
    else
        return 1
    end
end

-- combinators
---
-- 设置不变的属性.
-- @function [parent=#animation] constant
-- @param #Value value 动画中不想变化的属性名
function M.constant(value)
    return function(f)
        return value
    end
end

M.empty = M.constant(nil)

function M.identity(f)
    return f
end

---
-- swf关键帧动画转action.
-- @function [parent=#animation] swfFrame
-- @param #table swf swf对象
-- @param #number startFrame 开始帧
-- @param #number endFrame 结束帧
-- @param #number repeatCount 重复播放的次数
function M.swfFrame(swf,startFrame,endFrame,repeatCount)
    return M.duration(swf:getTimeBetween(startFrame,endFrame) * repeatCount, function(f)
                        f = (f * repeatCount)%1 * (endFrame - startFrame) + startFrame;
                        swf:setAnimParams(startFrame,endFrame,repeatCount);
                        swf:gotoAndStop(f);
                        return {};
                        end);
end

---
-- 生成关键帧动画.
-- 通过提供一组关键帧的描述来生成一个关键帧动画。关键帧描述是一个table类型的数组，每一个成员都描述了一个关键帧。<br/>
--  1. 关键帧描述:={关键帧1，关键帧2，关键帧3，...} <br/>
--  2. 关键帧:={关键帧时间，属性列表，时间函数} <br/>
-- （1） 关键帧时间:表示了此帧执行的时间。取值为[0.0~1.0]。只有取值在[0.0~1.0]之间的补间动画才会被播放，如果取值不在此范围内，则只会与相邻帧之间计算补间动画。<br/>
-- （2） 属性列表：表示了在当前帧你期望的对象的属性的值。这是一个table。每一个元素代表一种属性。例如{x=50,opacity=0.5,...}。<br/>
-- （3） 时间函数:表示变化到下一帧的插值函数。如果是最后一帧，需要传一个nil值。<br/>
-- 
-- @function [parent=#animation] keyframes
-- @param #table frames 关键帧的描述
-- @return #Action 返回的关键帧动作
-- @usage local move = Anim.keyframes{
--  {0.0, {pos=Point(5,50)}, Anim.linear},   -- 第一帧，时间为0.0.期望的属性为pos = Point(5,50),采用线性变化的时间函数。
--  {1.0, {pos=Point(205,50)}, nil },            -- 最后一帧，时间为1.0.期望的属性为pos = Point(205,50),最后一帧不需要时间函数，传一个nil值
-- }
function M.keyframes(frames)
    return function(f)
        for i, frame in ipairs(frames) do
            if i == #frames then
                return frame[2]
            else
                local t1, v1, timing = unpack(frame)
                if f >= t1 then
                    local t2, v2, _ = unpack(frames[i+1])
                    if f < t2 then
                        f = timing((f - t1) / (t2 - t1))
                        return interp(v1, v2, f)
                    end
                end
            end
        end
    end
end

---
-- 从指定的值变化为另外一个值的action.
-- 默认为线性变化，你可以同过添加时间函数来使其变化的规律按时间函数的方式来变化。
-- @function [parent=#animation] value
-- @param #Value from 开始的值 。
-- @param #Value to 目标值。
-- @return #Action 根据from和to的值形成的插值action.
function M.value(from, to)
    return function(f)
        return interp(from, to, f)
    end
end


--- 
-- 绝对的属性动画.
-- 给定指定的属性，初始属性值和目标属性值来创建一个属性动画。
-- @function [parent=#animation] prop
-- @param #string name 属性的名称 。例如'pos','x','scale'等。
-- @param #Value from 初始属性值 。
-- @param #Value to 目标属性值 。
-- @param #number duration 此动画的持续的时间 。
-- @param #TimeFunc timing 动画变化的时间函数，默认为线性变化 。
-- @return #Action 给据给定的属性和值创建的action.
-- @usage 
-- -- 将位置在5s内从(0,0)按pow3_in变化到(100,100)
-- local move = M.porp('pos',Point(0,0),Point(100,100),5,M.pow3_in)

function M.prop(name, from, to, duration, timing)
    local ac = M.named(name, M.value(from, to))
    if timing then
        ac = M.timing(timing, ac)
    end
    if duration then
        ac = M.duration(duration, ac)
    end
    return ac
end

--- 
-- 相对的属性动画.
-- 给定指定的属性，初始属性相对值和目标属性相对值来创建一个属性动画。
-- @function [parent=#animation] prop_by
-- @param #string name 属性的名称 。例如'pos','x','scale'等。
-- @param #Value from 初始属性相对值 。
-- @param #Value to 目标属性相对值 。
-- @param #number duration 此动画的持续的时间 。
-- @param #TimeFunc timing 动画变化的时间函数，默认为线性变化 。
-- @return #Action 给据给定的属性和值创建的action.
-- @usage 
-- -- 将位置在5s内从当前位置按pow3_in变化到当前位置+(100,100)
-- local move = M.porp_by('pos',Point(0,0),Point(100,100),5,M.pow3_in)
function M.prop_by(name, from, to, duration, timing)
    assert(string.sub(name, 1, 9) ~= 'relative_', 'duplicate relative_ prefix.')
    return M.prop('relative_' .. name, from, to, duration, timing)
end
---
-- bezier轨迹的action.
-- 可以使widget按你想要的路径进行运动。![bezier_path效果图](http://engine.by.com:8080/hosting/data/1465186646907_4822095274486540186.gif)
-- @function [parent=#animation] bezier_path
-- @param #table points 控制点.每一个元素都是一个Point类型的点(每四个一组，分别表示:起始点，控制点1，控制点2，终点).
-- @return #Action 根据控制点生成的action对象
-- @usage 
-- local points = {
--     Point(0, 500),      -- start point
--     Point(100, 600),   -- control point 1
--     Point(0, 0),           -- control point 2
--     Point(400, 0),     -- endpoint
--
--     Point(400, 0),
--     Point(600, 0),
--     Point(800, 500),
--     Point(500, 500),
--
--     Point(500, 500),
--     Point(200, 500),
--     Point(700, 0),
--     Point(800, 200),
-- }
--
-- local s = Sprite(TextureUnit.default_unit())
-- root:add(s)
--
-- Anim.Animator(Anim.scale_duration(5, Anim.bezier_path(points)), Anim.updator(s), kAnimLoop):start()
-- 
function M.bezier_path(points)
    local sp = BSpline(3, 2, #points, BSpline.TS_BEZIERS)
    local ctrlp = {}
    for _, p in ipairs(points) do
        table.insert(ctrlp, p.x)
        table.insert(ctrlp, p.y)
    end
    sp.ctrlp = ctrlp
    return function(f)
        return {pos=Point(unpack(sp:evaluate(f).result))}
    end
end

---
-- 给动作添加时间函数.
-- @function [parent=#animation] timing
-- @param #function time_fn 时间函数
-- @param #Action action 需要添加时间函数的动作
-- @return #Action 添加了时间函数之后的Action
function M.timing(time_fn, action)
    return setmetatable({
        duration = M.get_duration(action)
    }, {
        __call = function(self, f)
            return action(time_fn(f))
        end
    })
end

---
-- 多个Action顺序执行.
-- 可以接收多个Action，多个Action之间的执行顺序如图所示:![sequence 示意](http://cocos2d-x.org/docs/programmers-guide/4-img/sequence.png)
-- @function [parent=#animation] sequence
-- @param  ... 多个Action
-- @return #Action 返回组合后的动作
function M.sequence(...)
    local actions = {...}
    local sum_duration = 0
    for _, item in ipairs(actions) do
        sum_duration = sum_duration + M.get_duration(item)
    end
    return setmetatable({
        duration = sum_duration
    }, {
        __call = function(self, f)
            f = f * sum_duration
            for _, action in ipairs(actions) do
                local duration = M.get_duration(action)
                if f <= duration then
                    return action(f / duration)
                else
                    f = f - duration
                end
            end
            return actions[#actions](1)
        end
    })
end
---
-- 多个Action同时执行.
-- 可以接收多个Action，多个Action之间的执行顺序如图所示:![spawn 示意](http://cocos2d-x.org/docs/programmers-guide/4-img/spawn.png)
-- @function [parent=#animation] spawn
-- @param  ... 多个Action
-- @return #Action 返回组合后的动作
function M.spawn(...)
    local actions = {...}
    local max_d = 0
    for _, item in ipairs(actions) do
        local d = M.get_duration(item)
        if d > max_d then
            max_d = d
        end
    end

    return setmetatable({
        duration = max_d,
    }, {
        __call = function(self, f)
            local t = {}
            for _, action in ipairs(actions) do
                local d = M.get_duration(action)
                local ff
                if d ~= 0 then
                    ff = f * max_d / d
                    if ff < 0 then
                        ff = math.abs(ff)%1;
                    end
                    if ff <= 1 then
                        table_merge(t, action(ff))
                    end
                end
            end
            return t
        end
    })
end

---
-- 给Action绑定名字.
-- 在有多个Action进行组合时，你可以通过name来设置指定的Action的更新函数。
-- @function [parent=#animation] named
-- @param #string name 动画的名字
-- @param #Action action 指定的action
-- @return #Action 返回添加名字后的action
function M.named(name, action)
    return setmetatable({
        duration = M.get_duration(action),
    }, {
        __call = function(self, f)
            return { [name] = action(f) }
        end,
    })
end

---
-- 设置动作执行的绝对时间.
-- @function [parent=#animation] duration
-- @param #number d 期望的action运行的时间
-- @param #Action ac 需要更改执行时间的action
-- @return #Action 设置完时间后的Action
function M.duration(d, ac)
    return setmetatable({
        duration = d
    }, {
        __call = function(self, f)
            return ac(f)
        end
    })
end
---
-- 设置动作执行时间的倍数.
-- @function [parent=#animation] scale_duration
-- @param #number s 期望的action运行的时间的缩放系数
-- @param #Action ac 需要更改执行时间的action
-- @return #Action 设置完时间后的Action
function M.scale_duration(s, ac)
    return setmetatable({
        duration = M.get_duration(ac) * s
    }, {
        __call = function(self, f)
            return ac(f)
        end
    })
end

-- timing functions
---
-- 线性时间函数.
-- 线性变化的时间函数 *T***<sub>out</sub> =  *T*<sub>in</sub>。动画中效果如图:![linear](http://engine.by.com:8080/hosting/data/1464862334170_4144640210494627037.gif)
-- @field [parent=#animation] #TimeFunc linear 
-- @usage 
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.linear},
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.linear(f)
    return f
end
---
-- 反向变化时间函数.
-- 反向变化的时间函数 *T*<sub>out</sub> = 1 -  *T*<sub>in</sub>。动画中效果如图:![reverse](http://engine.by.com:8080/hosting/data/1464862389018_1107144725669160687.gif)
-- @field [parent=#animation] #TimeFunc reverse 
-- 
-- @usage 
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.reverse},
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.reverse(f)
    return 1-f
end
---
-- 多次相同变化的时间函数.
-- @function [parent=#animation] repeat_
-- @param #number s 重复播放的次数 
-- @return #TimeFunc 一个多次相同变化的时间函数
-- @usage 
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.repeat_(2)},
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.repeat_(s)
    return function(f)
        local _, f = math.modf(f / s)
        return f
    end
end
---
-- 3次函数，先慢后快.
-- 3次函数，先慢后快 *T*<sub>out</sub> = math.pow(*T*<sub>in</sub>,3)。动画中效果如图:![pow3_in](http://engine.by.com:8080/hosting/data/1464862371361_5730821432858915832.gif)
-- @field [parent=#animation] #TimeFunc pow3_in 
-- 
-- @usage 
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.pow3_in},
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.pow3_in (f)
    return math.pow(f, 3)
end
---
-- 3次函数，先快后慢.
-- 3次函数，先快后慢 *T*<sub>out</sub> = math.pow(*T*<sub>in</sub>,1/3)。动画中效果如图:![pow3_out](http://engine.by.com:8080/hosting/data/1464862380793_8381120355325009877.gif)
-- @field [parent=#animation] #TimeFunc pow3_out 
-- 
-- @usage 
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.pow3_out},
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.pow3_out(f)
    return math.pow(f, 1/3)
end
---
-- 3次函数，先快后慢再快.
-- 3次函数，先快后慢再快 ，[0~0.5]的时间和@{#animation.pow3_in}相同，[0.5~1]的时间与@{#animation.pow3_out}相同。
-- @field [parent=#animation] #TimeFunc pow3_in_out 
-- 
-- @usage 
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.pow3_in_out},
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.pow3_in_out(f)
    f = f * 2
    if f < 1 then
        return math.pow(f, 3) / 2
    else
        return math.pow(2-f, 3) / 2;
    end
end
---
-- 平滑非匀速变化.
-- 平滑非匀速变化 ，*T*<sub>out</sub> = *T*<sub>in</sub>*T*<sub>in</sub>(3-2*T*<sub>in</sub>)。![smooth_step](http://engine.by.com:8080/hosting/data/1464862398392_6229252258291208818.gif)
-- @field [parent=#animation] #TimeFunc smooth_step 
-- 
-- @usage 
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.smooth_step},
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.smooth_step(f)
    return f * f * (3 - 2 * f)
end
---
-- 类似喷泉变化时间函数.
-- 类似喷泉变化时间函数 ，带阻尼的效果，速度由快慢慢下降为0。![spring](http://engine.by.com:8080/hosting/data/1464862407127_2154363867620164038.gif)
-- @function [parent=#animation]  spring 
-- @param #number factor 值越小变化越剧烈。默认值为0.4
-- @return #TimeFunc 返回不同阻尼系数下的时间函数
-- @usage 
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.spring(0.4)},
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.spring( factor )
    local _factor = factor or 0.4
    return function ( f )
        return math.pow(2,-10*f) * math.sin((f- _factor / 4 ) * (2 * math.pi) / _factor)+1
    end
end
---
-- 类似冲刺的时间函数.
-- 先反向减速速再加速再减速，是一个对称变化的过程 。接收一个参数，作为加速系数，默认为1.5。![anticipate_overshoot](http://engine.by.com:8080/hosting/data/1464861690909_7121567812415811870.gif)
-- @function [parent=#animation]  anticipate_overshoot 
-- @param #number factor 值越大变化越剧烈。默认值为1.5
-- @return #TimeFunc 返回不同系数下的时间函数
-- @usage 
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.anticipate_overshoot()},
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.anticipate_overshoot( tension )
    tension = tension or 1.5
    local _t = 2.0 * tension
    local function a(t,s)  return t * t * ((s + 1) * t - s) end
    local function o(t,s)  return t * t * ((s + 1) * t + s) end 
    return function ( f )
        if f < 0.5 then
            return 0.5 * a(f * 2.0, tension)
        else
            return 0.5 * (o(f * 2.0 - 2.0, tension) + 2.0)
        end
    end
end
---
-- 非常平滑的非线性变化时间函数.
-- 非常平滑的非线性变化时间函数,*T*<sub>out</sub> = math.cos((*T*<sub>out</sub>+1)math.pi)/2+0.5。![accelerate_decelerate](http://engine.by.com:8080/hosting/data/1464861090044_1488282525116267855.gif)
-- @field [parent=#animation] #TimeFunc accelerate_decelerate
--  
-- @usage 
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.accelerate_decelerate},
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.accelerate_decelerate( f )
    return (math.cos((f + 1) * math.pi) / 2.0) + 0.5
end
---
-- 幂函数变化的时间函数.
-- 幂函数变化的时间函数,*T*<sub>out</sub> = math.pow((*T*<sub>out</sub>,2*factor))。![accelerate](http://engine.by.com:8080/hosting/data/1464861038942_2335540559085891230.gif)
-- @function [parent=#animation] accelerate
-- @param #number factor 给定幂的值。默认为1
-- @return #TimeFunc 返回幂函数的时间函数。
-- @usage 
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.accelerate()},
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.accelerate( factor )
    local _factor = factor or 1.0
    return function ( f )
        if _factor == 1.0 then
            return f*f
        else
            return math.pow(f,2*_factor)
        end
    end
end
---
-- 一种三次变化时间函数.
-- 一种三次变化时间函数,先反向减速速再加速，与@{animation.anticipate_overshoot}不同，这不是一个对称变化的过程,*T*<sub>out</sub> = *T*<sub>out</sub>*T*<sub>out</sub>((tension+1)*T*<sub>out</sub>-tension)。![anticipate](http://engine.by.com:8080/hosting/data/1464861680263_3204627104233402969.gif)
-- @function [parent=#animation] anticipate
-- @param #number tension 给定系数值。默认为1.5
-- @return #TimeFunc 返回幂函数的时间函数。
-- @usage 
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.anticipate()}, 
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.anticipate( tension )
    local _t = tension or 1.5
    return function ( f )
        return f*f*((_t + 1) *f - _t)
    end
end
---
-- 一种快速变化的时间函数.
-- 一种快速变化的时间函数,先加速再减速，接收一个参数，作为加速系数。![overshoot](http://engine.by.com:8080/hosting/data/1464862342538_8822044005028054523.gif)
-- @function [parent=#animation] overshoot
-- @param #number tension 给定系数值。默认为2.0
-- @return #TimeFunc 返回时间函数。
-- @usage 
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.overshoot()}, 
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.overshoot( tension )
    local _t = tension or 2.0
    return function ( f )
        f = f - 1.0
        return f * f * ((_t + 1)*f + _t) + 1.0 
    end
end
---
-- 弹性变化时间函数.
-- 类似弹性的小球落地运动模式的时间变化函数。![bounce_timing](http://engine.by.com:8080/hosting/data/1464862229845_5368559268665709188.gif)
-- @field [parent=#animation] #TimeFunc bounce_timing 
-- 
-- @usage
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.bounce_timing}, 
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.bounce_timing( f )
    local function bounce(t) return t*t*8 end
    if f < 0.3535 then
        return bounce(f)
    elseif f < 0.7408 then
        return bounce(f - 0.54719) + 0.7
    elseif f < 0.9644 then
        return bounce(f - 0.8526) + 0.9
    else
        return bounce(f - 1.0435) + 0.95
    end
end
---
-- 循环时间函数.
-- 按正弦曲线的方式变化，可以指定变化周期数。*T*<sub>out</sub> = math.sin(2 * count * math.pi * *T*<sub>in</sub>)。![cycles](http://engine.by.com:8080/hosting/data/1464862260985_2525726980879273310.gif)
-- @function [parent=#animation] cycles
-- @param #number count 循环的周期数
-- @return #TimeFunc 时间函数
-- @usage
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.cycles(2)}, 
--  {1.0, {pos=Point(205,50)}, nil },
-- }


function M.cycles( count )
    local _count = count 
    return function ( f )
        return math.sin(2 * _count * math.pi * f)
    end
end
---
-- 减速运动.
-- 减速运动。![decelerate](http://engine.by.com:8080/hosting/data/1464862278612_4538196336190879466.gif)
-- @function [parent=#animation] decelerate
-- @param #number factor 衰减系数，默认为1
-- @return #TimeFunc 时间函数
-- @usage
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.decelerate()}, 
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.decelerate( factor )
    local _factor = factor or 1.0
    return function ( f )
        if _factor == 1.0 then
            return ( 1.0 - ( 1.0 - f ) * ( 1.0 - f ) )
        else
            return ( 1.0 - math.pow( ( 1.0 - f ) , 2 * _factor ))
        end
    end
end
---
-- hermite插值时间函数.
-- 埃尔米特。![cubic_hermite](http://engine.by.com:8080/hosting/data/1464862242954_535686203469168120.gif)
-- @function [parent=#animation] cubic_hermite
-- @param #number _start 开始时间，默认为0。
-- @param #number _end 结束时间，默认为1。
-- @param #number tangent0 变化速率，影响前半段的变化，默认为4。
-- @param #number tangent1 变化速率，影响前半段的变化，默认为4。
-- @return #TimeFunc 时间函数
-- @usage
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.cubic_hermite()}, 
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.cubic_hermite( _start,_end ,tangent0,tangent1)
    local function CubicHermite( t,p0,p1,m0,m1)
        local t_2 = t*t
        local t_3 = t_2*t
        return (2*t_3 - 3*t_2 + 1)*p0 + (t_3 - 2 * t_2 + t )*m0 + (-2*t_3+3*t_2)*p1 + (t_3 - t_2)*m1
    end
    return function (f )
        _start = _start or 0
        _end = _end or 1
        tangent0 = tangent0 or 4
        tangent1 = tangent1 or 4
        return CubicHermite(f,_start,_end ,tangent0,tangent1)
    end
end
-- timing function used in kinetic scroll effect.
---
-- 衰减
-- 速度会缓慢减小。（ScrollView的滚动用的此动画）![kinetic](http://engine.by.com:8080/hosting/data/1464862317962_1280305792160819539.gif)
-- @field [parent=#animation] #TimeFunc kinetic 
-- @usage
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.kinetic}, 
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.kinetic(f)
    -- http://ariya.ofilabs.com/2013/11/javascript-kinetic-scrolling-part-2.html
    return (1 - math.exp(-f * 1000 / 325)) * 1.0483288923594
end
---
-- 快速衰减
-- 速度会快速减小。
-- @field [parent=#animation] #TimeFunc kinetic_fast 
-- @usage
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.kinetic_fast}, 
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.kinetic_fast(f)
    return (1 - math.exp(-f * 1000 / 240))
end
---
-- bezier时间函数
-- 通过给定两个控制点来控制时间函数的变化。可以参考此网站[Css bezier](http://cubic-bezier.com/)
-- @function [parent=#animation] bezier 
-- @param engine#Point c1 起始控制点
-- @param engine#Point c2 结束控制点
-- @return #TimeFunc 返回给定控制点的时间函数
-- @usage
-- local move = Anim.keyframes{
--
--  {0.0, {pos=Point(5,50)}, Anim.bezier(Point(0.25,0.1),Point(0.25,1))}, 
--  {1.0, {pos=Point(205,50)}, nil },
-- }
function M.bezier(c1, c2)
    if c1.x == c1.y and c2.x == c2.y then
        return M.linear
    end
    return BezierTiming(c1, c2)
end

-- builtin bezier timing functions.
---
-- ease.
-- 等于@{#animation.bezier}(Point(0.25,0.1),Point(0.25,1))。
-- @field [parent=#animation] #TimeFunc ease 
M.ease = M.bezier(Point(0.25,0.1),Point(0.25,1))
---
-- ease_in.
-- 等于@{#animation.bezier}(Point(0.42,0),Point(1,1))。
-- @field [parent=#animation] #TimeFunc ease_in 
M.ease_in = M.bezier(Point(0.42,0),Point(1,1))
---
-- ease_out.
-- 等于@{#animation.bezier}(Point(0,0),Point(0.58,1))。
-- @field [parent=#animation] #TimeFunc ease_out 
M.ease_out = M.bezier(Point(0,0),Point(0.58,1))
---
-- ease_in_out.
-- 等于@{#animation.bezier}(Point(0.42,0),Point(0.58,1))。
-- @field [parent=#animation] #TimeFunc ease_in_out 
M.ease_in_out = M.bezier(Point(0.42,0),Point(0.58,1))
---
-- timing_bounce.
-- 等于@{#animation.bezier}(Point(.1,.26), Point(.3,1.29))。
-- @field [parent=#animation] #TimeFunc timing_bounce 
M.timing_bounce = M.bezier(Point(.1,.26), Point(.3,1.29))

---
-- 动画控制对象.
-- @type animation.Animator

---
-- @function [parent=#animation] Animator
-- @param #Action action 需要执行的action。
-- @param #function fn 更新数据函数回调。
-- @param #LoopType loop 执行的循环方式，可选@{#kAnimLoop},@{#kAnimNormal},@{#kAnimRepeat},默认为@{#kAnimNormal}
-- @return #animation.Animator 动画控制对象
function M.Animator(action, fn, loop)
    local clock = Clock.instance()
    return {
        action = action,
        duration = action and M.get_duration(action) or 0,
        _stop_listeners = {},
        handler = nil,
        fn = fn,
        interval = 0,
        passed = 0,
        loopWay = 1,
        loop_count = 0,
        on_loop = nil,
        on_stop = nil,
        loop = loop,

        update = function(self, f)
            if self.loopWay == -1 then
                f = 1 - f
            end
            self.fn(self.action(f))
        end,
        ---
        -- 暂停动画.
        -- @function [parent=#animation.Animator] pause
        -- @param #animation.Animator self 
        -- @return #boolean 暂停成功返回true,否则返回false
        pause = function(self)
            if self.handler and not self.handler.stopped then
                self.handler:cancel()
                return true
            end
            self.handler = nil
            return false
        end,
        ---
        -- 继续播放动画
        -- @function [parent=#animation.Animator] resume
        -- @param #animation.Animator self 
        resume = function(self)
            self.handler = clock:schedule(function(dt)
                if self.passed == -1 then
                    self.passed = 0
                    self:update(0)
                    return;
                end
                self.passed = self.passed + dt
                local f = self.passed / self.duration
                if f >= 1 then
                    f = 1
                end
                self:update(f)
                if f == 1 then
                    self.loop_count = self.loop_count + 1
                    if self.loop == kAnimRepeat then
                        self.passed = -1
                        if self.on_loop then
                            self:on_loop(self.loop_count)
                        end
                    elseif self.loop == kAnimLoop then
                        self.passed = -1
                        self.loopWay = self.loopWay * -1
                        if self.on_loop then
                            self:on_loop(self.loop_count)
                        end
                    else
                        self:stop()
                    end
                end
            end, self.interval)
        end,
        ---
        -- 开始播放动画.
        -- @function [parent=#animation.Animator] start
        -- @param #animation.Animator self 
        -- @param #Action action 需要播放的动作，如果没有则播放创建对象时传入的action
        -- @param #function fn 更新数据函数回调。
        -- @param #LoopType loop 执行的循环方式，可选@{#kAnimLoop},@{#kAnimNormal},@{#kAnimRepeat},默认为@{#kAnimNormal}
        start = function(self, action, fn, loop)
            self:stop()

            if action ~= nil then
                self.action = action
                self.duration = M.get_duration(action)
            end
            if fn ~= nil then
                self.fn = fn
            end
            if loop ~= nil then
                if loop == true then
                    loop = kAnimRepeat
                end
                self.loop = loop
            end
            --self.interval = interval or 0
            self.passed = 0
            self:update(0)
            self:resume()
        end,
        ---
        -- 停止播放动画.
        -- 停止播放动画.如果@{animation.Animator.on_stop}存在则会调用此方法。
        -- @function [parent=#animation.Animator] stop
        -- @param #animation.Animator self 
        stop = function(self)
            if self:pause() then
                if self.action then
                    self:update(1)
                end

                self.passed = 0
                ---
                -- 动画结束回调函数.
                -- @field [parent=#animation.Animator] #function on_stop 
                if self.on_stop then
                    self:on_stop()
                end
            end
        end,
    }
end

---
-- 更新一个widget对象的属性.
-- @function [parent=#animation] updator
-- @param engine#Widget w 需要更新的widget对象
-- @usage
-- local move = Anim.keyframes{
--  -- 关键帧位置, 属性, 时间函数，这里取得Anim.linear，你可以通过取不同的时间函数得到不同的动画效果。
--  {0.0, {pos=Point(5,50)}, Anim.linear},
--  {1.0, {pos=Point(205,50)}, nil },
-- }
-- --设置时常为2秒。
-- local move = Anim.duration(2, move)
--
-- local s = Sprite()
-- s.unit = TextureUnit.default_unit()
-- s.size = Point(10,10)
-- 使用 Animator 来运行动画, 第三个参数表示循环播放，Anim.updator为默认的更新widget属性的函数。
-- local anim = Anim.Animator(move,  Anim.updator(s), true)
function M.updator(w)
    local init = {}
    return function(state)
        for k, v in pairs(state) do
            local relative = false
            if string.sub(k, 1, 9)=='relative_' then
                relative = true
                k = string.sub(k, 10)
            end
            if relative then
                if init[k] == nil then
                    init[k] = w[k]
                end
                w[k] = init[k] + v
            else
                w[k] = v
            end
        end
    end
end
--- 
-- 更新多个widget的属性.
-- 你可以传入多个更新函数，从而更新不同的对象的不同属性.
-- @function [parent=#animation] updators
-- @param #table t 多个更新函数的集合
-- 
-- @usage
-- anim.Animator(ac1, anim.updators{
--     bounce      = anim.updator(ss[1][1]),     -- 给不同的对象执行不同的动画。
--     flash       = anim.updator(ss[1][2]),
--     shake       = anim.updator(ss[1][3]),
--     head_shake  = anim.updator(ss[2][1]),
--     jello       = anim.updator(ss[2][2]),
--     pulse       = anim.updator(ss[2][3]),
--     rubber_band = anim.updator(ss[3][1]),
--     swing       = anim.updator(ss[3][2]),
--     tada        = anim.updator(ss[3][3]),
-- }, kAnimRepeat)
function M.updators(t)
    return function(v)
        for k, vv in pairs(v) do
            local fn = t[k]
            if fn then
                fn(vv)
            end
        end
    end
end

-- examples

---
-- 弹性动画.
-- 引擎内置关键帧动画。<br/> ![](http://engine.by.com:8080/hosting/data/1465180436120_2176449637879886110.gif)
-- @function [parent=#animation] bounce
-- @return #Action 
function M.bounce()
    local b1 = M.bezier(Point(0.215, 0.610), Point(0.355, 1.000))
    local b2 = M.bezier(Point(0.755, 0.050), Point(0.855, 0.060))
    return M.keyframes{
        {0.0,  {relative_y=0   }, b1},
        {0.2,  {relative_y=0   }, b1},
        {0.4,  {relative_y=-30 }, b2},
        {0.43, {relative_y=-30 }, b2},
        {0.53, {relative_y=0   }, b1},
        {0.70, {relative_y=-15 }, b2},
        {0.80, {relative_y=0   }, b1},
        {0.90, {relative_y=-4  }, M.ease},
        {1.0,  {relative_y=0   }, nil},
    }
end
---
-- 闪烁动画.
-- 引擎内置关键帧动画。<br/> ![](http://engine.by.com:8080/hosting/data/1465180465116_2828324001546279837.gif)
-- @function [parent=#animation] flash
-- @return #Action 
function M.flash()
    return M.keyframes{
        {0.0,  {opacity=1}, M.ease},
        {0.25, {opacity=0}, M.ease},
        {0.50, {opacity=1}, M.ease},
        {0.75, {opacity=0}, M.ease},
        {1.0,  {opacity=1}, nil}
    }
end
---
-- 摇晃动画.
-- 引擎内置关键帧动画。<br/> ![](http://engine.by.com:8080/hosting/data/1465180509084_5508064607527390791.gif)
-- @function [parent=#animation] shake
-- @return #Action 
function M.shake()
    return M.keyframes{
        {0.0, {relative_x=0  }, M.ease},
        {0.1, {relative_x=-10}, M.ease},
        {0.2, {relative_x=10 }, M.ease},
        {0.3, {relative_x=-10}, M.ease},
        {0.4, {relative_x=10 }, M.ease},
        {0.5, {relative_x=-10}, M.ease},
        {0.6, {relative_x=10 }, M.ease},
        {0.7, {relative_x=-10}, M.ease},
        {0.8, {relative_x=10 }, M.ease},
        {0.9, {relative_x=-10}, M.ease},
        {1.0, {relative_x=0  }, nil},
    }
end
---
-- 头部摇晃动画.
-- 引擎内置关键帧动画。<br/> ![](http://engine.by.com:8080/hosting/data/1465180473189_466755087320987004.gif)
-- @function [parent=#animation] head_shake
-- @return #Action 
function M.head_shake()
    return M.keyframes{
        {0,     {relative_x=0,  rotation=0},   M.ease_in_out},
        {0.065, {relative_x=-6, rotation=-9},  M.ease_in_out},
        {0.185, {relative_x=5,  rotation=7},   M.ease_in_out},
        {0.315, {relative_x=-3, rotation=-5},  M.ease_in_out},
        {0.435, {relative_x=2,  rotation=3},   M.ease_in_out},
        {0.50,  {relative_x=0,  rotation=0},   M.ease_in_out},
    }
end
---
-- 果冻动画.
-- 引擎内置关键帧动画。<br/> ![](http://engine.by.com:8080/hosting/data/1465180482301_4647592762542531884.gif)
-- @function [parent=#animation] jello
-- @return #Action 
function M.jello()
    return M.keyframes{
        {0,     {skew=Point(0,0), scale_at_anchor_point=true}, M.ease},
        {0.111, {skew=Point(0,0)}, M.ease},
        {0.222, {skew=Point(-12.5, -12.5)}, M.ease},
        {0.333, {skew=Point(6.25, 6.25)}, M.ease},
        {0.444, {skew=Point(-3.125, -3.125)}, M.ease},
        {0.555, {skew=Point(1.5625, 1.5625)}, M.ease},
        {0.666, {skew=Point(-0.78125, -0.78125)}, M.ease},
        {0.777, {skew=Point(0.390625, 0.390625)}, M.ease},
        {0.888, {skew=Point(-0.1953125, -0.1953125)}, M.ease},
        {1.0,   {skew=Point(0,0)}, M.ease},
    }
end
---
-- 心跳动画.
-- 引擎内置关键帧动画。<br/> ![](http://engine.by.com:8080/hosting/data/1465180491049_7243170442224714042.gif)
-- @function [parent=#animation] pulse
-- @return #Action 
function M.pulse()
    return M.keyframes{
        {0.0, {scale=Point(1,1), scale_at_anchor_point=true}, M.ease},
        {0.5, {scale=Point(1.05,1.05)}, M.ease},
        {1.0, {scale=Point(1,1)},       M.ease},
    }
end
---
-- 橡皮筋动画.
-- 引擎内置关键帧动画。<br/> ![](http://engine.by.com:8080/hosting/data/1465180500051_7800740885625694311.gif)
-- @function [parent=#animation] rubber_band
-- @return #Action 
function M.rubber_band()
    return M.keyframes{
        {0.0, {scale=Point(1,1), scale_at_anchor_point=true}, M.ease},
        {0.3, {scale=Point(1.25,1.25)}, M.ease},
        {0.4, {scale=Point(0.75,0.75)}, M.ease},
        {0.5, {scale=Point(1.15,0.85)}, M.ease},
        {0.65,{scale=Point(0.95,1.05)}, M.ease},
        {0.75,{scale=Point(1.05,0.95)}, M.ease},
        {1.0, {scale=Point(1,1)},       M.ease},
    }
end
---
-- 摇摆动画.
-- 引擎内置关键帧动画。<br/> ![](http://engine.by.com:8080/hosting/data/1465180518478_2233583156938851955.gif)
-- @function [parent=#animation] rubber_band
-- @return #Action 
function M.swing()
    return M.keyframes{
        {0.2, {rotation=15, anchor=Point(0.5, 0)}, M.ease},
        {0.4, {rotation=-10}, M.ease},
        {0.6, {rotation=5}, M.ease},
        {0.8, {rotation=-5}, M.ease},
        {1.0, {rotation=0}, M.ease},
    }
end
---
-- 缩放摇摆动画.
-- 引擎内置关键帧动画。<br/> ![](http://engine.by.com:8080/hosting/data/1465180527531_8001645470865122389.gif)
-- @function [parent=#animation] tada
-- @return #Action 
function M.tada()
    return M.keyframes{
        {0.0, {scale=Point(1,1),     rotation=0, scale_at_anchor_point=true},  M.ease},
        {0.1, {scale=Point(0.9,0.9), rotation=-3}, M.ease},
        {0.2, {scale=Point(0.9,0.9), rotation=-3}, M.ease},
        {0.3, {scale=Point(1.1,1.1), rotation=3},  M.ease},
        {0.4, {rotation=-3}, M.ease},
        {0.5, {rotation=3},  M.ease},
        {0.6, {rotation=-3}, M.ease},
        {0.7, {rotation=3},  M.ease},
        {0.8, {rotation=-3}, M.ease},
        {0.9, {scale=Point(1.1,1.1), rotation=3},  M.ease},
        {1.0, {scale=Point(1,1),     rotation=0},  M.ease},
    }
end
---
-- 弹性出现动画.
-- 引擎内置关键帧动画。<br/> ![](http://engine.by.com:8080/hosting/data/1465180446626_2681022851152686097.gif)
-- @function [parent=#animation] bounce_in_down
-- @return #Action 
function M.bounce_in_down()
    local t = M.bezier(Point(0.215, 0.610), Point(0.355, 1.000))
    return M.keyframes{
        {0.0, {relative_y=-3000, opacity=0}, t},
        {0.6, {relative_y=25, opacity=1},    t},
        {0.75,{relative_y=-10},              t},
        {0.9, {relative_y=5},                t},
        {1.0, {relative_y=0},                nil},
    }
end
---
-- 弹性消失动画.
-- 引擎内置关键帧动画。<br/> ![](http://engine.by.com:8080/hosting/data/1465180455623_7152125096994456005.gif)
-- @function [parent=#animation] bounce_out_down
-- @return #Action 
function M.bounce_out_down()
    return M.keyframes{
        {0.0, {relative_y=0},              M.ease},
        {0.2, {relative_y=10},             M.ease},
        {0.4, {relative_y=-20,  opacity=1}, M.ease},
        {0.45,{relative_y=-20,  opacity=1}, M.ease},
        {1.0, {relative_y=2000, opacity=0},nil},
    }
end

local function test1(root)
    -- combined animation
    local unit = TextureUnit(TextureCache.instance():get('sprite.png'))
    local ss = {}
    for i=0,2 do
        local t = {}
        for j=0,2 do
            local s = Sprite(unit)
            --s.size = Point(150,150)
            s.pos = Point(150 * i + 50, 180 * j + 50)
            root:add(s)
            table.insert(t, s)
        end
        table.insert(ss, t)
    end

    local ac1 = M.spawn(M.sequence(
        M.named('bounce', M.bounce()),
        M.named('flash',  M.flash()),
        M.named('shake',  M.shake())
    ), M.sequence(
        M.named('head_shake',  M.head_shake()),
        M.named('jello',  M.jello()),
        M.named('pulse',  M.pulse())
    ), M.sequence(
        M.named('rubber_band', M.rubber_band()),
        M.named('swing', M.swing()),
        M.named('tada', M.tada())
    ))

    --ac1 = M.sequence{ac1, M.timing(M.reverse, ac1)}
    return M.Animator(ac1, M.updators{
        bounce      = M.updator(ss[1][1]),
        flash       = M.updator(ss[1][2]),
        shake       = M.updator(ss[1][3]),
        head_shake  = M.updator(ss[2][1]),
        jello       = M.updator(ss[2][2]),
        pulse       = M.updator(ss[2][3]),
        rubber_band = M.updator(ss[3][1]),
        swing       = M.updator(ss[3][2]),
        tada        = M.updator(ss[3][3]),
    }, kAnimRepeat)
end

local function test_simple(root)
    -- simple animation
    local s = Sprite(TextureUnit.default_unit())
    s.size = Point(100,100)
    s.pos = Point(10,10)
    root:add(s)

    local simple = M.flash()
    return M.Animator(simple, M.updator(s), kAnimRepeat)
end

local function test2(root)
    local ac2 = M.spawn(M.named('1', M.sequence(
        M.bounce(),
        M.flash(),
        M.shake()
    )), M.named('2', M.sequence(
        M.head_shake(),
        M.jello(),
        M.pulse()
    )), M.named('3', M.sequence(
        M.rubber_band(),
        M.swing(),
        M.tada()
    )))

    local lbl = Label()
    lbl:set_rich_text('<b><i><font size=120 color=#000000 weight=3 glow=#ff0000>Hello 富文本! </font></i></b>')
    local fbo = lbl:render_to_fbo()
    local unit = TextureUnit(fbo.texture)
    local nodes = {}
    for i=0,2 do
        local nd = Sprite(unit)
        nd.pos = Point(550, i * 200 + 50)
        root:add(nd)
        table.insert(nodes, nd)
    end
    return M.Animator(ac2, M.updators{
        ['1'] = M.updator(nodes[1]),
        ['2'] = M.updator(nodes[2]),
        ['3'] = M.updator(nodes[3]),
    }, kAnimRepeat)
end

-- test bezier path animation
local function test_bezier_path(root)
    if BSpline == nil then
        return
    end
    local w = LuaWidget()
    w.size = root.size
    local nvg = Nanovg(bit.bor(Nanovg.NVG_ANTIALIAS, Nanovg.NVG_DEBUG, Nanovg.NVG_STENCIL_STROKES))
    local draw = function ( w,nvg )
        local scale = Window.instance().drawing_root.scale
        nvg:reset()
        nvg:scale(scale)
        -- nvg:translate(circle_pos)
        nvg:begin_path()
        nvg:move_to(Point(0, 500))
        nvg:bezier_to(Point(100, 600), Point(0, 0),Point(400, 0))
        nvg:stroke_color(Colorf.white)
        nvg:stroke()

        nvg:begin_path()
        nvg:move_to(Point(400, 0))
        nvg:bezier_to(Point(600, 0), Point(800, 500),Point(500, 500))
        nvg:stroke_color(Colorf.red)
        nvg:stroke()

        nvg:begin_path()
        nvg:move_to(Point(500, 500))
        nvg:bezier_to(Point(200, 500), Point(700, 0),Point(800, 200))
        nvg:stroke_color(Colorf.blue)
        nvg:stroke()
    end
    local inst = LuaInstruction(function(self, canvas)
        nvg:begin_frame(canvas)
        draw(w, nvg)
        nvg:end_frame()
    end, true)

    w.lua_do_draw = function(self, canvas)
        canvas:add(inst)
    end
    root:add(w)
    local points = {
        Point(0, 500),
        Point(100, 600),
        Point(0, 0),
        Point(400, 0),

        Point(400, 0),
        Point(600, 0),
        Point(800, 500),
        Point(500, 500),

        Point(500, 500),
        Point(200, 500),
        Point(700, 0),
        Point(800, 200),
    }

    local s = Sprite(TextureUnit.default_unit())
    root:add(s)
    M.Animator(M.bezier_path(points), function(p)
        s.pos = p.pos
    end, kAnimLoop):start()
end

local function test_callback(root)
    local s = Sprite(TextureUnit.default_unit())
    s.size = Point(100,100)
    root:add(s)
    --local tfn = M.bezier(Point(0.1, 0.1),Point(0.2, 1.0))
    return M.Animator(M.timing(M.kinetic, M.value(0, 300)), function(v)
        s.x = v
    end, kAnimLoop)
end

function M.test(root)
    test1(root):start()
    test_simple(root):start()
    test2(root):start()
    test_bezier_path(root)
    test_callback(root):start()
end
return M

end
        
local name = ...
if name == "animation" then
    return package.preload[ "animation" ]()
end

