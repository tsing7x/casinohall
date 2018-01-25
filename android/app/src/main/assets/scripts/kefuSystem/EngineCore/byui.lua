
package.preload[ "byui/autolayout" ] = function( ... )
require('byui/utils')
local class, mixin, super, cls_utils = unpack(require('byui/class'))
---
-- AutoLayout.
-- @module byui.autolayout
-- @return #byui.autolayout
local M = {}

--- 
-- 居中对齐.
-- @field [parent=#global] #number kAlignCenter 
kAlignCenter		= 0;
--- 
-- 顶部居中对齐.
-- @field [parent=#global] #number kAlignTop 
kAlignTop			= 1;
--- 
-- 右上角对齐.
-- @field [parent=#global] #number kAlignTopRight
kAlignTopRight		= 2;
--- 
-- 右部居中对齐.
-- @field [parent=#global] #number kAlignTopRight
kAlignRight	    = 3;
--- 
-- 右下角对齐.
-- @field [parent=#global] #number kAlignBottomRight
kAlignBottomRight	= 4;
--- 
-- 下部居中对齐.
-- @field [parent=#global] #number kAlignBottom
kAlignBottom		= 5;
--- 
-- 左下角对齐.
-- @field [parent=#global] #number kAlignBottomLeft
kAlignBottomLeft	= 6;
--- 
-- 左部居中对齐.
-- @field [parent=#global] #number kAlignLeft
kAlignLeft			= 7;
--- 
-- 左上角对齐.
-- @field [parent=#global] #number kAlignTopLeft
kAlignTopLeft		= 8;


-- expression metamethods
local function print_op(op)
    if op == kiwi.OP_EQ then
        return '=='
    elseif op == kiwi.OP_GE then
        return '>='
    elseif op == kiwi.OP_LE then
        return '<='
    else
        error('')
    end
end
local function linear_expression_methods(cls, get_type)
    local r
    r = {
        Variable = {
            __tostring = function(self)
                return self.name
            end,
            __add = function(self, o)
                return cls.Term(self) + o
            end,
            __unm = function(self, o)
                return cls.Term(self, -1)
            end,
            __sub = function(self, o)
                return self + (-o)
            end,
            __mul = function(self, o)
                assert(get_type(o) == 'number', 'invalid target')
                return cls.Term(self, o)
            end,
            __div = function(self, o)
                return self * (1/o)
            end,
            ---
            -- 等于操作符.
            -- @function [parent=#Variable] eq
            -- @param #Variable self 
            -- @param #Expression o 赋值的表达式
            -- @return #Constraint 返回的约束
            -- @usage AL.width:eq(100)
            eq = function(self, o)
                return cls.Term(self):eq(o)
            end,
            ---
            -- 小于等于操作符.
            -- @function [parent=#Variable] le
            -- @param #Variable self 
            -- @param #Expression o 赋值的表达式
            -- @return #Constraint 返回的约束
            -- @usage AL.width:le(100) -- 宽度小于等于100
            le = function(self, o)
                return cls.Term(self):le(o)
            end,
            ---
            -- 大于等于操作符.
            -- @function [parent=#Variable] ge
            -- @param #Variable self 
            -- @param #Expression o 赋值的表达式
            -- @return #Constraint 返回的约束
            -- @usage AL.width:ge(100)   --宽度大于等于100
            ge = function(self, o)
                return cls.Term(self):ge(o)
            end,
        },
        Term = {
            __tostring = function(self)
                return string.format('%s * %s', r.Variable.__tostring(self.variable), self.coefficient)
            end,
            __add = function(self, o)
                local t = get_type(o)
                if t == 'number' then
                    return cls.Expression({self}, o)
                elseif t == cls.Variable then
                    return cls.Expression({self, cls.Term(o)}, 0)
                elseif t == cls.Term then
                    return cls.Expression{self, o}
                elseif t == cls.Expression then
                    return o + self
                else
                    assert(false, 'invalid add argument')
                end
            end,
            __unm = function(self)
                return cls.Term(self.variable, -self.coefficient)
            end,
            __sub = function(self, o)
                return self + (-o)
            end,
            __mul = function(self, o)
                return cls.Term(self.variable, self.coefficient * o)
            end,
            __div = function(self, o)
                return self * (1/o)
            end,
            eq = function(self, o)
                return cls.Expression({self}):eq(o)
            end,
            le = function(self, o)
                return cls.Expression{self}:le(o)
            end,
            ge = function(self, o)
                return cls.Expression{self}:ge(o)
            end,
        },
        Expression = {
            __tostring = function(self)
                local s = ''
                for _, t in ipairs(self.terms) do
                    s = s .. string.format('%s + ', r.Term.__tostring(t))
                end
                s = s .. tostring(self.constant)
                return s
            end,
            __add = function(self, o)
                local t = get_type(o)
                if t == 'number' then
                    return cls.Expression(self.terms, self.constant + o)
                elseif t == cls.Variable then
                    return self + cls.Term(o)
                elseif t == cls.Term then
                    local terms = table.copy(self.terms)
                    table.insert(terms, o)
                    return cls.Expression(terms, self.constant)
                elseif t == cls.Expression then
                    local terms = table.copy(self.terms)
                    table.append(terms, o.terms)
                    return cls.Expression(terms, self.constant + o.constant)
                else
                    assert(false, 'invalid add argument' .. tostring(o))
                end
            end,
            __unm = function(self)
                return self * -1
            end,
            __sub = function(self, o)
                return self + (-o)
            end,
            __mul = function(self, o)
                assert(type(o) == 'number', 'invalid multiply argument')
                local terms = {}
                for _, term in ipairs(self.terms) do
                    table.insert(terms, term * o)
                end
                return cls.Expression(terms, self.constant * o)
            end,
            __div = function(self, o)
                return self * (1/o)
            end,
            eq = function(self, o)
                return cls.Constraint(self - o, kiwi.OP_EQ, kiwi.STRONG)
            end,
            le = function(self, o)
                return cls.Constraint(self - o, kiwi.OP_LE, kiwi.STRONG)
            end,
            ge = function(self, o)
                return cls.Constraint(self - o, kiwi.OP_GE, kiwi.STRONG)
            end
        },
        Constraint = {
            __tostring = function(self)
                return string.format('%s %s 0 [%d]', r.Expression.__tostring(self.expression), print_op(self.op), self.strength)
            end,
            ---
            -- 设置优先级.
            -- 优先级的文档请参考[优先级](http://engine.by.com:8000/doc/sphinx/build/html/autolayout.html#id6)
            -- @function [parent=#Constraint] priority
            -- @param #Constraint self 
            -- @param #number s 优先级的值
            -- @usage  
            -- local parent = Widget()
            -- parent.background_color = Colorf.red
            -- parent:add_rules{AL.width:eq(300),
            --                 AL.height:eq(300), }
            --
            -- local widget = Widget()
            -- widget:add_rules({AL.width:eq(AL.parent('width')):priority(kiwi.MEDIUM)  --宽度等于父节点的宽度，优先级为kiwi.MEDIUM
            --                ,AL.width:le(300):priority(kiwi.REQUIRED)                                    --宽度小于300 ，优先级为kiwi.REQUIRED
            --                    })
            -- widget:add_rules(AL.rules.align(ALIGN.CENTER))
            -- widget:add_rules({AL.height:eq(200)})
            -- widget.background_color = Colorf.white
            -- parent:add(widget)
            -- Window.instance().drawing_root:add(parent)
            --
            -- Clock.instance():schedule_once(function ( ... )
            --     parent.autolayout_mask = Widget.AL_MASK_WIDTH   --parent不再使用规则，而是自定义的宽度。
            --     parent.width = 400                                                         -- 修改父节点宽度，此时widget 的宽度规则不能同时满足，选取优先级高的那一个
            -- end,2)
            priority = function(self, s)
                return cls.Constraint(self.expression, self.op, s)
            end,
        },
    }
    return r
end

local function setup_metamethods(cls)
    local methods = linear_expression_methods(cls, function(o)
        if type(o) == 'number' then
            return 'number'
        else
            return assert(o.class, 'invalid type')
        end
    end)
    for k, v in pairs(cls) do
        table.merge(v.___class, methods[k])
    end
end

local function getvar(elem, name)
    return elem.vars[name]
end

local function memorize(fn)
    local cache = {}
    return function(...)
        local tmp = {}
        for _, arg in ipairs{...} do
            table.insert(tmp, tostring(arg))
        end
        local k = table.concat(tmp)
        local v = cache[k]
        if v ~= nil then
            return v
        end
        v = fn(...)
        cache[k] = v
        return v
    end
end

---
-- 变量.
-- 变量重载了+-*/的操作符，均只能和数一起使用.
-- @type Variable
-- @usage 
--  local AL = require('ui/autolayout')
--  -- 横向居中
--  AL.centerx:eq(AL.parent('width') * 2)
--  -- 横向居右 
--  AL.right:eq(AL.parent('width') + 10)
--  -- 纵向居上
--  AL.top:eq(0)
--  -- 纵向居中
--  AL.centery:eq(AL.parent('height') / 2)
--  -- 宽度等于父节点减60
--  AL.width:eq(AL.parent('width') - 60)
--  -- 高度只占父节点一半
--  AL.height:eq(AL.parent('height') / 2) 
--  -- 指定的大小
--  AL.height:eq(200) 

---
-- 创建一个变量.
-- 1.四个基本变量 left, top, width, height ，对应 Widget 的 pos 和 size 属性。<br/>
-- 2.其他衍生变量：
--      right (= left + width)
--      right (= left + width)
--      bottom (= top + height)
--      centerx (= left + width / 2)
--      centery (= top + height / 2)
--      leading (= left)
--      trailing (= parent.width  - left - width)
-- @callof #Variable
-- @param #Variable self 
-- @param #string name 变量的名称.代表当前的Widget的属性.
-- @param #function selector 默认为nil此时选择的变量为当前的Widget的属性,通过selector你可以选则非当前Widget的变量.
-- @return #Variable 返回一个变量.
-- @usage local AL = require 'byui/autolayout'   -- 引入AutoLayout模块.
-- local w = Widget()
-- w:add_rules{AL.width:eq('100'),-- 此处的AL.width就是一个基本变量.等价于Al.Variable('width')
--             AL.height:eq(AL.parent('height')) } 
--          -- 此处AL.parent('height')即引用非当前的Widget的变量.
--          -- 等价于Al.Variable('height',function(elem, name)
--          --        -- 此处的elem 即当前的widget。
--          --        return elem的父节点的为name的变量
--          --     end)
-- 

---
-- 变量.
-- 查看@{#Variable}
-- @field [parent=#byui.autolayout] #Variable Variable 
--RVariable

---
-- 表达式中的项.
-- 每一个项:=Variable * 系数。在lua用户不需要自己去创建，每一条规则会生成若干个Term。
--      width*2 + left*1 = 0
--      这里的width*2 就是一项.width是一个Variable，2是对应的系数
-- @type Term

---
-- 生成表达式中的一项.
-- @callof #Term
-- @param #Term self 
-- @param #Variable var 变量.
-- @param #number coefficient 变量对应的系数.
-- @return #Term 返回生成的项.

---
-- 表达式中的项.
-- 查看@{#Term}
-- @field [parent=#byui.autolayout] #Term Term 
--RTerm

---
-- 表达式.
-- 表达式由若干项和一个常数项组成.如:width*2 + left*1  + 100 。
-- 在lua用户不需要自己去创建，每一条规则会生成一个表达式。
-- @type Expression

---
-- 创建一个表达式.
-- @callof #Expression
-- @param #Expression self 
-- @param #table terms 变量的项的集合.
-- @param #number const 常数项对应的值.
-- @return #Expression 返回创建的表达式


---
-- 表达式.
-- 查看@{#Expression}
-- @field [parent=#byui.autolayout] #Expression Expression 
--RExpression

---
-- 约束.
-- 约束:= 表达式:比较操作(表达式):priority(优先级)。
-- 表达式可以使用变量、数值常量和任意 +-/* 操作符进行组合。
--      比较操作有:相等 eq
--              小于等于 le
--              大于等于 ge
-- @type Constraint
-- @usage local AL = require 'byui/autolayout'   -- 引入AutoLayout模块.
-- local w = Widget()
-- w:add_rules{AL.height:eq(AL.parent('height')*0.3 + 20):priority(kiwi.REQUIRED) } 
-- 这里就是一个完整的约束。你可以省略priority(kiwi.REQUIRED) 那优先级就是默认的kiwi.STRONG

---
-- 约束.
-- @callof #Constraint
-- @param #Constraint self 
-- @param #Expression expr 表达式.
-- @param #function op 比较操作符.
-- @param #number strength 优先级.
-- @return #Constraint 返回创建的约束.


---
-- 表达式.
-- 查看@{#Constraint}
-- @field [parent=#byui.autolayout] #Constraint Constraint 
--RConstraint

-- init solver expression metamethods
setup_metamethods{
    Variable = kiwi.Variable,
    Term = kiwi.Term,
    Expression = kiwi.Expression,
    Constraint = kiwi.Constraint,
}

-- init rules expression metamethods
setup_metamethods{
    Term = RTerm,
    Variable = RVariable,
    Expression = RExpression,
    Constraint = RConstraint,
}

local v1 = kiwi.Variable('test')
assert(v1.class == kiwi.Variable)
assert(getmetatable(v1) == kiwi.Variable.___class)
local v2 = RVariable(RVariable.VAR_LEFT, RVariable.SELECTOR_SELF)
assert(v2.class == RVariable)
assert(getmetatable(v2) == RVariable.___class)

---
-- 访问父节点的属性.
-- @function [parent=#byui.autolayout] parent
-- @param #string name 属性的名称.
-- @return #Variable 父节点给定name对应的属性.
-- @usage local AL = require 'byui/autolayout'   -- 引入AutoLayout模块.
-- local w = Widget()
-- w:add_rules{AL.height:eq(AL.parent('height')) }  -- 访问父节点'height'用来设置自己的'height'
local function get_var_type(name)
    if name == 'left' then
        return RVariable.VAR_LEFT
    elseif name == 'top' then
        return RVariable.VAR_TOP
    elseif name == 'width' then
        return RVariable.VAR_WIDTH
    elseif name == 'height' then
        return RVariable.VAR_HEIGHT
    end
end
local function get_rvariable(name, ...)
    local t = get_var_type(name)
    if t then
        return RVariable(t, ...)
    elseif name == 'right' then
        return RVariable(RVariable.VAR_LEFT, ...) + RVariable(RVariable.VAR_WIDTH, ...)
    elseif name == 'bottom' then
        return RVariable(RVariable.VAR_TOP, ...) + RVariable(RVariable.VAR_HEIGHT, ...)
    elseif name == 'centerx' then
        return RVariable(RVariable.VAR_LEFT, ...) + RVariable(RVariable.VAR_WIDTH, ...) * 0.5
    elseif name == 'centery' then
        return RVariable(RVariable.VAR_TOP, ...) + RVariable(RVariable.VAR_HEIGHT, ...) * 0.5
    elseif name == 'leading' then
        return RVariable(RVariable.VAR_LEFT, ...)
    elseif name == 'trailing' then
        return RVariable(RVariable.VAR_WIDTH, RVariable.SELECTOR_PARENT) - RVariable(RVariable.VAR_LEFT, ...) - RVariable(RVariable.VAR_WIDTH, ...)
    else
        error('invalid variable name ' .. name)
    end
end
local function get_parent_rvariable(name)
    if name == 'left' or name == 'top' then
        return 0
    end
    if name == 'width' or name == 'right' then
        return RVariable(RVariable.VAR_WIDTH, RVariable.SELECTOR_PARENT)
    elseif name == 'height' or name == 'bottom' then
        return RVariable(RVariable.VAR_HEIGHT, RVariable.SELECTOR_PARENT)
    elseif name == 'centerx' then
        return RVariable(RVariable.VAR_WIDTH, RVariable.SELECTOR_PARENT) * 0.5
    elseif name == 'centery' then
        return RVariable(RVariable.VAR_HEIGHT, RVariable.SELECTOR_PARENT) * 0.5
    else
        error('invalid variable name ' .. name)
    end
end
M.parent = function(name)
    return get_parent_rvariable(name)
end

---
-- 访问后继节点的属性.
-- @function [parent=#byui.autolayout] succ
-- @param #string name 属性的名称.
-- @return #Variable 后继节点给定name对应的属性.
-- @usage local AL = require 'byui/autolayout'   -- 引入AutoLayout模块.
-- local root = Widget()
-- root.size = Point(100,100)
-- local w = Widget()
-- root:add(w)
-- local succ = Widget()
-- succ.size = Point(100,60)
-- root:add(succ)
-- w:add_rules{AL.height:eq(AL.succ('height')) }  -- 访问后继节点'height'用来设置自己的'height'
M.succ = function(name)
    return get_rvariable(name, RVariable.SELECTOR_SUCC)
end

---
-- 访问前驱节点的属性.
-- @function [parent=#byui.autolayout] pred
-- @param #string name 属性的名称.
-- @return #Variable 前驱节点给定name对应的属性.
-- @usage local AL = require 'byui/autolayout'   -- 引入AutoLayout模块.
-- local root = Widget()
-- root.size = Point(100,100)
-- local pred = Widget()
-- pred.size = Point(100,60)
-- root:add(pred)
-- local w = Widget()
-- root:add(w)
-- w:add_rules{AL.height:eq(AL.pred('height')) }  -- 访问前驱节点'height'用来设置自己的'height'
M.pred = function(name)
    return get_rvariable(name, RVariable.SELECTOR_PRED)
end

---
-- 访问指定的兄弟节点的属性.
-- @function [parent=#byui.autolayout] sibling
-- @param #string name 兄弟节点的名字.
-- @return #function 返回指定兄弟节点的选择器函数.
-- @usage local AL = require 'byui/autolayout'   -- 引入AutoLayout模块.
-- local root = Widget()
-- root.size = Point(100,100)
-- local b = Widget()
-- b.size = Point(100,60)
-- b.name = "child"
-- root:add(b)
-- local w = Widget()
-- root:add(w)
-- w:add_rules{AL.height:eq(AL.sibling('child')('height')) }  -- 访问名字为"child"的兄弟节点的'height'用来设置自己的'height'
M.sibling = function(elem_name)
    return function(name)
        return get_rvariable(name, RVariable.SELECTOR_SIBLING, elem_name)
    end
end

local function get_root()
    return Window.instance().drawing_root
end

---
-- 宽度属性.
-- 表示widget的width的大小.
-- @field [parent=#byui.autolayout] #Variable width 
M.width = get_rvariable('width', RVariable.SELECTOR_SELF)
---
-- 高度属性.
-- 表示widget的height的大小.
-- @field [parent=#byui.autolayout] #Variable height 
M.height = get_rvariable('height', RVariable.SELECTOR_SELF)
---
-- left属性.
-- 表示widget的x的位置.
-- @field [parent=#byui.autolayout] #Variable left 
M.left = get_rvariable('left', RVariable.SELECTOR_SELF)
---
-- top属性.
-- 表示widget的y的位置.
-- @field [parent=#byui.autolayout] #Variable top 
M.top = get_rvariable('top', RVariable.SELECTOR_SELF)
---
-- right属性.
-- 表示widget的右边界的位置.即left+width。
-- @field [parent=#byui.autolayout] #Variable right
M.right = get_rvariable('right', RVariable.SELECTOR_SELF)
---
-- bottom属性.
-- 表示widget的下边界的位置.即top+height。
-- @field [parent=#byui.autolayout] #Variable bottom
M.bottom = get_rvariable('bottom', RVariable.SELECTOR_SELF)
---
-- leading属性.
-- 表示widget的左边界的位置.即left。
-- @field [parent=#byui.autolayout] #Variable leading
M.leading = get_rvariable('leading', RVariable.SELECTOR_SELF)

---
-- trailing属性.
-- 表示widget的右边界与父节点右边界的距离.即parent.width  - left - width。
-- @field [parent=#byui.autolayout] #Variable leading
-- @usage local AL = require 'byui/autolayout'   -- 引入AutoLayout模块.
-- local w = Widget()
-- w:add_rules{AL.trailing:eq(0)}          --表示右边界和父节点右边界重合
M.trailing = get_rvariable('trailing', RVariable.SELECTOR_SELF)

---
-- centerx属性.
-- 表示widget的中心点的x坐标.即left + width / 2。
-- @field [parent=#byui.autolayout] #Variable centerx
-- @usage local AL = require 'byui/autolayout'   -- 引入AutoLayout模块.
-- local w = Widget()
-- w:add_rules{AL.centerx:eq(0)，AL.centery:eq(0)}          --中心点在Point(0,0)点上
M.centerx = get_rvariable('centerx', RVariable.SELECTOR_SELF)

---
-- centery属性.
-- 表示widget的中心点的y坐标.即top + height / 2。
-- @field [parent=#byui.autolayout] #Variable centery
-- @usage local AL = require 'byui/autolayout'   -- 引入AutoLayout模块.
-- local w = Widget()
-- w:add_rules{AL.centerx:eq(0)，AL.centery:eq(0)}          --中心点在Point(0,0)点上
M.centery = get_rvariable('centery', RVariable.SELECTOR_SELF)


--function M.stack_view_rules()
--    return {
--        container = {},
--        item = {
--            M.left:eq(M.parent('margin_left')),
--            M.right:eq(M.parent('margin_right')),
--        }
--    }
--end

local function compat_align_split(a)
    local t = {
        [kAlignCenter]      = {ALIGN_H.CENTER,  ALIGN_V.CENTER},
        [kAlignTop]         = {ALIGN_H.CENTER,  ALIGN_V.TOP},
        [kAlignBottom]      = {ALIGN_H.CENTER,  ALIGN_V.BOTTOM},
        [kAlignRight]       = {ALIGN_H.RIGHT,   ALIGN_V.CENTER},
        [kAlignTopRight]    = {ALIGN_H.RIGHT,   ALIGN_V.TOP},
        [kAlignBottomRight] = {ALIGN_H.RIGHT,   ALIGN_V.BOTTOM},
        [kAlignLeft]        = {ALIGN_H.LEFT,    ALIGN_V.CENTER},
        [kAlignTopLeft]     = {ALIGN_H.LEFT,    ALIGN_V.TOP},
        [kAlignBottomLeft]  = {ALIGN_H.LEFT,    ALIGN_V.BOTTOM},
    }
    return unpack(t[a])
end

M.compat_align_split = compat_align_split

local function compat_align_rules(align, alignX, alignY)
    local h, v = compat_align_split(align)
    local h_rule
    if h == ALIGN_H.LEFT then
        h_rule = M.left:eq(alignX)
    elseif h == ALIGN_H.CENTER then
        h_rule = M.centerx:eq(M.parent('width') / 2 + alignX)
    elseif h == ALIGN_H.RIGHT then
        h_rule = M.right:eq(M.parent('width') - alignX)
    end
    assert(h_rule ~= nil)

    local v_rule
    if v == ALIGN_V.TOP then
        v_rule = M.top:eq(alignY)
    elseif v == ALIGN_V.CENTER then
        v_rule = M.centery:eq(M.parent('height') / 2 + alignY)
    elseif v == ALIGN_V.BOTTOM then
        v_rule = M.bottom:eq(M.parent('height') - alignY)
    end
    assert(v_rule ~= nil)

    return {h_rule, v_rule}

end

M.compat_align_rules = memorize(compat_align_rules)

M.LayoutItemMixin = {
    __init__ = function(self)
        self.autolayout_enabled = true
        self.compat_rules = {}

        -- set a default value
        self._width_hug = kiwi.WEAK
        self._height_hug = kiwi.WEAK

        self.constraint_dirty = true
        self.constraint_cache = {}

        self.vars = self:lua_vars()
        self.parent_vars = self:lua_parent_vars()

        if not ___clean_byui then
            M.LayoutItemMixin.ctor(self)
        end
    end,
    autolayout_enabled = {function(self)
        return self._autolayout_enabled
    end, function(self, b)
        if self._autolayout_enabled ~= b then
            self._autolayout_enabled = b
            if b then
                self.lua_build_constraints = self.build_constraints
            else
                self.lua_build_constraints = nil
            end
        end
    end},
    build_constraints = function(self)
        if not self.constraint_dirty then
            return self.constraint_cache
        end
        local constraints = {}
        -- basic constraints
        --table.insert(constraints, self.vars.width:ge(0))
        --table.insert(constraints, self.vars.height:ge(0))

        for _, r in ipairs(self.compat_rules) do
            local rr = r(self)
            if type(rr) == 'table' then
                table.append(constraints, rr)
            else
                table.insert(constraints, rr)
            end
        end

        -- apply size hint
        if self.width_hint ~= nil then
            if self.width_hug ~= nil then
                table.insert(constraints, self.vars.width:eq(self.width_hint):priority(self.width_hug))
            end
            if self.width_resist ~= nil then
                table.insert(constraints, self.vars.width:ge(self.width_hint):priority(self.width_resist))
            end
            if self.width_limit ~= nil then
                table.insert(constraints, self.vars.width:le(self.width_hint):priority(self.width_limit))
            end
        end
        if self.height_hint ~= nil then
            if self.height_hug ~= nil then
                table.insert(constraints, self.vars.height:eq(self.height_hint):priority(self.height_hug))
            end
            if self.height_resist ~= nil then
                table.insert(constraints, self.vars.height:ge(self.height_hint):priority(self.height_resist))
            end
            if self.height_limit ~= nil then
                table.insert(constraints, self.vars.height:le(self.height_hint):priority(self.height_limit))
            end
        end

        self.constraint_cache = constraints
        return constraints
    end,
    dump_constraint = function(self)
        print_string(self:__tostring())
        for _, c in ipairs(self.constraint_cache) do
            print_string('    ' .. tostring(c))
        end
    end,
    add_rules = function(self, rules)
        local add_rule = self.add_rule
        for _, rule in ipairs(rules) do
            add_rule(self, rule)
        end
    end,
    size_hint = {function(self)
        return Point(self._width_hint, self._height_hint)
    end, function(self, s)
        self.width_hint = s.x
        self.height_hint = s.y
    end},
    width_hint = {function(self)
        return self._width_hint
    end, function(self, v)
        if self._width_hint ~= v then
            self._width_hint = v
            self.constraint_dirty = true
        end
    end},
    width_hug = {function(self)
        return self._width_hug
    end, function(self, v)
        if self._width_hug ~= v then
            self._width_hug = v
            self.constraint_dirty = true
        end
    end},
    width_resist = {function(self)
        return self._width_resist
    end, function(self, v)
        if self._width_resist ~= v then
            self._width_resist = v
            self.constraint_dirty = true
        end
    end},
    width_limit = {function(self)
        return self._width_limit
    end, function(self, v)
        if self._width_limit ~= v then
            self._width_limit = v
            self.constraint_dirty = true
        end
    end},

    height_hint = {function(self)
        return self._height_hint
    end, function(self, v)
        if self._height_hint ~= v then
            self._height_hint = v
            self.constraint_dirty = true
        end
    end},
    height_hug = {function(self)
        return self._height_hug
    end, function(self, v)
        if self._height_hug ~= v then
            self._height_hug = v
            self.constraint_dirty = true
        end
    end},
    height_resist = {function(self)
        return self._height_resist
    end, function(self, v)
        if self._height_resist ~= v then
            self._height_resist = v
            self.constraint_dirty = true
        end
    end},
    height_limit = {function(self)
        return self._height_limit
    end, function(self, v)
        if self._height_limit ~= v then
            self._height_limit = v
            self.constraint_dirty = true
        end
    end},
}

local widget_update = cls_utils.index(nil, 'update', Widget.___class)
local function getRootParent(p)
    local pp = p.parent
    while pp do
        p = pp
        pp = p.parent
    end
    return p
end

if not ___clean_byui then
table.merge(M.LayoutItemMixin, {
    ctor = function(self)
        self.m_align = kAlignTopLeft
        self.m_x = 0
        self.m_y = 0
        self.m_alignX = 0
        self.m_alignY = 0
    end,
    setAlign = function(self, align)
        self.m_align = align or kAlignTopLeft
        self:updateRules()
    end,
    setPos = function(self, x, y)
        self.m_alignX = x or self.m_alignX
        self.m_alignY = y or self.m_alignY

        if not (self.m_fillParentWidth and self.m_fillParentHeight) then
            self:updateRules()
        end
    end,
    getPos = function(self)
        return self.m_fillParentWidth and 0 or self.m_alignX,
               self.m_fillParentHeight and 0 or self.m_alignY
    end,
    getUnalignPos = function(self)
        return self.m_x, self.m_y
    end,
    getAbsolutePos = function(self)
        widget_update(getRootParent(self))
        local dx=self.x
        local dy=self.y
        local p = self.parent
        while p do
            dx = dx + p.x
            dy = dy + p.y
            p = p.parent
        end
        return dx, dy
    end,
    setSize = function(self, w, h) 
        w = w or self.width
        h = h or self.height
        self.size = Point(w, h)
        self:updateRules()
    end,
    convertPointToSurface = function(self, x, y)
        local p = self:to_world(Point(x or 0, y or 0))
        return p.x, p.y
    end,
    convertSurfacePointToView = function(self, x, y)
        local p = self:from_world(Point(x or 0, y or 0))
        return p.x, p.y
    end,
    updateRules = function(self)
        local rules = {}
        if self.m_fillRegion then
            rules = {
                M.left:eq(self.m_fillRegionTopLeftX),
                M.top:eq(self.m_fillRegionTopLeftY),
                M.right:eq(M.parent('width') - self.m_fillRegionBottomRightX),
                M.bottom:eq(M.parent('height') - self.m_fillRegionBottomRightY),
            }
        else
            if self.m_fillParentWidth then
                table.insert(rules, M.width:eq(M.parent('width')))
            else
                table.insert(rules, M.width:eq(self.width))
            end
            if self.m_fillParentHeight then
                table.insert(rules, M.height:eq(M.parent('height')))
            else
                table.insert(rules, M.height:eq(self.height))
            end
            local x, y = self:getPos()
            if self.m_align ~= kAlignTopLeft then
                table.append(rules, compat_align_rules(self.m_align, x, y))
            else
                table.insert(rules, M.left:eq(x))
                table.insert(rules, M.top:eq(y))
            end
        end
        for _, r in ipairs(rules) do
            r.strength = kiwi.MEDIUM
        end
        self.compat_rules = rules
        self:update_constraints()
    end,
    setFillParent = function(self, doFillParentWidth, doFillParentHeight)
        self.m_fillParentWidth = doFillParentWidth
        self.m_fillParentHeight = doFillParentHeight
        self:updateRules()
    end,
    getFillParent = function(self)
        return self.m_fillParentWidth,self.m_fillParentHeight
    end,
    setFillRegion = function(self, doFill, topLeftX, topLeftY, bottomRightX, bottomRightY)
        self.m_fillRegion = doFill
        if self.m_fillRegion then
            self.m_fillRegionTopLeftX = topLeftX
            self.m_fillRegionTopLeftY = topLeftY
            self.m_fillRegionBottomRightX = bottomRightX
            self.m_fillRegionBottomRightY = bottomRightY
        end
        self:updateRules()
    end,
    getFillRegion = function(self)
        return self.m_fillRegion,self.m_fillRegionTopLeftX,self.m_fillRegionTopLeftY,
        self.m_fillRegionBottomRightX,self.m_fillRegionBottomRightY
    end,
    getSize = function(self)
        if not (self.m_fillParentWidth or self.m_fillParentHeight or self.m_fillRegion) then
            return self.width,self.height
        end

        if self.m_fillRegion then
            local w,h
            if self.m_parent then
                w,h = self.m_parent:getSize()
            else
                w,h = Window.instance().drawing_root.width,
                Window.instance().drawing_root.width
            end

            w = w - self.m_fillRegionTopLeftX - self.m_fillRegionBottomRightX
            h = h - self.m_fillRegionTopLeftY - self.m_fillRegionBottomRightY

            return w,h
        end

        if self.m_fillParentWidth and self.m_fillParentHeight then
            if self.m_parent then
                return self.m_parent:getSize()
            else
                return System.getScreenWidth(),
                System.getScreenHeight()
            end
        end

        local w= self.width
        local h = self.height

        if self.m_fillParentWidth then
            if self.m_parent then
                w = self.m_parent:getSize()
            else
                w = System.getScreenWidth()
            end
        end

        if self.m_fillParentHeight then
            if self.m_parent then
                local tw = nil; 
                tw, h = self.m_parent:getSize()
            else
                h = System.getScreenHeight()
            end
        end

        return w,h
    end,
    getRealSize = function(self)
        return M.LayoutItemMixin.getSize(self);
    end,
    getChildByName = function(self, name)
        for _,v in pairs(self.children) do 
            if v.name == name then
                return v
            end
        end
    end,
})
end



function M.patch_root()
    get_root().metatable = Widget.___class
    local root = get_root():to_lua()
    root:__init__{}
end

---
-- 给定的默认的规则.
-- @field [parent=#byui.autolayout] #rules rules 
M.rules = {
    ---
    -- 对齐函数
    -- @function [parent=#rules] align
    -- @param byui.utils#ALIGN a 
    -- @usage local AL = require 'byui/autolayout'   -- 引入AutoLayout模块.
    -- local w = Widget()
    -- w.size = Point(100,100)
    -- w:add_rules(AL.rules.align(ALIGN.CENTER))          --居中显示
    align = memorize(function(a)
        local h = align_h(a)
        local h_rule
        if h == ALIGN_H.LEFT then
            h_rule = M.left:eq(0)
        elseif h == ALIGN_H.CENTER then
            h_rule = M.centerx:eq(M.parent('width') / 2)
        elseif h == ALIGN_H.RIGHT then
            h_rule = M.right:eq(M.parent('width'))
        end

        local v = align_v(a)
        local v_rule
        if v == ALIGN_V.TOP then
            v_rule = M.top:eq(0)
        elseif v == ALIGN_V.CENTER then
            v_rule = M.centery:eq(M.parent('height') / 2)
        elseif v == ALIGN_V.BOTTOM then
            v_rule = M.bottom:eq(M.parent('height'))
        end

        return {h_rule, v_rule}
    end),
    ---
    -- 填充父节点的大小.
    -- @field [parent=#rules] #table fill_parent
    -- @usage local AL = require 'byui/autolayout'   -- 引入AutoLayout模块.
    -- local w = Widget()
    -- w:add_rules(AL.rules.fill_parent)          --填充父节点
    fill_parent = {
        M.width:eq(M.parent('width')),
        M.height:eq(M.parent('height')),
    },
}

local function _lua_on_enter(self)
    local fn = self.on_enter
    if fn then
        fn(self)
    end
end
local function _lua_on_exit(self)
    local fn = self.on_exit
    if fn then
        fn(self)
    end
end
local function patch_on_enter_exit(self)
    self.lua_on_enter = _lua_on_enter
    self.lua_on_exit  = _lua_on_exit
end

-- patch widgets
if Widget.___class.___lua == nil then
    CWidget = Widget
    Widget = class('Widget', CWidget, mixin(M.LayoutItemMixin, {
        __new__ = function(size, b)
            return CWidget(size, b)
        end,
        __init__ = function(self, size, b)
            M.LayoutItemMixin.__init__(self)
            patch_on_enter_exit(self)
        end
    }))
    
    for _, name in ipairs{'AL_MASK_LEFT', 'AL_MASK_TOP', 'AL_MASK_WIDTH', 'AL_MASK_HEIGHT', 'AL_MASK_SIZE', 'AL_MASK_POSITION', 'AL_MASK_NONE', 'AL_MASK_ALL',
        'get_by_id', 'get_uservalue', 'set_uservalue', 'ATTR_X','ATTR_Y','ATTR_WIDTH','ATTR_HEIGHT','ATTR_SCALEX','ATTR_SCALEY','ATTR_SKEWX','ATTR_SKEWY','ATTR_ROTATION','ATTR_COLOR','ATTR_OPACITY','ATTR_VISIBLE','Perspective_3D','Perspective_2D'
    } do
        Widget[name] = CWidget[name]
    end

    CSprite = Sprite
    Sprite = class('Sprite', CSprite, mixin(M.LayoutItemMixin, {
        __new__ = function(unit)
            return CSprite(unit)
        end,
        __init__ = function(self, unit)
            M.LayoutItemMixin.__init__(self)
            patch_on_enter_exit(self)
            if unit then
                self.size = unit.size
                self.size_hint = unit.size
            end
        end,
    }))

    -- CGridSprite = GridSprite
    -- GridSprite = class('GridSprite', CGridSprite, mixin(M.LayoutItemMixin, {
    --     __new__ = function(args)
    --         return CGridSprite(args.row or 10, args.col or 10, args.unit, args.action_type)
    --     end,
    --     __init__ = function(self, args)
    --         M.LayoutItemMixin.__init__(self)
    --         patch_on_enter_exit(self)

    --         args.row = nil
    --         args.col = nil
    --         args.unit = nil
    --         args.action_type = nil

    --         for k, v in pairs(args) do
    --             self[k] = v
    --         end
    --     end,
    -- }))
 
    -- for _, name in ipairs{'GRID_ACTION_TYPE_WAVES_3D', 'GRID_ACTION_TYPE_LENS', 'GRID_ACTION_TYPE_RIPPLE', 'GRID_ACTION_TYPE_SHAKY', 'GRID_ACTION_TYPE_LIQUID', 'GRID_ACTION_TYPE_WAVES', 'GRID_ACTION_TYPE_TWIRL',
    --     'GRID_ACTION_TYPE_SHUFFLE', 'GRID_ACTION_TYPE_FADE_OUT', 'GRID_ACTION_TYPE_TURN_OFF', 'GRID_ACTION_TYPE_JUMP', 'GRID_ACTION_TYPE_SPLIT', 'GRID_ACTION_TYPE_PAGE_TURN', 'GRID_ACTION_TYPE_CUSTOM',
    --     'FADE_OUT_TYPE_TL', 'FADE_OUT_TYPE_TR', 'FADE_OUT_TYPE_BL', 'FADE_OUT_TYPE_BR', 'FADE_OUT_TYPE_LEFT', 'FADE_OUT_TYPE_RIGHT', 'FADE_OUT_TYPE_UP', 'FADE_OUT_TYPE_DOWN',
    --     'PAGE_TURN_TYPE_TR', 'PAGE_TURN_TYPE_BR', 'PAGE_TURN_TYPE_TL', 'PAGE_TURN_TYPE_BL',
    -- } do
    --     GridSprite[name] = CGridSprite[name]
    -- end

    -- CGridWidget = GridWidget
    -- GridWidget = class('GridWidget', CGridWidget, mixin(M.LayoutItemMixin, {
    --     __new__ = function(args)
    --         return CGridWidget(true, args.size)
    --     end,
    --     __init__ = function(self, args)
    --         M.LayoutItemMixin.__init__(self)
    --         patch_on_enter_exit(self)

    --         self:set_widget(args.row or 10, args.col or 10, args.widget, args.action_type)

    --         args.row = nil
    --         args.col = nil
    --         args.widget = nil
    --         args.size = nil
    --         args.action_type = nil

    --         local need_depth = args.need_depth or false
    --         args.need_depth = nil

    --         local grid_sprite = self:get_grid_sprite()
    --         for k, v in pairs(args) do
    --             grid_sprite[k] = v
    --         end

    --         if need_depth then grid_sprite.fbo.need_depth = true end
    --     end,
    -- }))

    CBorderSprite = BorderSprite
    BorderSprite = class('BorderSprite', CBorderSprite, mixin(M.LayoutItemMixin, {
        __new__ = function(unit)
            return CBorderSprite(unit)
        end,
        __init__ = function(self, unit)
            M.LayoutItemMixin.__init__(self)
            patch_on_enter_exit(self)
            if unit then
                self.size = unit.size
                self.size_hint = unit.size
            end
        end,
    }))

    CLabel = Label
    Label = class('Label', CLabel, mixin(M.LayoutItemMixin, {
        __new__ = function(...)
            return CLabel(...)
        end,
        __init__ = function(self, ...)
            M.LayoutItemMixin.__init__(self)
            patch_on_enter_exit(self)
            super(Label, self).on_size_changed = function(_)
                if not self.layout_size:bool() then
                    self.size_hint = self.size
                end
                --self:setSize(self.width, self.height)
                self:update_constraints()
                if self._on_size_changed then
                    self:_on_size_changed()
                end
            end
            super(Label, self).on_content_bbox_changed = function(_)
                if self.absolute_align then
                    self.absolute_align = self._absolute_align
                end
                if self._on_content_bbox_changed then
                    self:_on_content_bbox_changed()
                end
            end
        end,
        layout_size = {function(self)
            return super(Label, self).layout_size
        end, function(self, s)
            super(Label, self).layout_size = s
            if s:bool() then
                self.size_hint = s
            else
                self.size_hint = self.size
            end
        end},
        on_size_changed = {function(self)
            return self._on_size_changed
        end, function(self, fn)
            self._on_size_changed = fn
        end},
        _set_prop = function ( self,key,value,index )
            index = index or 1
            local config_data = self:get_data()
            assert(config_data[index],"Paragraph does not exist")
            -- assert(config_data[index][key],"Paragraph' key does not exist")

            config_data[index][key] = value
            self:set_data(config_data)
        end,
        set_text = function ( self,value,index)
            self:_set_prop('text',value,index)
        end,
        set_size = function ( self,value,index)
            self:_set_prop('size',value,index)
        end,
        set_style = function ( self,value,index)
            self:_set_prop('style',value,index)
        end,
        set_color = function ( self,value,index)
            self:_set_prop('color',value,index)
        end,
        set_bg_color = function ( self,value,index)
            self:_set_prop('bg',value,index)
        end,
        set_stroke = function ( self,value,index)
            self:_set_prop('stroke',value,index)
        end,
        set_weight = function ( self,value,index)
            self:_set_prop('weight',value,index)
        end,
        set_glow = function ( self,value,index)
            self:_set_prop('glow',value,index)
        end,
        set_underline = function ( self,value,index)
            self:_set_prop('underline',value,index)
        end,
        set_middleline = function ( self,value,index)
            self:_set_prop('middleline',value,index)
        end,
        set_tag = function ( self,value,index)
            self:_set_prop('tag',value,index)
        end,
        absolute_align = {function ( self )
            return self._absolute_align 
        end,function ( self,align )
            if not align then
                self:clear_rules()
                self:update_constraints()
            end
            self._absolute_align = align 
            self:update(false)
            local content = self.content_bbox
            local h, v = align_h(self._absolute_align),align_v(self._absolute_align)
            local h_rule
            if h == ALIGN_H.LEFT then
                h_rule = M.left:eq(-content.x)
            elseif h == ALIGN_H.CENTER then
                h_rule = M.left:eq((M.parent('width') -content.w)/2 - content.x)
            elseif h == ALIGN_H.RIGHT then
                h_rule = M.left:eq(M.parent('width') - content.w - content.x)
            end
            assert(h_rule ~= nil)

            local v_rule
            if v == ALIGN_V.TOP then
                v_rule = M.top:eq(-content.y)
            elseif v == ALIGN_V.CENTER then
                v_rule = M.top:eq((M.parent('height') - content.h) / 2 - content.y)
            elseif v == ALIGN_V.BOTTOM then
                v_rule = M.top:eq(M.parent('height') - content.h - content.y)
            end
            assert(v_rule ~= nil)
            self:clear_rules()
            self:add_rules{h_rule, v_rule}
            self:update_constraints()
        end},
        init_link = function(self, onclick)
            local byui = require('byui/simple_ui')
            byui.init_label_link(self, onclick)
        end,
    }))
    for _, name in ipairs{'LEFT', 'TOP', 'CENTER', 'MIDDLE', 'RIGHT', 'BOTTOM', 'config', 'get_default_line_height','add_emoji', 'set_emoji_baseline', 'set_emoji_scale', 'set_default_line_scale','STYLE_ITALIC','STYLE_BOLD','STYLE_NORMAL'} do
        Label[name] = CLabel[name]
    end

    CLuaWidget = LuaWidget
    LuaWidget = class('LuaWidget', CLuaWidget, mixin(M.LayoutItemMixin, {
        __new__ = function(tbl)
            return CLuaWidget(tbl)
        end,
        __init__ = function(self, tbl)
            M.LayoutItemMixin.__init__(self)
        end,
    }))

    CDrawing = Drawing
    Drawing = class('Drawing', CDrawing, mixin(M.LayoutItemMixin, {
        __new__ = function()
            return CDrawing()
        end,
        __init__ = function(self)
            M.LayoutItemMixin.__init__(self)
        end,
    }))
end

M.patch_root()

function M.test(root)
    local layout = require('byui/layout')
    local ui = require('byui/basic')

    local parent = Widget()
    parent.background_color = Colorf.red
    parent:add_rules(M.rules.align(ALIGN.CENTER))
    parent:add_rules(M.rules.fill_parent)

    local btn = ui.Button{}
    btn:add_rules(M.rules.align(ALIGN.TOPRIGHT))
    btn.on_click = function(self)
        btn.text = 'hahahahaha'
    end
    parent:add(btn)

    local c = ui.ScrollView{
        dimension = kVertical,
    }
    c.content = layout.FloatLayout{
        spacing = Point(5,5),
    }
    c.size = Point(50,50)
    c.content.relative = true
    c.content.autolayout_size_enabled = true
    c.background_color = Colorf.blue
    for i=1,11 do
        local btn = ui.Button{text='Item'}
        c.content:add(btn)
    end
    --c.content:add_rules(M.rules.align(ALIGN.TOPLEFT))
    c.content:add_rules(M.rules.fill_parent)
    c:add_rules(M.rules.align(ALIGN.BOTTOM))
    c:add_rules{
        M.width:eq(M.parent('width') - 40),
        M.height:eq(M.parent('height') - 40),
    }
    parent:add(c)

    root:add(parent)
end

return M

end
        

package.preload[ "byui.autolayout" ] = function( ... )
    return require('byui/autolayout')
end
            

package.preload[ "byui/basic" ] = function( ... )
---
-- UI库.
-- 包含@{# byui.bmfont} ,@{# byui.scroll},@{# byui.simple_ui},@{# byui.edit}
-- @module byui
-- @return #byui

local simple_ui = require 'byui/simple_ui'
local scroll = require 'byui/scroll'
local edit = require 'byui/edit'
local tableview = require 'byui/tableview'
local bmfont = require 'byui/bmfont'
 


local M = {}
table.merge(M,simple_ui)
table.merge(M,scroll)
table.merge(M,edit)
table.merge(M,tableview)
table.merge(M,bmfont)
return M 
end
        

package.preload[ "byui.basic" ] = function( ... )
    return require('byui/basic')
end
            

package.preload[ "byui/bmfont" ] = function( ... )
---
-- 图片字.
-- @module byui.bmfont
-- @extends byui#byui.bmfont
-- @return #table 返回listview等类型 
local M = {}
local class, mixin, super = unpack(require('byui/class'))

local function Utf8to32(utf8str)
    assert(type(utf8str) == "string")
    local res, seq, val = {}, 0, nil
    for i = 1, #utf8str do
	    local c = string.byte(utf8str, i)
	    if seq == 0 then
	        table.insert(res, val)
	        seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
	              c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
	              error("invalid UTF-8 character sequence")
	        val = bit.band(c, 2^(8-seq) - 1)
	    else
	        val = bit.bor(bit.lshift(val, 6), bit.band(c, 0x3F))
	    end
	    seq = seq - 1
    end
    table.insert(res, val)
    table.insert(res, 0)
    return res
end

---
-- 图片字.
-- @type byui.LabelBMFont
-- @extends engine#Widget 

---
-- 创建图片字对象.
-- @callof #byui.LabelBMFont
-- @param #byui.LabelBMFont self 
-- @param #table args 构造时传入的参数.<br/>
--                    1. filename:图片字的配置文件。
--                    2. text:需要显示的文本。
-- @return #byui.LabelBMFont 返回创建的图片字对象. 
-- @usage 
-- local labelBMFont = M.LabelBMFont{text = '13245\n6.12312\n78dsdsd46542390',filename = 'fnt.lua',line_width = nil}
--    root:add(labelBMFont)
--    Clock.instance():schedule_once(function ( ... )
--        -- labelBMFont.text = '1.321657463156746458'
--        for i,v in ipairs(labelBMFont.children_node) do
--            if i == 3 then
--                -- v.background_color = Colorf.red
--            end
--            print(i,v.pos,v.size)
--        end
--    end,2)


M.LabelBMFont = class('LabelBMFont',Widget,{
	__init__ = function ( self,args )
		super(M.LabelBMFont, self).__init__(self)
		self.filename = require(args.filename)
		self._line_width = args.line_width 
		self._children_node = {}
		self.text = args.text or ''
	end,
	
	--- 
	-- 显示的文字.
	-- 不能为nil,且必须为字符串。如果在配置中不存在对应的字符则不会显示。 
	-- @field [parent=#byui.LabelBMFont] #string text 
	text = {function ( self )
		return self._text or ''
	end,function ( self,value )
		assert(value,'string does not exist')
		assert(type(value) == 'string','the parameter must be a string')
		self._text = value
		self._uchar = Utf8to32(self._text)
		self._length = #self._uchar - 1
		self:_clear()
		self:_create_font_chars()
	end},
	_clear = function ( self )
		for key,value in ipairs(self._children_node) do
			value:remove_from_parent()
		end
		self._children_node = {}
	end,
	_create_font_chars = function ( self )
		local nextFontPositionX = 0
	    local nextFontPositionY = 0
	    local common_height = 0

	    local tmpSize = Point(0,0)

	    local longestLine = 0;
    	local totalHeight = 0;

    	local quantityOfLines = 1;
    	
    	if self._length == 0 then
    		self.size = tmpSize
    		return 
    	end
    	local charSet = self.filename  	
    	common_height = charSet[tostring(self._uchar[1])..".png"].utHeight -- charSet[tostring(self._uchar[1])..".png"].offsetY
		for i=1,self._length do
			local c = self._uchar[i]
			if c == 10 then
				nextFontPositionX = 0
            	nextFontPositionY = nextFontPositionY + common_height
            	quantityOfLines = quantityOfLines + 1
            elseif not charSet[tostring(c)..".png"] then
            	print(string.format("LabelBMFont: Attempted to use character not defined in this bitmap:%s",string.char(c)))
            else
            	local unit_data = charSet[tostring(c)..".png"]
            	local unit = TextureUnit.load(unit_data)
            	local sprite = Sprite()
            	sprite.unit = unit
            	sprite.size = unit.original_size

            	local xoffset = 0
            	local real_width = 0
            	if unit_data.rotated then
            		real_width = unit_data.height
            	else
            		real_width = unit_data.width
            	end
				xoffset = unit_data.offsetX

            	local tempx = nextFontPositionX + real_width 
            	if self._line_width and tempx > self._line_width then
            		if nextFontPositionX == 0 then
            			nextFontPositionY = nextFontPositionY
            			quantityOfLines = quantityOfLines
         			else
            			nextFontPositionX = 0
            			nextFontPositionY = nextFontPositionY + common_height
            			quantityOfLines = quantityOfLines + 1
         			end
                end 
            	local fontPos = Point(nextFontPositionX-xoffset,nextFontPositionY)
            	sprite.pos = fontPos
            	nextFontPositionX = nextFontPositionX + real_width
            	if longestLine < nextFontPositionX then
		            longestLine = nextFontPositionX
        		end
        		table.insert(self._children_node,sprite)
        		self:add(sprite)
			end 
		end
		totalHeight = common_height*quantityOfLines
		tmpSize.x = longestLine 
		tmpSize.y = totalHeight
		self.size = tmpSize
	end,
	---
	-- 返回所有的文符对象集合.
	-- 主要用来做动画。
	-- @field [parent=#byui.LabelBMFont] #table children_node 
	children_node = {function ( self )
		return self._children_node
	end},
	})
M.test = function ( root )
	-- local test = M.BMFontConfiguration{filename = 'bmp.fnt'}
	-- test:parse_config_file()
	-- print(string_length('你好nihao12adsd!!￥'))
	local labelBMFont = M.LabelBMFont{text = '13245\n6.12312\n78dsdsd46542390',filename = 'fnt.lua',line_width = nil}
	root:add(labelBMFont)
	Clock.instance():schedule_once(function ( ... )
		-- labelBMFont.text = '1.321657463156746458'
		for i,v in ipairs(labelBMFont.children_node) do
			if i == 3 then
				-- v.background_color = Colorf.red
			end
			print(i,v.pos,v.size)
		end
	end,2)
end


return M
end
        

package.preload[ "byui.bmfont" ] = function( ... )
    return require('byui/bmfont')
end
            

package.preload[ "byui/class" ] = function( ... )
--local inspect = require('inspect')

local function index(self, name, meta)
    if meta == nil then
        meta = getmetatable(self)
    end
    local result
    while true do
        result = rawget(meta, name)
        if result ~= nil then
            return result
        end
        local getters = rawget(meta, '___getters')
        if getters ~= nil then
            result = getters[name]
            if result ~= nil then
                return result(self)
            end
        end

        meta = rawget(meta, '___super')
        if meta == nil then
            if type(self) == 'userdata' then
                return Widget.get_uservalue(self, name)
            else
                return rawget(self, name)
            end
        end
    end
end

local function newindex(self, name, value, meta)
    if meta == nil then
        meta = getmetatable(self)
    end
    local result
    while true do
        local setters = rawget(meta, '___setters')
        if setters ~= nil then
            result = setters[name]
            if result ~= nil then
                result(self, value)
                return
            end
        end
        meta = rawget(meta, '___super')
        if meta == nil then
            if type(self) == 'userdata' then
                Widget.set_uservalue(self, name, value)
            else
                rawset(self, name, value)
            end
            return
        end
    end
end

local function is_property(t)
    return type(t) == 'table' and type(t[1]) == 'function' and (#t==1 or (#t==2 and type(t[2]) == 'function'))
end

local function process_meta(meta)
    local new_meta = {}
    local getters = {}
    local setters = {}
    for k, v in pairs(meta) do
        if is_property(v) then
            getters[k] = v[1]
            setters[k] = v[2]
        else
            rawset(new_meta, k, v)
        end
    end
    rawset(new_meta, '___getters', getters)
    rawset(new_meta, '___setters', setters)
    return new_meta
end

local function find_native_class(meta)
    if meta.___lua == true then
        if meta.___super == nil then
            return
        end
        return find_native_class(meta.___super)
    else
        return meta
    end
end

local function class(name, super, meta)
    name = name or "";
    meta = meta or {};

    meta = process_meta(meta)
    if super ~= nil then
        meta.___super = super.___class
    end
    local type_name = string.format('class(%s)', name)
    meta.___lua = true
    meta.___native = find_native_class(meta)
    local native = meta.___native ~= nil

    -- auto-call super's gc
    local self_gc = meta.__gc
    function meta.__gc(self)
        --if self.___deleted ~= true then
            if self_gc then
                self_gc(self)
            end
            if meta.___super ~= nil then
                rawget(meta.___super, '__gc')(self)
            end
        --    self.___deleted = true
        --end
    end

    local cls = {
        ___name = name,
        ___type = 'static_' .. type_name,
        ___class = meta,
        __call = function(_, ...)
            local obj
            if native then
                if meta.__new__ then
                    obj = meta.__new__(...)
                else
                    obj = meta.___native.class()
                end
                assert(type(obj) == 'userdata')
                obj.metatable = meta
                obj.contain_children = true
                obj = obj:to_lua()
            else
                obj = setmetatable({}, meta)
            end
            local fn = obj.__init__
            if fn then
                fn(obj, ...)
            end
            return obj
        end
    }
    setmetatable(cls, cls)
    meta.class = cls
    meta.___type = type_name
    meta.__index = index
    meta.__newindex = newindex

    if super == nil or not rawget(super.___class, '___lua') then
        meta.setDelegate = function(self, d)
            self.m_delegate = d
        end
    end

    return cls
end

local function mixin(...)
    local tt = {...}
    assert(#tt >= 1)
    local r = tt[#tt]
    if #tt == 1 then
        return r
    end
    for i, t in ipairs(tt) do
        if i < #tt then
            table.merge(r, t, false)
        end
    end
    return r
end

local function super(cls, obj)
    assert(cls.___class.___super ~= nil)
    return setmetatable({}, {
        __index = function(_, name)
            return index(obj, name, cls.___class.___super)
        end,
        __newindex = function(_, name, value)
            newindex(obj, name, value, cls.___class.___super)
        end,
    })
end
local function isinstance(obj, cls)
    local meta = cls.___class
    local m = getmetatable(obj)
    while m do
        if m == meta then
            return true
        end
        m = m.___super
    end
    return false
end
local function issubclass(cls1, cls2)
    local meta1 = cls1.___class
    local meta2 = cls2.___class
    while true do
        if meta1 == meta2 then
            return true
        end
        meta1 = meta1.___super
    end
    return false
end
return {class, mixin, super, {
    index = index,
    newindex = newindex,
    isinstance = isinstance,
    issubclass = issubclass,
}}

end
        

package.preload[ "byui.class" ] = function( ... )
    return require('byui/class')
end
            

package.preload[ "byui/debugger" ] = function( ... )
--[[
	Copyright (c) 2015 Scott Lembcke and Howling Moon Software
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
	
	TODO:
	* Print short function arguments as part of stack location.
	* Bug: sometimes doesn't advance to next line (same line event reported multiple times).
	* Do coroutines work as expected?
]]


-- Use ANSI color codes in the prompt by default.
local COLOR_RED = ""
local COLOR_BLUE = ""
local COLOR_RESET = ""

local function pretty(obj, recurse)
	-- Returns true if a table has a __tostring metamethod.
	local function coerceable(tbl)
		local meta = getmetatable(tbl)
		return (meta and meta.__tostring)
	end
	
	if type(obj) == "string" then
		-- Dump the string so that escape sequences are printed.
		return string.format("%q", obj)
	elseif type(obj) == "table" and not coerceable(obj) and not recurse then
		local str = "{"
		
		for k, v in pairs(obj) do
			local pair = pretty(k, true).." = "..pretty(v, true)
			str = str..(str == "{" and pair or ", "..pair)
		end
		
		return str.."}"
	else
		-- tostring() can fail if there is an error in a __tostring metamethod.
		local success, value = pcall(function() return tostring(obj) end)
		return (success and value or "<!!error in __tostring metamethod!!>")
	end
end

local help_message = [[
[return] - re-run last command
c(ontinue) - contiue execution
s(tep) - step forward by one line (into functions)
n(ext) - step forward by one line (skipping over functions)
p(rint) [expression] - execute the expression and print the result
f(inish) - step forward until exiting the current function
u(p) - move up the stack by one frame
d(own) - move down the stack by one frame
t(race) - print the stack trace
l(ocals) - print the function arguments, locals and upvalues.
h(elp) - print this message
]]

-- The stack level that cmd_* functions use to access locals or info
-- The structure of the code very carefully ensures this.
local LOCAL_STACK_LEVEL = 6

-- Extra stack frames to chop off.
-- Used for things like dbgcall() or the overridden assert/error functions
local stack_top = 0

-- The current stack frame index.
-- Changed using the up/down commands
local stack_offset = 0

local dbg

-- Default dbg.read function
local function dbg_read(prompt)
	dbg.write(prompt)
	return io.read()
end

-- Default dbg.write function
local function dbg_write(str, ...)
	io.write(string.format(str, ...))
end

-- Default dbg.writeln function.
local function dbg_writeln(str, ...)
	dbg.write((str or "").."\n", ...)
end

local function format_stack_frame_info(info)
	local fname = (info.name or string.format("<%s:%d>", info.short_src, info.linedefined))
	return string.format(COLOR_BLUE.."%s:%d"..COLOR_RESET.." in '%s'", info.short_src, info.currentline, fname)
end

local repl

local function hook_factory(repl_threshold)
	return function(offset)
		return function(event, _)
			local info = debug.getinfo(2)
			
			if event == "call" and info.linedefined >= 0 then
				offset = offset + 1
			elseif event == "return" and info.linedefined >= 0 then
				if offset <= repl_threshold then
					-- TODO this is what causes the duplicated lines
					-- Don't remember why this is even here...
					--repl()
				else
					offset = offset - 1
				end
			elseif event == "line" and offset <= repl_threshold then
				repl()
			end
		end
	end
end

local hook_step = hook_factory(1)
local hook_next = hook_factory(0)
local hook_finish = hook_factory(-1)

local function table_merge(t1, t2)
	local tbl = {}
	for k, v in pairs(t1) do tbl[k] = v end
	for k, v in pairs(t2) do tbl[k] = v end
	
	return tbl
end

-- Create a table of all the locally accessible variables.
-- Globals are not included when running the locals command, but are when running the print command.
local function local_bindings(offset, include_globals)
	local level = stack_offset + offset + LOCAL_STACK_LEVEL
	local func = debug.getinfo(level).func
	local bindings = {}
	
	-- Retrieve the upvalues
	do local i = 1; repeat
		local name, value = debug.getupvalue(func, i)
		if name then bindings[name] = value end
		i = i + 1
	until name == nil end
	
	-- Retrieve the locals (overwriting any upvalues)
	do local i = 1; repeat
		local name, value = debug.getlocal(level, i)
		if name then bindings[name] = value end
		i = i + 1
	until name == nil end
	
	-- Retrieve the varargs. (works in Lua 5.2 and LuaJIT)
	local varargs = {}
	do local i = -1; repeat
		local name, value = debug.getlocal(level, i)
		table.insert(varargs, value)
		i = i - 1
	until name == nil end
	if #varargs ~= 0 then bindings["..."] = varargs end
	
	if include_globals then
		-- Merge the local bindings over the top of the environment table.
		-- In Lua 5.2, you have to get the environment table from the function's locals.
		local env = (_VERSION <= "Lua 5.1" and getfenv(func) or bindings._ENV)
		
		-- Finally, merge the tables and add a lookup for globals.
		return setmetatable(table_merge(env or {}, bindings), {__index = _G})
	else
		return bindings
	end
end

-- Compile an expression with the given variable bindings.
local function compile_chunk(expr, env)
	local source = "debugger.lua REPL"
	
	if _VERSION <= "Lua 5.1" then
		local chunk = loadstring("return "..expr, source)
		if chunk then setfenv(chunk, env) end
		return chunk
	else
		-- The Lua 5.2 way is a bit cleaner
		return load("return "..expr, source, "t", env)
	end
end

-- Wee version differences
local unpack = unpack or table.unpack

local function cmd_print(expr)
	local env = local_bindings(1, true)
	local chunk = compile_chunk(expr, env)
	if chunk == nil then
		dbg.writeln(COLOR_RED.."Error: Could not evaluate expression."..COLOR_RESET)
		return false
	end
	
	-- Call the chunk and collect the results.
	local results = {pcall(chunk, unpack(rawget(env, "...") or {}))}
	
	-- The first result is the pcall error.
	if not results[1] then
		dbg.writeln(COLOR_RED.."Error:"..COLOR_RESET.." %s", results[2])
	elseif #results == 1 then
		dbg.writeln(COLOR_BLUE..expr..COLOR_RED.." => "..COLOR_BLUE.."<no result>"..COLOR_RESET)
	else
		local result = ""
		for i = 2, #results do
			result = result..(i ~= 2 and ", " or "")..pretty(results[i])
		end
		
		dbg.writeln(COLOR_BLUE..expr..COLOR_RED.." => "..COLOR_RESET..result)
	end
	
	return false
end

local function cmd_up()
	local info = debug.getinfo(stack_offset + LOCAL_STACK_LEVEL + 1)
	
	if info then
		stack_offset = stack_offset + 1
	else
		dbg.writeln(COLOR_BLUE.."Already at the top of the stack."..COLOR_RESET)
	end
	
	dbg.writeln("Inspecting frame: "..format_stack_frame_info(debug.getinfo(stack_offset + LOCAL_STACK_LEVEL)))
	return false
end

local function cmd_down()
	if stack_offset > stack_top then
		stack_offset = stack_offset - 1
	else
		dbg.writeln(COLOR_BLUE.."Already at the bottom of the stack."..COLOR_RESET)
	end
	
	dbg.writeln("Inspecting frame: "..format_stack_frame_info(debug.getinfo(stack_offset + LOCAL_STACK_LEVEL)))
	return false
end

local function cmd_trace()
	local location = format_stack_frame_info(debug.getinfo(stack_offset + LOCAL_STACK_LEVEL))
	local offset = stack_offset - stack_top
	local message = string.format("Inspecting frame: %d - (%s)", offset, location)
	local str = debug.traceback(message, stack_top + LOCAL_STACK_LEVEL)
	
	-- Iterate the lines of the stack trace so we can highlight the current one.
	local line_num = -2
	while str and #str ~= 0 do
		local line, rest = string.match(str, "([^\n]*)\n?(.*)")
		str = rest
		
		if line_num >= 0 then line = tostring(line_num)..line end
		dbg.writeln((line_num + stack_top == stack_offset) and COLOR_BLUE..line..COLOR_RESET or line)
		line_num = line_num + 1
	end
	
	return false
end

local function cmd_locals()
	local bindings = local_bindings(1, false)
	
	-- Get all the variable binding names and sort them
	local keys = {}
	for k, _ in pairs(bindings) do table.insert(keys, k) end
	table.sort(keys)
	
	for _, k in ipairs(keys) do
		local v = bindings[k]
		
		-- Skip the debugger object itself, temporaries and Lua 5.2's _ENV object.
		if not rawequal(v, dbg) and k ~= "_ENV" and k ~= "(*temporary)" then
			dbg.writeln("\t"..COLOR_BLUE.."%s "..COLOR_RED.."=>"..COLOR_RESET.." %s", k, pretty(v))
		end
	end
	
	return false
end

local last_cmd = false

local function match_command(line)
	local commands = {
		["c"] = function() return true end,
		["s"] = function() return true, hook_step end,
		["n"] = function() return true, hook_next end,
		["f"] = function() return true, hook_finish end,
		["p%s?(.*)"] = cmd_print,
		["u"] = cmd_up,
		["d"] = cmd_down,
		["t"] = cmd_trace,
		["l"] = cmd_locals,
		["h"] = function() dbg.writeln(help_message); return false end,
	}
	
	for cmd, cmd_func in pairs(commands) do
		local matches = {string.match(line, "^("..cmd..")$")}
		if matches[1] then
			return cmd_func, select(2, unpack(matches))
		end
	end
end

-- Run a command line
-- Returns true if the REPL should exit and the hook function factory
local function run_command(line)
	-- Continue without caching the command if you hit control-d.
	if line == nil then
		dbg.writeln()
		return true
	end
	
	-- Re-execute the last command if you press return.
	if line == "" then
		if last_cmd then line = last_cmd else return false end
	else
		last_cmd = line
	end
	
	local command, command_arg = match_command(line)
	if command then
		-- unpack({...}) prevents tail call elimination so the stack frame indices are predictable.
		return unpack({command(command_arg)})
	else
		dbg.writeln(COLOR_RED.."Error:"..COLOR_RESET.." command '%s' not recognized", line)
		return false
	end
end

repl = function()
	dbg.writeln(format_stack_frame_info(debug.getinfo(LOCAL_STACK_LEVEL - 3 + stack_top)))
	
	repeat
		local success, done, hook = pcall(run_command, dbg.read(COLOR_RED.."debugger.lua> "..COLOR_RESET))
		if success then
			debug.sethook(hook and hook(0), "crl")
		else
			local message = string.format(COLOR_RED.."INTERNAL DEBUGGER.LUA ERROR. ABORTING\n:"..COLOR_RESET.." %s", done)
			dbg.writeln(message)
			error(message)
		end
	until done
end

-- Make the debugger object callable like a function.
dbg = setmetatable({}, {
	__call = function(self, condition, offset)
		if condition then return end
		
		offset = (offset or 0)
		stack_offset = offset
		stack_top = offset
		
		debug.sethook(hook_next(1), "crl")
		return
	end,
})

-- Expose the debugger's IO functions.
dbg.read = dbg_read
dbg.write = dbg_write
dbg.writeln = dbg_writeln
dbg.pretty = pretty

-- Works like error(), but invokes the debugger.
function dbg.error(err, level)
	level = level or 1
	dbg.writeln(COLOR_RED.."Debugger stopped on error:"..COLOR_RESET.."(%s)", pretty(err))
	dbg(false, level)
	
	error(err, level)
end

-- Works like assert(), but invokes the debugger on a failure.
function dbg.assert(condition, message)
	if not condition then
		dbg.writeln(COLOR_RED.."Debugger stopped on "..COLOR_RESET.."assert(..., %s)", message)
		dbg(false, 1)
	end
	
	assert(condition, message)
end

-- Works like pcall(), but invokes the debugger on an error.
function dbg.call(f, l)
	return (xpcall(f, function(err)
		dbg.writeln(COLOR_RED.."Debugger stopped on error: "..COLOR_RESET..pretty(err))
		dbg(false, (l or 0) + 1)
		
		-- Prevent a tail call to dbg().
		return
	end))
end

-- Error message handler that can be used with lua_pcall().
function dbg.msgh(...)
	dbg.write(...)
	dbg(false, 1)
	
	return ...
end

-- Detect Lua version.
if jit then -- LuaJIT
	dbg.writeln(COLOR_RED.."debugger.lua: Loaded for "..jit.version..COLOR_RESET)
elseif _VERSION == "Lua 5.2" or _VERSION == "Lua 5.1" then
	dbg.writeln(COLOR_RED.."debugger.lua: Loaded for ".._VERSION..COLOR_RESET)
else
	dbg.writeln(COLOR_RED.."debugger.lua: Not tested against ".._VERSION..COLOR_RESET)
	dbg.writeln(COLOR_RED.."Please send me feedback!"..COLOR_RESET)
end

-- Assume stdin/out are TTYs unless we can use LuaJIT's FFI to properly check them.
local stdin_isatty = true
local stdout_isatty = true

-- Conditionally enable the LuaJIT FFI.
local ffi = (jit and require("ffi"))
if ffi then
	ffi.cdef[[
		bool isatty(int);
		void free(void *ptr);
		
		char *readline(const char *);
		int add_history(const char *);
	]]
	
	stdin_isatty = ffi.C.isatty(0)
	stdout_isatty = ffi.C.isatty(1)
end

-- Conditionally enable color support.
local color_maybe_supported = (stdout_isatty and os.getenv("TERM") and os.getenv("TERM") ~= "dumb")
if color_maybe_supported and not os.getenv("DBG_NOCOLOR") then
	COLOR_RED = string.char(27) .. "[31m"
	COLOR_BLUE = string.char(27) .. "[34m"
	COLOR_RESET = string.char(27) .. "[0m"
end

-- Conditionally enable LuaJIT readline support.
local dbg_readline = nil
pcall(function()
	if ffi and stdin_isatty and not os.getenv("DBG_NOREADLINE") then
		local readline = ffi.load("readline")
		
		dbg_readline = function(prompt)
			local cstr = readline.readline(prompt)
			if cstr ~= nil then
				local str = ffi.string(cstr)
				if string.match(str, "[^%s]+") then
					readline.add_history(cstr)
				end
				
				ffi.C.free(cstr)
				return str
			else
				return nil
			end
		end
		
		dbg.read = dbg_readline
		dbg.writeln(COLOR_RED.."debugger.lua: Readline support enabled."..COLOR_RESET)
	end
end)

return dbg

end
        

package.preload[ "byui.debugger" ] = function( ... )
    return require('byui/debugger')
end
            

package.preload[ "byui/draw_res" ] = function( ... )
require('byui/utils')

local nvg = Nanovg(bit.bor(Nanovg.NVG_ANTIALIAS, Nanovg.NVG_DEBUG, Nanovg.NVG_STENCIL_STROKES))
local function nvg_node(size, draw)
    --local fbo = Widget()
    --fbo.background_color = Colorf.white
    --fbo.cache = true
    local w = LuaWidget()
    w.size = size
    local inst = LuaInstruction(function(self, canvas)
        nvg:begin_frame(canvas)
        draw(w, nvg)
        nvg:end_frame()
    end, true)

    w.lua_do_draw = function(self, canvas)
        canvas:add(inst)
    end
    --fbo:add(w)

    return w
end

local units = nil
return (function()
    if units == nil then
        units = {}
        local size = Point(512,512)
        local circle_r = 30
        local shadow_r = circle_r + 5
        local shadow_offset = Point(4,2)
        local editbox_size = Point(50, 20)
        local editbox_border = 1
        
        -- magnifier
        local magnifier_size = Point(100, 100)     
        
        -- delete icon 1
        local del_icon_1_size = Point(20, 20)    
        
        local circle_pos = Point(0,0)
        local shadow_pos = Point(circle_r * 2 + 2, 0)
        local editbox_pos = Point(shadow_pos.x + shadow_r * 2 + 2,0) 
        local editbox_pos2 = Point(editbox_pos.x ,editbox_size.y +2)
        local editbox_pos3 = Point(editbox_pos2.x ,2*(editbox_size.y +2))  
        local editbox_pos4 = Point(editbox_pos2.x ,3*(editbox_size.y +2)) 
        local magnifier_pos = Point(editbox_pos4.x + editbox_size.x + 2, 0)
        local del_icon_1_pos = Point(magnifier_pos.x + magnifier_size.x, 0)

        -- loading
        local loading_size = {Point(37,37),Point(22,22),Point(22,22)}
        local loading_pos = {Point(del_icon_1_pos.x+del_icon_1_size.x,0),Point(del_icon_1_pos.x+del_icon_1_size.x+38,0),Point(del_icon_1_pos.x+del_icon_1_size.x+61,0)}
        local count = 12

        

        local triangle_height = 20
        local triangle_pos = {Point(loading_pos[3].x+loading_size[3].x,0),Point(triangle_height + loading_pos[3].x+loading_size[3].x,0),
                                Point(triangle_height*2+loading_pos[3].x+loading_size[3].x,0),Point(triangle_height*2+loading_pos[3].x+loading_size[3].x,triangle_height)}
        local triangle_size = {Point(triangle_height,triangle_height*2),Point(triangle_height,triangle_height*2),
                                Point(triangle_height*2,triangle_height),Point(triangle_height*2,triangle_height)}
        
        -- samll magnifier
        local small_magnifier_size = Point(16, 16)
        local small_magnifier_pos  = Point(triangle_pos[3].x+triangle_size[3].x,0)
        -- radiobutton
        local radiobutton_r = 50
        local radiobutton_pos = Point(0,magnifier_size.y)
        local radiobutton_check_pos = Point(radiobutton_pos.x+radiobutton_r*2,magnifier_size.y)

        local arrow_size = Point(20,30)
        local arrow_pos = Point(radiobutton_check_pos.x + radiobutton_r*2,radiobutton_check_pos.y)
        local w = nvg_node(size, function(self, nvg)
            nvg:reset()
            nvg:translate(circle_pos)
            nvg:begin_path()
            nvg:circle(Point(circle_r, circle_r), circle_r);
            nvg:fill_color(Colorf.white)
            nvg:fill()
            --nvg:stroke_color(Colorf(0.8,0.8,0.8,1))
            --nvg:stroke()

            --nvg:reset()
            --nvg:translate(stroke_pos)
            --nvg:begin_path()
            --nvg:circle(Point(circle_r, circle_r), circle_r);
            --nvg:stroke_color(Colorf.black)
            --nvg:stroke()
            --nvg:fill_color(Colorf.white)
            --nvg:fill()

            -- shadow
            nvg:reset()
            nvg:translate(shadow_pos)
            local bg = nvg:radial_gradient(Point(shadow_r, shadow_r), 0, shadow_r, Colorf(1,1,1,0.7), Colorf(1,1,1,0))
            nvg:begin_path()
            nvg:path_winding(Nanovg.NVG_HOLE)
            nvg:circle(Point(shadow_r, shadow_r), shadow_r)
            nvg:circle(Point(circle_r, circle_r), circle_r)
            nvg:fill_paint(bg)
            nvg:fill()

            -- textedit box
            nvg:reset()
            nvg:translate(editbox_pos)
            nvg:begin_path()            
            nvg:rect(Rect(0, 0, editbox_size.x , editbox_size.y ))
            nvg:stroke_width(editbox_border+1)
            nvg:close_path()
            nvg:stroke_color(Colorf(0.5, 0.5, 0.5, 1))
            nvg:stroke()

            nvg:begin_path() 
            nvg:rect(Rect(editbox_border+1, editbox_border+1, editbox_size.x - editbox_border -1, editbox_size.y - editbox_border-1 ))
            nvg:stroke_width(editbox_border+2)
            nvg:close_path()
            nvg:stroke_color(Colorf(0.68, 0.68, 0.68, 1))
            nvg:stroke()


            -- textedit box2
            nvg:reset()
            nvg:translate(editbox_pos2)
            nvg:begin_path()            
            nvg:rect(Rect(editbox_border, editbox_border, editbox_size.x - 2*editbox_border , editbox_size.y - 2*editbox_border))
            nvg:stroke_width(editbox_border)
            nvg:close_path()
            nvg:stroke_color(Colorf(0.0, 0.0, 0.0, 1))
            nvg:stroke()

            -- textedit box3
            nvg:reset()
            nvg:translate(editbox_pos3)
            nvg:begin_path()            
            nvg:rounded_rect(Rect(editbox_border, editbox_border, editbox_size.x - 2*editbox_border , editbox_size.y - 2*editbox_border),editbox_border*6)
            nvg:close_path()
            nvg:fill_color(Colorf(0.65, 0.65, 0.65, 1))
            nvg:fill()
            nvg:begin_path()            
            nvg:rounded_rect(Rect(editbox_border+2, editbox_border+2, editbox_size.x - 6*editbox_border , editbox_size.y - 5*editbox_border),editbox_border*6)
            nvg:close_path()
            nvg:fill_color(Colorf(1.0, 1.0, 1.0, 1))
            nvg:fill()

            -- textedit box4
            nvg:reset()
            nvg:translate(editbox_pos4)
            nvg:begin_path()            
            nvg:rect(Rect(0, 0, editbox_size.x , editbox_size.y ))
            nvg:close_path()
            nvg:fill_color(Colorf(1.0, 1.0, 1.0, 1))
            nvg:fill()


            -- magnifier
            do
                local d = magnifier_size.x
                local r = d / 2 - 2
                local color = Colorf(0.8, 0.8, 0.8, 1.0)
                local sw = 0.5
                                
                nvg:reset()
                nvg:translate(magnifier_pos)
                nvg:begin_path()
                nvg:circle(Point(r + 1, r + 1), r)
                nvg:stroke_color(color)
                nvg:stroke_width(1)
                nvg:stroke()
                
                --nvg:begin_path()
                --nvg:move_to(Point(r + 1 + r / math.sqrt(2), r + 1 + r / math.sqrt(2)))
                --nvg:line_to(magnifier_size)
                --nvg:stroke_color(color)
                --nvg:stroke_width(sw)
                --nvg:stroke()                
            end
            
            -- delete icon 1
            do
                -- parameters
                local inR_ratio = 0.6
                local sw = 2
            
                local center = Point(del_icon_1_size.x / 2, del_icon_1_size.y / 2)  
                local r = del_icon_1_size.x / 2 - 1
                local inR = r * inR_ratio
                local ix = inR / math.sqrt(2)
                local color = Colorf(0.8, 0.8, 0.8, 0.8)
                local sx = sw / math.sqrt(2) / 2
                
                nvg:reset()
                nvg:translate(del_icon_1_pos)
                nvg:begin_path()
                nvg:circle(center, r)

                nvg:move_to(Point(center.x - ix - sx, center.y - ix + sx))                
                nvg:line_to(Point(center.x - ix + sx, center.y - ix - sx))
                nvg:line_to(Point(center.x, center.y - sx))
                
                nvg:line_to(Point(center.x + ix - sx, center.y - ix - sx))
                nvg:line_to(Point(center.x + ix + sx, center.y - ix + sx))
                nvg:line_to(Point(center.x + sx, center.y))
                
                nvg:line_to(Point(center.x + ix + sx, center.y + ix - sx))
                nvg:line_to(Point(center.x + ix - sx, center.y + ix + sx))
                nvg:line_to(Point(center.x, center.y + sx))
                
                nvg:line_to(Point(center.x - ix + sx, center.y + ix + sx))
                nvg:line_to(Point(center.x - ix - sx, center.y + ix - sx))
                nvg:line_to(Point(center.x - sx, center.y))
                
                nvg:line_to(Point(center.x - ix - sx, center.y - ix + sx))
                nvg:path_winding(Nanovg.NVG_HOLE)
                
                nvg:fill_color(color)
                nvg:fill()
            end

            -- loading White Large
            do 
                for i=0,count do
                    nvg:reset()
                    local a0 = i / count * math.pi * 2.0    
                    local c = i  / count + 0.04
                    nvg:translate(loading_pos[1])
                    nvg:translate(Point(loading_size[1].x/2, loading_size[1].y/2))
                    nvg:rotate(a0)
                    nvg:translate(Point(-loading_size[1].x/2, -loading_size[1].y/2))
                    nvg:begin_path()
                    nvg:rounded_rect(Rect(0,loading_size[1].y*7/16,loading_size[1].x/4,loading_size[1].y/8), loading_size[1].x/16)
                    nvg:fill_color(Colorf(1.0,1.0,1.0,c))
                    nvg:fill()
                end
            end

            -- loading White 
            do 
                for i=0,count do
                    nvg:reset()
                    local a0 = i / count * math.pi * 2.0    
                    local c = (i + 1 ) / (count +1)
                    nvg:translate(loading_pos[2])
                    nvg:translate(Point(loading_size[2].x/2, loading_size[2].y/2))
                    nvg:rotate(a0)
                    nvg:translate(Point(-loading_size[2].x/2, -loading_size[2].y/2))
                    nvg:begin_path()
                    nvg:rounded_rect(Rect(0,loading_size[2].y*7/16,loading_size[2].x/4,loading_size[2].y/8), loading_size[2].x/16)
                    nvg:fill_color(Colorf(1.0,1.0,1.0,c))
                    nvg:fill()
                end
            end

            -- loading Gray 
            do 
                for i=0,count do
                    nvg:reset()
                    local a0 = i / count * math.pi * 2.0    
                    local c = (i + 1 ) / (count +1)
                    nvg:translate(loading_pos[3])
                    nvg:translate(Point(loading_size[3].x/2, loading_size[3].y/2))
                    nvg:rotate(a0)
                    nvg:translate(Point(-loading_size[3].x/2, -loading_size[3].y/2))
                    nvg:begin_path()
                    nvg:rounded_rect(Rect(0,loading_size[3].y*7/16,loading_size[3].x/4,loading_size[3].y/8), loading_size[3].x/16)
                    nvg:fill_color(Colorf(0.5,0.5,0.5,c))
                    nvg:fill()
                end
            end

            -- radiobutton normal
            do 
                nvg:reset()
                nvg:translate(radiobutton_pos)
                local bg2 =nvg:linear_gradient(Point(radiobutton_r,0), Point(radiobutton_r,radiobutton_r*4/3),  Colorf(1,1,1,1.0), Colorf(0.6,0.6,0.6,0.7))
                nvg:begin_path()
                nvg:circle(Point(radiobutton_r,radiobutton_r), radiobutton_r -2)
                nvg:fill_paint(bg2)
                nvg:fill()

                local bg = nvg:box_gradient(Rect(1,1,2*radiobutton_r, 2*radiobutton_r),3,3, Colorf(0,0,0,32/255), Colorf(1,1,1,92/255))

                nvg:begin_path()
                nvg:stroke_width(2.5)
                nvg:circle(Point(radiobutton_r,radiobutton_r), radiobutton_r -2)
                nvg:stroke_color(Colorf(0,0,0,92/255))
                nvg:stroke()
            end

            -- radiobutton check
            do 
                nvg:reset()
                nvg:translate(radiobutton_check_pos)
                local bg =nvg:linear_gradient(Point(0,0), Point(radiobutton_r*2,radiobutton_r*4/3), Colorf(0.6,0.6,0.6,0.7),  Colorf(1,1,1,1.0))
                nvg:begin_path()
                nvg:circle(Point(radiobutton_r,radiobutton_r), radiobutton_r -2)
                nvg:fill_paint(bg)
                nvg:fill()

                nvg:begin_path()
                nvg:stroke_width(2.5)
                nvg:circle(Point(radiobutton_r,radiobutton_r), radiobutton_r - 2)
                nvg:stroke_color(Colorf(0,0,0,128/255))
                nvg:stroke()

                local bg2 =nvg:linear_gradient(Point(0,0), Point(radiobutton_r*2,radiobutton_r*2),  Colorf(0,0,0,1.0), Colorf(0.6,0.6,0.6,0.7))
                nvg:begin_path()
                nvg:circle(Point(radiobutton_r,radiobutton_r), radiobutton_r*0.3)
                nvg:fill_paint(bg2)
                nvg:fill()
            end

            -- do triangle 
            do
                -- draw left triangle
                nvg:reset()
                nvg:translate(triangle_pos[1])

                nvg:begin_path()
                nvg:move_to(Point(triangle_height,0))
                nvg:line_to(Point(0,triangle_height))
                nvg:line_to(Point(triangle_height,triangle_height*2))
                -- nvg:line_to(Point(0,0))
                nvg:close_path()
                nvg:fill_color(Colorf.white)
                nvg:fill()

                -- draw right triangle
                nvg:reset()
                nvg:translate(triangle_pos[2])

                nvg:begin_path()
                nvg:move_to(Point(0,0))
                nvg:line_to(Point(0,triangle_height*2))
                nvg:line_to(Point(triangle_height,triangle_height))
                nvg:line_to(Point(0,0))
                nvg:close_path()
                nvg:fill_color(Colorf.white)
                nvg:fill()

                -- draw top triangle
                nvg:reset()
                nvg:translate(triangle_pos[3])

                nvg:begin_path()
                nvg:move_to(Point(0,triangle_height))
                nvg:line_to(Point(triangle_height*2,triangle_height))
                nvg:line_to(Point(triangle_height,0))
                nvg:line_to(Point(0,triangle_height))
                nvg:close_path()
                nvg:fill_color(Colorf.white)
                nvg:fill()

                -- draw top triangle
                nvg:reset()
                nvg:translate(triangle_pos[4])

                nvg:begin_path()
                nvg:move_to(Point(0,0))
                nvg:line_to(Point(triangle_height*2,0))
                nvg:line_to(Point(triangle_height,triangle_height))
                nvg:line_to(Point(0,0))
                nvg:close_path()
                nvg:fill_color(Colorf.white)
                nvg:fill()


            end
            -- small_magnifier
            do
                local d = small_magnifier_size.x * (0.75)
                local r = d / 2
                local color = Colorf(0.0, 0.0, 0.0, 1.0)
                local sw = 0.5
                                
                nvg:reset()
                nvg:translate(small_magnifier_pos)
                nvg:begin_path()
                nvg:circle(Point(r + 1, r + 1), r)
                nvg:stroke_color(color)
                nvg:stroke_width(sw)
                nvg:stroke()
                
                nvg:begin_path()
                nvg:move_to(Point(r + 1 + r / math.sqrt(2), r + 1 + r / math.sqrt(2)))
                nvg:line_to(small_magnifier_size)
                nvg:stroke_color(color)
                nvg:stroke_width(sw)
                nvg:stroke()                
            end

            do
                local color = Colorf(0.0, 0.0, 0.0, 1.0)
                local sw = 0.5

                nvg:reset()
                nvg:translate(arrow_pos)
                nvg:begin_path()
                nvg:move_to(Point(arrow_size.x/2,arrow_size.y))
                nvg:line_to(Point(0,arrow_size.y - arrow_size.x/2))
                nvg:stroke_color(color)
                nvg:stroke_width(sw)
                nvg:stroke()

                nvg:begin_path()
                nvg:move_to(Point(arrow_size.x/2,arrow_size.y))
                nvg:line_to(Point(arrow_size.x,arrow_size.y -arrow_size.x/2))
                nvg:stroke_color(color)
                nvg:stroke_width(sw)
                nvg:stroke()

                nvg:begin_path()
                nvg:move_to(Point(arrow_size.x/2,0))
                nvg:line_to(Point(arrow_size.x/2,arrow_size.y))
                nvg:stroke_color(color)
                nvg:stroke_width(sw)
                nvg:stroke()
            end
        end)
        
        local fbo = FBO.create(size)
        --fbo.clear_color = Colorf(1,1,1,1)
        fbo.need_stencil = true
        fbo:render(w)
        -- fbo:save('output.png')
        local t = fbo.texture
        t.pre_alpha = true
        units.circle = TextureUnit(t)
        units.circle.rect = Rect(circle_pos.x, circle_pos.y, circle_r * 2, circle_r * 2)
        units.shadow = TextureUnit(fbo.texture)
        units.shadow.rect = Rect(shadow_pos.x, shadow_pos.y, shadow_r * 2, shadow_r * 2)
        units.editbox = TextureUnit(fbo.texture)
        units.editbox.rect = Rect(editbox_pos.x, editbox_pos.y, editbox_size.x, editbox_size.y)
        units.magnifier = TextureUnit(fbo.texture)
        units.magnifier.rect = Rect(magnifier_pos.x + 1, magnifier_pos.y + 1, magnifier_size.x - 2, magnifier_size.y - 2)
        units.del_icon_1 = TextureUnit(fbo.texture)
        units.del_icon_1.rect = Rect(del_icon_1_pos.x, del_icon_1_pos.y, del_icon_1_size.x, del_icon_1_size.y)
        units.loading_white_large = TextureUnit(fbo.texture)
        units.loading_white_large.rect = Rect(loading_pos[1].x, loading_pos[1].y, loading_size[1].x , loading_size[1].y)
        units.loading_white = TextureUnit(fbo.texture)
        units.loading_white.rect = Rect(loading_pos[2].x, loading_pos[2].y, loading_size[2].x , loading_size[2].y)
        units.loading_gray = TextureUnit(fbo.texture)
        units.loading_gray.rect = Rect(loading_pos[3].x, loading_pos[3].y, loading_size[3].x , loading_size[3].y)
        units.radiobutton_uncheck = TextureUnit(fbo.texture)
        units.radiobutton_uncheck.rect = Rect(radiobutton_pos.x,radiobutton_pos.y,radiobutton_r * 2,radiobutton_r * 2)
        units.radiobutton_check = TextureUnit(fbo.texture)
        units.radiobutton_check.rect = Rect(radiobutton_check_pos.x,radiobutton_check_pos.y,radiobutton_r * 2,radiobutton_r * 2)


        units.left_triangle = TextureUnit(fbo.texture)
        units.left_triangle.rect = Rect(triangle_pos[1].x,triangle_pos[1].y,triangle_size[1].x,triangle_size[1].y)
        units.right_triangle = TextureUnit(fbo.texture)
        units.right_triangle.rect = Rect(triangle_pos[2].x,triangle_pos[2].y,triangle_size[2].x,triangle_size[2].y)
        units.top_triangle = TextureUnit(fbo.texture)
        units.top_triangle.rect = Rect(triangle_pos[3].x,triangle_pos[3].y,triangle_size[3].x,triangle_size[3].y)
        units.bottom_triangle = TextureUnit(fbo.texture)
        units.bottom_triangle.rect = Rect(triangle_pos[4].x,triangle_pos[4].y,triangle_size[4].x,triangle_size[4].y)
       

        units.editbox_style_bezel = TextureUnit(fbo.texture)
        units.editbox_style_bezel.rect = Rect(editbox_pos.x, editbox_pos.y, editbox_size.x, editbox_size.y)
        units.editbox_style_line = TextureUnit(fbo.texture)
        units.editbox_style_line.rect = Rect(editbox_pos2.x, editbox_pos2.y, editbox_size.x, editbox_size.y)
        units.editbox_style_rounded_rect = TextureUnit(fbo.texture)
        units.editbox_style_rounded_rect.rect = Rect(editbox_pos3.x, editbox_pos3.y, editbox_size.x, editbox_size.y)
        units.editbox_style_none = TextureUnit(fbo.texture)
        units.editbox_style_none.rect = Rect(editbox_pos4.x, editbox_pos4.y, editbox_size.x, editbox_size.y)

        units.small_magnifier = TextureUnit(fbo.texture)
        units.small_magnifier.rect = Rect(small_magnifier_pos.x,small_magnifier_pos.y,small_magnifier_size.x,small_magnifier_size.y)

        units.arrow = TextureUnit(fbo.texture)
        units.arrow.rect = Rect(arrow_pos.x,arrow_pos.y,arrow_size.x,arrow_size.y)
    end
    return units
end)()

end
        

package.preload[ "byui.draw_res" ] = function( ... )
    return require('byui/draw_res')
end
            

package.preload[ "byui/edit" ] = function( ... )
local Scroll = require('byui/scroll');
local Simple = require('byui/simple_ui');
local class, mixin, super = unpack(require('byui/class'))
local anim = require('animation')
local units = require('byui/draw_res')
local AL = require('byui/autolayout')
local ui_utils = require('byui/ui_utils')
local Kinetic = require('byui/kinetic')
local M = {}

---
-- 编辑控件.
-- @module byui.edit
-- @extends byui#edit 
-- @return #table  




---
-- 放大镜.
-- 给定屏幕点将其放大显示出来。
-- @type byui.Magnifier


---
-- 创建一个放大镜.
-- @callof #byui.Magnifier
-- @param #byui.Magnifier self 
-- @param #table args 构造列表。
--      root:Widget类型，你可以指定放大镜的根节点是那一个.默认为Window.instance().drawing_root
-- @return #byui.Magnifier 返回创建的放大镜
-- @usage local mag= M.Magnifier{}


M.Magnifier = class('Magnifier', LuaWidget, {
    __init__ = function(self, args)
        self.root = args.root or Window.instance().drawing_root
        local default_unit = TextureUnit.default_unit()
        local circle = Circle(Point(0,0), 0, 40)
        local vertex1 = Rectangle(self.bbox, Matrix(), default_unit.uv_rect)
        local vertex2 = Rectangle(self.bbox, Matrix(), Rect(0,0,self.root.width,self.root.height))
        local vertex3 = Rectangle(self.bbox, Matrix(), units.magnifier.uv_rect)
        local old_bbox
        local function update_vertex(bbox)
            if old_bbox ~= bbox then
                local r = bbox.w / 2
                circle.pos = Point(bbox.x + r, bbox.y + r)
                circle.r = r
                vertex1.rect = bbox
                vertex1.colorf = self._background_color
                vertex2.rect = bbox
                vertex3.rect = bbox
                old_bbox = Rect(bbox.x, bbox.y, bbox.w, bbox.h)
            end
        end
        self.lua_do_draw = function(_, canvas)
            update_vertex(self.bbox)
            canvas:add(PushStencil())
            canvas:add(circle)
            canvas:add(UseStencil())

            -- background
            canvas:add(BindTexture(default_unit.texture, 0))
            canvas:add(vertex1)

            -- content
            canvas:add(PushBlendFunc(gl.GL_ONE, gl.GL_ONE_MINUS_SRC_ALPHA, gl.GL_ONE, gl.GL_ONE))
            canvas:add(BindTexture(self.unit.texture, 0))
            vertex2.uv_rect = self.unit.uv_rect
            canvas:add(vertex2)

            canvas:add(PopStencil())

            -- foreground
            canvas:add(BindTexture(units.magnifier.texture, 0))
            canvas:add(vertex3)

            canvas:add(PopBlendFunc())
        end
        self.radius = args.radius or 100
        self.multiply = args.multiply or 0.8
        self.offset = args.offset or Point(0, -100)
        self.size = Point(self.radius * 2, self.radius * 2)
    end,
    ---
    -- 需要放大显示的点.
    -- 点必须是在放大镜的root的座标系下的点.
    -- @field [parent=#byui.Magnifier] engine#Point center 
    -- @usage local mag= M.Magnifier{}
    -- mag.center = Point(100,100)
    center = {function(self)
        return self._center
    end, function(self, p)
        self._center = p
        self.pos = p - Point(self.radius, self.radius) + self.offset
        if self._attached then
            if self.root.fbo then
                self.unit = TextureUnit(self.root.fbo.texture)
                self.unit.rect = Rect(p.x - self.radius * self.multiply, p.y - self.radius * self.multiply, self.radius * self.multiply * 2, self.radius * self.multiply * 2)
            end
        end
    end},
    ---
    -- 开启放大镜.
    -- 只有attached为true时才能放大显示指定的点。
    -- @field [parent=#byui.Magnifier] #boolean attached 
    -- @usage local mag= M.Magnifier{}
    -- mag.center = Point(100,100)
    -- mag.attached = true
    -- -- mag.attached = false -- 关闭放大镜
    attached = {function(self)
        return self._attached
    end, function(self, b)
        if self._attached ~= b then
            self._attached = b
            if b then
                self._background_color = self.root.parent.background_color
                self._old_cache = self.root.cache
                self.root.cache = true
                self.root.clip = true
                Clock.instance():schedule_once(function ( ... )
                    -- body
                    -- if self.root.cache then
                        
                        if self.root.fbo then
                            self.root.parent:add(self)
                            self.unit = TextureUnit(self.root.fbo.texture)
                            local p = self._center
                            self.unit.rect = Rect(p.x - self.radius * self.multiply, p.y - self.radius * self.multiply, self.radius * self.multiply * 2, self.radius * self.multiply * 2)
                        end
                    -- end
                    -- body
                end)
            else
                self.root.cache = self._old_cache
                self.root.clip = false
                self:remove_from_parent()
            end
        end
    end}
})

M.EditEventHandler = {
    __init__ = function(self, args)
        self.event_widget = args.event_widget or self
        self.editbox = args.editbox or self
        if self.event_widget:getId() < 0 then
            self.event_widget:initId()
        end
        self.event_widget:add_listener(function(_, ...)
            self:handle_msg_chain(...)
        end)
        if args.enabled ~= nil then
            self.enabled = args.enabled
        else
            self.enabled = true
        end

        self.need_capture = args.need_capture or false

        self._recognizers = {}
    end,
    handle_msg_chain = function(self, touch, canceled)
        if self._enabled then
            if canceled then
                self:on_touch_cancel()
            else
                if touch.action == kFingerDown then
                    -- if self.___type ~= "class(MenuItem)"  then
                    --     M.share_menu_controller():set_menu_visible(false,false)
                    -- end
                    ui_utils.set_focus(self.editbox,true)
                    self:on_touch_down(touch.pos, touch.time)
                elseif touch.action == kFingerMove then
                    self:on_touch_move(touch.pos, touch.time)
                elseif touch.action == kFingerUp then
                    self:on_touch_up(touch.pos, touch.time)
                end
            end

            for _, recog in ipairs(self._recognizers or {}) do
                if canceled then
                    recog:on_cancel()
                else
                    recog:on_touch(touch)
                end
            end
        end
        if not touch.locked_by and self.need_capture then
            touch:lock(self.event_widget)
        end
    end,
    enabled = {function(self)
        return self._enabled
    end, function(self, value)
        if self._enabled ~= value then
            self._enabled = value
            if self.on_enable_changed then
                self:on_enable_changed()
            end
        end
    end},

    add_recognizer = function(self, recog)
        table.insert(self._recognizers, recog)
    end,

}

M.SelectHandler = class('SelectHandler', RoundedView, mixin(M.EditEventHandler, {
    __init__ = function(self, args)
        super(M.SelectHandler, self).__init__(self)
        M.EditEventHandler.__init__(self, args)
        
        self.cursor = 0
        self.radius = 2
        
        self.label = args.label
        self.parent_node = args.parent_node
        self.mode = args.mode
        self.__circle = BorderSprite()
        self.__circle.unit = units.circle
        self.__circle.t_border = {units.circle.size.x/2,units.circle.size.y/2,units.circle.size.x/2,units.circle.size.y/2}
        self.__circle.v_border = {8,8,8,8}
        self.__circle.size = Point(16,16)
        self:add(self.__circle)
        self.line_height = args.line_height or 34
        
        self._after = false
        -- 放大镜
        self.mag = M.Magnifier{}
    end,
    on_touch_down = function(self, p, t)
        -- if self.mode == kSelectBegin then
        -- end
        Simple.share_menu_controller():set_menu_visible(false,false)
        self.mag.center = Window.instance().drawing_root:from_world(p)
        self.mag.attached = true

        self.need_capture = true
        p = self.label:from_world(p)
        self.cursor ,self._after= self.label:get_cursor_by_position(p)
        self.pos = self.label:to_parent(self.label:get_cursor_position(self.cursor,self._after)) 
        
        self.parent_node:_update_selection_view()
    end,
    on_touch_move = function(self, p, t)
        self.mag.center = Window.instance().drawing_root:from_world(p)
        p = self.label:from_world(p)
        if self.mode == kSelectBegin then
            if self.label:get_cursor_by_position(p) < self.parent_node.select_end.cursor then
                self.cursor,self._after = self.label:get_cursor_by_position(p) 
            end
        elseif self.mode == kSelectEnd then
            if self.parent_node.select_begin.cursor == 0 then 
                self.cursor,self._after = self.label:get_cursor_by_position(p)
                if  self._after == self.parent_node.select_begin._after then
                    self._after = true
                end
            else
                if self.label:get_cursor_by_position(p) > self.parent_node.select_begin.cursor then
                    self.cursor,self._after = self.label:get_cursor_by_position(p)
                end
            end
            
        end 
        -- print("self.cursor",self.cursor,self.label.length,p,self._after,self.parent_node.select_end.cursor,self.parent_node.select_begin.cursor)
        
        self.pos = self.label:to_parent(self.label:get_cursor_position(self.cursor,self._after)) 
        self.editbox:_update_by_select_handler(self,p)
        
        
    end,
    on_touch_up = function(self, p, t)
        self.need_capture = false
        self.mag.attached = false
        self.parent_node:_selectitem()
    end,
    on_touch_cancel = function ( )
        self.mag.attached = false
    end,
    cursor_color = {function ( self )
        return self.self_colorf
    end,function ( self,value )
        self.self_colorf = value
        self.__circle.self_colorf = value
    end
    },
    update_cursor = function ( self,cursor,after)
        -- body
        self.cursor = cursor
        self._after = after
        self.pos = self.label:to_parent(self.label:get_cursor_position(self.cursor,self._after)) 
        self:update(false)
        
        self.parent_node:_update_selection_view()
    end,
    line_height = {function ( self )
        return self._line_height
    end,function ( self,v )
        self._line_height = v 
        self.size = Point(2, self._line_height)
        if self.mode == kSelectBegin then
            self.__circle.pos = Point(self.width/2-self.__circle.width/2,-self.__circle.height+2)
            self:set_pick_ext(20,10,8,0)
        elseif self.mode == kSelectEnd then
            self.__circle.pos = Point(self.width/2-self.__circle.width/2,self.height -2)
            self:set_pick_ext(10,20,0,8)
        end
    end

    },
}))
M.Pasteboard = ""


local function insert_table( t,str,cursor,after ,max)
    -- print("insert_table before",table.concat(t),cursor,after,max,#t)
    local i = 1 
    local j = 0 
    if after then
        i = cursor + 2
        for uchar in string.gfind(str, "([%z\1-\127\194-\244][\128-\191]*)") do 
            if max and #t >= max then
                break
            end
            table.insert(t,cursor + 2,uchar)
            j = cursor + 2
            cursor = cursor + 1

        end
    else
        i = cursor + 1
        for uchar in string.gfind(str, "([%z\1-\127\194-\244][\128-\191]*)") do 
            if max and #t >= max then
                break
            end
            table.insert(t,cursor+1,uchar)
            j = cursor + 1
            cursor = cursor + 1
        end
    end
    -- print(t)
    -- print("insert_table after",table.concat(t),max,#t)
    return i,j
end

local function delete_backward_table( t,count,cursor,after  )
    -- print("delete_backward before",table.concat(t),after,cursor)
    if not after then
        local real_count = cursor - count + 1 >= 1 and cursor - count + 1 or 1
        for i=cursor,real_count,-1 do
            table.remove(t,i)
        end
    else
        local real_count = cursor +1 - count + 1 >= 1 and cursor +1 - count + 1 or 1
        for i=cursor+1,real_count,-1 do
            table.remove(t,i)
        end
    end
    -- print("delete_backward before",table.concat(t))
end
local function delete_selection_table( t,b,e )
    -- print("delete_selection before",table.concat(t))
    for i= e + 1,b+1,-1 do
        table.remove(t,i)
    end
    -- print("delete_selection after",table.concat(t))
end

local function set_cursor_pos( view,pos )
    if pos.x < 0 then
        pos.x =0
    end
    
    view.pos = pos
end 
---
-- 可编辑文本基类.
-- @type byui.TextBehaviour

---
-- 可编辑文本基类构造函数.
-- @function [parent=#byui.TextBehaviour] __init__
-- @param #byui.TextBehaviour self 
-- @param #table args 构造列表。
--      label_clip:Widget类型。用来裁剪label的容器
--      cursor_color:Colorf类型。用来表示光标，选择器的颜色。
--      text:默认为{{text  = "",color = Color(0.0,0.0,0.0)}},表示输入文本的富文本属性。
--      hint_text:默认为{{text  = "",color = Color(0.5,0.5,0.5)}},表示提示文本的富文本属性。


M.TextBehaviour = {
    
    __init__ = function ( self,args )
        self.line_height = CLabel.get_default_line_height()
        self.label_clip = args.label_clip
        self._label_container = Widget()
        self.label = Label()
        self.label:set_data({{text = "",color = Color(0.0,0.0,0.0)}})
        -- self.label.background_color = Colorf(1.0,0.0,0.0,1.0)
        self._label_container:add(self.label)
        self.text_color = args.text_color or Colorf(0.0,0.0,0.0)
  
        -- 输入光标
        
        
        self.cursor_view = BorderSprite()
        self.cursor_view.unit = units.circle
        local tsize = units.circle.size
        self.cursor_view.t_border = {tsize.x/2,tsize.y/2,tsize.x/2,tsize.y/2}
        self.cursor_view.v_border = {1,1,1,1}
        self.cursor_view.size = Point(2, self.line_height)
        self.cursor_view.radius = 2
        self.cursor_view.visible = false

        
        self._cursor_twinkling_time = 1.0
        self.cursor = 0
        self._after = false
        self._label_container:add(self.cursor_view)

        -- 放大镜
        self.mag = M.Magnifier{}

        -- 选择游标
        self.select_begin = M.SelectHandler{label=self.label,parent_node= self,mode = kSelectBegin,editbox = self,line_height =self.line_height }
        self.select_end = M.SelectHandler{label=self.label,parent_node= self,mode = kSelectEnd,editbox = self,line_height =self.line_height}

        -- 游标中间区域
        self.selection_view = Widget()
        self.selection_right_view = Widget()
        self.selection_left_view = Widget()
        self.selection_view.visible = false
        self.selection_right_view.visible = false
        self.selection_left_view.visible = false
        self._label_container:add(self.selection_right_view)
        self._label_container:add(self.selection_left_view)
        self._label_container:add(self.selection_view) 

        self._keyboard_enable = false
        self._label_container:add(self.select_begin)
        self._label_container:add(self.select_end)

        self._hint_label = Label()
        self._label_container:add(self._hint_label)

        self.cursor_color = args.cursor_color or  Colorf(0.0,122/255,1.0,1.0)
        
        Clock.instance():schedule_once(function ( ... )
            if self.select_begin then
                self.select_begin.visible = false
            end
            if self.select_end then
                self.select_end.visible = false
            end
        end)

        self._is_mark = false
        local action = function ()
            return anim.keyframes{
                {0.0,  {opacity=1}, anim.ease},
                {0.5, {opacity=0}, anim.ease},
                {1.0,  {opacity=1}, nil}
            }
        end
        self._cursor_anim = anim.Animator(action()
                , function ( value )
                    self.cursor_view.opacity = value.opacity
                end,
                true)
        self._cursor_anim:start()
        local handle = nil
        self._cursor_anim.on_stop = function (  )
            if handle then
                handle:cancel()
            end
            handle = Clock.instance():schedule_once(function ( ... )
                if self.mag then
                    if self.mag.attached == true then
                        self._cursor_anim:start()
                        self._cursor_anim:stop()
                    else
                        self._cursor_anim:start()
                    end
                end
            end,self._cursor_twinkling_time)
        end

        self.keyboard_secure = args.keyboard_secure 
        self.max_length = args.max_length

        self._truly_text = {}

        self.text = args.text or {{text  = "",color = Color(0.0,0.0,0.0)}}
        self.hint_text = args.hint_text or {{text  = "",color = Color(0.5,0.5,0.5)}}
        


        
    end,
    _update_selection_view = function(self)
        local select_begin_pos = self.select_begin.pos
        local select_end_pos = self.select_end.pos
        local select_height = self.select_end.height
        local label_width = self.label.width
        if select_end_pos.x > select_begin_pos.x and select_end_pos.y >= select_begin_pos.y then
            self.selection_view.size = Point(select_end_pos.x - select_begin_pos.x
                    , select_end_pos.y-select_begin_pos.y + select_height)
            self.selection_view.pos = select_begin_pos
            self.selection_right_view.size = Point(label_width - (self.selection_view.x + self.selection_view.width)
                , select_end_pos.y - select_begin_pos.y)
            self.selection_right_view.pos = Point(self.selection_view.x + self.selection_view.width,select_begin_pos.y)
            self.selection_left_view.size = Point(self.selection_view.x, select_end_pos.y - select_begin_pos.y)
            self.selection_left_view.pos = Point(0, select_begin_pos.y + select_height)
        else
            local height = select_end_pos.y-select_begin_pos.y - select_height > 10 and select_end_pos.y-select_begin_pos.y - select_height or 0
            self.selection_view.size = Point(select_begin_pos.x - select_end_pos.x , height)
            self.selection_view.pos = Point(select_end_pos.x, select_begin_pos.y + select_height)
            self.selection_right_view.size = Point(label_width - select_begin_pos.x
                , select_end_pos.y - select_begin_pos.y)
            self.selection_right_view.pos = select_begin_pos
            self.selection_left_view.size = Point(select_end_pos.x
                , select_end_pos.y - select_begin_pos.y )
            self.selection_left_view.pos = Point(0,select_begin_pos.y + select_height)
        end
    end,
    registered_keyboard = function ( self )
        Simple.share_keyboard_controller().keyboard_delegate = self
        Simple.share_keyboard_controller().on_keyboard = 
            function( action, arg)
                -- print_string(string.format("on_keyboard :%s,%s",action, arg))
                self:_keyboard_event(action, arg)
            end
    end,
    _keyboard_event = function ( self, action, arg)
        if action == Application.KeyboardShow then
            self:_on_keyboard_show(arg)
        elseif action == Application.KeyboardHide then
            self._is_mark = false
            self._keyboard_enable = false
            self.mode = "normal"
            self:_on_keyboard_hide(arg)
        elseif action == Application.KeyboardInsert then
            if self.mode == "select" then
                self:delete_selection()
                self.mode = "edit"
            end
            self._cursor_anim:stop()
            Simple.share_menu_controller():set_menu_visible(false,false)

            if string.find(arg, '\n') ~= nil then
                -- self:reset_text()
                self:_on_return_click()
            else
                self:insert(arg)
            end
        elseif action == Application.KeyboardDeleteBackward then
            if self.mode == "select" then
                self:delete_selection()
            else
                self:delete_backward(arg)
            end
        elseif action == Application.KeyboardSetMarkedText then
            if self.mode == "select" then
                self:delete_selection()
            end
            if self.mode ~= "edit" then
                self.mode = "edit"
            end
            self._cursor_anim:stop()
            Simple.share_menu_controller():set_menu_visible(false,false)
            self:set_marked_text(arg)
        end
    end,
    attach_ime = function(self)
        Simple.share_keyboard_controller().keyboard_config = {
            type = self.keyboard_type,
            return_type = self.keyboard_return_type,
            appearance = self.keyboard_appearance,
            secure = self.keyboard_secure and 1 or 0,
            auto_capitalization = self.keyboard_capitalization_type,
        }
        self:registered_keyboard()
        if not self._keyboard_enable then
            self._keyboard_enable = true
            Simple.share_keyboard_controller().keyboard_status = true
        end  
    end,
    detach_ime = function(self)
        -- M.share_keyboard_controller().on_keyboard = nil
        if  self._keyboard_enable then
            self._keyboard_enable = false
            Simple.share_keyboard_controller().keyboard_status = false
        end
        
    end,
    _on_keyboard_show = function ( self,arg )
        ---
        -- 键盘显示的回调.
        -- 这里你可以知道键盘的大小，从而作出响应的调整。
        -- @field [parent=#byui.TextBehaviour] #function on_keyboard_show 
        -- @usage 
        -- text.on_keyboard_show = function (rect)
        --      local real_pos = Window.instance().drawing_root:from_world(Point(rect.x,rect.y))
        --      local x = real_pos.x
        --      local y = real_pos.y
        --      self.keyboard_height  = Window.instance().drawing_root.height - y
        -- end
        if self.on_keyboard_show then
            self.on_keyboard_show(arg)
        end
    end,
    _on_keyboard_hide = function (self, arg )
        ---
        -- 键盘关闭的回调.
        -- 这里你可以恢复你在on_keyboard_show中的行为。
        -- @field [parent=#byui.TextBehaviour] #function on_keyboard_hide 
        -- @usage 
        -- text.on_keyboard_hide = function (rect)
        --         -- do something
        -- end
        if self.on_keyboard_hide then
            self.on_keyboard_hide(arg)
        end
    end,
    insert = function(self, txt)
    ---
    -- 在当前光标处插入文本.
    -- **插入后需要下一帧才能更新好所有状态.**
    -- @function [parent=#byui.TextBehaviour] insert
    -- @param #byui.TextBehaviour self 
    -- @param #string txt 

    ---
    -- 检查插入的文本.
    -- **你可以在键盘的文字写入到输入框前修改将要插入的文本.**
    -- @function [parent=#byui.TextBehaviour] inspection_insert
    -- @param #string txt 当前输入的文本
    -- @return #string 过滤后希望插入到输入框的文本。

        if self.inspection_insert then
            local ret = self.inspection_insert(txt)
            txt = ret and tostring(ret) or txt
        end
        local start = #self._truly_text
        local i,j=insert_table(self._truly_text,txt,self.cursor,self._after,self.max_length)

        if self.keyboard_secure then
            txt = string.rep(self.password_character,#self._truly_text - start) 
        else
            txt = table.concat(self._truly_text,"",i,j)
        end
        self.cursor,self._after = self.label:insert(txt, self.cursor,self._after)

        set_cursor_pos(self.cursor_view,self.label:to_parent(self.label:get_cursor_position(self.cursor,self._after)))
        self:_on_text_changed()
        
    end,
    delete_selection = function ( self ,is_reset)
    ---
    -- 删除选择的文本.
    -- **插入后需要下一帧才能更新好所有状态.**
    -- @function [parent=#byui.TextBehaviour] delete_selection
    -- @param #byui.TextBehaviour self 
        self.cursor = self.select_begin.cursor
        self._after = self.select_begin._after

        delete_selection_table(self._truly_text,self:_cursor_to_index(self.select_begin.cursor,self.select_begin._after),self:_cursor_to_index(self.select_end.cursor,self.select_end._after) -1)
        self.label:delete_selection( self:_cursor_to_index(self.select_begin.cursor,self.select_begin._after), self:_cursor_to_index(self.select_end.cursor,self.select_end._after) -1)
        if not is_reset then
            self.mode = "edit"
        end
        set_cursor_pos(self.cursor_view,self.label:to_parent(self.label:get_cursor_position(self.cursor,self._after)))
        self:_on_text_changed()
        
    end,
    delete_backward = function(self, n)
    ---
    -- 从光标处向前删除指定个数的字符.
    -- **插入后需要下一帧才能更新好所有状态.**
    -- @function [parent=#byui.TextBehaviour] delete_backward
    -- @param #byui.TextBehaviour self 
    -- @param #number count 需要删除的字符数。

        delete_backward_table(self._truly_text,n,self.cursor,self._after)
        self.cursor,self._after = self.label:delete_backward( n, self.cursor,self._after)
        set_cursor_pos(self.cursor_view,self.label:to_parent(self.label:get_cursor_position(self.cursor,self._after)))
        self:_on_text_changed()
        
    end,
    set_marked_text = function(self, t)
        ---
        -- 插入标记的文本.
        -- **插入后需要下一帧才能更新好所有状态.**
        -- @function [parent=#byui.TextBehaviour] set_marked_text
        -- @param #byui.TextBehaviour self 
        -- @param #string txt 插入的文本。
        if t == "" then
            self._is_mark = false
        else
            self._is_mark = true
        end
        self.cursor,self._after = self.label:set_marked_text( t, self.cursor,self._after)
        set_cursor_pos(self.cursor_view,self.label:to_parent(self.label:get_cursor_position(self.cursor,self._after)))
        self:_on_text_changed()
    end,
    mode = {function ( self )
        return self._mode
    end,function ( self,value )
        ---
        -- 可编辑文本的状态.
        -- 三种状态,"normal","edit","select"。**normal**状态并不会关闭键盘，需要自己去关闭键盘。回剥夺输入焦点的控件比如button，ScrollView 也会将键盘关闭。
        -- @field [parent=#byui.TextBehaviour] #string mode 
        -- @usage text.mode = "edit" --进入编辑状态，回显示光标.同时回开启键盘。
        self._mode  = value 
        if self._mode  == "edit" then
            -- edit
            self.cursor_view.visible = true
            self.select_begin.visible = false
            self.select_end.visible = false
            self.selection_view.visible = false
            self.selection_right_view.visible = false
            self.selection_left_view.visible = false
            self:attach_ime()
            self:_on_text_changed()
            -- self.text = (self.label:get_selection(0,self.label.length-1))
        elseif self._mode  == "select" then
            --view
            self.select_begin.visible = true
            self.select_end.visible = true
            self.selection_view.visible = true
            self.selection_right_view.visible = true
            self.selection_left_view.visible = true
            if self.cursor == 0 then
                self.select_begin:update_cursor(0,false)
                self.select_end:update_cursor(0,true)
            else
                if self._after then
                    self.select_begin:update_cursor(self.cursor-1,self.cursor ~= 1)
                    -- self.select_begin:update_cursor(self.cursor-1,false)
                    self.select_end:update_cursor(self.cursor,true)
                else
                    self.select_begin:update_cursor(self.cursor,false)
                    self.select_end:update_cursor(self.cursor,true)
                end
                
            end 
            
            self.cursor_view.visible = false
        else
            self.cursor_view.visible = false
            self.select_begin.visible = false
            self.select_end.visible = false
            self.selection_view.visible = false
            self.selection_right_view.visible = false
            self.selection_left_view.visible = false
            self:_on_text_changed()
        end
    end},
    _selectitem = function ( self )
        local point_parent = Point(0,0)
        local point_begin = self._label_container:to_parent(self.select_begin.pos)
        local point_end = self._label_container:to_parent(self.select_end.pos)
        
        point_begin.x = math.max(point_begin.x,point_parent.x)
        point_end.x = math.min(point_end.x,point_parent.x + self.label_clip.width)
        point_begin.y = math.max(point_begin.y,point_parent.y)
        point_end.y = math.min(point_end.y,point_parent.y + self.label_clip.height)
        local rect  --= nil
        if self.select_begin.y == self.select_end.y then
            rect = Rect(point_begin.x,point_end.y,point_end.x - point_begin.x ,point_begin.y - point_end.y +self.select_begin.height )
        else
            rect = Rect(0,point_begin.y,self.width,point_end.y - point_begin.y +self.select_end.height )
        end 
        if rect.w <= 0 then
            return 
        end
        local str = {kStringCut,kStringCopy,kStringPaste}--,kStringDefine,kStringAdd,kStringShare,kStringIndent}
        local items = {}
        for i,v in ipairs(str) do
            items[i] = {}
            items[i].title  = v
            items[i].action = function ( view )
                if view.title == kStringCut then
                    M.Pasteboard = ""
                    M.Pasteboard = self.label:get_selection(self:_cursor_to_index(self.select_begin.cursor,self.select_begin._after) ,self:_cursor_to_index(self.select_end.cursor,self.select_end._after) -1)
                    self:delete_selection()
                elseif view.title == kStringCopy then
                    M.Pasteboard = ""
                    M.Pasteboard = self.label:get_selection(self:_cursor_to_index(self.select_begin.cursor,self.select_begin._after) ,self:_cursor_to_index(self.select_end.cursor,self.select_end._after) -1)
                elseif view.title == kStringPaste then
                    if self.mode == "select" then
                        self:delete_selection()
                        Clock.instance():schedule_once(function (  )
                            self:insert(M.Pasteboard)
                        end)
                    elseif self.mode == "edit" then
                        self:insert(M.Pasteboard)
                    end
                end
            end
        end
        Simple.share_menu_controller():set_target_rect(rect,self.label_clip)
        Simple.share_menu_controller():set_menu_items(items)
        Simple.share_menu_controller():set_menu_visible(true,true)
    end,
    _cursor_to_index = function ( self,cursor,after )
        return after and cursor+1 or cursor
    end ,
    text = {function ( self )
        if self.keyboard_secure then
            return table.concat(self._truly_text)
        else
            return self.label:get_selection(0,self.label.length-1)
        end
    end,function ( self,value )
        ---
        -- 当前输入的文本.
        -- 只读的.
        -- @field [parent=#byui.TextBehaviour] #string text 
        local temp_lbl = Label()
        if type(value) == "string" then
            self.label:set_rich_text(value)
            temp_lbl:set_rich_text(value)
        elseif type(value) == "table" then
            self.label:set_data(value)
            temp_lbl:set_data(value)
        else 
            error("the args`s type must be string or table")
        end
        temp_lbl:update(false)

        self.line_height = math.floor(temp_lbl.height)
        self.cursor_view.size = Point(2,self.line_height)
        self.select_begin.line_height = self.line_height
        self.select_end.line_height = self.line_height
        
        self._truly_text = {}
        local i,j = insert_table(self._truly_text,temp_lbl:get_data()[1].text,0,false,self.max_length)
        if self.keyboard_secure then
            local str = string.rep(self.password_character,#self._truly_text)
            self.label:set_text(str)
        else
            local str = table.concat(self._truly_text,"",i,j)
            self.label:set_text(str)
        end
        Clock.instance():schedule_once(function()
            self.cursor = self.label.length -1 < 0 and 0 or self.label.length -1
            
            Clock.instance():schedule_once(function()
                -- self.cursor_view.pos = self.label:to_parent(self.label:get_cursor_position(self.cursor,self._after))
                set_cursor_pos(self.cursor_view,self.label:to_parent(self.label:get_cursor_position(self.cursor,self._after)))
                self:_on_text_changed()
            end)
        end)
    end
    },
    hint_text = {function(self)
        return self._hint_text
    end, function(self, v)
        ---
        -- 提示的文本.
        -- @field [parent=#byui.TextBehaviour] #string hint_text
        -- @usage txt.hint_text = "<font color=#777777>search</font>"
        self._hint_text = v
        if type(self._hint_text) == "string" then
            self._hint_label:set_rich_text(self._hint_text)
        elseif type(self._hint_text) == "table" then
            self._hint_label:set_data(self._hint_text)  
        else
            error("the args`s type must be string or table")
        end
    end},   
    keyboard_type = {function ( self )
        return self._keyboard_type or Application.KeyboardTypeDefault
    end,function ( self,v )
        ---
        -- 键盘的类型.
        -- 取值为@{engine#Application.KeyboardTypeDefault},@{engine#Application.KeyboardTypeASCIICapable},@{engine#Application.KeyboardTypeNumbersAndPunctuation},@{engine#Application.KeyboardTypeURL},<br/>
        -- @{engine#Application.KeyboardTypeNumberPad},@{engine#Application.KeyboardTypePhonePad},@{engine#Application.KeyboardTypeNamePhonePad},@{engine#Application.KeyboardTypeEmailAddress},<br/>
        -- @{engine#Application.KeyboardTypeDecimalPad},@{engine#Application.KeyboardTypeTwitter},@{engine#Application.KeyboardTypeWebSearch}。
        -- @field [parent=#byui.TextBehaviour] #number keyboard_type 
        self._keyboard_type = v
    end},
    keyboard_appearance = {function ( self )
        return self._keyboard_appearance or Application.KeyboardAppearanceDefault
    end,function ( self,v )
        ---
        -- 键盘的风格.
        -- 取值为@{engine#Application.KeyboardAppearanceDefault},@{engine#Application.KeyboardAppearanceDark},@{engine#Application.KeyboardAppearanceLight},@{engine#Application.KeyboardAppearanceAlert}。
        -- @field [parent=#byui.TextBehaviour] #number keyboard_appearance
        self._keyboard_appearance = v
    end},
    keyboard_return_type = {function ( self )
        return self._keyboard_return_type or Application.ReturnKeyDefault
    end,function ( self,v )
        ---
        -- 键盘的返回类型.
        -- 取值为@{engine#Application.ReturnKeyDefault},@{engine#Application.ReturnKeyGo},@{engine#Application.ReturnKeyGoogle},@{engine#Application.ReturnKeyJoin},@{engine#Application.ReturnKeyNext},<br/>
        -- @{engine#Application.ReturnKeyRoute},@{engine#Application.ReturnKeySearch},@{engine#Application.ReturnKeySend},@{engine#Application.ReturnKeyYahoo},@{engine#Application.ReturnKeyDone},<br/>
        -- @{engine#Application.ReturnKeyEmergencyCall},@{engine#Application.ReturnKeyContinue}。
        -- @field [parent=#byui.TextBehaviour] #number keyboard_return_type
        self._keyboard_return_type = v
    end},
    keyboard_capitalization_type = {function ( self )
        return self._keyboard_capitalization_type or Application.KeyboardAutocapitalizationTypeNone
    end,function ( self,v )
        ---
        -- 键盘的大写属性.
        -- 取值为@{engine#Application.KeyboardAutocapitalizationTypeNone},@{engine#Application.KeyboardAutocapitalizationTypeWords},@{engine#Application.KeyboardAutocapitalizationTypeSentences},<br/>
        -- @{engine#Application.KeyboardAutocapitalizationTypeAllCharacters}。
        -- @field [parent=#byui.TextBehaviour] #number keyboard_capitalization_type
        self._keyboard_capitalization_type = v
    end},
    keyboard_secure = {function ( self )
        return self._keyboard_secure or false
    end,function ( self,v )
        ---
        -- 是否为密码框.
        -- 为true则为密码框，否则为普通输入框.
        -- @field [parent=#byui.TextBehaviour] #boolean keyboard_secure
        self._keyboard_secure = v
    end},
    on_focus_change = function ( self,value)
        if not value then
            self._keyboard_enable = false
            self:set_marked_text("")
            self.mode = "normal"
        end
    end,
    reset_text = function ( self )
        ---
        -- 重置输入框的输入文字.
        -- 不能直接调用text=“”可能导致很多状态丢失.
        -- @function [parent=#byui.TextBehaviour] reset_text
        -- @param #byui.TextBehaviour self 
        self.select_begin.cursor = 0
        self.select_begin._after = false
        self.select_end.cursor = self.label.length-1
        self.select_end._after = true
        self:delete_selection(true)

        self._truly_text = {}

        if self.mode == "select" then
            self.mode = "edit"
        end
    end,
    _update_cursor_pos = function ( self,p )
        if not self._is_mark then
            self.cursor,self._after = self.label:get_cursor_by_position(p)
            -- self.cursor_view.pos = self.label:to_parent(self.label:get_cursor_position(self.cursor,self._after))
            set_cursor_pos(self.cursor_view,self.label:to_parent(self.label:get_cursor_position(self.cursor,self._after)))
        end
    end,
    _on_return_click = function ( self )
        if self.on_return_click then
            self.on_return_click()
        end
    end,
    cursor_color = {function ( self )
        return self._cursor_color
    end,function ( self,value )
        ---
        -- 光标和选择器的颜色.
        -- @field [parent=#byui.TextBehaviour] engine#Colorf cursor_color 
        self._cursor_color = value
        self.select_begin.cursor_color =  self._cursor_color
        self.select_end.cursor_color =  self._cursor_color
        self.cursor_view.self_colorf = self._cursor_color

        self.__cursor_select_color = Colorf(self._cursor_color.r,self._cursor_color.g,self._cursor_color.b,0.5)
        self.selection_view.background_color = self.__cursor_select_color
        self.selection_right_view.background_color = self.__cursor_select_color
        self.selection_left_view.background_color = self.__cursor_select_color
    end},
    on_touch_down = function(self, p, t)
        self.mag.center = Window.instance().drawing_root:from_world(p)
        local l_p = self.label:from_world(p)
        self:_update_cursor_pos(l_p)
        self._status = 'press'
        if self._mode  == "edit" then
            self._handle = Clock.instance():schedule_once(function()
                if self._status == 'press' then
                    self._press = true
                    self.mag.attached = true
                    self.need_capture = true
                end
            end, 0.15)
            Simple.share_menu_controller():set_menu_visible(false,false)
        elseif self._mode  == "select" then
            self._handle = Clock.instance():schedule_once(function()
                if self._status == 'press' then
                    self.mag.attached = true
                    self._press = true
                    self.mode = "edit"
                end
                Simple.share_menu_controller():set_menu_visible(false,false) 
            end, 1) 
        else
            self._handle = Clock.instance():schedule_once(function()
                if self._status == 'press' then
                    self._press = true
                    self.mode = "edit"
                end
            end, 0.15)
            Simple.share_menu_controller():set_menu_visible(false,false)
        end 
    end,
    on_touch_move = function ( self, p, t )
        -- body
    end,
    on_touch_up = function(self, p, t)
        self._status = 'normal'
        self._handle:cancel()
        if self._mode  == "edit" then
            if self.mag.attached == true then
                self.mag.attached = false
                local str 
                if self.text == "" then
                    str = {kStringPaste}
                else
                    str = {kStringSelect,kStringSelectAll,kStringPaste}
                end
                local rect = Rect(0,0,self.cursor_view.width,self.cursor_view.height)
                local items = {}
                for i,v in ipairs(str) do
                    items[i] = {}
                    items[i].title = v 
                    items[i].action = function ( view )
                            if view.title == kStringSelect then
                                self.mode = "select"
                            elseif view.title == kStringSelectAll then
                                self.mode = "select"
                                self.select_begin:update_cursor(0,false)
                                self.select_end:update_cursor(self.label.length-1,true)
                                self:_selectitem()
                            elseif view.title == kStringPaste then
                                self:insert(M.Pasteboard)
                            end
                        end
                end
                Simple.share_menu_controller():set_target_rect(rect,self.cursor_view)
                Simple.share_menu_controller():set_menu_items(items)
                Simple.share_menu_controller():set_menu_visible(true,true)
            end
        elseif self._mode  == "select" then
            --view
            if self.selection_view:point_in(p) or 
                self.selection_left_view:point_in(p) or 
                self.selection_right_view:point_in(p) then
                    -- print(" M.share_menu_controller().visible", M.share_menu_controller()._menu_visible)
                    if Simple.share_menu_controller()._menu_visible then
                        Simple.share_menu_controller():set_menu_visible(false,false)
                        self.mode = "edit"
                    else
                        self:_selectitem()
                    end
            else
                Simple.share_menu_controller():set_menu_visible(false,false) 
                self.mode = "edit"
            end
        else
            if self._press == true  or self:point_in(p) then
                self.mode = "edit"
            end
        end  
        self._press = false  
        self.need_capture = false  
    end,
    on_touch_cancel = function ( self )
        self.need_capture = false
        self._press = false
        self.mag.attached = false
        if self._handle then
            self._handle:cancel()
        end
    end,
    ---
    -- 密码框显示的字符.
    -- 默认显示的字符为"•"，你可以修改一个任意字符来替代密码显示.
    -- @field [parent=#byui.TextBehaviour] #string password_character
    
    password_character = {function ( self )
        return self._password_character or "•"
    end,function ( self,value )
        if value and value ~= "" then
            self._password_character = tostring(value)
        end
    end},
    ---
    -- 输入的最大字符最大长度.
    -- 如果为nil则不会限制输入的长度，中文字符和数字字母一样也只算一个字符.
    -- @field [parent=#byui.TextBehaviour] #number max_length

    max_length = {function ( self )
        return self._max_length
    end,function ( self,value )
        if tonumber(value) then
            self._max_length = tonumber(value)
        else
            self._max_length = nil
        end
    end},
    ---
    -- 光标显示的宽度.
    -- 通过此属性你可以设置不同宽度的光标，建议不要太大，否则会盖住文字，默认为2。
    -- @field [parent=#byui.TextBehaviour] #number cursor_width

    cursor_width = {function ( self )
        return self.cursor_view.width
    end,function ( self,value )
        self.cursor_view.width = value
        self.cursor_view.v_border = {value/2,value/2,value/2,value/2}
    end},
    ---
    -- 光标两次闪烁的时间间隔.
    -- 通过此属性你可以设置设置光标闪烁的时间间隔，默认为1s。
    -- @field [parent=#byui.TextBehaviour] #number cursor_twinkling_time

    cursor_twinkling_time = {function ( self )
        return self._cursor_twinkling_time
    end,function ( self,value )
        self._cursor_twinkling_time = value
    end},
    on_exit = function ( self )
        if self:equal(Simple.share_keyboard_controller().keyboard_delegate) then
            Simple.share_keyboard_controller().keyboard_delegate = nil
            Simple.share_keyboard_controller().on_keyboard = nil
        end
        if self:equal(ui_utils.get_focus()) then
            ui_utils.remove_focus()
        end
        self._cursor_anim:stop()
    end
}

---
-- 单行文本输入框.
-- 同时继承了@{byui.edit#byui.TextBehaviour}.
-- @type byui.EditBox
-- @extends engine#Widget 

---
-- 创建单行文本框.
-- @callof #byui.EditBox
-- @param #byui.EditBox self 
-- @param #table args 参数列表.
--        radius:number类型，圆角半径。
--        background_style:背景的样式。可选值KTextBorderStyleRoundedRect ，KTextBorderStyleBezel ，KTextBorderStyleLine ，KTextBorderStyleWhite ,KTextBorderStyleNone 。
--        icon_style :icon的样式，可选KTextIconNone，KTextIconDelete,KTextIconMagnifier。

M.EditBox = class('EditBox',Widget,mixin(M.EditEventHandler,M.TextBehaviour,{
    __init__ = function ( self,args )
        super(M.EditBox, self).__init__(self,args)

        self._background = BorderSprite()
        self:add(self._background)
        self._radius = args.radius or 10
        self._background.t_border = {10,10,10,10}
        self._background.v_border = {self._radius,self._radius,self._radius,self._radius}
        if not args.margin then
            args.margin = {0,0,0,0}
        end
        self.margin = args.margin


        
        -- self.clip = true
        self._scroll_view = Scroll.ScrollView{ dimension = kHorizental,}
        self._scroll_view.pos = Point(self.margin[1],self.margin[2])
        self._scroll_view.enabled = false
        self:add(self._scroll_view)
        args.label_clip = self._scroll_view
        M.EditEventHandler.__init__(self,args )
        M.TextBehaviour.__init__(self,args )
        self._scroll_view.content = self._label_container
        self._label_container.relative = true


        
        self._press = false


        self._icon = BorderSprite()
        self._icon.need_capture = true
        Simple.init_simple_event(self._icon,function ()
            self:_icon_click()
        end) 
        -- self._icon.visible = false
        self:add(self._icon)

        
        self.background_style = args.background_style or KTextBorderStyleNone
        self.icon_style = args.icon_style or KTextIconNone

        self.on_size_changed = function ( _ )
            -- self.cursor_view.pos = self.label:to_parent(self.label:get_cursor_position(self.cursor,self._after))
            set_cursor_pos(self.cursor_view,self.label:to_parent(self.label:get_cursor_position(self.cursor,self._after)))
            self:_refresh()
        end
    end,
    _refresh = function ( self )
        self._background.size = self.size
        if self._icon then
            self._icon.y = (self.height - self._icon.height)/2
            self._icon.x = self.width - self.height + (self.height - self._icon.width)/2
            self._scroll_view.size = Point(self.width -self.height,self.height - (self.margin[2] + self.margin[4]))
            self._icon:set_pick_ext(self._icon.y, self._icon.y, self._icon.y, self._icon.y)
        else
            self._scroll_view.size = Point(self.width - (self.margin[1] + self.margin[3]) ,self.height - (self.margin[2] + self.margin[4]) )
        end
        self._label_container.size = self._scroll_view.size
        if self.label.content_bbox.w > self._scroll_view.width then
            -- self._label_container.x = self._label_clip.width - self.label.content_bbox.w 
            self._scroll_view:scroll_to_right(0.25)
        else
            -- self._label_container.x = 0
            self._scroll_view:scroll_to_left(0.25)
        end 
    end,
    _icon_click = function ( self )
        if self.icon_style == KTextIconDelete then
            self:reset_text()
        end
        --- 
        -- icon点击回调事件.
        -- @field [parent=#byui.EditBox] #function icon_click 
        -- @usage txt.icon_click = function()
        --      -- do something
        -- end
        if self.icon_click then
            self.icon_click()
        end
    end,
    on_touch_move = function(self, p, t)
        self.mag.center = Window.instance().drawing_root:from_world(p)

        p = self.label:from_world(p)
        self:_update_cursor_pos(p) 
        if self.cursor_view.x + self._label_container.x < 0 then
            -- self._label_container.x = -self.cursor_view.x
            self._scroll_view:scroll_to(Point(-self.cursor_view.x,0),0.0)
        elseif self.cursor_view.x + self._label_container.x > self._scroll_view.width  then
            -- self._label_container.x = self._scroll_view.width  -self.cursor_view.x
            self._scroll_view:scroll_to(Point(self._scroll_view.width  -self.cursor_view.x,0),0.0)
        end
        self._cursor_anim:stop()
    end,
    ---
    -- 背景的样式.
    -- 可取@{byui.utils#KTextBorderStyleRoundedRect},@{byui.utils#KTextBorderStyleBezel },@{byui.utils#KTextBorderStyleLine },@{byui.utils#KTextBorderStyleWhite },@{byui.utils#KTextBorderStyleNone }。
    -- @field [parent=#byui.EditBox] #number background_style 
    background_style = {function ( self )
        return self._background_style
    end,function ( self,value )
        self._background.visible = true
        if value == KTextBorderStyleRoundedRect then
            self._background_style = KTextBorderStyleRoundedRect
            self._background.unit = units.editbox_style_rounded_rect
        elseif value == KTextBorderStyleBezel then
            self._background_style = KTextBorderStyleBezel
            self._background.unit = units.editbox_style_bezel
        elseif value == KTextBorderStyleLine then
            self._background_style = KTextBorderStyleLine
            self._background.unit = units.editbox_style_line
        elseif value == KTextBorderStyleWhite then
            self._background_style = KTextBorderStyleWhite
            self._background.unit = units.editbox_style_none
        else
            self._background_style = KTextBorderStyleNone
            self._background.visible = false
        end

    end},
    ---
    -- icon的样式.
    -- 可取@{byui.utils#KTextIconNone},@{byui.utils#KTextIconDelete },@{byui.utils#KTextIconMagnifier }。
    -- @field [parent=#byui.EditBox] #number icon_style
    icon_style = {function ( self )
        return self._icon_style or KTextIconNone
    end,function ( self,value )
        if value == KTextIconDelete then
            self._icon_style = KTextIconDelete
            self:_create_icon()
            self._icon.unit = units.del_icon_1
            self._icon.size = units.del_icon_1.size
        elseif value == KTextIconMagnifier then
            self._icon_style = KTextIconMagnifier
            self:_create_icon()
            self._icon.unit = units.small_magnifier
            self._icon.size = units.small_magnifier.size
        else
            self._icon_style = KTextIconNone
            if self._icon then
                self._icon:remove_from_parent()
                self._icon = nil 
            end
        end
        self:_refresh()
    end},
    _create_icon = function ( self )
        if not self._icon then
            self._icon = BorderSprite()
            Simple.init_simple_event(self._icon,function ()
                self:_icon_click()
            end) 
            self:add(self._icon)
        end 
    end,
    _on_text_changed = function ( self )
        local text_temp = self.label:get_selection(0,self.label.length-1)
        if text_temp == "" then
            if self._icon and self.icon_style == KTextIconDelete then
                self._icon.visible = false
            end
            self._hint_label.visible = true
        else
            if self._icon and self.icon_style == KTextIconDelete then
                self._icon.visible = true
            end
            self._hint_label.visible = false
        end
        local cursor_pos  = self.cursor_view.pos + self._scroll_view.content.pos--self._scroll_view:from_world(self.cursor_view:to_world(Point(0,0)))
        local offset = 10
        self._scroll_view:update()
        if cursor_pos.x < offset then
            self._scroll_view:scroll_to(Point(-self.cursor_view.x,0),0)
        elseif cursor_pos.x + self.cursor_view.width +offset > self._scroll_view.width then
            self._scroll_view:scroll_to(Point(-self.cursor_view.x + self._scroll_view.width ,0),0)
        end
        --- 
        -- 输入文字发生改变.
        -- @field [parent=#byui.EditBox] #function on_text_changed 
        -- @usage txt.on_text_changed = function(str)
        --      print(str)
        -- end
        if self.on_text_changed then
            self.on_text_changed(text_temp)
        end
    end,
    _update_by_select_handler = function ( self,select_handler,point )
        -- self._label_container.x = 0
        local local_pos = self._scroll_view:from_world(self.label:to_world(point))
        if local_pos.x < 0 then
            if (self._scroll_view._content.x) < 0 then
                self._scroll_view._content.x  = self._scroll_view._content.x + 10 < 0 and self._scroll_view._content.x + 10 or 0
            end
        elseif local_pos.x > self._scroll_view.width then
            if (self._scroll_view._content.x ) > self._scroll_view.kinetic.x.min then
                self._scroll_view._content.x  = self._scroll_view._content.x - 10 > self._scroll_view.kinetic.x.min and self._scroll_view._content.x - 10 or self._scroll_view.kinetic.x.min
            end
        end
        self:_update_selection_view()
    end,
    }),true)

---
-- 多行文本输入框.
-- 同时继承了@{byui.edit#byui.TextBehaviour}.
-- @type byui.MultilineEditBox
-- @extends engine#Widget 

---
-- 创建一个多行文本.
-- @callof #byui.MultilineEditBox
-- @param #byui.MultilineEditBox self 
-- @param #table args 参数列表。
--      style : MultilineEditBox的样式。可选值KTextBorderStyleRoundedRect ，KTextBorderStyleBezel ，KTextBorderStyleLine ，KTextBorderStyleWhite ,KTextBorderStyleNone 。
--      radius : 背景框的圆角半径。
--      expect_height :输入框的默认高度。如果没有则大小跟随文本的大小变化而变化。

M.MultilineEditBox = class('MultilineEditBox',Widget,mixin(M.EditEventHandler,M.TextBehaviour,{
    __init__ = function ( self, args )
        super(M.MultilineEditBox, self).__init__(self,args)
        M.EditEventHandler.__init__(self,args )
        self._background = BorderSprite()
        self.style = args.style or KTextBorderStyleRoundedRect
        self._background.size = self._background.unit.size
        self._radius = args.radius or 10

        if not args.margin then
            args.margin = {0,0,0,0}
        end
        self.margin = args.margin

        self._background.t_border = {self._radius,self._radius,self._radius,self._radius}
        self._background.v_border = {self._radius,self._radius,self._radius,self._radius}
        self:add(self._background)

        self._scroll_view = Scroll.ScrollView{ dimension = kVertical,}
        -- self._scroll_view.shows_vertical_scroll_indicator = true
        
        self._scroll_view.pos = Point(self.margin[1],self.margin[2])
        self:add(self._scroll_view)

        args.label_clip = self._scroll_view
        M.TextBehaviour.__init__(self,args )
        self._scroll_view.content = self._label_container
        self._label_container.relative = true
        self._label_change = false
        
        self.on_size_changed = function (  )
            self._background.size = self.size
            self._scroll_view.size = self.size - Point(self.margin[1]+self.margin[3],self.margin[2]+self.margin[4])
            self._label_container.size = self._scroll_view.size 

            if self._scroll_view._vertical_scroll_indicator then
                self._scroll_view._vertical_scroll_indicator.offset = -5
            end

            -- if not self._label_change then
                self.label.layout_size = self._scroll_view.size -- Point(self._radius,0)
                self.label:update(false)
            -- <end></end>
            -- if self.label.height  < self._scroll_view.height then
            --     self.label.height = self._scroll_view.height
            -- end
            -- self.cursor_view.pos = self.label:to_parent(self.label:get_cursor_position(self.cursor,self._after))
            set_cursor_pos(self.cursor_view,self.label:to_parent(self.label:get_cursor_position(self.cursor,self._after)))
            --- 
            -- 文本框的内容大小发生改变.
            -- @field [parent=#byui.MultilineEditBox] #function on_content_size_change 
            -- @usage txt.on_content_size_change = function()
            --      print(“on_content_size_change”)
            -- end 
            if self.on_content_size_change then
                self.on_content_size_change()
            end
        end
        self.expect_height = args.expect_height
        if self.expect_height then
            self.height_hint = self.expect_height
        end
    end,
    ---
    -- 文本框的最大高度.
    -- 文本框大小没有达到最大高度时会跟随文本大小一直变化，直到高度达到最大高度后便不在发生变化.
    -- @field [parent=#byui.MultilineEditBox] #number max_height 
    max_height = {function ( self )
        return self._max_height or self.height
    end,function ( self,v )
        self._max_height = v 
        if self.height > self._max_height then
            self.height_hint = self._max_height
        end
    end},
    on_touch_down = function ( self, p, t)
        M.TextBehaviour.on_touch_down(self, p, t)
        self._scroll_view.shows_vertical_scroll_indicator = true
    end,
    on_touch_move = function(self, p, t)
        -- self.mag.center = p 
        self.mag.center = Window.instance().drawing_root:from_world(p)
        p = self.label:from_world(p)
        self:_update_cursor_pos(p)
        if self.cursor_view.y + self._label_container.y < 0 then
            self._scroll_view:scroll_to(Point(0.0,-(self.cursor_view.y)),0.01) 
        elseif self.cursor_view.y + self._label_container.y +self.cursor_view.height > self.height  then
            self._scroll_view:scroll_to(Point(0.0,-(self.cursor_view.y + self.cursor_view.height)),0.01) 
        end
        self._cursor_anim:stop()
    end,
    _on_text_changed = function ( self )
        local text_temp = self.label:get_selection(0,self.label.length-1)
        -- self.label:update(false)
        if text_temp == "" then
            self._hint_label.visible = true
        else
            self._hint_label.visible = false
        end
        self._scroll_view.shows_vertical_scroll_indicator = false
        self._scroll_view:update()
        
        self._label_change = true
        self._label_container.x = 0
        if self.label.height > self.max_height - (self.margin[2] + self.margin[4])  then
            self.height_hint = self.max_height
            self._scroll_view.enabled = true
            -- self._scroll_view:scroll_to_bottom(0.0)
            self:update_constraints()
        elseif self.label.height - self._scroll_view.height > 10 then
            self.height_hint =  self.label.height +  (self.margin[2] + self.margin[4]) 
            -- self._scroll_view:scroll_to_bottom(0.0)
            self._scroll_view.enabled = false
            self:update_constraints()
        elseif self.label.height - self._scroll_view.height < -10 then
            if self.expect_height then
                if self.label.height < self.expect_height then
                    self.height_hint = self.expect_height
                else
                    self.height_hint = self.label.height + (self.margin[2] + self.margin[4]) 
                end
            else
                self.height_hint =  self.label.height > 0 and self.label.height + (self.margin[2] + self.margin[4])  or self.line_height + (self.margin[2] + self.margin[4]) 
            end
            
            self._scroll_view.enabled = false
            self:update_constraints()
        end
        local _scroll_view_height
        if self.height_hint then
            _scroll_view_height = self.height_hint - (self.margin[2] + self.margin[4]) 
        else
            _scroll_view_height = self.height - (self.margin[2] + self.margin[4]) 
        end
        self._scroll_view:update(false)
        if self.label.height > _scroll_view_height then
            if self.cursor_view.y + self.cursor_view.height + self._label_container.y > _scroll_view_height then
                self._scroll_view:scroll_to(Point(0,-(self.cursor_view.y + self.cursor_view.height - (_scroll_view_height))),0.1)
            elseif self.cursor_view.y + self._label_container.y < 0 then
                self._scroll_view:scroll_to(Point(0,-(self.cursor_view.y)),0.1) 
            end
        else
            self._scroll_view:scroll_to_top(0.0)
        end
        --- 
        -- 输入文字发生改变.
        -- @field [parent=#byui.MultilineEditBox] #function on_text_changed 
        -- @usage txt.on_text_changed = function(str)
        --      print(str)
        -- end 
        if self.on_text_changed then
            self.on_text_changed(text_temp)
        end
        
    end,
    ---
    -- 文本框的背景样式.
    -- 可取@{byui.utils#KTextBorderStyleRoundedRect},@{byui.utils#KTextBorderStyleBezel },@{byui.utils#KTextBorderStyleLine },@{byui.utils#KTextBorderStyleWhite },@{byui.utils#KTextBorderStyleNone }。
    -- @field [parent=#byui.MultilineEditBox] #number style 
    style = {function ( self )
        return self._style
    end,function ( self,value )
        self._background.visible = true
        if value == KTextBorderStyleRoundedRect then
            self._style = KTextBorderStyleRoundedRect
            self._background.unit = units.editbox_style_rounded_rect
        elseif value == KTextBorderStyleBezel then
            self._style = KTextBorderStyleBezel
            self._background.unit = units.editbox_style_bezel
        elseif value == KTextBorderStyleLine then
            self._style = KTextBorderStyleLine
            self._background.unit = units.editbox_style_line
        else
            self._style = KTextBorderStyleNone
            self._background.unit = units.editbox_style_none
            self._background.visible = false
        end

    end},
    _update_by_select_handler = function ( self,select_handler,point )
        self._label_container.x = 0
        local local_pos = self:from_world(self.label:to_world(point))
        -- self._scroll_view.shows_vertical_scroll_indicator = true
        if local_pos.y < 0 then
            if (self._scroll_view._content.y ) < 0 then
                self._scroll_view._content.y  = self._scroll_view._content.y + 10 < 0 and self._scroll_view._content.y + 10 or 0
                -- self._scroll_view:scroll_to(Point(0,self._scroll_view._content.y + 10 < 0 and self._scroll_view._content.y + 10 or 0),0.0)
            end
        elseif local_pos.y > self.height then
            if (self._scroll_view._content.y) > self._scroll_view.height - self.label.height then
                self._scroll_view._content.y  = self._scroll_view._content.y - 10 > self._scroll_view.height - self.label.height and self._scroll_view._content.y - 10 or self._scroll_view.height - self.label.height 
                -- self._scroll_view:scroll_to(Point(0,self._scroll_view._content.y - 10 > self._scroll_view.height - self.label.height and self._scroll_view._content.y - 10 or self._scroll_view.height - self.label.height),0.0)
            end
        end
        self:_update_selection_view()
    end,
    }))

---
-- 搜索框.
-- @type byui.SearchView

---
-- 创建SearchView
-- @callof #byui.SearchView.
-- @param #byui.SearchView self 
-- @param #table args 参数列表.
--          margin:外边框的边界。
--          tint_color :光标和取消按钮的颜色。
--          cancel_title :取消按钮的title。
--          radius: 搜索框的圆角半径。
-- @return #byui.SearchView 返回创建的SearchView

M.SearchView = class('SearchView', Widget, {
    __init__ = function ( self,args )
        super(M.SearchView, self).__init__(self,args)

        local  radius = args.radius
        args.radius = 0
        args.background_style = KTextBorderStyleNone
        self.editbox = M.EditBox(args)
        
        self.default_line_height = self.editbox.line_height or CLabel.get_default_line_height()
        self.radius = radius or self.default_line_height/2


        self.margin = args.margin or {10,10,10,10}
        -- self.height_hint = self.default_line_height + 4
        self._search_field = BorderSprite()
        self._search_field.unit = units.circle
        self._search_field.t_border = ui_utils.default_t_border(units.circle)
        self._search_field.v_border = {self.radius,self.radius,self.radius,self.radius}
        self:add(self._search_field)
        self._search_field:add(self.editbox)

        self.left_icon = BorderSprite()
        self.left_icon.unit = units.small_magnifier
        self.left_icon.size = self.left_icon.unit.size
        self._search_field:add(self.left_icon)

        self.right_icon = BorderSprite()
        self.right_icon.unit = units.del_icon_1
        self.right_icon.size = self.right_icon.unit.size
        self._search_field:add(self.right_icon)
        Simple.init_simple_event(self.right_icon,function (  )
            self.editbox:reset_text()
            if self.on_delete then
                self.on_delete()
            end
        end)

        self._delete_icon = BorderSprite()
        self._delete_icon.unit = units.del_icon_1
        self._delete_icon.size = self._delete_icon.unit.size
        self._delete_icon.visible = false
        self._search_field:add(self._delete_icon)
        Simple.init_simple_event(self._delete_icon,function (  )
            self.editbox:reset_text()
            ---
            -- 删除按钮响应事件.
            -- @field [parent=#byui.SearchView] #function on_delete 
            -- @usage search.on_delete = function()
            --      print("click delete button")
            -- end
            if self.on_delete then
                self.on_delete()
            end
        end)

        self._cancel_button = Label()
        self.tint_color = args.tint_color or Colorf(0.0,122/255,1.0,1.0)
        self.cancel_title = args.cancel_title or "Cancel"
        self:add(self._cancel_button)
        Simple.init_simple_event(self._cancel_button,function (  )
            self.editbox:detach_ime()
            ---
            -- 取消按钮响应事件.
            -- @field [parent=#byui.SearchView] #function on_cancel 
            -- @usage search.on_cancel = function()
            --      print("click cancel button")
            -- end
            if self.on_cancel then
                self.on_cancel()
            end
        end)
        -- self.clip = true
        self.editbox.on_text_changed = function ( text )
            if text == "" then
                self._delete_icon.visible = false
                self.right_icon.visible = true
            else
                self._delete_icon.visible = true
                self.right_icon.visible = false
            end
            ---
            -- 输入文字变化响应回调.
            -- @field [parent=#byui.SearchView] #function on_text_changed 
            -- @usage search.on_delete = function()
            --      print("click delete button")
            -- end
            if self.on_text_changed then
                self.on_text_changed(text)
            end
        end
        self.on_size_changed = function (  )
            self:_refresh()
        end
    end,
    _refresh = function ( self )
        if self._cancel_button.visible then
            self._search_field.size = Point(self.width - self._cancel_button.width - 1.5*self.margin[1] - 1.5*self.margin[3],self.height-self.margin[2]-self.margin[4])
            self._search_field.pos = Point(self.margin[1],self.margin[2])
            self._cancel_button.pos = Point(self.width - self.margin[3] - self._cancel_button.width,(self.height - self._cancel_button.height)/2)
        else
            self._search_field.size = Point(self.width - self.margin[1] - self.margin[3],self.height-self.margin[2]-self.margin[4])
            self._search_field.pos = Point(self.margin[1],self.margin[2])
        end

        if self.left_icon.unit then
            self.left_icon.y =  (self._search_field.height - self.left_icon.height)/2 
            self.left_icon.x =  (self.default_line_height - self.left_icon.width)/2 
            self.right_icon.y =  (self._search_field.height - self.right_icon.height)/2 
            self.right_icon.x =  self._search_field.width - self.default_line_height+ (self.default_line_height - self.right_icon.width)/2 
            self.editbox.size = Point(self._search_field.width - 2*self.default_line_height,self.default_line_height)
            self.editbox.pos = Point((self._search_field.width -self.editbox.width)/2 ,(self._search_field.height -self.editbox.height)/2)
        else
            self.right_icon.y =  (self._search_field.height - self.right_icon.height)/2 
            self.right_icon.x =  self._search_field.width -self.default_line_height+ (self.default_line_height - self.right_icon.width)/2
            self.editbox.size = Point(self._search_field.width - self.default_line_height - self.radius,self.default_line_height)
            self.editbox.pos = Point(self.radius ,(self._search_field.height -self.editbox.height)/2)
        end
        self._delete_icon.pos = Point(self._search_field.width -self.default_line_height+ (self.default_line_height - self._delete_icon.width)/2,(self._search_field.height - self._delete_icon.height)/2 ) 
    end,
    --- 
    -- 左边icon的纹理.
    -- 默认为放大镜。
    -- @field [parent=#byui.SearchView] #TextureUnit left_icon_units 
    left_icon_units = {function ( self )
        return self.left_icon.visible and self.left_icon.unit or nil
    end,function ( self,desc )
        if not desc then
            self.left_icon.unit = nil
            self.left_icon.size = Point(0,0)
        elseif desc.class == TextureUnit then
            self.left_icon.unit = desc
            self.left_icon.t_border = ui_utils.default_t_border(desc)
            self.left_icon.self_colorf = Colorf.white
            self.left_icon.size = desc.size
        else
            error('invalid texture description')
        end
        self:_refresh()
    end},
    --- 
    -- 右边icon的纹理.
    -- @field [parent=#byui.SearchView] #TextureUnit right_icon_units 
    right_icon_units = {function ( self )
        return self.right_icon.visible and self.right_icon.unit or nil
    end,function ( self,desc )
        if not desc then
            self.right_icon.unit = nil
            self.right_icon.size = Point(0,0)
        elseif desc.class == TextureUnit then
            self.right_icon.unit = desc
            self.right_icon.t_border = ui_utils.default_t_border(desc)
            self.right_icon.color = Colorf.white
            self.right_icon.size = desc.size
        else
            error('invalid texture description')
        end
        self:_refresh()
    end},
    ---
    -- 光标和取消按钮的颜色.
    -- @field [parent=#byui.SearchView] engine#Colorf tint_color 
    tint_color = {function ( self )
        return self._tint_color 
    end,function ( self,value )
        self._tint_color = value
        self.editbox.cursor_color = value
        self._cancel_button:set_data{{text = self.cancel_title,color = colorf_to_color(self.tint_color),size = 32}}
    end},
    ---
    -- 取消按钮的title.
    -- 默认为"Cancel"。
    -- @field [parent=#byui.SearchView] #string cancel_title 
    cancel_title = {function ( self )
        return self._cancel_title or "Cancel"
    end,function ( self,value )
        if type(value) == "string" then
            self._cancel_title = value
            self._cancel_button:set_data{{text = self._cancel_title,color = colorf_to_color(self.tint_color),size = 32}}
            self._cancel_button:update(false)
            self:_refresh()
        else
            error('the cancel title is invalid')
        end
    end},
    ---
    -- 是否显示取消按钮.
    -- 默认为true。即显示取消按钮。
    -- @field [parent=#byui.SearchView] #boolean shows_cancel_button description
    shows_cancel_button = {function ( self )
        return self._cancel_button.visible
    end,function ( self,value )
        if value ~= self._cancel_button.visible then
            self._cancel_button.visible = value
            self:_refresh()
        end
    end},
},true)

return M

end
        

package.preload[ "byui.edit" ] = function( ... )
    return require('byui/edit')
end
            

package.preload[ "byui/inspect" ] = function( ... )
local inspect ={
  _VERSION = 'inspect.lua 3.0.2',
  _URL     = 'http://github.com/kikito/inspect.lua',
  _DESCRIPTION = 'human-readable representations of tables',
  _LICENSE = [[
    MIT LICENSE

    Copyright (c) 2013 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

inspect.KEY       = setmetatable({}, {__tostring = function() return 'inspect.KEY' end})
inspect.METATABLE = setmetatable({}, {__tostring = function() return 'inspect.METATABLE' end})

-- returns the length of a table, ignoring __len (if it exists)
local rawlen = _G.rawlen or function(t) return #t end

-- Apostrophizes the string if it has quotes, but not aphostrophes
-- Otherwise, it returns a regular quoted string
local function smartQuote(str)
  if str:match('"') and not str:match("'") then
    return "'" .. str .. "'"
  end
  return '"' .. str:gsub('"', '\\"') .. '"'
end

local controlCharsTranslation = {
  ["\a"] = "\\a",  ["\b"] = "\\b", ["\f"] = "\\f",  ["\n"] = "\\n",
  ["\r"] = "\\r",  ["\t"] = "\\t", ["\v"] = "\\v"
}

local function escape(str)
  local result = str:gsub("\\", "\\\\"):gsub("(%c)", controlCharsTranslation)
  return result
end

local function isIdentifier(str)
  return type(str) == 'string' and str:match( "^[_%a][_%a%d]*$" )
end

local function isSequenceKey(k, length)
  return type(k) == 'number'
     and 1 <= k
     and k <= length
     and math.floor(k) == k
end

local defaultTypeOrders = {
  ['number']   = 1, ['boolean']  = 2, ['string'] = 3, ['table'] = 4,
  ['function'] = 5, ['userdata'] = 6, ['thread'] = 7
}

local function sortKeys(a, b)
  local ta, tb = type(a), type(b)

  -- strings and numbers are sorted numerically/alphabetically
  if ta == tb and (ta == 'string' or ta == 'number') then return a < b end

  local dta, dtb = defaultTypeOrders[ta], defaultTypeOrders[tb]
  -- Two default types are compared according to the defaultTypeOrders table
  if dta and dtb then return defaultTypeOrders[ta] < defaultTypeOrders[tb]
  elseif dta     then return true  -- default types before custom ones
  elseif dtb     then return false -- custom types after default ones
  end

  -- custom types are sorted out alphabetically
  return ta < tb
end

local function getNonSequentialKeys(t)
  local keys, length = {}, rawlen(t)
  for k,_ in pairs(t) do
    if not isSequenceKey(k, length) then table.insert(keys, k) end
  end
  table.sort(keys, sortKeys)
  return keys
end

local function getToStringResultSafely(t, mt)
  local __tostring = type(mt) == 'table' and rawget(mt, '__tostring')
  local str, ok
  if type(__tostring) == 'function' then
    ok, str = pcall(__tostring, t)
    str = ok and str or 'error: ' .. tostring(str)
  end
  if type(str) == 'string' and #str > 0 then return str end
end

local maxIdsMetaTable = {
  __index = function(self, typeName)
    rawset(self, typeName, 0)
    return 0
  end
}

local idsMetaTable = {
  __index = function (self, typeName)
    local col = {}
    rawset(self, typeName, col)
    return col
  end
}

local function countTableAppearances(t, tableAppearances)
  tableAppearances = tableAppearances or {}

  if type(t) == 'table' then
    if not tableAppearances[t] then
      tableAppearances[t] = 1
      for k,v in pairs(t) do
        countTableAppearances(k, tableAppearances)
        countTableAppearances(v, tableAppearances)
      end
      countTableAppearances(getmetatable(t), tableAppearances)
    else
      tableAppearances[t] = tableAppearances[t] + 1
    end
  end

  return tableAppearances
end

local copySequence = function(s)
  local copy, len = {}, #s
  for i=1, len do copy[i] = s[i] end
  return copy, len
end

local function makePath(path, ...)
  local keys = {...}
  local newPath, len = copySequence(path)
  for i=1, #keys do
    newPath[len + i] = keys[i]
  end
  return newPath
end

local function processRecursive(process, item, path)
  if item == nil then return nil end

  local processed = process(item, path)
  if type(processed) == 'table' then
    local processedCopy = {}
    local processedKey

    for k,v in pairs(processed) do
      processedKey = processRecursive(process, k, makePath(path, k, inspect.KEY))
      if processedKey ~= nil then
        processedCopy[processedKey] = processRecursive(process, v, makePath(path, processedKey))
      end
    end

    local mt  = processRecursive(process, getmetatable(processed), makePath(path, inspect.METATABLE))
    setmetatable(processedCopy, mt)
    processed = processedCopy
  end
  return processed
end


-------------------------------------------------------------------

local Inspector = {}
local Inspector_mt = {__index = Inspector}

function Inspector:puts(...)
  local args   = {...}
  local buffer = self.buffer
  local len    = #buffer
  for i=1, #args do
    len = len + 1
    buffer[len] = tostring(args[i])
  end
end

function Inspector:down(f)
  self.level = self.level + 1
  f()
  self.level = self.level - 1
end

function Inspector:tabify()
  self:puts(self.newline, string.rep(self.indent, self.level))
end

function Inspector:alreadyVisited(v)
  return self.ids[type(v)][v] ~= nil
end

function Inspector:getId(v)
  local tv = type(v)
  local id = self.ids[tv][v]
  if not id then
    id              = self.maxIds[tv] + 1
    self.maxIds[tv] = id
    self.ids[tv][v] = id
  end
  return id
end

function Inspector:putKey(k)
  if isIdentifier(k) then return self:puts(k) end
  self:puts("[")
  self:putValue(k)
  self:puts("]")
end

function Inspector:putTable(t)
  if t == inspect.KEY or t == inspect.METATABLE then
    self:puts(tostring(t))
  elseif self:alreadyVisited(t) then
    self:puts('<table ', self:getId(t), '>')
  elseif self.level >= self.depth then
    self:puts('{...}')
  else
    if self.tableAppearances[t] > 1 then self:puts('<', self:getId(t), '>') end

    local nonSequentialKeys = getNonSequentialKeys(t)
    local length            = rawlen(t)
    local mt                = getmetatable(t)
    local toStringResult    = getToStringResultSafely(t, mt)

    self:puts('{')
    self:down(function()
      if toStringResult then
        self:puts(' -- ', escape(toStringResult))
        if length >= 1 then self:tabify() end
      end

      local count = 0
      for i=1, length do
        if count > 0 then self:puts(',') end
        self:puts(' ')
        self:putValue(t[i])
        count = count + 1
      end

      for _,k in ipairs(nonSequentialKeys) do
        if count > 0 then self:puts(',') end
        self:tabify()
        self:putKey(k)
        self:puts(' = ')
        self:putValue(t[k])
        count = count + 1
      end

      if mt then
        if count > 0 then self:puts(',') end
        self:tabify()
        self:puts('<metatable> = ')
        self:putValue(mt)
      end
    end)

    if #nonSequentialKeys > 0 or mt then -- result is multi-lined. Justify closing }
      self:tabify()
    elseif length > 0 then -- array tables have one extra space before closing }
      self:puts(' ')
    end

    self:puts('}')
  end
end

function Inspector:putValue(v)
  local tv = type(v)

  if tv == 'string' then
    self:puts(smartQuote(escape(v)))
  elseif tv == 'number' or tv == 'boolean' or tv == 'nil' then
    self:puts(tostring(v))
  elseif tv == 'table' then
    self:putTable(v)
  else
    self:puts('<',tv,' ',self:getId(v),'>')
  end
end

-------------------------------------------------------------------

function inspect.inspect(root, options)
  options       = options or {}

  local depth   = options.depth   or math.huge
  local newline = options.newline or '\n'
  local indent  = options.indent  or '  '
  local process = options.process

  if process then
    root = processRecursive(process, root, {})
  end

  local inspector = setmetatable({
    depth            = depth,
    buffer           = {},
    level            = 0,
    ids              = setmetatable({}, idsMetaTable),
    maxIds           = setmetatable({}, maxIdsMetaTable),
    newline          = newline,
    indent           = indent,
    tableAppearances = countTableAppearances(root)
  }, Inspector_mt)

  inspector:putValue(root)

  return table.concat(inspector.buffer)
end

setmetatable(inspect, { __call = function(_, ...) return inspect.inspect(...) end })

return inspect

end
        

package.preload[ "byui.inspect" ] = function( ... )
    return require('byui/inspect')
end
            

package.preload[ "byui/kinetic" ] = function( ... )
require('byui/class')
local Am = require('animation')
local M = {}
local class, mixin, super = unpack(require('byui/class'))
local NORMAL_DECAY = 0.95
local FAST_DECAY = 0.70
local Decay = class('Decay', nil, {
    __init__ = function(self, on_value)
        self.on_value = on_value
        self._handler = nil
        self.decay = NORMAL_DECAY
        self.min_distance = 0.1
        self.extra_force = 0
        self.velocity = 0
    end,
    running = {function(self)
        return self._handler ~= nil and not self._handler.stopped
    end},
    start = function(self, value, velocity, decay, on_value, on_stop)
        if self._handler ~= nil then
            self._handler:cancel()
        end
        self.velocity = velocity
        self.extra_force = 0
        self.decay = decay
        on_value = on_value or self.on_value
        self._handler = Clock.instance():schedule(function(dt)
            dt = math.min(dt, 2/60)
            self.velocity = self.velocity * self.decay + self.extra_force
            local diff = self.velocity * dt
            value = value + diff
            if on_value(value) then
                if on_stop then
                    on_stop()
                end
                self:stop()
            end
        end)
    end,
    stop = function(self)
        if self._handler ~= nil then
            self._handler:cancel()
            self._handler = nil
        end
    end,
})

M.KineticEffect = class('KineticEffect', nil, {
    __init__ = function(self, args)
        self.velocity = 0
        self._value = 0

        self.min_distance = 0.1

        -- history
        self.last_value = nil

        self.on_value_changed = args.on_value_changed 
        self.on_stop = args.on_stop
        self.drag_threshold = 20 -- unit

        self.decay = Decay(function(v)
            if math.abs(v - self.value) < self.min_distance then
                return true
            end
            self.value = v
        end)
        
        self.anim = Am.Animator()
        self.anim.on_stop = function()
            self:_on_stop()
        end

        self.min = args.min or 0
        self.max = args.max or 0
    end,
    min = {function(self)
        return self._min or 0
    end, function(self, v)
        if self._min ~= v then
            if self.max and v > self.max then
                v = self.max
            end
            self._min = v
            self:_range_updated()
        end
    end},
    max = {function(self)
        return self._max or 0
    end, function(self, v)
        if self._max ~= v then
            if self.min and v < self.min then
                v = self.min
            end
            self._max = v
            self:_range_updated()
        end
    end},
    _range_updated = function(self)
        if self._min and self._max and self.decay then
            local overscroll = self:get_overscroll(self.value)
            if overscroll ~= 0 then
                self.value = overscroll > 0 and self.max or self.min
                self:cancel()
            end
            --if overscroll ~= 0 and not self.decay.running then
            --    local target = overscroll > 0 and self.max or self.min
            --    local velocity = (target - self.value) / 0.8
            --    self.decay:start(self.value, velocity, FAST_DECAY, function(v)
            --        self.value = v
            --        local overscroll = self:get_overscroll(self.value)
            --        if overscroll == 0 then
            --            return true
            --        end
            --        self.decay.extra_force = -overscroll * 2
            --    end, function()
            --        self.value = target
            --        self:_on_stop()
            --    end)
            --end
        end
    end,
    value = {function(self)
        return self._value
    end, function(self, v)
        if self.is_mannal then
            local overscroll = math.abs(self:get_overscroll(v))
            local diff = v - self._value
            if overscroll > 0 then
                diff = diff / (1.0 + overscroll * self.viscosity)
            end
            v = self._value + diff
        end
        self._value = v
        if self.on_value_changed then
            self:on_value_changed(self._value)
        end
    end},
    get_overscroll = function(self, v)
        if v < self.min then
            return v - self.min
        elseif v > self.max then
            return v - self.max
        else
            return 0
        end
    end,
    start = function(self, val, t)
        if t == nil then
            t = Clock.now() / 1000
        else
            t = t / 1000
        end
        self.velocity = 0
        self.last_value = {val, t}
        self.is_mannal = true

        self.decay:stop(self.history)
        self.anim:stop()
    end,
    update = function(self, val, t)
        if not self.is_mannal then
            -- canceled
            return
        end
        t = t / 1000
        local offset = val - self.last_value[1]
        self:apply(offset)

        local duration = math.max(t - self.last_value[2], 0.03)
        local v = 1000 * offset / (1 + duration * 1000)
        if t - self.last_value[2] < 10/60 then
            -- moving average
            self.velocity = 0.8 * v + 0.2 * self.velocity
        else
            self.velocity = v
        end

        self.velocity = self.velocity * self.velocity_factor

        self.last_value = {val, t}
        --self.is_mannal = true
    end,
    stop = function(self, val, t)
        if not self.is_mannal then
            -- canceled
            return
        end
        t = t / 1000
        if val - self.last_value[1] < 0.0001 and t - self.last_value[2] < 5/60 then
            -- ignore this value
        else
            --self:update(val, t * 1000)
        end
        self.is_mannal = false

        -- check overscroll
        local overscroll = self:get_overscroll(self.value)
        if overscroll == 0 and self.velocity == 0 then
            self:_on_stop()
            return
        end

        local status = 'normal'
        local target
        local direction
        if overscroll ~= 0 then
            target = overscroll > 0 and self.max or self.min
            direction = overscroll > 0 and 1 or -1
        else
            target = self.velocity > 0 and self.max or self.min
            direction = self.velocity > 0 and 1 or -1
        end
        self.decay:start(self.value, self.velocity, NORMAL_DECAY, function(v)
            local diff = math.abs(v - self.value)
            self.value = v
            local overscroll = self:get_overscroll(self.value)
            if status == 'normal' then
                if overscroll ~= 0 then
                    status = 'edge'
                    self.decay.decay = FAST_DECAY
                elseif diff < self.min_distance then
                    return true
                end
            end
            if status == 'edge' then
                if math.abs(overscroll) <= self.min_distance then
                    self.value = target
                    return true
                else
                    self.decay.extra_force = -overscroll * 2
                end
            end
        end, function()
            self:_on_stop()
        end)
    end,
    scroll_to = function(self, target,duration)
        self:cancel()

        if target < self.min then
            target = self.min
        elseif target > self.max then
            target = self.max
        end

        -- use animation to scroll_to target
        self.anim:start(Am.duration(duration or 0.25,Am.timing(Am.kinetic, Am.value(self.value, target))), function(v)
            self.value = v
        end)
    end,
    cancel = function(self)
        self.decay:stop()
        self.is_mannal = false
        self.last_value = nil
        self.anim:stop()
        -- self:_on_stop() 
    end,
    apply = function(self, distance)
        if math.abs(distance) < self.min_distance then
            self.velocity = 0
        end
        self.value = self.value + distance
    end,
    update_velocity = function(self, dt)
        if math.abs(self.velocity) <= self.min_velocity then
            self.velocity = 0
            return
        end

        self.velocity = self.velocity - self.velocity * self.friction
        self:apply(self.velocity * dt)
    end,
    _on_stop = function(self)
        if self.on_stop then
            self:on_stop()
        end
    end,
    velocity_factor = {function ( self )
        return self._velocity_factor or 1 
    end,function ( self,value )
        self._velocity_factor = value
    end},
    viscosity = {function ( self )
        return self._viscosity or 1/50 
    end,function ( self,value )
        self._viscosity = value 
    end},
})

return M.KineticEffect

end
        

package.preload[ "byui.kinetic" ] = function( ... )
    return require('byui/kinetic')
end
            

package.preload[ "byui/label_config" ] = function( ... )

local default_char_list = '一乙二十丁厂七卜人入八九几儿了力乃刀又三于干亏士工土才寸下大丈与万上小口巾山千乞川亿个勺久凡及夕丸么广亡门义之尸弓己已子卫也女飞刃习叉马乡丰王井开夫天无元专云扎艺木五支厅不太犬区历尤友匹车巨牙屯比互切瓦止少日中冈贝内水见午牛手毛气升长仁什片仆化仇币仍仅斤爪反介父从今凶分乏公仓月氏勿欠风丹匀乌凤勾文六方火为斗忆订计户认心尺引丑巴孔队办以允予劝双书幻玉刊示末未击打巧正扑扒功扔去甘世古节本术可丙左厉右石布龙平灭轧东卡北占业旧帅归且旦目叶甲申叮电号田由史只央兄叼叫另叨叹四生失禾丘付仗代仙们仪白仔他斥瓜乎丛令用甩印乐句匆册犯外处冬鸟务包饥主市立闪兰半汁汇头汉宁穴它讨写让礼训必议讯记永司尼民出辽奶奴加召皮边发孕圣对台矛纠母幼丝式刑动扛寺吉扣考托老执巩圾扩扫地扬场耳共芒亚芝朽朴机权过臣再协西压厌在有百存而页匠夸夺灰达列死成夹轨邪划迈毕至此贞师尘尖劣光当早吐吓虫曲团同吊吃因吸吗屿帆岁回岂刚则肉网年朱先丢舌竹迁乔伟传乒乓休伍伏优伐延件任伤价份华仰仿伙伪自血向似后行舟全会杀合兆企众爷伞创肌朵杂危旬旨负各名多争色壮冲冰庄庆亦刘齐交次衣产决充妄闭问闯羊并关米灯州汗污江池汤忙兴宇守宅字安讲军许论农讽设访寻那迅尽导异孙阵阳收阶阴防奸如妇好她妈戏羽观欢买红纤级约纪驰巡寿弄麦形进戒吞远违运扶抚坛技坏扰拒找批扯址走抄坝贡攻赤折抓扮抢孝均抛投坟抗坑坊抖护壳志扭块声把报却劫芽花芹芬苍芳严芦劳克苏杆杠杜材村杏极李杨求更束豆两丽医辰励否还歼来连步坚旱盯呈时吴助县里呆园旷围呀吨足邮男困吵串员听吩吹呜吧吼别岗帐财针钉告我乱利秃秀私每兵估体何但伸作伯伶佣低你住位伴身皂佛近彻役返余希坐谷妥含邻岔肝肚肠龟免狂犹角删条卵岛迎饭饮系言冻状亩况床库疗应冷这序辛弃冶忘闲间闷判灶灿弟汪沙汽沃泛沟没沈沉怀忧快完宋宏牢究穷灾良证启评补初社识诉诊词译君灵即层尿尾迟局改张忌际陆阿陈阻附妙妖妨努忍劲鸡驱纯纱纳纲驳纵纷纸纹纺驴纽奉玩环武青责现表规抹拢拔拣担坦押抽拐拖拍者顶拆拥抵拘势抱垃拉拦拌幸招坡披拨择抬其取苦若茂苹苗英范直茄茎茅林枝杯柜析板松枪构杰述枕丧或画卧事刺枣雨卖矿码厕奔奇奋态欧垄妻轰顷转斩轮软到非叔肯齿些虎虏肾贤尚旺具果味昆国昌畅明易昂典固忠咐呼鸣咏呢岸岩帖罗帜岭凯败贩购图钓制知垂牧物乖刮秆和季委佳侍供使例版侄侦侧凭侨佩货依的迫质欣征往爬彼径所舍金命斧爸采受乳贪念贫肤肺肢肿胀朋股肥服胁周昏鱼兔狐忽狗备饰饱饲变京享店夜庙府底剂郊废净盲放刻育闸闹郑券卷单炒炊炕炎炉沫浅法泄河沾泪油泊沿泡注泻泳泥沸波泼泽治怖性怕怜怪学宝宗定宜审宙官空帘实试郎诗肩房诚衬衫视话诞询该详建肃录隶居届刷屈弦承孟孤陕降限妹姑姐姓始驾参艰线练组细驶织终驻驼绍经贯奏春帮珍玻毒型挂封持项垮挎城挠政赴赵挡挺括拴拾挑指垫挣挤拼挖按挥挪某甚革荐巷带草茧茶荒茫荡荣故胡南药标枯柄栋相查柏柳柱柿栏树要咸威歪研砖厘厚砌砍面耐耍牵残殃轻鸦皆背战点临览竖省削尝是盼眨哄显哑冒映星昨畏趴胃贵界虹虾蚁思蚂虽品咽骂哗咱响哈咬咳哪炭峡罚贱贴骨钞钟钢钥钩卸缸拜看矩怎牲选适秒香种秋科重复竿段便俩贷顺修保促侮俭俗俘信皇泉鬼侵追俊盾待律很须叙剑逃食盆胆胜胞胖脉勉狭狮独狡狱狠贸怨急饶蚀饺饼弯将奖哀亭亮度迹庭疮疯疫疤姿亲音帝施闻阀阁差养美姜叛送类迷前首逆总炼炸炮烂剃洁洪洒浇浊洞测洗活派洽染济洋洲浑浓津恒恢恰恼恨举觉宣室宫宪突穿窃客冠语扁袄祖神祝误诱说诵垦退既屋昼费陡眉孩除险院娃姥姨姻娇怒架贺盈勇怠柔垒绑绒结绕骄绘给络骆绝绞统耕耗艳泰珠班素蚕顽盏匪捞栽捕振载赶起盐捎捏埋捉捆捐损都哲逝捡换挽热恐壶挨耻耽恭莲莫荷获晋恶真框桂档桐株桥桃格校核样根索哥速逗栗配翅辱唇夏础破原套逐烈殊顾轿较顿毙致柴桌虑监紧党晒眠晓鸭晃晌晕蚊哨哭恩唤啊唉罢峰圆贼贿钱钳钻铁铃铅缺氧特牺造乘敌秤租积秧秩称秘透笔笑笋债借值倚倾倒倘俱倡候俯倍倦健臭射躬息徒徐舰舱般航途拿爹爱颂翁脆脂胸胳脏胶脑狸狼逢留皱饿恋桨浆衰高席准座脊症病疾疼疲效离唐资凉站剖竞部旁旅畜阅羞瓶拳粉料益兼烤烘烦烧烛烟递涛浙涝酒涉消浩海涂浴浮流润浪浸涨烫涌悟悄悔悦害宽家宵宴宾窄容宰案请朗诸读扇袜袖袍被祥课谁调冤谅谈谊剥恳展剧屑弱陵陶陷陪娱娘通能难预桑绢绣验继球理捧堵描域掩捷排掉堆推掀授教掏掠培接控探据掘职基著勒黄萌萝菌菜萄菊萍菠营械梦梢梅检梳梯桶救副票戚爽聋袭盛雪辅辆虚雀堂常匙晨睁眯眼悬野啦晚啄距跃略蛇累唱患唯崖崭崇圈铜铲银甜梨犁移笨笼笛符第敏做袋悠偿偶偷您售停偏假得衔盘船斜盒鸽悉欲彩领脚脖脸脱象够猜猪猎猫猛馅馆凑减毫麻痒痕廊康庸鹿盗章竟商族旋望率着盖粘粗粒断剪兽清添淋淹渠渐混渔淘液淡深婆梁渗情惜惭悼惧惕惊惨惯寇寄宿窑密谋谎祸谜逮敢屠弹随蛋隆隐婚婶颈绩绪续骑绳维绵绸绿琴斑替款堪搭塔越趁趋超提堤博揭喜插揪搜煮援裁搁搂搅握揉斯期欺联散惹葬葛董葡敬葱落朝辜葵棒棋植森椅椒棵棍棉棚棕惠惑逼厨厦硬确雁殖裂雄暂雅辈悲紫辉敞赏掌晴暑最量喷晶喇遇喊景践跌跑遗蛙蛛蜓喝喂喘喉幅帽赌赔黑铸铺链销锁锄锅锈锋锐短智毯鹅剩稍程稀税筐等筑策筛筒答筋筝傲傅牌堡集焦傍储奥街惩御循艇舒番释禽腊脾腔鲁猾猴然馋装蛮就痛童阔善羡普粪尊道曾焰港湖渣湿温渴滑湾渡游滋溉愤慌惰愧愉慨割寒富窜窝窗遍裕裤裙谢谣谦属屡强粥疏隔隙絮嫂登缎缓编骗缘瑞魂肆摄摸填搏塌鼓摆携搬摇搞塘摊蒜勤鹊蓝墓幕蓬蓄蒙蒸献禁楚想槐榆楼概赖酬感碍碑碎碰碗碌雷零雾雹输督龄鉴睛睡睬鄙愚暖盟歇暗照跨跳跪路跟遣蛾蜂嗓置罪罩错锡锣锤锦键锯矮辞稠愁筹签简毁舅鼠催傻像躲微愈遥腰腥腹腾腿触解酱痰廉新韵意粮数煎塑慈煤煌满漠源滤滥滔溪溜滚滨粱滩慎誉塞谨福群殿辟障嫌嫁叠缝缠静碧璃墙撇嘉摧截誓境摘摔聚蔽慕暮蔑模榴榜榨歌遭酷酿酸磁愿需弊裳颗嗽蜻蜡蝇蜘赚锹锻舞稳算箩管僚鼻魄貌膜膊膀鲜疑馒裹敲豪膏遮腐瘦辣竭端旗精歉熄熔漆漂漫滴演漏慢寨赛察蜜谱嫩翠熊凳骡缩慧撕撒趣趟撑播撞撤增聪鞋蕉蔬横槽樱橡飘醋醉震霉瞒题暴瞎影踢踏踩踪蝶蝴嘱墨镇靠稻黎稿稼箱箭篇僵躺僻德艘膝膛熟摩颜毅糊遵潜潮懂额慰劈操燕薯薪薄颠橘整融醒餐嘴蹄器赠默镜赞篮邀衡膨雕磨凝辨辩糖糕燃澡激懒壁避缴戴擦鞠藏霜霞瞧蹈螺穗繁辫赢糟糠燥臂翼骤鞭覆蹦镰翻鹰警攀蹲颤瓣爆疆壤耀躁嚼嚷籍魔灌蠢霸露囊罐匕刁丐歹戈夭仑讥冗邓艾夯凸卢叭叽皿凹囚矢乍尔冯玄邦迂邢芋芍吏夷吁吕吆屹廷迄臼仲伦伊肋旭匈凫妆亥汛讳讶讹讼诀弛阱驮驯纫玖玛韧抠扼汞扳抡坎坞抑拟抒芙芜苇芥芯芭杖杉巫杈甫匣轩卤肖吱吠呕呐吟呛吻吭邑囤吮岖牡佑佃伺囱肛肘甸狈鸠彤灸刨庇吝庐闰兑灼沐沛汰沥沦汹沧沪忱诅诈罕屁坠妓姊妒纬玫卦坷坯拓坪坤拄拧拂拙拇拗茉昔苛苫苟苞茁苔枉枢枚枫杭郁矾奈奄殴歧卓昙哎咕呵咙呻咒咆咖帕账贬贮氛秉岳侠侥侣侈卑刽刹肴觅忿瓮肮肪狞庞疟疙疚卒氓炬沽沮泣泞泌沼怔怯宠宛衩祈诡帚屉弧弥陋陌函姆虱叁绅驹绊绎契贰玷玲珊拭拷拱挟垢垛拯荆茸茬荚茵茴荞荠荤荧荔栈柑栅柠枷勃柬砂泵砚鸥轴韭虐昧盹咧昵昭盅勋哆咪哟幽钙钝钠钦钧钮毡氢秕俏俄俐侯徊衍胚胧胎狰饵峦奕咨飒闺闽籽娄烁炫洼柒涎洛恃恍恬恤宦诫诬祠诲屏屎逊陨姚娜蚤骇耘耙秦匿埂捂捍袁捌挫挚捣捅埃耿聂荸莽莱莉莹莺梆栖桦栓桅桩贾酌砸砰砾殉逞哮唠哺剔蚌蚜畔蚣蚪蚓哩圃鸯唁哼唆峭唧峻赂赃钾铆氨秫笆俺赁倔殷耸舀豺豹颁胯胰脐脓逛卿鸵鸳馁凌凄衷郭斋疹紊瓷羔烙浦涡涣涤涧涕涩悍悯窍诺诽袒谆祟恕娩骏琐麸琉琅措捺捶赦埠捻掐掂掖掷掸掺勘聊娶菱菲萎菩萤乾萧萨菇彬梗梧梭曹酝酗厢硅硕奢盔匾颅彪眶晤曼晦冕啡畦趾啃蛆蚯蛉蛀唬啰唾啤啥啸崎逻崔崩婴赊铐铛铝铡铣铭矫秸秽笙笤偎傀躯兜衅徘徙舶舷舵敛翎脯逸凰猖祭烹庶庵痊阎阐眷焊焕鸿涯淑淌淮淆渊淫淳淤淀涮涵惦悴惋寂窒谍谐裆袱祷谒谓谚尉堕隅婉颇绰绷综绽缀巢琳琢琼揍堰揩揽揖彭揣搀搓壹搔葫募蒋蒂韩棱椰焚椎棺榔椭粟棘酣酥硝硫颊雳翘凿棠晰鼎喳遏晾畴跋跛蛔蜒蛤鹃喻啼喧嵌赋赎赐锉锌甥掰氮氯黍筏牍粤逾腌腋腕猩猬惫敦痘痢痪竣翔奠遂焙滞湘渤渺溃溅湃愕惶寓窖窘雇谤犀隘媒媚婿缅缆缔缕骚瑟鹉瑰搪聘斟靴靶蓖蒿蒲蓉楔椿楷榄楞楣酪碘硼碉辐辑频睹睦瞄嗜嗦暇畸跷跺蜈蜗蜕蛹嗅嗡嗤署蜀幌锚锥锨锭锰稚颓筷魁衙腻腮腺鹏肄猿颖煞雏馍馏禀痹廓痴靖誊漓溢溯溶滓溺寞窥窟寝褂裸谬媳嫉缚缤剿赘熬赫蔫摹蔓蔗蔼熙蔚兢榛榕酵碟碴碱碳辕辖雌墅嘁踊蝉嘀幔镀舔熏箍箕箫舆僧孵瘩瘟彰粹漱漩漾慷寡寥谭褐褪隧嫡缨撵撩撮撬擒墩撰鞍蕊蕴樊樟橄敷豌醇磕磅碾憋嘶嘲嘹蝠蝎蝌蝗蝙嘿幢镊镐稽篓膘鲤鲫褒瘪瘤瘫凛澎潭潦澳潘澈澜澄憔懊憎翩褥谴鹤憨履嬉豫缭撼擂擅蕾薛薇擎翰噩橱橙瓢蟥霍霎辙冀踱蹂蟆螃螟噪鹦黔穆篡篷篙篱儒膳鲸瘾瘸糙燎濒憾懈窿缰壕藐檬檐檩檀礁磷瞭瞬瞳瞪曙蹋蟋蟀嚎赡镣魏簇儡徽爵朦臊鳄糜癌懦豁臀藕藤瞻嚣鳍癞瀑襟璧戳攒孽蘑藻鳖蹭蹬簸簿蟹靡癣羹鬓攘蠕巍鳞糯譬霹躏髓蘸镶瓤矗'

-- 
-- local config_tbl = {
--     content_scale_factor = 1,
--     font_size = 24,
--     enable_distance_field = true,
--     texture_width = 512,
--     texture_height = 512,
--     cache_char_list = '12345',
--     cache_font_style = font_style,  -- [Label.STYLE_NORMAL, Label.STYLE_ITALIC, Label.STYLE_BOLD]
--     cache_outline = 0,
-- }

local M = {}

function M.simple_config(tbl)
    tbl.cache_config = {
        all_cache_char = {
            {
                font_style = tbl.cache_font_style or Label.STYLE_NORMAL,
                outline = tbl.cache_outline or 0,
                char_list = tbl.cache_char_list or default_char_list,
            },
        },
    }

    M.config(tbl)
end

function M.config(tbl)
    Label.config(
        tbl.content_scale_factor,
        tbl.font_size,
        tbl.enable_distance_field,
        tbl.texture_width,
        tbl.texture_height
    )

    SimpleCache.get_simple_cache():alloc_cache(tbl.cache_config)
end

return M


end
        

package.preload[ "byui.label_config" ] = function( ... )
    return require('byui/label_config')
end
            

package.preload[ "byui/layout" ] = function( ... )
---
-- 布局模块.
-- 包含了GridLayout和FloatLayout.
-- @module byui.layout
-- @extends byui#byui.layout
-- @return #byui.layout 
local M = {}
require('byui/utils')
local class, mixin, super = unpack(require('byui/class'))

---
-- 网格布局.
-- 详细说明请参考[网格布局](http://engine.by.com:8000/doc/ui.html#gridlayout)。
-- @type byui.GridLayout
-- @extends engine#Widget 
-- @usage byui.GridLayout{rows = 3,cols=4}

---
-- 创建网格布局对象.
-- @callof #byui.GridLayout
-- @param #byui.GridLayout self 
-- @param #table args 构造时传入的参数.<br/>
--                    1. cols:number类型,表示列的数目。
--                    2. rows:number类型,表示行的数目。
--                    3. align:ALIGN,每一个网格中元素的对齐方式。默认为ALIGN.TOPLEFT。
--                    4. dimension:取值为kHorizental和kVertical,元素排列生长的方向。
-- @return #byui.GridLayout 返回创建的网格布局对象. 

---
-- 网格布局.
-- 参看@{#byui.GridLayout}
-- @field [parent=#byui.layout] #byui.GridLayout GridLayout 
M.GridLayout = class('GridLayout', Widget, {
    __init__ = function(self, args)
        super(M.GridLayout, self).__init__(self, args)
        self.rows = args.rows
        self.cols = args.cols
        self.align = args.align or ALIGN.TOPLEFT
        self.dimension = args.dimension or kVertical
        self.lua_layout_children = function(self)
            self:layout()
        end
    end,
    -- add = function(self, w)
    --     super(M.GridLayout, self).add(self, w)
    --     local unit = Point(self.width / self.cols, self.height / self.rows)
    --     local i = #self.children - 1
    --     local c,r
    --     local offset_h = unit.x - w.width
    --     local offset_v = unit.y - w.height
    --     local x_c = align_h(self.align)
    --     local y_c = align_v(self.align)/4
    --     if self.dimension == kVertical then
    --         c = i % self.cols
    --         r = math.floor(i / self.cols)
    --     else
    --         c = math.floor(i / self.rows)
    --         r = i % self.rows 
    --     end
    --     w.pos = Point(c * unit.x + (-0.75*x_c*x_c+3.25*x_c-2.5) *offset_h, r * unit.y+(-0.75*y_c*y_c+3.25*y_c-2.5) *offset_v)
    -- end,
    layout = function(self)
        local unit = Point(self.width / self.cols, self.height / self.rows)
            ---
            -- top,left 1 ---> 0
            -- buttom,right 2 ---> 1
            -- center,center 3 ---> 0.5
            -- formula： -0.75*x^2 + 3.25*x - 2.5
        if self.dimension == kVertical then
            for i, w in ipairs(self.children) do
                w.compat_rules = {}
                w:update_constraints()
                i = i - 1
                local c = i % self.cols
                local r = math.floor(i / self.cols)

                local offset_h = unit.x - w.width
                local offset_v = unit.y - w.height
                local x_c = align_h(self.align)
                local y_c = align_v(self.align)/4

                w.pos = Point(c * unit.x + (-0.75*x_c*x_c+3.25*x_c-2.5) *offset_h, r * unit.y+(-0.75*y_c*y_c+3.25*y_c-2.5) *offset_v)
            end
        else
            for i, w in ipairs(self.children) do
                w.compat_rules = {}
                w:update_constraints()
                i = i - 1
                local c = math.floor(i / self.rows)
                local r = i % self.rows

                local offset_h = unit.x - w.width
                local offset_v = unit.y - w.height
                local x_c = align_h(self.align)
                local y_c = align_v(self.align)/4

                w.pos = Point(c * unit.x + (-0.75*x_c*x_c+3.25*x_c-2.5) *offset_h, r * unit.y+(-0.75*y_c*y_c+3.25*y_c-2.5) *offset_v)
            end
        end
        
    end,
    
    ---
    -- 元素在网格的对齐方式.
    -- 在修改对齐方式后会立刻重新重新布局。
    -- @field [parent=#byui.GridLayout] byui.utils#ALIGN align 
    align = {function ( self )
        return self._algin or ALIGN.TOPLEFT
    end,function ( self,value )
        self._algin = value
        self:layout()
    end},
    
    ---
    -- 元素在网格的生长方向.
    -- 在修改方向后会立刻重新布局。<br/>
    -- 取值为@{#byui.utils.kHorizental}和@{#byui.utils.kVertical}
    -- @field [parent=#byui.GridLayout] #number dimension 
    dimension = {function ( self )
        return self._dimension or kVertical
    end,function ( self,value )
        self._dimension  = value or kVertical
        self:layout()
    end},
}, true)



---
-- 线性布局.
-- 详细说明请参考[线性布局](http://engine.by.com:8000/doc/ui.html#floatlayout)。
-- @type byui.FloatLayout
-- @extends engine#Widget 
-- @usage byui.FloatLayout{spacing =  Point(0,0)}

---
-- 创建一个线性布局.
-- @callof #byui.FloatLayout
-- @param #byui.FloatLayout self 
-- @param #table args 构造时传入的参数.<br/>
--                    1. spacing:Point类型,表示子元素之间的间距。
--                    2. dimension:取值为kHorizental和kVertical,元素排列生长的方向。
-- @return #byui.FloatLayout 返回创建的线性布局对象.                  


---
-- 线性布局.
-- 参看@{#byui.FloatLayout}
-- @field [parent=#byui.layout] #byui.FloatLayout FloatLayout
M.FloatLayout = class('FloatLayout', Widget, {
    __init__ = function(self, args)
        super(M.FloatLayout, self).__init__(self, args)
        self.spacing = args.spacing or Point(0,0)
        self._pen = Point(0,0)
        self._line_height = 0
        self.dimension = args.dimension or kVertical
        self.lua_layout_children = function(self)
            self:layout()
        end
    end,
    
    ---
    -- 子元素之间的间隔.
    -- spacing.x表示水平方向的间距，spacing.y表示垂直方向的间距。
    -- @field [parent=#byui.FloatLayout] engine#Point spacing 
    spacing = {function(self)
        return self._spacing
    end, function(self, s)
        if self._spacing ~= s then
            self._spacing = s
            self:layout()
        end
    end},
    layout = function(self)
        self._pen = Point(0,0)
        self._layout_size = Point(0,0)
        for i, w in ipairs(self.children) do
            self:_append(w)
        end
    end,
    -- add = function(self, w,r)
    --     super(M.FloatLayout, self).add(self, w)
    --     self:_append(w) 
    -- end,
    _append = function(self, w)
        w.compat_rules = {}
        w:update_constraints()
        if self.dimension == kVertical then
            if self._pen.x == 0 or self._pen.x + w.width <= self.width then
                w.pos = self._pen
                w.vars.left.value = self._pen.x
                w.vars.top.value = self._pen.y
                self._pen.x = self._pen.x + w.width + self.spacing.x

                if w.height > self._layout_size.y then
                    self._layout_size.y = w.height
                end
            else
                -- break line
                self._pen.x = 0
                self._pen.y = self._pen.y + self._layout_size.y + self.spacing.y
                self._layout_size.y = w.height
                w.pos = self._pen
                w.vars.left.value = self._pen.x
                w.vars.top.value = self._pen.y
                self._pen.x = self._pen.x + w.width + self.spacing.x
            end
        else
            if self._pen.y == 0 or self._pen.y + w.height <= self.height then
                w.pos = self._pen
                w.vars.left.value = self._pen.x
                w.vars.top.value = self._pen.y
                self._pen.y = self._pen.y + w.height + self.spacing.y

                if w.width > self._layout_size.x then
                    self._layout_size.x = w.width
                end
            else
                -- break line
                self._pen.y = 0
                self._pen.x = self._pen.x + self._layout_size.x + self.spacing.x
                self._layout_size.x = w.width
                w.pos = self._pen
                w.vars.left.value = self._pen.x
                w.vars.top.value = self._pen.y
                self._pen.y = self._pen.y + w.height + self.spacing.y
            end
        end
    end,
    
    ---
    -- 元素生长方向.
    -- 在修改方向后会立刻重新布局。<br/>
    -- 取值为@{#byui.utils.kHorizental}和@{#byui.utils.kVertical}
    -- @field [parent=#byui.FloatLayout] #number dimension 
    dimension = {function ( self )
        return self._dimension or kVertical
    end,function ( self,value )
        self._dimension  = value or kVertical
        self:layout()
    end},
}, true)

---
-- 测试Demo.
-- @field [parent=#byui.layout] #function test 
function M.test(root)
    -- local l = M.GridLayout{
    --     cols = 4,
    --     rows = 6,
    --     dimension = kHorizental,
    -- }
    local l = M.FloatLayout{
       spacing = Point(5,5),
    }
    l.background_color = Colorf(0.5,0.5,0.5,1.0)
    l.size = Point(300,300)
    -- for i=1,30 do
    --     local s = Sprite()
    --     s.unit = TextureUnit.default_unit()
    --     s.size = Point(10,10)
    --     l:add(s)
    -- end
    Clock.instance():schedule(function ( ... )
        local s = Sprite()
        s.unit = TextureUnit.default_unit()
        s.size = Point(100,100)
        l:add(s)
    end,1)

    -- Clock.instance():schedule_once(function ( ... )
    --     print("添加")
    --     local s = Sprite()
    --     s.unit = TextureUnit.default_unit()
    --     s.size = Point(10,10)
    --     s.colorf = Colorf(1.0,0.0,0.0,1.0)
    --     l:add(s,l.children[10])
    -- end,30)
    root:add(l)

    -- for k,v in pairs(ALIGN) do
    --     local align = {["k"] = k,["v"]=v}
    --     Clock.instance():schedule_once(function ( ... )
    --         l.align = align.v
    --     end,align.v*2)
    -- end
    
end

return M

end
        

package.preload[ "byui.layout" ] = function( ... )
    return require('byui/layout')
end
            

package.preload[ "byui/particle" ] = function( ... )

local function create_ps_node(ps, node_data)
    local ps_node = PSNode(node_data.name)
    if node_data.pos then ps_node:set_translate(node_data.pos) end
    return ps_node
end

local function create_ps_camera(ps, camera_data)
    local ps_camera = PSCamera(camera_data.name)
    if camera_data.pos then ps_camera:set_translate(camera_data.pos) end

    local look_at = camera_data.look_at or Point3(0.0, 0.0, 0.0)
    local up = camera_data.up or Point3(0.0, 1.0, 0.0)
    ps_camera:look_at_world_point(look_at, up)

    if camera_data.view_port then ps_camera.view_port = camera_data.view_port end

    if camera_data.frustum then
        ps_camera:set_view_frustum(
            camera_data.frustum.left,
            camera_data.frustum.right,
            camera_data.frustum.top,
            camera_data.frustum.bottom,
            camera_data.frustum.near,
            camera_data.frustum.far,
            camera_data.frustum.ortho
            )
    end

    return ps_camera
end

local function create_emitter(ps, emitter_data)
    local ps_node = ps:get_node(emitter_data.emitter_obj)

    local emitter_types = {
        ['Box'] = function()
            return PSBoxEmitter(
                emitter_data.name,
                emitter_data.emitter_width,
                emitter_data.emitter_height,
                emitter_data.emitter_depth,
                ps_node,
                emitter_data.speed,
                emitter_data.speed_var,
                emitter_data.speed_flip_ratio,
                math.rad(emitter_data.declination),
                math.rad(emitter_data.declination_var),
                math.rad(emitter_data.planar_angle),
                math.rad(emitter_data.planar_angle_var),
                emitter_data.size,
                emitter_data.size_var,
                emitter_data.life_span,
                emitter_data.life_span_var,
                math.rad(emitter_data.rotation_angle),
                math.rad(emitter_data.rotation_angle_var),
                math.rad(emitter_data.rotation_speed),
                math.rad(emitter_data.rotation_speed_var),
                emitter_data.random_rotation_speed_sign,
                emitter_data.rot_axis,
                emitter_data.random_rotation_axis
            )
        end,
        ['Cylinder'] = function()
            return PSCylinderEmitter(
                emitter_data.name,
                emitter_data.emitter_radius,
                emitter_data.emitter_height,
                ps_node,
                emitter_data.speed,
                emitter_data.speed_var,
                emitter_data.speed_flip_ratio,
                math.rad(emitter_data.declination),
                math.rad(emitter_data.declination_var),
                math.rad(emitter_data.planar_angle),
                math.rad(emitter_data.planar_angle_var),
                emitter_data.size,
                emitter_data.size_var,
                emitter_data.life_span,
                emitter_data.life_span_var,
                math.rad(emitter_data.rotation_angle),
                math.rad(emitter_data.rotation_angle_var),
                math.rad(emitter_data.rotation_speed),
                math.rad(emitter_data.rotation_speed_var),
                emitter_data.random_rotation_speed_sign,
                emitter_data.rot_axis,
                emitter_data.random_rotation_axis
            )
        end,
        ['Sphere'] = function()
            return PSSphereEmitter(
                emitter_data.name,
                emitter_data.emitter_radius,
                ps_node,
                emitter_data.speed,
                emitter_data.speed_var,
                emitter_data.speed_flip_ratio,
                math.rad(emitter_data.declination),
                math.rad(emitter_data.declination_var),
                math.rad(emitter_data.planar_angle),
                math.rad(emitter_data.planar_angle_var),
                emitter_data.size,
                emitter_data.size_var,
                emitter_data.life_span,
                emitter_data.life_span_var,
                math.rad(emitter_data.rotation_angle),
                math.rad(emitter_data.rotation_angle_var),
                math.rad(emitter_data.rotation_speed),
                math.rad(emitter_data.rotation_speed_var),
                emitter_data.random_rotation_speed_sign,
                emitter_data.rot_axis,
                emitter_data.random_rotation_axis
            )
        end,
        ['Torus'] = function()
            return PSTorusEmitter(
                emitter_data.name,
                emitter_data.emitter_radius,
                emitter_data.emitter_section_radius,
                ps_node,
                emitter_data.speed,
                emitter_data.speed_var,
                emitter_data.speed_flip_ratio,
                math.rad(emitter_data.declination),
                math.rad(emitter_data.declination_var),
                math.rad(emitter_data.planar_angle),
                math.rad(emitter_data.planar_angle_var),
                emitter_data.size,
                emitter_data.size_var,
                emitter_data.life_span,
                emitter_data.life_span_var,
                math.rad(emitter_data.rotation_angle),
                math.rad(emitter_data.rotation_angle_var),
                math.rad(emitter_data.rotation_speed),
                math.rad(emitter_data.rotation_speed_var),
                emitter_data.random_rotation_speed_sign,
                emitter_data.rot_axis,
                emitter_data.random_rotation_axis
            )
        end,
        ['Curve'] = function()
            local curve_parent_node = ps:get_node(emitter_data.curve_parent or '')
            local curve = PSCurve3()
            curve:initialize(emitter_data.curve.degree, emitter_data.curve.control_points, emitter_data.curve.knots)
            return PSCurveEmitter(
                emitter_data.name,
                curve_parent_node,
                ps_node,
                curve,
                emitter_data.speed,
                emitter_data.speed_var,
                emitter_data.speed_flip_ratio,
                math.rad(emitter_data.declination),
                math.rad(emitter_data.declination_var),
                math.rad(emitter_data.planar_angle),
                math.rad(emitter_data.planar_angle_var),
                emitter_data.size,
                emitter_data.size_var,
                emitter_data.life_span,
                emitter_data.life_span_var,
                math.rad(emitter_data.rotation_angle),
                math.rad(emitter_data.rotation_angle_var),
                math.rad(emitter_data.rotation_speed),
                math.rad(emitter_data.rotation_speed_var),
                emitter_data.random_rotation_speed_sign,
                emitter_data.rot_axis,
                emitter_data.random_rotation_axis
            )
        end,
    }

    local emitter = emitter_types[emitter_data.emitter_type]()

    if emitter_data.default_direction then emitter.default_direction = emitter_data.default_direction end

    return emitter
end

local function create_emitter_controller(ps, emitter_ctrl_data)
    local emitter_ctrl_types = {
        ['EmitParticles'] = function()
            local emit_particles_ctrl = PSEmitParticlesCtlr(emitter_ctrl_data.emitter_name)

            if emitter_ctrl_data.birth_rate_ctrl and emitter_ctrl_data.birth_rate_ctrl.frames then
                local birth_rate_ctrl = emit_particles_ctrl:get_birth_rate_ctrl()
                for _,frame in ipairs(emitter_ctrl_data.birth_rate_ctrl.frames) do
                    birth_rate_ctrl:insert_frame(frame.time, frame.value)
                end
                birth_rate_ctrl:start()
            end

            if emitter_ctrl_data.active_ctrl and emitter_ctrl_data.active_ctrl.frames then
                local active_ctrl = emit_particles_ctrl:get_active_ctrl()
                for _,frame in ipairs(emitter_ctrl_data.active_ctrl.frames) do
                    active_ctrl:insert_frame(frame.time, frame.value)
                end
                active_ctrl:start()
            end

            return emit_particles_ctrl
        end,
        ['FloatCtrl'] = function()
            local float_ctrl = PSEmitterFloatCtrl(emitter_ctrl_data.emitter_name, emitter_ctrl_data.attr_type)

            local key_frame_ctrl = float_ctrl:get_key_frame_ctrl()
            key_frame_ctrl.cycle_type = emitter_ctrl_data.cycle_type

            if emitter_ctrl_data.frames then
                for _,frame in ipairs(emitter_ctrl_data.frames) do
                    key_frame_ctrl:insert_frame(frame.time, frame.value)
                end
                key_frame_ctrl:start()
            end

            return float_ctrl
        end,
    }

    local emitter_ctrl = emitter_ctrl_types[emitter_ctrl_data.emitter_ctrl_type]()
    emitter_ctrl:set_target(ps)

    return emitter_ctrl
end

local function create_force(ps, force_data)
    local ps_node = ps:get_node(force_data.force_obj)

    local force_types = {
        ['BombForce'] = function()
            return PSBombForce(
                force_data.name,
                ps_node,
                force_data.bomb_axis,
                force_data.decay,
                force_data.delta_v,
                force_data.decay_type,
                force_data.symm_type
            )
        end,
        ['DragForce'] = function()
            return PSDragForce(
                force_data.name,
                ps_node,
                force_data.drag_axis,
                force_data.percentage,
                force_data.range,
                force_data.range_falloff
            )
        end,
        ['AirFieldForce'] = function()
            return PSAirFieldForce(
                force_data.name,
                ps_node,
                force_data.magnitude,
                force_data.attenuation,
                force_data.use_max_distance,
                force_data.max_distance,
                force_data.direction,
                force_data.air_friction,
                force_data.inherited_velocity,
                force_data.inherit_rotation,
                force_data.enable_spread,
                force_data.spread
            )
        end,
        ['DragFieldForce'] = function()
            return PSDragFieldForce(
                force_data.name,
                ps_node,
                force_data.magnitude,
                force_data.attenuation,
                force_data.use_max_distance,
                force_data.max_distance,
                force_data.use_direction,
                force_data.direction
            )
        end,
        ['GravityFieldForce'] = function()
            return PSGravityFieldForce(
                force_data.name,
                ps_node,
                force_data.magnitude,
                force_data.attenuation,
                force_data.use_max_distance,
                force_data.max_distance,
                force_data.direction
            )
        end,
        ['RadialFieldForce'] = function()
            return PSRadialFieldForce(
                force_data.name,
                ps_node,
                force_data.magnitude,
                force_data.attenuation,
                force_data.use_max_distance,
                force_data.max_distance,
                force_data.radial_factor
            )
        end,
        ['TurbulenceFieldForce'] = function()
            return PSTurbulenceFieldForce(
                force_data.name,
                ps_node,
                force_data.magnitude,
                force_data.attenuation,
                force_data.use_max_distance,
                force_data.max_distance,
                force_data.frequency
            )
        end,
        ['VortexFieldForce'] = function()
            return PSVortexFieldForce(
                force_data.name,
                ps_node,
                force_data.magnitude,
                force_data.attenuation,
                force_data.use_max_distance,
                force_data.max_distance,
                force_data.direction
            )
        end,
        ['GravityForce'] = function()
            return PSGravityForce(
                force_data.name,
                ps_node,
                force_data.gravity_axis,
                force_data.decay,
                force_data.strength,
                force_data.gravity_force_type,
                force_data.turbulence,
                force_data.turbulence_scale
            )
        end,
    }

    local force = force_types[force_data.force_type]()
    force.active = force_data.active

    return force
end

local function create_collider(ps, spawner, collider_data)
    local ps_node = ps:get_node(collider_data.collider_obj)

    local collider_types = {
        ['PlanarCollider'] = function()
            return PSPlanarCollider(
                collider_data.bounce,
                collider_data.spawn_on_collide,
                collider_data.die_on_collide,
                spawner,
                ps_node,
                collider_data.width,
                collider_data.height,
                collider_data.x_axis,
                collider_data.y_axis
            )
        end,
        ['SphericalCollider'] = function()
            return PSSphericalCollider(
                collider_data.bounce,
                collider_data.spawn_on_collide,
                collider_data.die_on_collide,
                spawner,
                ps_node,
                collider_data.radius
            )
        end,
    }

    return collider_types[collider_data.collider_type]()
end

local function create_spawner(spawner_data)
    return PSSpawner(
        spawner_data.num_spawn_generations,
        spawner_data.percentage_spawned,
        spawner_data.min_num_to_spawn,
        spawner_data.max_num_to_spawn,
        spawner_data.spawn_speed_factor,
        spawner_data.spawn_speed_factor_var,
        spawner_data.spawn_dir_chaos,
        spawner_data.life_span,
        spawner_data.life_span_var,
        spawner_data.relative_speed
        )
end

local function create_particle_systme(ps_data)
    local has_animated_textures = false

    local has_rotations = false
    if ps_data.general_data and ps_data.general_data.rotation_frames then has_rotations = true end

    local has_colors = false
    if ps_data.general_data and ps_data.general_data.color_frames then has_colors = true end

    local has_living_spawner = false
    local living_spawner = ps_data.living_spawner and create_spawner(ps_data.living_spawner) or nil
    if living_spawner then has_living_spawner = true end

    local dynamic_bounds = false
    local create_default_generator = false

    local ps = PSParticleSystem.create(
        ps_data.max_num_particles,
        ps_data.normal_method,
        ps_data.normal_direction,
        ps_data.up_method,
        ps_data.up_direction,
        has_living_spawner,
        has_colors,
        has_rotations,
        has_animated_textures,
        ps_data.world_space,
        dynamic_bounds,
        create_default_generator
    )

    ps.src_blend_alpha = ps_data.src_blend_alpha
    ps.src_blend_rgb = ps_data.src_blend_rgb
    ps.dst_blend_alpha = ps_data.dst_blend_alpha
    ps.dst_blend_rgb = ps_data.dst_blend_rgb

    if ps_data.texture then
        ps:set_unit(TextureUnit(TextureCache.instance():get(ps_data.texture)))
    else
        ps_data:set_unit(TextureUnit.default_unit())
    end

    for _,node_data in ipairs(ps_data.ps_nodes) do
        ps:add_node(create_ps_node(ps, node_data))
    end

    if ps_data.camera then
        ps.camera = create_ps_camera(ps, ps_data.camera)
    end

    for _,emitter_data in ipairs(ps_data.emitters or {}) do
        ps:add_emitter(create_emitter(ps, emitter_data))
    end

    for _,emitter_ctrl_data in ipairs(ps_data.emitter_controllers) do
        ps:add_controller(create_emitter_controller(ps, emitter_ctrl_data))
    end

    for _,force_data in ipairs(ps_data.forces or {}) do
        ps:add_force(create_force(ps, force_data))
    end

    local death_spawner = ps_data.death_spawner and create_spawner(ps_data.death_spawner) or nil
    if death_spawner then ps:set_death_spawner(death_spawner) end

    if living_spawner then ps:set_living_spawner(living_spawner) end

    for _,collider_data in ipairs(ps_data.colliders or {}) do
        local collider = create_collider(ps, death_spawner, collider_data)
        collider.active = collider_data.active
        ps:add_collider(collider)
    end

    if ps_data.general_data then
        ps.grow_time = ps_data.general_data.grow_time
        ps.shrink_time = ps_data.general_data.shrink_time
        ps.grow_generation = ps_data.general_data.grow_generation
        ps.shrink_generation = ps_data.general_data.shrink_generation

        ps.size_loop_behavior = ps_data.general_data.size_loop_behavior
        for _,frame_data in ipairs(ps_data.general_data.size_frames or {}) do
            ps:insert_size_frame(frame_data.time, frame_data.value)
        end

        if ps_data.general_data.color_frames then
            ps.color_loop_behavior = ps_data.general_data.color_loop_behavior
            for _,frame_data in ipairs(ps_data.general_data.color_frames) do
                ps:insert_color_frame(frame_data.time, frame_data.value)
            end
        end

        if ps_data.general_data.rotation_frames then
            ps.rotation_loop_behavior = ps_data.general_data.rotation_loop_behavior
            for _,frame_data in ipairs(ps_data.general_data.rotation_frames or {}) do
                ps:insert_rotation_frame(frame_data.time, frame_data.value)
            end
        end
    end

    -- 由于旋转的存在，这里使用双面渲染
    ps.double_sided = true

    return ps
end

return create_particle_systme

end
        

package.preload[ "byui.particle" ] = function( ... )
    return require('byui/particle')
end
            

package.preload[ "byui/scroll" ] = function( ... )
local Simple = require('byui/simple_ui');
local class, mixin, super = unpack(require('byui/class'))
local anim = require('animation')
local units = require('byui/draw_res')
local AL = require('byui/autolayout')
local ui_utils = require('byui/ui_utils')
local Kinetic = require('byui/kinetic')
local utils = require('byui/utils')
local layout = require('byui/layout')


---
-- 包含了所有的滚动视图的模块.
-- @module byui.scroll
-- @extends byui#byui.scroll
-- @return #table 返回listview等类型 


local  M = {}
local ScrollBar = class('ScrollBar',BorderSprite,{
    __init__ = function (self,args)
        self.dimension = args.dimension or kVertical
        self.pos_dimension = self.dimension == kVertical and 'y' or 'x'
        self.unit = units.circle
        local tsize = self.unit.size
        self.t_border = {tsize.x/2, tsize.y/2, tsize.x/2, tsize.y/2}
        local vsize = Point(5,5)
        self.size = vsize
        self.v_border = {2.5,2.5,2.5,2.5}
        self.self_colorf = Colorf(0,0,0,0.5)
        self.zorder = 255
        self.anim = anim.Animator()
    end,
    content_size = {function ( self )
        return self._content_size
    end,function ( self,value )
        self._content_size = value
        if self.parent then
            local length = 5

            if self._content_size ~= 0 then
                length = self.parent.size[self.pos_dimension] * self.parent.size[self.pos_dimension] / self._content_size
            end
            local tmp_size = Point(5,5)
            tmp_size[self.pos_dimension] = length
            self.size = tmp_size
            if self.dimension == kVertical then
                self.pos = Point(self.parent.size.x - self.offset ,0)
            else
                self.pos = Point(0,self.parent.size.y - self.offset)
            end 
        end
    end},
    content_offset = {function ( self )
        return self._content_offset or 0
    end,function ( self,value )
        self._content_offset = value
        if self._content_size > self.parent.size[self.pos_dimension] then
            self:anim_visible(true)
            local length = (self.parent.size[self.pos_dimension])*(self.parent.size[self.pos_dimension]) / self.content_size
            local _pos = (-self._content_offset / self._content_size) * self.parent.size[self.pos_dimension]
            local tmp_size = Point(5,5)
            tmp_size[self.pos_dimension] = length

            if _pos < 0 then
                tmp_size[self.pos_dimension] = math.pow(length + _pos,3)/math.pow(length,2)
                _pos = 0 
            elseif _pos + length > self.parent.size[self.pos_dimension]   then
                tmp_size[self.pos_dimension] = math.pow(self.parent.size[self.pos_dimension]-_pos,3)/math.pow(length,2)
                _pos = self.parent.size[self.pos_dimension] - tmp_size[self.pos_dimension]
            end
            
            if tmp_size[self.pos_dimension] <= 10 then
                tmp_size[self.pos_dimension] = 10
            end 
            self.size = tmp_size
            self[self.pos_dimension] = _pos
        end
    end},
    anim_visible = function(self,status)
        if status then
            self.anim:stop()
            ui_utils.play_attr_anim(self.anim, {
            {self,"opacity", 1.0},
            }, 0.1)
        else
            self.anim:stop()
            ui_utils.play_attr_anim(self.anim, {
            {self,"opacity", 0},
            }, 0.5)
        end
    end,
    offset = {function ( self )
        return self._offset or 10
    end,function ( self,value )
        self._offset = value
        if self.dimension == kVertical then
            self.pos = Point(self.parent.size.x - self._offset ,0)
        else
            self.pos = Point(0,self.parent.size.y - self._offset)
        end
    end},
})


---
-- ScrollView，滚动视图。
-- @type byui.ScrollView
-- @extends engine#Widget 
-- @usage byui.ScrollView{dimension = kVertical,}

---
-- 创建一个ScrollView.
-- @callof #byui.ScrollView
-- @param #byui.ScrollView self 
-- @param #table args 参数列表。
--                  1.dimension:取值为kBoth,kHorizental,kVertical。表示滚动的方向。
--                  2.on_overscroll:在滚动到边沿时的回调监听。
--                  3.on_stop:滚动停止的回调监听。
--                  4.on_scroll:正常滚动的回调监听。
-- @return #byui.ScrollView 返回创建的ScrollView对象。

---
-- ScrollView，滚动视图.
-- 见@{#byui.ScrollView}。
-- @field [parent=#byui] #byui.ScrollView ScrollView 
M.ScrollView = class('ScrollView', Widget, mixin(Simple.EventHandler, {
    __init__ = function(self, args)
		super(M.ScrollView, self).__init__(self, args)
        
        ---
        -- 设置滚动方向.
        -- 可取kBoth，kHorizental，kVertical三个值，默认为kBoth
        -- @field [parent=#byui.ScrollView] #number dimension 
        self.dimension = args.dimension or kBoth        
        self._scrolling = false
        Simple.EventHandler.__init__(self, args)

        self._scroll_recognizers = {}
        self._scroll_recognizers[1] = Simple.ScrollRecognizer{
            min_distance = 10,
            callback = function(touch)
                if bit.band(self.dimension,kHorizental)  == kHorizental then
                    touch:lock(self.event_widget)
                end
            end,
            pos_dimension = 'x',
        }

        self._scroll_recognizers[2] = Simple.ScrollRecognizer{
            min_distance = 10,
            callback = function(touch)
                if bit.band(self.dimension,kVertical)  == kVertical then
                    touch:lock(self.event_widget)
                end
            end,
            pos_dimension = 'y',
        }

        self:add_recognizer(self._scroll_recognizers[1])
        self:add_recognizer(self._scroll_recognizers[2])

        self.clip = true
        self.kinetic = {}
        self.kinetic.x = Kinetic{}
        self.kinetic.y = Kinetic{}
        self.on_size_changed = function(_)
            if self.content then
                self:_on_size_changed()
            end
        end
        self.on_value_changed = function(self, h,v )
            local value = Point(math.floor(h.value), math.floor(v.value))
            local direction = value - self._content.pos
            if direction ~= Point(0,0) then
                self._scrolling = true
                self._content.pos = value
                if self._vertical_scroll_indicator and direction.y ~= 0 then
                    self._vertical_scroll_indicator.content_offset = value.y
                end
                if self._horizental_scroll_indicator and direction.x ~= 0 then
                    self._horizental_scroll_indicator.content_offset = value.x
                end
                if value.x > 0 or value.x < h.min  then
                    self:_on_overscroll(Point(value.x > 0 and value.x or value.x - h.min,0))
                elseif value.y > 0 or value.y < v.min then
                    self:_on_overscroll(Point(0,value.y > 0 and value.y or value.y - v.min))
                else
                    self:_on_overscroll(Point(0,0))
                    self:_on_scroll(value, direction, Point(h.decay.velocity,v.decay.velocity))
                end
            end
        end
        self.kinetic.x.on_value_changed = function(k)
            if bit.band(self.dimension,kHorizental)  == kHorizental then
                self:on_value_changed(self.kinetic.x,self.kinetic.y)
            end
        end
        self.kinetic.y.on_value_changed = function(k)
            if bit.band(self.dimension,kVertical)  == kVertical then
                self:on_value_changed(self.kinetic.x,self.kinetic.y)
            end
        end
        ---
        -- 当滑到边缘时的回调函数.
        -- function(self,pos)end 。
        -- @field [parent=#byui.ScrollView] #function on_overscroll 
        self.on_overscroll = args.on_overscroll
        self.on_stop = args.on_stop

        ---
        -- 滚动时的回调监听.
        -- 接受三个参数，分别为 position(内容当前滚动的位置),direction(当前滚动的方向)，velocity(当前滚动的速度)
        -- @field [parent=#byui.ScrollView] #function on_scroll
        self.on_scroll = args.on_scroll
        self.kinetic.x.on_stop = function()
            if self._horizental_scroll_indicator then self._horizental_scroll_indicator:anim_visible(false) end
            if not self.kinetic.y.decay.running then
                self:_on_stop()
            end
        end
        self.kinetic.y.on_stop = function()
            if self._vertical_scroll_indicator then self._vertical_scroll_indicator:anim_visible(false) end
            if not self.kinetic.x.decay.running then
                self:_on_stop()
            end
        end

        --
        self._focus = false

        self.min_distance = args.min_distance or Point(10,10)
    end,
    min_distance = {function ( self )
        return Point(self._scroll_recognizers[1].min_distance,self._scroll_recognizers[2].min_distance)
    end,function ( self,v )
        if not v then
            return 
        end
        self._scroll_recognizers[1].min_distance = v.x or 10
        self._scroll_recognizers[2].min_distance = v.y or 10
    end},
    _on_scroll = function(self, p, d, v)
        if self.on_scroll then
            self:on_scroll(p, d, v)
        end
    end,
    _on_overscroll = function ( self,p )
        if self.on_overscroll then
            self:on_overscroll(p)
        end
    end,
    ---
    -- 滚动的内容
    -- @field [parent=#byui.ScrollView] engine#Widget content 
    content = {function(self)
        return self._content
    end, function(self, w)
        if self._content then
            self._content:remove_from_parent()
        end
        self._content = w
        self:add(w)

        self._content.on_content_bbox_changed = function(_)
            if self._vertical_scroll_indicator then self._vertical_scroll_indicator.content_size = self._content.content_bbox.h end 
            if self._horizental_scroll_indicator then self._horizental_scroll_indicator.content_size = self._content.content_bbox.w end 
            self.kinetic.x.max = 0
            self.kinetic.y.max = 0
            if bit.band(self.dimension,kHorizental)  == kHorizental then
                self.kinetic.x.min = -(self._content.content_bbox.w - self.width)
            end
            if bit.band(self.dimension,kVertical) == kVertical then
                self.kinetic.y.min = -(self._content.content_bbox.h - self.height)
            end
        end

        self._content:on_content_bbox_changed()
    end},
    on_touch_down = function(self, p, t)
        if not self.content then
            return
        end
        if Simple.share_menu_controller()._menu_visible then
            Simple.share_menu_controller():set_menu_visible(false,false)
        elseif self.focus then
            Simple.share_keyboard_controller().keyboard_status = false
            ui_utils.set_focus(nil)
        end
        self.need_capture = self._scrolling
        if bit.band(self.dimension,kHorizental)  == kHorizental then
            self.kinetic.x.value = self._content.x
            self.kinetic.x:start(p.x, t)
        end
        if bit.band(self.dimension,kVertical) == kVertical then
            self.kinetic.y.value = self._content.y
            self.kinetic.y:start(p.y, t)
        end
    end,
    on_touch_move = function(self, p, t)
        if not self.content then
            return
        end
        if bit.band(self.dimension,kHorizental) == kHorizental then
            self.kinetic.x:update(p.x, t)
        end
        if bit.band(self.dimension,kVertical) == kVertical then
            self.kinetic.y:update(p.y, t)
        end
    end,
    on_touch_up = function(self, p, t)
        if not self.content then
            return
        end
        if bit.band(self.dimension,kHorizental) == kHorizental then
            self.kinetic.x:stop(p.x, t)
        end
        if bit.band(self.dimension,kVertical) == kVertical then
            self.kinetic.y:stop(p.y, t)
        end
    end,
    on_touch_cancel = function(self, p, t)
        if not self.content then
            return
        end
        if bit.band(self.dimension,kHorizental) == kHorizental then
            self.kinetic.x:cancel()
        end
        if bit.band(self.dimension,kVertical) == kVertical then
            self.kinetic.y:cancel()
        end
        
        if self._horizental_scroll_indicator then 
            self._horizental_scroll_indicator:anim_visible(false) 
        end
        if self._vertical_scroll_indicator then 
            self._vertical_scroll_indicator:anim_visible(false) 
        end
    end,
    ---
    -- 滚动视图到指定的位置.
    -- @function [parent=#byui.ScrollView] scroll_to
    -- @param engine#Point target 滚动到的目标位置。
    -- @param #number duration 滚动所需要的时间，默认值为0.25
    -- @param #function callback 本次scroll_to结束后的回调，如果此回调存在，则会执行完此回调后再执行 @{#byui.ScrollView.on_stop} 的回调。**每一次的scroll_to 回调会在回调函数执行后自动销毁，并不会被保存**。
    scroll_to = function(self, target,duration,callback)
        self.kinetic.x:scroll_to(target.x,duration)
        self.kinetic.y:scroll_to(target.y,duration)    
        self._scroll_to_callback = callback
    end,
    ---
    -- 滚动视图到底部.
    -- @function [parent=#byui.ScrollView] scroll_to_bottom
    -- @param #number duration 滚动所需要的时间，默认值为0.25
    -- @param #function callback 参见 @{#byui.ScrollView.scroll_to}
    scroll_to_bottom = function(self,duration,callback)
        self.kinetic.y:scroll_to(self.kinetic.y.min,duration,callback)    
    end,
    ---
    -- 滚动视图到顶部.
    -- @function [parent=#byui.ScrollView] scroll_to_top
    -- @param #number duration 滚动所需要的时间，默认值为0.25
    -- @param #function callback 参见 @{#byui.ScrollView.scroll_to}
    scroll_to_top = function(self,duration,callback)
        self.kinetic.y:scroll_to(self.kinetic.y.max,duration,callback)
    end,
    ---
    -- 滚动视图到最左边.
    -- @function [parent=#byui.ScrollView] scroll_to_left
    -- @param #number duration 滚动所需要的时间，默认值为0.25
    -- @param #function callback 参见 @{#byui.ScrollView.scroll_to}
    scroll_to_left = function(self,duration,callback)
        self.kinetic.x:scroll_to(self.kinetic.x.max,duration,callback)
    end,
    ---
    -- 滚动视图到最右边.
    -- @function [parent=#byui.ScrollView] scroll_to_right
    -- @param #number duration 滚动所需要的时间，默认值为0.25
    -- @param #function callback 参见 @{#byui.ScrollView.scroll_to}
    scroll_to_right = function(self,duration,callback)
        self.kinetic.x:scroll_to(self.kinetic.x.min,duration,callback)
    end,
    ---
    -- 显示垂直滚动条.
    -- 只有@{#byui.ScrollView.content}存在时才能生效。
    -- @field [parent=#byui.ScrollView] #boolean shows_vertical_scroll_indicator 
    shows_vertical_scroll_indicator = {function( self)
        return self.__shows_vertical_scroll_indicator
    end,function ( self ,v )
        if v then
            self.__shows_vertical_scroll_indicator = true
            if not self._vertical_scroll_indicator then
                self._vertical_scroll_indicator = ScrollBar{dimension = kVertical }
                self._vertical_scroll_indicator.opacity = 0.0
                self:add(self._vertical_scroll_indicator)
                if self._content then
                    self._vertical_scroll_indicator.content_size = self._content.content_bbox.h
                end
            end
        else
            self.__shows_vertical_scroll_indicator = false
            if self._vertical_scroll_indicator then
                self._vertical_scroll_indicator:remove_from_parent()
                self._vertical_scroll_indicator = nil
            end
        end
    end
    },
    ---
    -- 显示水平滚动条.
    -- 只有@{#byui.ScrollView.content}存在时才能生效。
    -- @field [parent=#byui.ScrollView] #boolean shows_horizental_scroll_indicator 
    shows_horizental_scroll_indicator = {function( self)
        return self.__shows_horizental_scroll_indicator
    end,function ( self ,v )
        if v then
            self.__shows_horizental_scroll_indicator = true
            if not self._horizental_scroll_indicator then
                self._horizental_scroll_indicator = ScrollBar{dimension = kHorizental }
                self._horizental_scroll_indicator.opacity = 0.0
                self:add(self._horizental_scroll_indicator)
                if self._content then
                    self._horizental_scroll_indicator.content_size = self._content.content_bbox.w
                end
            end
        else
            self.__shows_horizental_scroll_indicator = false
            if self._horizental_scroll_indicator then
                self._horizental_scroll_indicator:remove_from_parent()
                self._horizental_scroll_indicator = nil
            end
        end
    end
    },
    ---
    -- 滚动停止时的回调.
    -- @field [parent=#byui.ScrollView] #function on_stop 
    _on_stop = function(self)
        self._scrolling = false
        self.need_capture = false
        if self._scroll_to_callback then
            self:_scroll_to_callback()
            self._scroll_to_callback = nil
        end
        if self.on_stop then
            self:on_stop()
        end
    end,
    _on_size_changed = function ( self )
        if self._vertical_scroll_indicator then self._vertical_scroll_indicator.content_size = self._content.content_bbox.h end 
        if self._horizental_scroll_indicator then self._horizental_scroll_indicator.content_size = self._content.content_bbox.w end 
        self.kinetic.y.min = -(self._content.content_bbox.h - self.height)
        self.kinetic.x.min = -(self._content.content_bbox.w - self.width)
    end,
    ---
    -- 设置是否吞噬键盘输入事件.
    -- @field [parent=#byui.ScrollView] #boolean focus
    focus = {function ( self )
        return self._focus 
    end,function ( self ,v)
        self._focus = v
    end},
    ---
    -- 设置滚动的速度系数.
    -- 默认值为1，系数越高滚动的速度越快，系数越低，滚动的速度越慢。
    -- @field [parent=#byui.ScrollView] #number velocity_factor
    velocity_factor = {function ( self )
        return self._velocity_factor or 1 
    end,function ( self,value )
        self.kinetic.y.velocity_factor = value
        self.kinetic.x.velocity_factor = value
    end},
    ---
    -- 设置边缘回弹的阻尼系数.
    -- 默认值为0.02，系数越低滚动的内容离开边缘的距离越远。
    -- @field [parent=#byui.ScrollView] #number viscosity
    viscosity = {function ( self )
        return self._viscosity or 1/20 
    end,function ( self,value )
        self.kinetic.y.viscosity = value
        self.kinetic.x.viscosity = value
    end},
    on_exit = function ( self )
        self.kinetic.x:cancel()
        self.kinetic.y:cancel()
    end,
    ---
    -- 当前ScorllView 是否有滚动.
    -- 当ScorllView在滚动时返回true,静止时返回false。
    -- @field [parent=#byui.ScrollView] #boolean is_scrolling
    is_scrolling = {function ( self )
        return self._scrolling
    end}
}))


-- attribute
--      max_number
--
-- data source delegate
--      create_cell
--

---
-- 翻页滚动视图.
-- 继承自@{#byui.ScrollView}。
-- @type byui.PageView
-- @extends byui#byui.ScrollView
-- @usage local pageview = byui.PageView{dimension = kVertical}

---
-- 创建一个PageView.
-- @callof #byui.PageView
-- @param #byui.PageView self 
-- @param #table args 参数列表。
--                  1.dimension:取值为kHorizental,kVertical。表示滚动的方向。
--                  2.max_number:显示的最大页面数量。
--                  3.create_cell:创建item的函数。
--                  4.size:PageView的大小。
-- @return #byui.PageView 返回创建的PageView对象.

---
-- 翻页滚动视图.
-- 见@{#byui.PageView}。
-- @field [parent=#byui] #byui.PageView PageView 
M.PageView = class('PageView', M.ScrollView, {
    __init__ = function(self, args)
        args.dimension = args.dimension == kHorizental and kHorizental or kVertical 
        super(M.PageView, self).__init__(self, args)
        self.pos_dimension = args.dimension == kVertical and 'y' or 'x'
        self.container = Widget()

        self.container.relative = true
        self.content = self.container
        self.content:add_rules(AL.rules.fill_parent)
        -- item manage
        self.max_number = args.max_number or 1 
        self.create_cell = args.create_cell
        self._cached_items = {}

        
        self.__page_num = 1
        -- load first and second page

        self.__begin_change = false

        self.is_cache = args.is_cache 
        
        self.size = args.size or Point(0,0)
    end,
    ---
    -- 创建item的回调函数.
    -- function(data) -- block return　Widget end<br/>
    -- 会接收一个数据参数，需要返回一个widget对象。
    -- @field [parent=#byui.PageView] #function create_cell
    create_cell = {function ( self )
        return self._create_cell
    end,function ( self,value )
        self._create_cell = value
    end},
    ---
    -- 更新数据后主动通知PageView去更新.
    -- @function [parent=#byui.PageView] update_data
    -- @param #byui.PageView self 
    update_data = function ( self )
        if self.is_cache then
            for i=1,self.max_number do
                self:__create_view(i)
            end
        else
            self.page_num = self.page_num
        end
    end,
    ---
    -- 最大页面数.
    -- @field [parent=#byui.PageView] #number max_number 
    max_number = {function(self)
        return self._max_number
    end, function(self, v)
        if self._max_number ~= v then
            self._max_number = v
            if self.dimension == kVertical then
                self.container.size = Point(self.size.x, self.max_number * self.size[self.pos_dimension])
            else
                self.container.size = Point(self.max_number * self.size[self.pos_dimension], self.size.y)
            end
        end
    end},
    ---
    -- 当前显示的页面.
    -- @field [parent=#byui.PageView] #number page_num 
    page_num = {function ( self )
        return self.__page_num
    end,function ( self , v )
        if v >= self.max_number then
            v = self.max_number
        elseif v < 1 then
            v = 1
        end
        self.__page_num = math.ceil(v)
    
        local target = Point(0,0)
        target[self.pos_dimension] = -(self.__page_num - 1) * self.size[self.pos_dimension]
        self.__begin_change = true
        super(M.PageView, self):scroll_to(target,0.5) 
        if self._cached_items[self.__page_num] == nil then
            for i=self.page_num -1,self.page_num + 1 do
                if self._cached_items[i] == nil then
                    self:__create_view(i)  
                end
            end
        end
    end
    },
    ---
    -- 显示上一页.
    -- @function [parent=#byui.PageView] prev_page
    -- @param #byui.PageView self 
    prev_page = function ( self )
        if  self.page_num == 1 then
            return 
        end
        self:__create_view(self.page_num - 2)  
        self:__free_view(self.page_num + 1)
        self.page_num = self.page_num -1
    end,
    ---
    -- 显示下一页.
    -- @function [parent=#byui.PageView] next_page
    -- @param #byui.PageView self 
    next_page = function ( self )
        if  self.page_num == self.max_number then
            return 
        end
        self:__create_view(self.page_num + 2)
        self:__free_view(self.page_num -1)
        self.page_num = self.page_num + 1
    end,
    __create_view = function ( self,idx )
        if idx > 0 and idx <= self.max_number and self._cached_items[idx] == nil then
            local cell = self:create_cell(idx)
            cell.size = self.size 
            cell[self.pos_dimension] = (idx-1) * (self.size[self.pos_dimension])
            self._cached_items[idx] = cell
            self.container:add(cell)
        end
    end,
    __free_view = function ( self,idx )
        if self._cached_items[idx] ~= nil and not self.is_cache then
            self._cached_items[idx]:remove_from_parent()
            self._cached_items[idx] = nil
        end
    end,
    on_touch_up = function ( self, p,t )
        -- body
        super(M.PageView, self).on_touch_up(self,p,t)
        if  math.abs(self.kinetic[self.pos_dimension].velocity) > 100 then
            if self.kinetic[self.pos_dimension].velocity > 0 then
                self:prev_page()
            else
                self:next_page()
            end
        else
            if math.ceil(self.kinetic[self.pos_dimension].value / -self.size[self.pos_dimension] + 0.5)   < self.page_num then
                self:prev_page()
            elseif math.ceil(self.kinetic[self.pos_dimension].value / -self.size[self.pos_dimension]+ 0.5) > self.page_num then
                self:next_page()
            else
                self.page_num = self.page_num
            end
        end
    end,
    _on_size_changed = function ( self )
        super(M.PageView, self)._on_size_changed(self)
        if self.pos_dimension == kVertical then
            self.content.size = Point(self.width,self.height*self.max_number)
        else 
            self.content.size = Point(self.width*self.max_number,self.height)
        end
        if self.is_cache then
            for i=1,self.max_number do
                if self._cached_items[i] ~= nil then
                    self._cached_items[i].size = self.size
                    self._cached_items[i][self.pos_dimension] = (i-1) * (self.size[self.pos_dimension])
                end
            end
        else
            for i=self.page_num -1,self.page_num + 1 do
                if self._cached_items[i] ~= nil then
                    self._cached_items[i].size = self.size
                    self._cached_items[i][self.pos_dimension] = (i-1) * (self.size[self.pos_dimension])
                end
            end
        end
        
    end,
    _on_page_change = function (self)
        ---
        -- 监听页面变化.
        -- 当显示的页面发生改变时会回调此方法，传递当前的页面.当滚动到不同页面或者手动的跳转到某一页都会引起此回调的变化.
        -- @field [parent=#byui.PageView] #function on_page_change 
        -- @usage 
        -- function page_view:on_page_change( value )
        --        print("当前显示的页面",value)
        -- end
        if self.on_page_change then
            self:on_page_change(self.page_num)
        end
    end,
    _on_stop = function ( self )
        super(M.PageView, self)._on_stop(self)
        if self.__begin_change then
            self.__begin_change = false
            self:_on_page_change()
        end
    end
})

-- attribute
--      current_page
--      number_of_pages

---
-- 控制PageView控件.
-- 可以显示小圆点来提示现在PageView所在的页面以及页面的总数。
-- @type byui.PageControl
-- @extends engine#Widget

---
-- 创建一个PageControl.
-- @callof #byui.PageControl
-- @param #byui.PageControl self 
-- @param #table args 参数列表。
--                  1.dimension:取值为kHorizental,kVertical。表示滚动的方向。
--                  2.number_of_pages:页面的数量。
--                  3.hides_for_single_page:只有一个页面时是否自动隐藏。
-- @return #byui.PageControl 返回创建的PageControl对象.

---
-- 控制PageView控件.
-- 见@{#byui.PageControl}。
-- @field [parent=#byui] #byui.PageControl PageControl 
M.PageControl = class('PageControl', Widget, mixin(Simple.EventHandler,{
    __init__ = function(self, args)
        super(M.PageControl, self).__init__(self, args)
        ---
        -- 需要控制的PageView的滚动方向.
        -- 可取kVertical,kHorizental。
        -- @field [parent=#byui.PageControl] #number
        self.dimension = args.dimension  or kVertical 
        self.pos_dimension = self.dimension == kVertical and 'y' or 'x'
        self._page_view  = args.page_view 
        
        self._page_indicator_tint_color = args.page_indicator_tint_color or Colorf(0.5,0.5,0.5,0.5)
        self._current_page_indicator_tint_color = args.current_page_indicator_tint_color or Colorf(1.0,1.0,1.0,1.0)
        self._images = {}
        self._images[1] = Simple.Image(self._page_indicator_tint_color)
        self._images[2] = Simple.Image(self._current_page_indicator_tint_color)


        self._items = {}
        self.number_of_pages = args.number_of_pages or 0
        self._hides_for_single_page = args.hides_for_single_page or false
        Simple.EventHandler.__init__(self, args)
        
        self.on_size_changed = function ( _ )
            for i,v in ipairs(self._items) do
                local temp_pos = Point(14,14)
                temp_pos[self.pos_dimension] = (i-1)*15 + 4
                v.pos = temp_pos
                v[self.pos_dimension] = v[self.pos_dimension]  + (self.size[self.pos_dimension] - self.number_of_pages * 15)/2
            end
        end
    end,
    _create_items = function ( self )
        for i,v in ipairs(self._items) do
            v:remove_from_parent()
            v = nil
        end
        for i=1,self.number_of_pages do
            local item = Sprite()
            item.size = Point(8,8)
            local temp_pos = Point(14,14)
            temp_pos[self.pos_dimension] = (i-1)*15 + 4
            item.pos = temp_pos
            self._images[1]:apply(item)
            item.v_border = {4, 4, 4, 4}
            self._items[i] = item
            self:add(item)
        end
        if self._items[self._current_page] then
            self._images[2]:apply(self._items[self._current_page])
        end
    end,
    ---
    -- 当前显示的页面.
    -- @field [parent=#byui.PageControl] #number current_page 
    current_page = {function ( self )
        return self._current_page or 1
    end,function ( self,value )
        assert(value >= 1 and value <= self.number_of_pages,"current_page is error ")
        if self._current_page ~= value then
            self._images[1]:apply(self._items[self._current_page])
            self._current_page =  value
            self._images[2]:apply(self._items[self._current_page])
        end
    end},
    ---
    -- 页面的总数.
    -- @field [parent=#byui.PageControl] #number number_of_pages 
    number_of_pages = {function ( self )
        return self._number_of_pages
    end,function ( self,value )
        if self._number_of_pages ~= value then
            self._number_of_pages = value
            self._current_page = self._current_page or 1
            self:_create_items()
        end 
    end},
    ---
    -- 只有一个页面时是否自动隐藏.
    -- @field [parent=#byui.PageControl] #boolean hides_for_single_page 
    hides_for_single_page = {function ( self )
        return self._hides_for_single_page 
    end,function ( self,value )
        self._hides_for_single_page = value
        if self.number_of_pages == 1 and self._hides_for_single_page then
            self._items[1].visible = false
        elseif self.number_of_pages > 1 or not self._hides_for_single_page then
            self._items[1].visible = true
        end
    end},
    on_touch_down = function ( self,p,t )
        self.need_capture = true
    end,
    on_touch_move = function ( self,p,t )
    end,
    on_touch_up = function ( self,p,t )
        local point = self:from_world(p)
        if self._page_view then
            if point[self.pos_dimension] < self._items[self._current_page][self.pos_dimension] then
                self._page_view:prev_page()
            else
                self._page_view:next_page()
            end
        end
    end,
    on_touch_cancel = function (self,p,t )
    end,
}))

---
-- ListView，单列滚动容器.
-- 继承自@{#byui.ScrollView}。
-- @type byui.ListView
-- @extends byui#byui.ScrollView
-- @usage byui.ListView{dimension = kVertical,
--                      cell_spacing = 5,
--                      }


---
-- 创建一个ListView.
-- @callof #byui.ListView
-- @param #byui.ListView self 
-- @param #table args 参数列表。
--                  1.dimension:取值为kHorizental,kVertical。表示滚动的方向。
--                  2.cell_spacing:item的间距。
--                  3.create_cell:创建item的函数。
--                  4.size:ListView的大小。
--                  5.update_cell:更新item的函数。
--                  6.data:创建item的数据。
-- @return #byui.ListView 返回创建的ListView对象.

---
-- ListView，滚动视图.
-- 见@{#byui.ListView}。
-- @field [parent=#byui] #byui.ListView ListView 
local _top_rules = {AL.top:eq(0), AL.left:eq(0)}
local _bottom_rules = {AL.right:eq(AL.parent('width')), AL.bottom:eq(AL.parent('height'))}
M.ListView = class('ListView', M.ScrollView, {
    __init__ = function(self, args)
        args.dimension = args.dimension == kHorizental and kHorizental or kVertical 
        super(M.ListView, self).__init__(self, args)
        self.pos_dimension = args.dimension == kVertical and 'y' or 'x'
        self.container = layout.FloatLayout{spacing = Point(0,0),dimension = args.dimension}
        self.container.relative = true
        self.content = self.container
        self.content:add_rules(AL.rules.fill_parent)

        -- item manage
        self.row_height = args.row_height
        self.cell_spacing = args.cell_spacing or 0
        


        self.data = args.data or {}
        ---
        -- 创建item的回调函数.
        -- function(data) -- block return　Widget end<br/>
        -- 会接收一个数据参数，需要返回一个widget对象。
        -- @field [parent=#byui.ListView] #function create_cell
        self.create_cell = args.create_cell
        
        
        ---
        -- 更新item的回调函数.
        -- function(item ,data) -- block end<br/>
        -- 会接收一个需要更新的item和更新后的数据。你调用@{#byui.ListView.update} 时会触发，如果@{#byui.ListView.update_cell}
        -- 不存在则会删除之前的item调用@{#byui.ListView.create_cell}
        -- @field [parent=#byui.ListView] #function update_cell
        self.update_cell = args.update_cell
        
        
        ---
        -- 用于下/右拉刷新时添加UI的顶部/左边容器.
        -- @field [parent=#byui.ListView] engine#Widget top_view
        self.top_view = Widget()
        self.top_view.visible = false
        self:add(self.top_view)

        ---
        -- 用于上/左拉刷新时添加UI的底部/右边容器.
        -- @field [parent=#byui.ListView] engine#Widget bottom_view
        self.bottom_view = Widget()
        self.bottom_view.visible = false
        self:add(self.bottom_view)
        
        
        self.distance_to_refresh = args.distance_to_refresh or 0

        self.top_view:add_rules(_top_rules)
        self.bottom_view:add_rules(_bottom_rules)

        self.size = args.size or Point(0,0)
---
-- 刷新事件回调函数.
-- function(flag)end<br/>
-- 当falg == true 是表示下拉刷新，当flag == false时表示上拉刷新
-- @field [parent=#byui.ListView] #function on_refresh .

    end,
    _init_view = function ( self )
        if self.data then
            for i=1,#self.data do
                local cell = self:get_view(i)
                assert(cell,'item of '..i.. 'does not exist')
                self.container:add(cell)
            end
        end
    end,
    ---
    -- item之间的间隔. 
    -- number类型，可读可写
    -- @field [parent=#byui.ListView] #number cell_spacing  

    cell_spacing = {function(self)
        return self._item_space
    end,function (self,value)
        if self._item_space ~= value then
            self._item_space = value
            local space_temp = Point(0,0)
            space_temp[self.pos_dimension] = value
            self.container.spacing = space_temp
        end
    end},
    _on_changed_data = function ( self )
        -- 数据改变时回调
        self.container:remove_all()
        self:_init_view()
    end,
    _on_update_data = function ( self ,index,data_item)
        -- 更新数据时回调
        local item = self.container.children[index]
        if self.update_cell then
            self.update_cell(item,data_item)
        else
            self.container:remove(item)
            self:_on_insert_data(index)
        end
    end,
    _on_delete_data = function ( self,index )
        -- body
        local item = self.container.children[index]
        if item then
            self.container:remove(item)
        end
    end,
    _on_insert_data = function ( self,index )
        local cell = self:get_view(index)
        assert(cell ~= nil,'item of '..index.. 'does not exist')
        local refer_cell = self.container.children[index]
        self.container:add(cell,refer_cell)
    end,
    ---
    -- listview的数据. 
    -- table类型，可读可写
    -- @field [parent=#byui.ListView] #table data 
    data = {function (self)
        return self._data
    end,function(self,value)
        assert(value ~= nil,'the data is nil.')
        assert(type(value) == 'table','the data type must be a table.')
        self._data = value
        self:_on_changed_data()
    end},
    ---
    -- listview的更新数据接口. 
    -- 如果@{#byui.ListView.update_cell} 存在则会调用此方法，否则会调用@{#byui.ListView.create_cell}。
    -- @function [parent=#byui.ListView] update_item
    -- @param #byui.ListView self 
    -- @param #number index 指定需要更新的item索引
    -- @param #table data_item 新数据
    -- @usage local listview = byui.ListView{}
    --        listview:update_item(1,{height = 100})
    update_item = function (self,index,data_item)
        assert(index > 0 and index <= self.cell_size,"invalid index:" .. tostring(index))
        self.data[index] = data_item
        self:_on_update_data(index,data_item)
    end,
    ---
    -- listview的删除数据接口.
    -- 你可以删除一条listview里面的数据，从而删除对应的item，listview会自动重新排布item。
    -- @function [parent=#byui.ListView] delete
    -- @param #byui.ListView self 
    -- @param #number index 指定需要删除的索引
    -- @usage local listview = byui.ListView{}
    --        listview:delete(1)
    delete = function ( self,index )
        assert(index > 0 and index <= self.cell_size,"invalid index:" .. tostring(index))
        table.remove(self.data,index)
        self:_on_delete_data(index)
    end,
    ---
    -- listview的插入数据接口.
    -- 你可以删除一条listview里面的数据，从而删除对应的item，listview会自动重新排布item。
    -- @function [parent=#byui.ListView] delete
    -- @param #byui.ListView self 
    -- @param #number index 指定需要插入的索引
    -- @usage local listview = byui.ListView{}
    --        listview:delete(1)
    insert = function ( self,item,index)
        if #self.data ~= 0 then
            assert(index == nil or (index > 0 and index <= self.cell_size),"invalid index:" .. tostring(index))
        end
        if index then
            table.insert(self.data,index,item)
        else
            table.insert(self.data,item)
            index = #self.data
        end
        self:_on_insert_data(index)
    end,
    get_view = function ( self,index )
        assert(self.data[index] ~= nil and type(self.data[index]) == 'table',"the data of ".. tostring(index) .." is invalid." )
        local widget = self.create_cell(self.data[index],index)
        widget:initId()
        return widget
    end,
    on_touch_down = function ( self, p, t )
        -- body
        super(M.ListView, self).on_touch_down(self,p,t)
        self._refresh_length = 0
    end,
    on_touch_up = function ( self, p, t)
        -- body
        super(M.ListView, self).on_touch_up(self,p,t)
        if self._refresh_length > 0 then
            if self._refresh_length > self.distance_to_refresh then
                self.top_view.visible = true
                self.kinetic[self.pos_dimension].max = self.distance_to_refresh
                if self.on_refresh then
                    self.refresh_mode = true
                    self._length = self.cell_size
                    self.on_refresh(self.refresh_mode)
                end
            end
        elseif self._refresh_length < 0 then
            if math.abs(self._refresh_length) > self.distance_to_refresh then
                self.bottom_view.visible = true
                self._real_min = -(self._content.content_bbox.w - self.width)
                if self.pos_dimension == 'x' then
                    self._real_min = -(self._content.content_bbox.w - self.width)
                else
                    self._real_min = -(self._content.content_bbox.h - self.height)
                end
                self.kinetic[self.pos_dimension].min = self._real_min - self.distance_to_refresh
                if self.on_refresh then
                    self.refresh_mode = false
                    self._length = self.cell_size
                    self.on_refresh(self.refresh_mode)
                end
            end
        end

    end,
    _on_overscroll = function ( self,p)
        -- body
        self._refresh_length = p[self.pos_dimension]
        super(M.ListView,self)._on_overscroll(self,p)
    end,
    ---
    -- 触发刷新的阀值.
    -- number类型，可读可写。
    -- @field [parent=#byui.ListView] #number distance_to_refresh
    distance_to_refresh = {function ( self )
        return self._distance_to_refresh or 0
    end,function ( self,value )
        if not self._scrolling then
            self._distance_to_refresh = value > 0 and value or 0
            local temp_size = self.size
            temp_size[self.pos_dimension] = self._distance_to_refresh
            
            self.top_view.size_hint = temp_size
            self.bottom_view.size_hint = temp_size
        end
    end},
    _on_size_changed = function ( self )
        super(M.ListView, self)._on_size_changed(self)
        local temp_size = self.size

        temp_size[self.pos_dimension] = self.distance_to_refresh
        
        self.top_view.size_hint = temp_size
        self.bottom_view.size_hint = temp_size

    end,
    ---
    -- 清除刷新状态
    -- 在@{#byui.ListView.on_refresh}调用完后你应该调用此方法，清除Listview的刷新状态。
    -- @function [parent=#byui.ListView] refresh_end
    -- @param #byui.ListView self 
    -- @param #number time 在刷新结束时未插入数据时生效，如果未插入数据，time表示内容恢复回正常状态的时间。默认时间为0.25s。
    -- <p>
    -- <table align="justify" style="border-spacing: 20px 5px; border-collapse: separate">
    -- <tr>
    --     <td align="center" style="border-style: none;">self:refresh_end(0.25)</td>
    --     <td align="center" style="border-style: none;">self:refresh_end(0.0)</td></tr>
    -- <tr>
    -- <td><img height="564" width="426" src="http://engine.by.com:8080/hosting/data/1476243236361_4125995731407480904.gif"></td>
    -- <td><img height="564" width="426" src="http://engine.by.com:8080/hosting/data/1476243256610_2045987965875567317.gif"></td>
    -- </tr>
    -- </table>
    -- </p> 
    refresh_end = function ( self ,time)
        self.top_view.visible = false
        self.bottom_view.visible = false

        time = tonumber(time) or 0.25

        self.enabled = true
        if self.refresh_mode then
            local index = self.cell_size - self._length + 1
            if index == 1 then
                self:_reset_kinetic(true,time)
                return
            end
            self.container:update()
            local item = self.container.children[index]
            
            local offset = item.pos
            offset = offset*(-1)
            offset[self.pos_dimension] = offset[self.pos_dimension] + self.distance_to_refresh
            
            self.content.pos = offset
        else
            local index = self._length
            if index == self.cell_size then
                self:_reset_kinetic(false,time)
                return
            end
        end
    end,
    _reset_kinetic = function ( self, flag,time)
        if not self._anim then
                self._anim = anim.Animator()
            end
        if flag then
            self._anim:start(anim.duration(time,anim.value(self.kinetic[self.pos_dimension].max,0)),function ( v )
                    self.kinetic[self.pos_dimension].max = v
                end)
        else
            self._anim:start(anim.duration(time,anim.value(self.kinetic[self.pos_dimension].min,self._real_min)),function ( v )
                    self.kinetic[self.pos_dimension].min = v
                end)
        end
    end,
    on_exit = function ( self )
        if self._anim then
            self._anim:stop()
            self._anim = nil
        end
        super(M.ListView, self).on_exit(self)
    end,
    cell_size = {function ( self )
        if self.container.length then
            return self.container.length
        else
            return #self.container.children
        end
    end},

})
return M

end
        

package.preload[ "byui.scroll" ] = function( ... )
    return require('byui/scroll')
end
            

package.preload[ "byui/simple_ui" ] = function( ... )
local M = {}
require('byui/utils')
local class, mixin, super = unpack(require('byui/class'))
local anim = require('animation')
local units = require('byui/draw_res')
local AL = require('byui/autolayout')
local ui_utils = require('byui/ui_utils')
local Kinetic = require('byui/kinetic')

---
-- 基础控件.
-- @module byui.simple_ui
-- @extends byui#byui.simple_ui 
-- @return #table  

---
-- 带阴影圆角矩形.
-- @type byui.RoundedView
-- @extends engine#BorderSprite 

---
-- 创建一个带阴影圆角矩形的实例.
-- @callof #byui.RoundedView
-- @return #byui.RoundedView 返回创建的圆角矩形的实例.
-- @usage local s = RoundedView()
--    s.pos = Point(100,100)
--    s.size = Point(20,100)
--    s.radius = 5
--    s.need_box = false
--    s.need_shadow = true
--    s.shadow_colorf = Colorf(1.0,0.0,0.0,1.0)
--    s.shadow_offset = Point(5,5)
--    s.shadow_margin = 5

M.RoundedView = class('RoundedView', BorderSprite, {
    __init__ = function(self)
        super(M.RoundedView, self).__init__(self)
        self._colorf = Colorf.white
        self._radius = 0
        self._shadow_margin = 0
        self._shadow_offset = Point(0,0)
        self._need_shadow = false
        self._need_box = true
        self._colorf = Colorf.white
        self._shadow_colorf = Colorf.black
        self:_update_widget()
    end,
    _update_widget = function(self)
        if self._need_shadow and self._need_box then
            if self._extra_widget == nil then
                self._extra_widget = BorderSprite()
                self:add(self._extra_widget)
            end
        else
            if self._extra_widget ~= nil then
                self._extra_widget:remove_from_parent()
                self._extra_widget = nil
            end
        end
        if self._extra_widget then
            -- setup rules
            self._extra_widget.rules = {}
            self._extra_widget:add_rules{
                -- position
                AL.centerx:eq(AL.parent('width')/2-self._shadow_offset.x),
                AL.centery:eq(AL.parent('height')/2-self._shadow_offset.y),
                -- size
                AL.width:eq(AL.parent('width')-self._shadow_margin * 2),
                AL.height:eq(AL.parent('height')-self._shadow_margin * 2),
            }
            self._extra_widget:update_constraints()
        end
        if self._need_shadow and self._need_box then
            self.visible = true
            -- apply shadow attributes to self
            self.unit = units.shadow
            self.t_border = ui_utils.default_t_border(units.shadow)
            self.v_border = {self._radius, self._radius, self._radius, self._radius}
            super(M.RoundedView, self).self_colorf = self._shadow_colorf

            -- apply box attributes to extra_widget
            self._extra_widget.unit = units.circle
            self._extra_widget.t_border = ui_utils.default_t_border(units.circle)
            self._extra_widget.v_border = {self._radius, self._radius, self._radius, self._radius}
            self._extra_widget.self_colorf = self._colorf
        elseif self._need_box then
            self.visible = true
            -- apply box attribute to self
            self.unit = units.circle
            self.t_border = ui_utils.default_t_border(units.circle)
            self.v_border = {self._radius, self._radius, self._radius, self._radius}
            super(M.RoundedView, self).self_colorf = self._colorf
        elseif self._need_shadow then
            self.visible = true
            -- apply shadow attribute to self
            self.unit = units.shadow
            self.t_border = ui_utils.default_t_border(units.shadow)
            self.v_border = {self._radius, self._radius, self._radius, self._radius}
            super(M.RoundedView, self).self_colorf = self._shadow_colorf
        else
            self.visible = false
        end
    end,
    
    ---
    -- 自身的颜色.
    -- @field [parent=#byui.RoundedView] engine#Colorf self_colorf 
    self_colorf = {function(self)
        return self._colorf
    end, function(self, c)
        if self._colorf ~= c then
            self._colorf = c
            self:_update_widget()
        end
    end},
    
    ---
    -- 阴影的颜色.
    -- @field [parent=#byui.RoundedView] engine#Colorf shadow_colorf 
    shadow_colorf = {function(self)
        return self._shadow_colorf
    end, function(self, c)
        if self._shadow_colorf ~= c then
            self._shadow_colorf = c
            self:_update_widget()
        end
    end},
    
    ---
    -- 是否显示前景.
    -- 默认为true。如果设置为false则只会显示阴影。
    -- @field [parent=#byui.RoundedView] #boolean need_box
    need_box = {function(self)
        return self._need_box
    end, function(self, b)
        if self._need_box ~= b then
            self._need_box = b
            self:_update_widget()
        end
    end},
    
    ---
    -- 是否显示阴影.
    -- @field [parent=#byui.RoundedView] #boolean need_shadow
    need_shadow = {function(self)
        return self._need_shadow
    end, function(self, b)
        if self._need_shadow ~= b then
            self._need_shadow = b
            self:_update_widget()
        end
    end},
    
    ---
    -- 圆角矩形的圆角半径.
    -- @field [parent=#byui.RoundedView] #number radius  圆角的半径 
    radius = {function(self)
        return self._radius
    end, function(self, v)
        if self._radius ~= v then
            self._radius = v
            self:_update_widget()
        end
    end},
    
    ---
    -- 阴影的边距.
    -- 默认为0。设置后的效果是前景变小。
    -- @field [parent=#byui.RoundedView] #number shadow_margin 
    shadow_margin = {function(self)
        return self._shadow_margin
    end, function(self, f)
        if self._shadow_margin ~= f then
            self._shadow_margin = f
            self:_update_widget()
        end
    end},
    
    ---
    -- 阴影的偏移量.
    -- 前景会按偏移量向轴的负方向进行偏移。
    -- @field [parent=#byui.RoundedView] engine#Colorf shadow_offset 
    shadow_offset = {function(self)
        return self._shadow_offset
    end, function(self, f)
        if self._shadow_offset ~= f then
            self._shadow_offset = f
            self:_update_widget()
        end
    end},
})

---
-- 圆角矩形.
-- @field [parent=#global] #byui.RoundedView RoundedView 
RoundedView = M.RoundedView




---
-- 手指按下事件.
-- 子类必须重新此方法，否则不能正确的响应手指事件。
-- @function [parent=#byui.EventHandler] on_touch_down
-- @param #byui.EventHandler self 
-- @param engine#Point pos 手指按下的位置，为世界座标.
-- @param #number time 手指按下的时间.

---
-- 手指移动事件.
-- @function [parent=#byui.EventHandler] on_touch_move
-- @param #byui.EventHandler self 
-- @param engine#Point pos 手指移动到的位置，为世界座标.
-- @param #number time 此次事件的时间.

---
-- 手指松手事件.
-- @function [parent=#byui.EventHandler] on_touch_up
-- @param #byui.EventHandler self 
-- @param engine#Point pos 手指松手的位置，为世界座标.
-- @param #number time 此次事件的时间.

---
-- 手指事件被取消事件.
-- 可能被操作系统给取消比如电话等。也有可能由于父节点需要捕获事件从而导致收到取消事件。
-- @function [parent=#byui.EventHandler] on_touch_cancel
-- @param #byui.EventHandler self 
-- @param engine#Point pos 手指事件被取消时的位置，为世界座标.
-- @param #number time 此次事件的时间.



---
-- 事件处理基类.
-- 不能被实例化，你必须继承它，然后实现@{#byui.EventHandler.on_touch_down},@{#byui.EventHandler.on_touch_up},@{#byui.EventHandler.on_touch_move},@{#byui.EventHandler.on_touch_cancel}四个虚函数。
-- @type byui.EventHandler
-- @usage -- 默认手指事件的处理逻辑如下
-- handle_msg_chain = function(self, touch, canceled)
--    if canceled then
--        -- 优先判断canceled事件
--        self:on_touch_cancel()
--    else
--        -- 正常分发touch事件
--        if touch.action == kFingerDown then
--            self:on_touch_down(touch.pos, touch.time)
--        elseif touch.action == kFingerMove then
--            self:on_touch_move(touch.pos, touch.time)
--        elseif touch.action == kFingerUp then
--            self:on_touch_up(touch.pos, touch.time)
--        end
--    end
--
--    -- 分发给手势识别
--    for _, recog in ipairs(self._recognizers) do
--        if canceled then
--            recog:on_cancel()
--        else
--            recog:on_touch(touch)
--        end
--    end
--
--    -- 判断是否需要捕获事件
--    if not touch.locked_by and self.need_capture then
--        touch:lock(self.event_widget)
--    end
--end
M.EventHandler = {
    ---
    -- 事件处理基类构造函数.
    -- @param #byui.EventHandler self 
    -- @param #table args 构造参数.
    --          event_widget:响应事件的widget。默认自己。
    --          enabled:boolean类型。是否启用触摸事件。
    --          need_capture:boolean类型。是否需要捕获事件。
    __init__ = function(self, args)
        self:add_auto_cleanup('event_widget')
        self.event_widget = args.event_widget or self
        if self.event_widget:getId() < 0 then
            self.event_widget:initId()
        end
        if args.event_phase == nil then
            args.event_phase = 'bubbling'
        end
        self.event_widget:add_listener(function(_, ...)
            self:handle_msg_chain(...)
        end, args.event_phase == 'capturing')
        if args.enabled ~= nil then
            self.enabled = args.enabled
        else
            self.enabled = true
        end
        
        ---
        -- 是否需要捕获事件.
        -- 默认为false，既不捕获。如果开启如果没有被其父节点捕获则消息只会传递给此节点。
        -- @field [parent=#byui.EventHandler] #boolean need_capture 
        self.need_capture = args.need_capture or false

        self._recognizers = {}
    end,
    ---
    -- 手指事件分发.
    -- 提供默认的手指事件分发，你可以重写此方法来按你的规则来分发。其默认行为见@{#byui.EventHandler}。
    -- @param #byui.EventHandler self 
    -- @param engine#Touch touch 触摸事件对象
    -- @param #boolean canceled 是否为取消事件
    handle_msg_chain = function(self, touch, canceled)
        if self._enabled then
            if canceled then
                self:on_touch_cancel()
            else
                if touch.action == kFingerDown then
                    self:on_touch_down(touch.pos, touch.time)
                    if self.___type ~= "class(MenuItem)" then
                        M.share_menu_controller():set_menu_visible(false,false)
                    end
                elseif touch.action == kFingerMove then
                    self:on_touch_move(touch.pos, touch.time)
                elseif touch.action == kFingerUp then
                    self:on_touch_up(touch.pos, touch.time)
                end
            end

            for _, recog in ipairs(self._recognizers or {}) do
                if canceled then
                    recog:on_cancel()
                else
                    recog:on_touch(touch)
                end
            end
        end
        if not touch.locked_by and self.need_capture then
            touch:lock(self.event_widget)
        end
    end,
    ---
    -- 是否启用触摸事件.
    -- 默认为true,设为 false 将禁用所有事件响应。不会影响其子节点的事件响应。
    -- @field [parent=#byui.EventHandler] #boolean enabled 
    enabled = {function(self)
        return self._enabled
    end, function(self, value)
        if self._enabled ~= value then
            self._enabled = value
            if self.on_enable_changed then
                self:on_enable_changed()
            end
        end
    end},
    
    ---
    -- 添加一个手指手势.
    -- 你可以添加若干个自定义的手势，在符合手势后可以给你回调，处理相应的手势。
    -- @param #byui.EventHandler self 
    -- @param #table recog 手指事件识别的描述。
    add_recognizer = function(self, recog)
        table.insert(self._recognizers, recog)
    end,
    
    
    
    
    
    ---- default handlers
    --on_touch_down = function(self, p, t)
    --end,
    --on_touch_move = function(self, p, t)
    --end,
    --on_touch_up = function(self, p, t)
    --end,
    --on_touch_cancel = function(self)
    --end,
}

---
-- 添加一个简单的响应事件.
-- 你可以配合@{engine#Widget.set_pick_ext}订制你的触摸响应区域。
-- @function [parent=#byui] init_simple_event
-- @param engine#Widget widget 需要添加事件的widget对象。 
-- @param #function onclick  响应函数。
M.init_simple_event = function(widget, onclick)
    if widget:getId() < 0 then
        widget:initId()
    end
    widget._simple_event_handler = function(self, touch, canceled)
        if not touch.locked_by and self.need_capture then
            touch:lock(widget)
        end
        if not canceled and touch.action == kFingerUp then
            onclick(widget, touch)
        end
    end
    widget:add_listener(widget._simple_event_handler)
end

---
-- 移除widget的响应事件.
-- @function [parent=#byui] remove_simple_event
-- @param engine#Widget widget 需要移除响应事件的widget对象.
M.remove_simple_event = function(widget)
    widget:remove_listener(widget._simple_event_handler)
end

M.init_label_link = function(lbl, onclick)
    M.init_simple_event(lbl, function(self, touch)
        local p = lbl:from_world(touch.pos)
        local c = lbl:get_cursor_by_position(p)
        local seg = lbl:get_segment_by_cursor(c)
        if seg and seg.tag then
            onclick(lbl, seg.tag)
        end
    end)
end

---
-- 滚动手势识别.
-- @type byui.ScrollRecognizer

---
-- 创建手势识别的实例.
-- @callof #byui.ScrollRecognizer
-- @param #byui.ScrollRecognizer self 
-- @param #table args 
--      1.pos_dimension:滚动的方向。'x'或'y'
--      2.callback:符合手势后的回调函数。
-- @return #byui.ScrollRecognizer 返回创建的手势识别的实例.

M.ScrollRecognizer = class('ScrollRecognizer', nil, {
    __init__ = function(self, args)
        self.direction = args.direction
        self.callback = args.callback
        self.min_distance = args.min_distance or 10
        self.pos_dimension = args.pos_dimension or 'y'
        self._init = nil
        self._success = false
    end,
    
    ---
    -- 识别手势.
    -- @function [parent=#byui.ScrollRecognizer] on_touch
    -- @param #byui.ScrollRecognizer self 
    -- @param engine#Touch touch 触摸的touch对象
    on_touch = function(self, touch)
        if touch.action == kFingerDown then
            self._init = touch.pos[self.pos_dimension]
            self._success = false
        elseif not self._success then
            if math.abs(touch.pos[self.pos_dimension] - self._init) > self.min_distance then
                self._success = true
                self.callback(touch)
            end
        end
    end,
    ---
    -- 状态重置.
    -- @function [parent=#byui.ScrollRecognizer] on_cancel
    -- @param #byui.ScrollRecognizer self 
    on_cancel = function(self)
        self._init = nil
    end,
})


M.CommonRecognizer = class('CommonRecognizer', nil, {
    __init__ = function(self, args)
        self.direction = args.direction
        self.callback = args.callback
        self.recogize_func = args.recogize_func;
        self._init = nil
        self._success = false
        self.cancelCallBack = args.cancelCallBack
    end,
    on_touch = function(self, touch)
        self._touch = touch


        if touch.action == kFingerDown then
            self._init = touch.pos
            self._initTime = touch.time
            self._success = false
        elseif not self._success then
            self._success = self:recogize_func(touch)
            if self._success then
                self:callback(touch)
            end
        elseif self._success then
            if touch.action == kFingerUp then
                if self.cancelCallBack then
                    self:cancelCallBack()
                end
                self._success = false 
            else
                self:callback(touch)
            end
            
        end
    end,

    on_cancel = function(self)

        self._init = nil
        self._touch = nil

    end,
})


---
-- 按钮逻辑基类.
-- 不能被实例化，你必须继承它，里面描述了button的基本的行为。
-- @type byui.ButtonBehaviour
M.ButtonBehaviour = {
    ---
    -- 按钮逻辑基类构造函数.
    -- @param #byui.ButtonBehaviour self 
    -- @param #table args 构造参数。
    --      on_click:function类型。点击事件回调函数。
    --      on_state_changed:function类型。状态变化回调函数。
    __init__ = function(self, args)
    ---
    -- 点击的事件响应回调.
    -- 如果松手时还停在button的触摸区域内就会触发此回调.
    -- @field [parent=#byui.ButtonBehaviour] #function on_click 
        self.on_click = args.on_click
    ---
    -- button状态变化回调.
    -- 当button的状态发生变化时会触发此回调.
    -- @field [parent=#byui.ButtonBehaviour] #function on_state_changed 
        self.on_state_changed = args.on_state_changed
        self._focus = true
    end,
    ---
    -- 默认的手指按下事件处理.
    -- @param #byui.ButtonBehaviour self 
    -- @param engine#Point p 手指按下的位置。
    -- @param #number t 手指按下的时间。
    on_touch_down = function(self, p, t)
        if self.focus then
            M.share_keyboard_controller().keyboard_status = false
            ui_utils.set_focus(nil)
        end
        self.state = 'down'
    end,
    ---
    -- 默认的手指移动事件处理.
    -- @param #byui.ButtonBehaviour self 
    -- @param engine#Point p 手指移动的位置。
    -- @param #number t 手指移动的时间。
    on_touch_move = function(self, p, t)
        if self:point_in(p) then
            self.state = 'down'
        else
            self.state = 'normal'
        end
    end,
    ---
    -- 默认的手指松手事件处理.
    -- @param #byui.ButtonBehaviour self 
    -- @param engine#Point p 手指松手的位置。
    -- @param #number t 手指松手的时间。
    on_touch_up = function(self, p, t)
        self.state = 'normal'
        if self:point_in(p) and self.on_click then
            self:on_click(p, t)
        end
    end,
    ---
    -- 默认的手指取消事件处理.
    -- @param #byui.ButtonBehaviour self 
    on_touch_cancel = function(self)
        self.state = 'normal'
    end,
    ---
    -- button的状态。可取"normal","down"两种状态。
    -- @field [parent=#byui.ButtonBehaviour] #string state 
    state = {function(self)
        return self._state
    end, function(self, value)
        if self._state ~= value then
            self._state = value
            if self.on_state_changed then
                self:on_state_changed()
            end
        end
    end},
    ---
    -- 是否截获输入焦点.
    -- 默认为true.如果为false则响应事件时不会关闭键盘。
    -- @field [parent=#byui.ButtonBehaviour] #boolean focus 
    focus = {function ( self )
        return self._focus 
    end,function ( self ,v)
        self._focus = v
    end},
}


---
-- 选择框逻辑基类.
-- 不能被实例化，你必须继承它，里面描述了button的基本的行为。
-- @type byui.CheckboxBehaviour
M.CheckboxBehaviour = {
    ---
    -- 选择框逻辑基类构造函数.
    -- 其子类必须在其构造函数中去执行此方法用来完成其图片逻辑基类的构造工作。
    -- @param #byui.CheckboxBehaviour self 
    -- @param #table args 构造参数.
    --          on_change: function类型。状态改变回调。
    --          checked:boolean类型。初始选中状态。
    __init__ = function(self, args)
    ---
    -- 状态改变回调.
    -- 只要checked状态发生变化就会产生一次回调.
    -- @field [parent=#byui.CheckboxBehaviour] #function on_change 
        self.on_change = args.on_change
    
        self.checked = args.checked or false
    end,
    ---
    -- 默认的手指按下事件处理.
    -- @param #byui.CheckboxBehaviour self 
    -- @param engine#Point p 手指按下的位置。
    -- @param #number t 手指按下的时间。
    on_touch_down = function(self, p, t)
    end,
    ---
    -- 默认的手指移动事件处理.
    -- @param #byui.CheckboxBehaviour self 
    -- @param engine#Point p 手指移动的位置。
    -- @param #number t 手指移动的时间。
    on_touch_move = function(self, p, t)
    end,
    ---
    -- 默认的手指松手事件处理.
    -- @param #byui.CheckboxBehaviour self 
    -- @param engine#Point p 手指松手的位置。
    -- @param #number t 手指松手的时间。
    on_touch_up = function(self, p, t)
        if self:point_in(p) then
            self.checked = not self.checked
        end
    end,
    ---
    -- 默认的手指取消事件处理.
    -- @param #byui.CheckboxBehaviour self 
    on_touch_cancel = function(self)
    end,
    
    ---
    -- 选中状态.
    -- 默认为false.
    -- @field [parent=#byui.CheckboxBehaviour] #boolean checked 
    checked = {function(self)
        return self._checked
    end, function(self, value)
        if self._checked ~= value then
            self._checked = value
            self:_on_change()
        end
    end},

    _on_change = function(self)
        if self.on_change then
            self:on_change()
        end
    end,
    ---
    -- 选中状态的纹理.
    -- 可以是@{engine#TextureUnit}类型，@{engine#Colorf}，或者是table 格式 {uint=TextureUnit，color = Colorf，t_border = {left,top,right,bottom} }
    -- @field [parent=#byui.CheckboxBehaviour] #obj checked_enabled 
    checked_enabled = {function ( self )
        return self.images['checked_enabled'].unit
    end,function ( self ,desc)
        local checked_enabled_image = M.Image(desc)
        self.images['checked_enabled'] = checked_enabled_image
        if self.image_state == 'checked_enabled' then
            checked_enabled_image:apply(self)
        end
    end},
    ---
    -- 未选中状态的纹理.
    -- 可以是@{engine#TextureUnit}类型，@{engine#Colorf}，或者是table 格式 {uint=TextureUnit，color = Colorf，t_border = {left,top,right,bottom} }
    -- @field [parent=#byui.CheckboxBehaviour] #obj unchecked_enabled 
    unchecked_enabled = {function ( self )
        return self.images['unchecked_enabled'].unit
    end,function ( self ,desc)
        local unchecked_enabled_image = M.Image(desc)
        self.images['unchecked_enabled'] = unchecked_enabled_image
        if self.image_state == 'unchecked_enabled' then
            unchecked_enabled_image:apply(self)
        end
    end},
    
    ---
    -- 选中状态下禁用的纹理.
    -- 可以是@{engine#TextureUnit}类型，@{engine#Colorf}，或者是table 格式 {uint=TextureUnit，color = Colorf，t_border = {left,top,right,bottom} }
    -- @field [parent=#byui.CheckboxBehaviour] #obj checked_disabled 
    checked_disabled = {function ( self )
        return self.images['checked_disabled'].unit
    end,function ( self ,desc)
        local checked_disabled_image = M.Image(desc)
        self.images['checked_disabled'] = checked_disabled_image
        if self.image_state == 'checked_disabled' then
            checked_disabled_image:apply(self)
        end
    end},
    
    ---
    -- 未选中状态下禁用的纹理.
    -- 可以是@{engine#TextureUnit}类型，@{engine#Colorf}，或者是table 格式 {uint=TextureUnit，color = Colorf，t_border = {left,top,right,bottom} }
    -- @field [parent=#byui.CheckboxBehaviour] #obj unchecked_disabled 
    unchecked_disabled = {function ( self )
        return self.images['unchecked_disabled'].unit
    end,function ( self ,desc)
        local unchecked_disabled_image = M.Image(desc)
        self.images['unchecked_disabled'] = unchecked_disabled_image
        if self.image_state == 'unchecked_disabled' then
            unchecked_disabled_image:apply(self)
        end
    end},
}

-- property
--      text 
--      align (在初始未设置size时无效，即根据文本大小来确定size，默认为居中显示)
--      margin (仅在初始时未设置size时有效,并且会使得align变为center,在之后设置size后与size规则谁在后谁生效)


---
-- 文本逻辑行为基类.
-- 不能被实例化，你必须继承它，里面描述了文本的基本的行为。
-- @type byui.LabelBehaviour
M.LabelBehaviour = {
    ---
    -- 文本逻辑行为基类构造函数.
    -- 其子类必须在其构造函数中去执行此方法用来完成其图片逻辑基类的构造工作。
    -- @param #byui.LabelBehaviour self 
    -- @param #table args 构造输入的参数。
    --         size:Point类型。如果存在则固定大小，不能再被修改。
    --         margin:table类型。文本的边距，如果没有设定size，则大小依照文本大小来和margin来变化。
    --         on_size_changed:function类型。文本size变化的回调函数。 
    __init__ = function(self, args)
        
        -- sizing
        if args.size ~= nil then
            -- fixed sizing
            self.clip = true
            self.size_hint = args.size

            -- args for LabelBehaviour
            args.layout_size = args.size
            self._auto_size = false
        else
            -- auto-sizing
            self._auto_size = true
            if args.margin == nil then
                args.margin = {10,10,10,10}
            end

            self._margin = args.margin

            args.on_size_changed = function(_)
                if not self._auto_size then return end
                local s = self.label.size + Point(self.margin[1] + self.margin[3], self.margin[2] + self.margin[4])
                self.size_hint = s
                self:update_constraints()
            end
        end
        -- init text
        self.label = Label()
        self.label.multiline = args.multiline or false
        self.label.layout_size = args.layout_size or Point(0,0)
        self.align = args.align or ALIGN.CENTER
        self:add(self.label)

        if args.on_size_changed then
            self.label.on_size_changed = function(self)
                args.on_size_changed()
            end
        end

        self.text = args.text
    end,
    
    ---
    -- 显示的富文本内容.
    -- 可以为符合[富文本标签](http://engine.by.com:8000/doc/#id30)的string类型，也可以为符合[富文本table](http://engine.by.com:8000/doc/#table)的table类型。<br/>
    -- ![](http://engine.by.com:8080/hosting/data/1465197840810_1837834193760096555.gif)
    -- @field [parent=#byui.LabelBehaviour] #string text 
    text = {function(self)
        return self._text
    end, function(self, txt)
        if self._text ~= txt then
            if type(txt) == "string" then
                self._text = txt
                self.label:set_rich_text(txt)
            elseif type(txt) == "table" then
                self._text = txt
                self.label:set_data(txt)               
            end
        end
    end},
    ---
    -- 对齐方式.
    -- **不是指文本内容的对齐方式，而是相对与父节点的位置的对齐方式**.
    -- @field [parent=#byui.LabelBehaviour] byui.utils#ALIGN align 
    align = {function ( self )
        return self._align or ALIGN.CENTER
    end,function ( self,v )
        self._align = v 
        self.label.absolute_align = self.align
        -- self.label:clear_rules()
        -- self.label:add_rules(AL.rules.align(self.align))
        -- self.label:update_constraints()
    end},
    ---
    -- 文本内容的四周的留白.
    -- 仅在初始为设置size的时候有效。格式为 {left, top, right, bottom}。
    -- @field [parent=#byui.LabelBehaviour] #table margin 
    margin = {function ( self )
        return self._margin
    end,function ( self,value )
        self._margin = value 
        if self.label.on_size_changed then
            self._auto_size = true
            local s = self.label.size + Point(self.margin[1] + self.margin[3], self.margin[2] + self.margin[4])
            self.size_hint = s
            self:update_constraints()
        end
    end},
}

---
-- 纹理的包装.
-- 提供纹理的一个包装，可以方便控制纹理的颜色和绑定的纹理对象，以及@{# engine#BorderSprite.t_border}。
-- @type byui.Image

---
-- 通过纹理描述创建一个Image.
-- @callof #byui.Image
-- @param #byui.Image self 
-- @param #table desc 纹理的描述。
--      可以是可以是TextureUnit类型，Colorf，或者是table 格式 {uint=TextureUnit，color = Colorf，t_border = {left,top,right,bottom} } 。
-- @return #byui.Image 返回创建的对象

M.Image = class('Image', nil, {
    __init__ = function(self, desc)
        if desc.class == TextureUnit then
            self.unit = desc
            local tsize = desc.size
            self.t_border = {tsize.x/2, tsize.y/2, tsize.x/2, tsize.y/2}
            self.color = Colorf.white
        elseif desc.class == Colorf then
            self.unit = units.circle
            local tsize = self.unit.size
            self.t_border = {tsize.x/2, tsize.y/2, tsize.x/2, tsize.y/2}
            self.color = desc
        elseif type(desc) == 'table' then
            self.unit = desc.unit or units.circle
            self.color = desc.color or Colorf.white
            if desc.t_border ~= nil then
                self.t_border = desc.t_border
            else
                local tsize = self.unit.size
                self.t_border = {tsize.x/2, tsize.y/2, tsize.x/2, tsize.y/2}
            end
        else
            error('invalid image description')
        end
    end,
    ---
    -- 将纹理应用到制定的节点上.
    -- **这个节点必须时@{#engine.Sprite}类型或其子类。**
    -- @function [parent=#byui.Image] apply
    -- @param #byui.Image self 
    -- @param engine#Sprite node 需要设置纹理的节点.
    apply = function(self, node)
        node.unit = self.unit
        node.t_border = self.t_border
        node.self_colorf = self.color
    end,
})

---
-- 图片逻辑基类.
-- @type byui.ImageBehaviour
M.ImageBehaviour = {
    ---
    -- 图片逻辑基类构造函数.
    -- 其子类必须在其构造函数中去执行此方法用来完成其图片逻辑基类的构造工作。
    -- @param #byui.ImageBehaviour self 
    -- @param #table args 构造输入的参数。
    --         image:table类型。key表示状态，value表示不同状态对应的纹理描述。
    --         radius:number类型。表示是否圆角，以及圆角的半径。
    --         v_border:table类型。表示v_border的值。
    --         default_state:string类型。表示默认的状态。 
    __init__ = function(self, args)
        self.images = {}
        for name, desc in pairs(args.image) do
            self.images[name] = M.Image(desc)
        end
        if args.radius == nil then
            args.radius = 5
        end
        self.default_image = self.images[args.default_state]
        if args.v_border then
            self.v_border = args.v_border
        elseif args.radius then
            self.radius = args.radius
        end

        -- init state
        self.image_state = args.default_state

        if args.size ~= nil then
            self.size = args.size
        else
            self.size = self.default_image.unit.size
        end
    end,
    
    ---
    -- 设置当前的状态，以显示对应状态对应的纹理.
    -- **如果状态不存在则显示默认的纹理**
    -- @field [parent=#byui.ImageBehaviour] #string image_state 
    image_state = {function(self)
        return self._image_state
    end, function(self, state)
        if self._image_state ~= state then
            self._image_state = state

            local img = self.images[state]
            if img == nil then
                img = self.default_image
            end
            img:apply(self)
        end
    end},
    ---
    -- 圆角半径.
    -- 等价于 v_border = {radius, radius, radius, radius}。
    -- @field [parent=#byui.ImageBehaviour] #number radius 
    radius = {function ( self )
        return self._radius
    end,function ( self,v )
        self._radius = v
        self.v_border = {v, v, v, v}
    end},
}


---
-- 普通按钮.
-- 同时继承了@{#byui.EventHandler},@{#byui.ButtonBehaviour},@{#byui.LabelBehaviour},@{#byui.ImageBehaviour}。
-- @type byui.Button


---
-- 创建一个Button.
-- @callof #byui.Button
-- @param #byui.Button self 
-- @param #table args 构造参数.@{#byui.EventHandler.__init__},@{#byui.ButtonBehaviour.__init__},@{#byui.LabelBehaviour.__init__},@{#byui.ImageBehaviour.__init__}所需要的构造参数。
-- @return #byui.Button 返回创建的Button


M.Button = class('Button', BorderSprite, mixin(M.EventHandler, M.ButtonBehaviour, M.LabelBehaviour, M.ImageBehaviour, {
    __init__ = function(self, args)
        super(M.Button, self).__init__(self)

        self.args = args

        if args.image == nil then
            args.image = {
                normal = Colorf.green,
                down = Colorf.blue,
                disabled = Colorf(0.5,0.5,0.5,1),
            }
        end
        if args.text == nil then
            args.text = 'Button'
        end

        args.default_state = 'normal'
        M.ImageBehaviour.__init__(self, args)
        M.LabelBehaviour.__init__(self, args)
        M.EventHandler.__init__(self, args)
        self.label.colorf = Colorf(1.0,1.0,1.0,1.0)
        local fn = args.on_state_changed
        function args.on_state_changed(self)
            self.image_state = self._state
            if fn then
                fn(self)
            end
        end
        M.ButtonBehaviour.__init__(self, args)

        self.state = 'normal'
    end,

    on_enable_changed = function(self)
        self.image_state = self._enabled and 'normal' or 'disabled'
    end,
    ---
    -- 普通状态下的纹理.
    -- 可以是TextureUnit类型，Colorf，或者是table 格式 {uint=TextureUnit，color = Colorf，t_border = {left,top,right,bottom} } 。
    -- @field [parent=#byui.Button] #table normal 
    normal = {function ( self )
        return self.images['normal'].unit
    end,function ( self ,desc)
        local normal_image = M.Image(desc)
        self.images['normal'] = normal_image
        if self.state == 'normal' then
            normal_image:apply(self)
        end
    end},
    ---
    -- 按下状态的纹理.
    -- 可以是TextureUnit类型，Colorf，或者是table 格式 {uint=TextureUnit，color = Colorf，t_border = {left,top,right,bottom} } 。
    -- @field [parent=#byui.Button] #table down 
    down = {function ( self )
        return self.images['down'].unit
    end,function ( self ,desc)
        local down_image = M.Image(desc)
        self.images['down'] = down_image
        if self.state == 'down' then
            down_image:apply(self)
        end
    end},
    ---
    -- 禁用状态的纹理.
    -- 可以是TextureUnit类型，Colorf，或者是table 格式 {uint=TextureUnit，color = Colorf，t_border = {left,top,right,bottom} } 。
    -- @field [parent=#byui.Button] #table disabled 
    disabled = {function ( self )
        return self.images['disabled'].unit
    end,function ( self ,desc)
        local disabled_image = M.Image(desc)
        self.images['disabled'] = disabled_image
        if self.state == 'disabled' then
            disabled_image:apply(self)
        end
    end},
    ---
    -- 大小.
    -- 由于button自身存在 AutoLayout 的规则所以给其添加规则可能并不会生效。
    -- @field [parent=#byui.Button] engine#Point size 
    size = {function ( self )
        return super(M.Button, self).size
    end,function ( self,s )
        self._auto_size = false
        self.size_hint = s 
        super(M.Button, self).size = s
        self:update_constraints()
    end},
    width = {function ( self )
        return self.size.x
    end,function ( self,w)
        self.size = Point(w,self.size.y)
    end},
    height = {function ( self )
        return self.size.y
    end,function ( self,h )
        self.size = Point(self.size.x,h)
    end},
}))

---
-- 复选框控件.
-- 同时继承了@{#byui.EventHandler},@{#byui.CheckboxBehaviour},@{#byui.ImageBehaviour}。
-- @type byui.Checkbox
-- @extends engine#BorderSprite 

---
-- 创建一个复选框.
-- @callof #byui.Checkbox
-- @param #byui.Checkbox self 
-- @param #table args 构造参数.@{#byui.EventHandler.__init__},@{#byui.CheckboxBehaviour.__init__},@{#byui.ImageBehaviour.__init__}所需要的构造参数。
-- @return #byui.Checkbox 返回创建的复选框


M.Checkbox = class('Checkbox', BorderSprite, mixin(M.EventHandler, M.CheckboxBehaviour, M.ImageBehaviour, {
    __init__ = function(self, args)
        super(M.Checkbox, self).__init__(self)
        -- init event
        self.args = args

        args.default_state = 'checked_enabled'
        M.ImageBehaviour.__init__(self, args)
        M.EventHandler.__init__(self, args)
        M.CheckboxBehaviour.__init__(self, args)
    end,

    _on_change = function(self)
        if self._enabled then
            self.image_state = self._checked and 'checked_enabled' or 'unchecked_enabled'
        else
            self.image_state = self._checked and 'checked_disabled' or 'unchecked_disabled'
        end
        M.CheckboxBehaviour._on_change(self)
    end,
    on_enable_changed = function(self)
        if self._enabled then
            self.image_state = self._checked and 'checked_enabled' or 'unchecked_enabled'
        else
            self.image_state = self._checked and 'checked_disabled' or 'unchecked_disabled'
        end
    end,
}))

---
-- RadioButton的逻辑组.
-- @type byui.RadioGroup


M.RadioGroup = class('RadioGroup', nil, {
    __init__ = function(self, desc)
        self.items = {}
        self._current = -1
    end,
    ---
    -- 当前选中的RadioButton的id.
    -- 如果都没有选中默认为-1
    -- @field [parent=#byui.RadioGroup] #number current 
    current = {function (self )
        return self._current
    end,function ( self,id )
        assert(id > 0 and id <=#self.items,"invalid id:" .. tostring(id))
        if self.current ~= id and self.current ~= -1 then
            self.items[self._current].checked = false
        end
        self._current = id
        self.items[self._current].checked = true
        self:_on_change()
    end
    },
    ---
    -- 将已经选中的RadioButton清除选中状态.
    -- @function [parent=#byui.RadioGroup] clear_check 
    -- @param #byui.RadioGroup self 
    clear_check = function ( self )
        if self.current ~= -1 then
            self.items[self._current].checked = false
        end
    end,
    ---
    -- 选中指定的RadioButton.
    -- @function [parent=#byui.RadioGroup] check 
    -- @param #byui.RadioGroup self 
    -- @param #number id 指定的RadioButton的id.
    check = function (self,id)
        assert(id > 0 and id <=#self.items,"invalid id:" .. tostring(id))
        if self.current ~= id and self.current ~= -1 then
            self.items[self._current].checked = false
        end
        self._current = id
        self.items[self._current].checked = true
        self:_on_change()
    end,
    ---
    -- 获取RadioButton的索引.
    -- @function [parent=#byui.RadioGroup] index_of_item 
    -- @param #byui.RadioGroup self 
    -- @param #byui.RadioButton item 指定的RadioButton.
    -- @return #number 返回给定的索引。如果不存在则返回-1.
    index_of_item = function (self,item)
        for i,v in ipairs(self.items) do
            if v:getId() == item:getId() then
                return i
            end
        end
        return -1 
    end,
    ---
    -- 添加一个的RadioButton.
    -- @function [parent=#byui.RadioGroup] add_item 
    -- @param #byui.RadioGroup self 
    -- @param #byui.RadioButton item 需要添加的RadioButton.
    add_item = function (self,item)
        if item.group == self then return end
        if  item.group  then
            item.group:remove_item(item.group:index_of_item(item))
        end
        item.__group = self
        table.insert(self.items,item)
        if item.checked then
            self:check(#self.items)
        end
        self:_on_child_add(item)
    end,
    ---
    -- 删除一个的RadioButton.
    -- @function [parent=#byui.RadioGroup] add_item 
    -- @param #byui.RadioGroup self 
    -- @param #number id 需要删除的RadioButton的id.
    remove_item = function (self,id)
        if self._current == id then
            self._current = -1
        end
        local temp = table.remove(self.items,id)
        self:_on_child_remove(temp)
    end,
    _on_change = function(self)
        ---
        -- RadioButton选中状态变化事件的回调.
        -- 提供一个参数，表示当前选中状态的id。
        -- @field [parent=#byui.RadioGroup] #function on_change 
        if self.on_change then
            self:on_change(self._current)
        end
    end,
    _on_child_add = function(self,value)
        ---
        -- 添加一个RadioButton的回调.
        -- 提供一个参数，表示当前添加的RadioButton。
        -- @field [parent=#byui.RadioGroup] #function on_child_add 
        if self.on_child_add then
            self:on_child_add(value)
        end
    end,
    _on_child_remove = function(self,value)
        ---
        -- 删除一个RadioButton的回调.
        -- 提供一个参数，表示当前删除的RadioButton。
        -- @field [parent=#byui.RadioGroup] #function on_child_remove 
        if self.on_child_remove then
            self:on_child_remove(value)
        end
    end,
})

---
-- RadioButton容器.
-- 所有字节点会自动添加到一个@{#byui.RadioGroup}中。
-- @type byui.RadioContainer
-- @extends engine#Widget 
M.RadioContainer = class('RadioContainer', Widget, {
    __init__ = function(self, args)
        super(M.RadioContainer, self).__init__(self)
        self._group = M.RadioGroup(args)
    end,
    ---
    -- 添加一个@{#byui.RadioButton}.
    -- @function [parent=#byui.RadioContainer] add
    -- @param #byui.RadioContainer self 
    -- @param #byui.RadioButton c  添加的@{#byui.RadioButton}
    add = function(self, c)
        self._group:add_item(c)
        super(M.RadioContainer, self).add(self, c)
    end,
    ---
    -- 删除一个@{#byui.RadioButton}.
    -- @function [parent=#byui.RadioContainer] remove
    -- @param #byui.RadioContainer self 
    -- @param #byui.RadioButton c  删除的@{#byui.RadioButton}
    remove = function(self, c)
        self._group:remove_item(self._group:index_of_item(c))
        super(M.RadioContainer, self).remove(self, c)
    end,
})

---
-- 单选按钮控件.
-- 同时继承了@{#byui.EventHandler},@{#byui.ButtonBehaviour},@{#byui.ImageBehaviour}。
-- @type byui.RadioButton
-- @extends engine#BorderSprite 

---
-- 创建一个RadioButton
-- @callof #byui.RadioButton
-- @param #byui.RadioButton self 
-- @param #table args 构造参数.@{#byui.EventHandler.__init__},@{#byui.ButtonBehaviour.__init__},@{#byui.ImageBehaviour.__init__}所需要的构造参数。
-- @return #byui.RadioButton 返回创建的RadioButton

M.RadioButton = class('RadioButton', BorderSprite, mixin(M.EventHandler, M.CheckboxBehaviour, M.ImageBehaviour, {
    __init__ = function(self, args)
        super(M.RadioButton, self).__init__(self)
        -- init event
        self.args = args
        if not args.image then 
            args.image = {}
            args.image.unchecked_enabled = units.radiobutton_uncheck 
            args.image.checked_enabled = units.radiobutton_check
        end
        if not args.image.checked_enabled then 
            args.image.checked_enabled = units.radiobutton_check
        end
        if not args.image.unchecked_enabled then 
            args.image.unchecked_enabled = units.radiobutton_uncheck 
        end
        if not args.radius then
            args.radius = 0
        end
        args.default_state = 'checked_enabled'
        M.ImageBehaviour.__init__(self, args)
        M.EventHandler.__init__(self, args)
        M.CheckboxBehaviour.__init__(self, args)
    end,

    _on_change = function(self)
        if self.group and self.group.current == -1 and self._checked then
            self.group.current = self.group:index_of_item(self)
        end
        if self._enabled then
            self.image_state = self._checked and 'checked_enabled' or 'unchecked_enabled'
        else
            self.image_state = self._checked and 'checked_disabled' or 'unchecked_disabled'
        end
        M.CheckboxBehaviour._on_change(self)
    end,
    on_enable_changed = function(self)
        if self._enabled then
            self.image_state = self._checked and 'checked_enabled' or 'unchecked_enabled'
        else
            self.image_state = self._checked and 'checked_disabled' or 'unchecked_disabled'
        end
    end,
    on_touch_up = function(self, p, t)
        if self:point_in(p) and not self.checked then
            if self.__group then
                self.__group:check(self.__group:index_of_item(self))
            else
                self.checked = not self.checked
            end
        end
    end,
    ---
    -- 所在的组.
    -- @field [parent=#byui.RadioButton] #byui.RadioGroup group description
    group = {function ( self )
        return self.__group
    end,function ( self,value )
        value:add_item(self)
        self.__group = value
    end},
}))



-- property
--    on_tint
--    off_tint
--    on
--    thumb_tint

---
-- 创建一个Switch.
-- @callof #byui.Switch
-- @param #byui.Switch self 
-- @param #table args 构造参数列表.
--          on_tint :Colorf类型。表示 开启状态的颜色。
--          off_tint  :Colorf类型。表示关闭状态的颜色。
--          thumb_tint :Colorf类型。操作按钮的颜色。
--          on :boolean类型。设置默认的初始选择状态。
-- @return #byui.Switch 新创建的Switch对象。

---
-- 开关选择控件.
-- **Switch的size 是固定大小，请不要去重新设置其size，改变其大小可以通过scale的方式去实现。**
-- @type byui.Switch
-- @extends engine#BorderSprite 



M.Switch = class('Switch', BorderSprite, mixin(M.EventHandler, {
    __init__ = function(self, args)
        super(M.Switch, self).__init__(self)
        M.EventHandler.__init__(self, args)
        self.on_change = args.on_change

        if args.on == nil then
            self._on = true
        else
            self._on = args.on
        end

        local border = 3

        self.unit = units.circle
        local tsize = self.unit.size
        self.t_border = {tsize.x/2, tsize.y/2, tsize.x/2, tsize.y/2}
        local vsize = Point(100,60)
        self.size = vsize
        self.v_border = {vsize.y/2, vsize.y/2, vsize.y/2, vsize.y/2}

        self.color_on = args.on_tint or Colorf.green
        self.color_off = args.off_tint or Colorf(0.9,0.9,0.9,1)
        self.self_colorf = self._on and self.color_on or self.color_off

        -- fill
        self.fill = BorderSprite()
        self:add(self.fill)
        self.fill.unit = units.circle
        tsize = self.unit.size
        self.fill.t_border = {tsize.x/2, tsize.y/2, tsize.x/2, tsize.y/2}
        local fill_vsize = Point(vsize.x - border*2, vsize.y - border*2)
        self.fill.size = fill_vsize
        self.fill.v_border = {fill_vsize.y/2, fill_vsize.y/2, fill_vsize.y/2, fill_vsize.y/2}
        self.fill.pos = Point(border, border)
        self.fill.self_colorf = Colorf(1,1,1,1)
        self.fill.scale_at_anchor_point = true
        self.fill.scale = self._on and Point(0,0) or Point(1,1)

        -- thumb
        local shadow_margin = 3
        local thumb_vsize = Point(vsize.y - border*2 + shadow_margin*2, vsize.y - border*2 + shadow_margin*2)
        self.thumb = RoundedView()
        self.thumb.size = thumb_vsize
        self.thumb.radius = (thumb_vsize.x - shadow_margin*2) / 2
        --self.thumb.y = -1
        self.thumb.self_colorf = args.thumb_tint or Colorf.white

        -- shadow
        self.thumb.need_shadow = true
        --self.thumb.need_box = false

        self.thumb.shadow_radius = thumb_vsize.x / 2
        self.thumb.shadow_margin = shadow_margin
        self.thumb.shadow_offset = Point(1,1)

        self.thumb_width = thumb_vsize.x
        self.thumb_hover_width = thumb_vsize.x + 13 -- 按下状态加宽
        self.thumb_left_x = border
        self.thumb_right_x = vsize.x - thumb_vsize.x - self.thumb_left_x

        self.thumb.x = self._on and self.thumb_right_x or self.thumb_left_x

        self:add(self.thumb)

        self.anim = anim.Animator()
    end,
    ---
    -- 当前状态.
    -- @field [parent=#byui.Switch] #boolean on 
    on = {function(self)
        return self._on
    end, function(self, v)
        if self._on ~= v then
            self._on = v
            -- self:_anim_standby(self._on)
            self:_anim_toggle(self._on)
            -- self:_anim_cancel(self._on)
            
            if self.on_change then
                self:on_change(self._on)
            end
        end
    end},
    ---
    -- 开启状态的颜色.
    -- @field [parent=#byui.Switch] engine#Colorf on_tint 
    on_tint = {function ( self )
        return self.color_on
    end,function ( self,c )
        self.color_on = c or Colorf.green
        self.self_colorf = self._on and self.color_on or self.color_off
    end},
    ---
    -- 关闭状态的颜色.
    -- @field [parent=#byui.Switch] engine#Colorf off_tint 
    off_tint = {function ( self )
        return self.color_off
    end,function ( self,c )
        self.color_off = c or Colorf(0.9,0.9,0.9,1)
        if not self._on then
            self.self_colorf = self.color_off
            self.thumb.self_colorf = self.color_off
        end
    end},
    ---
    -- 按钮的颜色.
    -- @field [parent=#byui.Switch] engine#Colorf thumb_tint 
    thumb_tint = {function ( self )
        return self._thumb_tint
    end,function ( self,c )
        self._thumb_tint = c or Colorf.white
        self.thumb.self_colorf = self._thumb_tint
    end},
    _anim_standby = function(self, on)
        print("_anim_standby",on)
        if not on then
            ui_utils.play_attr_anim(self.anim, {
                {self.thumb, 'width', self.thumb_hover_width},
                {self.fill, 'scale', Point(0, 0)},
            }, 0.15)
        else
            ui_utils.play_attr_anim(self.anim, {
                {self.thumb, 'width', self.thumb_hover_width},
                {self.thumb, 'x', self.thumb_right_x - (self.thumb_hover_width - self.thumb_width)},
            }, 0.15)
        end
    end,
    _anim_toggle = function(self, on)
        if on then
            ui_utils.play_attr_anim(self.anim, {
                {self.thumb, 'width', self.thumb_width},
                {self.thumb, 'x', self.thumb_right_x, anim.timing_bounce},
                {self.fill, 'scale', Point(0, 0), anim.ease_in_out},
                {self, 'self_colorf', self.color_on},
            }, 0.20)
        else
            ui_utils.play_attr_anim(self.anim, {
                {self.thumb, 'width', self.thumb_width},
                {self.thumb, 'x', self.thumb_left_x, anim.timing_bounce},
                {self.fill, 'scale', Point(1, 1), anim.ease_in_out},
                {self, 'self_colorf', self.color_off},
            }, 0.18)
        end
    end,
    _anim_cancel = function(self, on)
        if on then
            ui_utils.play_attr_anim(self.anim, {
                {self.thumb, 'width', self.thumb_width},
                {self.thumb, 'x', self.thumb_right_x},
            }, 0.15)
        else
            ui_utils.play_attr_anim(self.anim, {
                {self.thumb, 'width', self.thumb_width},
                {self.fill, 'scale', Point(1, 1)},
            }, 0.15)
        end
    end,
    _anim_standby_switch = function(self, on)
        if on then
            ui_utils.play_attr_anim(self.anim, {
                {self.thumb, 'x', self.thumb_left_x},
                {self, 'self_colorf', self.color_off},
            }, 0.18)
        else
            ui_utils.play_attr_anim(self.anim, {
                {self.thumb, 'x', self.thumb_right_x - (self.thumb_hover_width - self.thumb_width)},
                {self, 'self_colorf', self.color_on},
            }, 0.18)
        end
    end,
    _clear = function(self)
        self._down = nil
        self._standby = nil
        self._standby_switched = nil
    end,
    on_touch_down = function(self, p, t)
        self._down = p
        self._standby = self.on and 'on' or 'off'
        self:_anim_standby(self.on)
    end,
    on_touch_up = function(self, p, t)
        if self._down == nil then
            -- canceled.
            return
        end
        local on
        if not self._standby_switched then
            self.on = not self.on
            self:_anim_toggle(self.on)
        else
            self.on = self._standby == 'on'
            self:_anim_cancel(self.on)
        end
        self:_clear()
    end,
    on_touch_cancel = function(self)
        if self._down == nil then
            return
        end

        self.on = self._standby == 'on'
        self:_anim_cancel(self.on)
        self:_clear()
    end,
    on_touch_move = function(self, p, t)
        if self._down == nil then
            return
        end
        if (self._standby == 'on' and (self._down.x - p.x > 40)) or (self._standby == 'off' and (p.x - self._down.x > 40)) then
            if self._down.x - p.x > 40 then
                if self._standby ~= 'off' then
                    self._standby = 'off'
                    self._standby_switched = true
                    self:_anim_standby_switch(true)
                end
            else
                if self._standby ~= 'on' then
                    self._standby = 'on'
                    self._standby_switched = true
                    self:_anim_standby_switch(false)
                end
            end
        elseif (self._standby == 'on' and (p.x - self._down.x) > 200) or (not self._standby == 'off' and (self._down.x - p.x) > 200) then
            self:on_touch_cancel()
        elseif (math.abs(p.y - self._down.y) > 200) then
            self:on_touch_cancel()
        end
    end,
}))

---
-- 创建一个ToggleButton.
-- @callof #byui.ToggleButton
-- @param #table args 构造参数.@{#byui.EventHandler.__init__},@{#byui.ButtonBehaviour.__init__},@{#byui.ImageBehaviour.__init__},@{#byui.LabelBehaviour.__init__}所需要的构造参数。
-- @return #byui.ToggleButton 返回创建的ToggleButton.

---
-- 开关按钮.
-- 同时继承了@{#byui.EventHandler},@{#byui.ButtonBehaviour},@{#byui.ImageBehaviour},@{#byui.LabelBehaviour}。
-- @type byui.ToggleButton
-- @extends engine#BorderSprite 



M.ToggleButton = class('ToggleButton', BorderSprite, mixin(M.EventHandler, M.CheckboxBehaviour, M.ImageBehaviour, M.LabelBehaviour, {
    __init__ = function(self, args)
        super(M.ToggleButton, self).__init__(self)
        self.args = args
        args.default_state = 'checked_enabled'
        if args.image == nil then
            args.image = {
                checked_enabled = Colorf.green,
                unchecked_enabled = Colorf.blue,
                checked_disabled = Colorf(0.8,0.8,0.8,1),
                unchecked_disabled = Colorf(0.5,0.5,0.5,1),
            }
        end
        M.ImageBehaviour.__init__(self, args)
        M.LabelBehaviour.__init__(self, args)
        M.EventHandler.__init__(self, args)
        M.CheckboxBehaviour.__init__(self, args)
        self.label.colorf = Colorf(1.0,1.0,1.0,1.0)
    end,

    _on_change = function(self)
        if self._enabled then
            self.image_state = self._checked and 'checked_enabled' or 'unchecked_enabled'
        else
            self.image_state = self._checked and 'checked_disabled' or 'unchecked_disabled'
        end
        M.CheckboxBehaviour._on_change(self)
    end,

    on_enable_changed = function(self)
        if self._enabled then
            self.image_state = self._checked and 'checked_enabled' or 'unchecked_enabled'
        else
            self.image_state = self._checked and 'checked_disabled' or 'unchecked_disabled'
        end
    end,
    size = {function ( self )
        return super(M.ToggleButton, self).size
    end,function ( self,s )
        self._auto_size = false
        self.size_hint = s 
        super(M.ToggleButton, self).size = s
        self:update_constraints()
        self:update(false)
    end},
    width = {function ( self )
        return self.size.x
    end,function ( self,w)
        self.size = Point(w,self.size.y)
    end},
    height = {function ( self )
        return self.size.y
    end,function ( self,h )
        self.size = Point(self.size.x,h)
    end},
}))


---
-- 进度条.
-- @type byui.ProgressBar
-- @extends engine#BorderSprite 

---
-- 创建一个进度条.
-- @callof #byui.ProgressBar
-- @param #byui.ProgressBar self 
-- @param #table args 构造参数列表。
--     size : Point类型。进度条的大小。
--     base_color :Colorf类型。背景的颜色。
--     base_image : TextureUnit类型。背景的贴图，如果存在则base_color不生效。
--     progress_color :Colorf类型。进度的颜色。
--     progress_image : TextureUnit类型。进度的贴图，如果存在则progress_color不生效。
--     radius :number类型。圆角的半径。

M.ProgressBar = class('ProgressBar', BorderSprite, {
    __init__ = function(self, args)
        super(M.ProgressBar, self).__init__(self)
        
        self.size = args.size or Point(300,4)
        self.unit = units.circle
        self.t_border =  ui_utils.default_t_border(units.circle)
        self.base_color = args.base_color or Colorf(0.5,0.5,0.5,1)
        self.base_image = args.base_image

        self.progress = BorderSprite()
        self.progress.unit = units.circle
        self.progress.t_border =  ui_utils.default_t_border(units.circle)
        self.progress_color = args.progress_color or Colorf.blue
        self.progress_image = args.progress_image
        self.progress.size = self.size
        self:add(self.progress)
        self.radius = args.radius or (self.size.y / 2 )
        self.value = args.value or 0
        self.on_size_changed = function (_)
            self.value = self.value
        end
    end,
    ---
    -- 进度的值.
    -- 取值在@{#byui.ProgressBar.mininum_value}和@{#byui.ProgressBar.maxinum_value}之间。
    -- @field [parent=#byui.ProgressBar] #number value 
    value = {function(self)
        return self._value
    end, function(self, v)
        v = math.max(math.min(v, self.maxinum_value), self.mininum_value)
        self._value = v
        local scale = (self._value - self.mininum_value) / (self.maxinum_value - self.mininum_value)
        self.progress.size = Point(scale * self.width, self.height)
    end},
    ---
    -- 进度的最小值.
    -- 默认为0。
    -- @field [parent=#byui.ProgressBar] #number mininum_value
    mininum_value = {function ( self )
        return self._mininum_value or 0.0
    end,function ( self,min )
        if min > self.maxinum_value then
            min = self.maxinum_value
        end
        if min ~= self.mininum_value then
            self._mininum_value = min
            if self.value < self.mininum_value then
                self.value = self.mininum_value
            end
        end
    end},
    ---
    -- 进度的最大值.
    -- 默认为1。
    -- @field [parent=#byui.ProgressBar] #number maxinum_value
    maxinum_value = {function ( self )
        return self._maxinum_value or 1.0
    end,function ( self,max )
        if max < self.mininum_value then
            max = self.mininum_value
        end
        if max ~= self.maxinum_value then
            self._maxinum_value = max
            if self.value > self.maxinum_value then
                self.value = self.maxinum_value
            end
        end
    end},
    ---
    -- 进度的颜色.
    -- 如果@{#byui.ProgressBar.progress_image}存在则不会生效。
    -- @field [parent=#byui.ProgressBar] engine#Colorf progress_color
    progress_color = {function ( self )
        return self._progress_color
    end,function ( self,color )
        self._progress_color = color
        if not self.progress_image then
            self.progress.self_colorf = self._progress_color
        end
    end},
    ---
    -- 进度的纹理.
    -- 如果存在则@{#byui.ProgressBar.progress_color}不会生效。
    -- @field [parent=#byui.ProgressBar] engine#TextureUnit progress_image
    progress_image = {function ( self )
        return self._progress_image
    end,function ( self,image )
        if image == nil then
            self._progress_image = nil
            self.progress.unit = units.circle
            self.progress.t_border = ui_utils.default_t_border(units.circle)
            self.progress.self_colorf = self.progress_color
        elseif image.class == TextureUnit then
            self._progress_image = image
            self.progress.unit = image
            self.progress.t_border = ui_utils.default_t_border(image)
            self.progress.self_colorf = Colorf.white
        else
            error('invalid image description')
        end
    end},
    ---
    -- 背景的颜色.
    -- 如果@{#byui.ProgressBar.base_image}存在则不会生效。
    -- @field [parent=#byui.ProgressBar] engine#Colorf base_color
    base_color = {function ( self )
        return self._base_color
    end,function ( self,color )
        self._base_color = color
        if not self.base_image then
            self.self_colorf = self._base_color
        end
    end},
    ---
    -- 背景的纹理.
    -- 如果存在则@{#byui.ProgressBar.base_color}不会生效。
    -- @field [parent=#byui.ProgressBar] engine#TextureUnit base_image
    base_image = {function ( self )
        return self._base_image
    end,function ( self,image )
        if image == nil then
            self._base_image = nil
            self.unit = units.circle
            self.t_border = ui_utils.default_t_border(units.circle)
            self.self_colorf = self.base_color
        elseif image.class == TextureUnit then
            self._base_image = image
            self.unit = image
            self.t_border = ui_utils.default_t_border(image)
            self.self_colorf = Colorf.white
        else
            error('invalid image description')
        end
    end},
    ---
    -- 圆角半径.
    -- @field [parent=#byui.ProgressBar] #number radius
    radius = {function ( self )
        return self._radius or self.size.y/2
    end,function ( self,value )
        self._radius = value
        self.progress.v_border = {self._radius,self._radius,self._radius,self._radius}
        self.v_border = {self._radius,self._radius,self._radius,self._radius}
    end

    },
})

---
-- 滑动条控件.
-- 同时继承了同时继承了@{#byui.EventHandler}。
-- @type byui.Slider
-- @extends engine#Widget 

---
-- 创建一个滑动条.
-- @callof #byui.Slider
-- @param #byui.Slider self 
-- @param #table args 构造参数列表
--        thumb_size:Point类型。滑块的大小。
--        thumb_color:Colorf类型。滑块的颜色，在 thumb_image存在情况下不生效。
--        thumb_image:TextureUnit类型。滑块的纹理，如果存在则thumb_color不生效。
--        on_change:function类型。当值改变时的回调函数。
--        ProgressBar需要的构造参数.
-- @return #byui.Slider 

M.Slider = class('Slider', Widget, mixin(M.EventHandler, {
    __init__ = function(self, args)
        super(M.Slider, self).__init__(self, args)

        self.size = args.size or Point(100,4)
        ---
        -- 包含的进度条对象.
        -- @field [parent=#byui.Slider] #byui.ProgressBar progress_bar 
        self.progress_bar = M.ProgressBar{
            size = self.size,
            base_color = args.base_color,
            progress_color = args.progress_color,
        }
        self:add(self.progress_bar)

        self.thumb = BorderSprite()
        self.thumb.unit = units.circle
        self.thumb.t_border =  ui_utils.default_t_border(units.circle)
        self.thumb_size = args.thumb_size or Point(60,60)
        self.thumb_color = args.thumb_color or Colorf.white
        self.thumb_image = args.thumb_image 
        self.thumb:initId()
        self:add(self.thumb)

        -- self.contain_children = true
        -- self.thumb.contain_children = true

        args.event_widget = self.thumb
        M.EventHandler.__init__(self, args)
        
        ---
        -- 值改变的回调.
        -- @field [parent=#byui.Slider] #function on_change 
        self.on_change = args.on_change
        self.on_size_changed = function (  )
            self.progress_bar.size = self.size
            self.value = self.value
        end
    end,
    value = {function(self)
        return self.progress_bar.value
    end, function(self, v)
        v = math.max(math.min(v, self.progress_bar.maxinum_value), self.progress_bar.mininum_value)
        self.progress_bar.value = v
        local coefficient = (v - self.progress_bar.mininum_value)/(self.progress_bar.maxinum_value - self.progress_bar.mininum_value)
        local from = 0--self.thumb.width/2
        local to = self.progress_bar.width - self.thumb.width
        self.thumb.pos = Point(from + coefficient * (to - from) ,self.progress_bar.height/2-self.thumb.height/2)
    end},
    on_touch_down = function(self, p, t)
        p = self:from_world(p)
        self._last = p.x
    end,
    on_touch_move = function(self, p, t)
        p = self:from_world(p)
        local diff = ((p.x - self._last) / self.progress_bar.width)*(self.progress_bar.maxinum_value - self.progress_bar.mininum_value)
        self._last = p.x
        self.value = self.value + diff
        self:_on_change(self.value)
    end,
    on_touch_up = function(self, p, t)
        p = self:from_world(p)
        self._start = nil
        self:_on_change(self.value)
    end,
    _on_change = function(self, value)
        if self.on_change then
            self:on_change(value)
        end
    end,
    ---
    -- 滑块的大小.
    -- @field [parent=#byui.Slider] engine#Point thumb_size
    thumb_size = {function ( self )
        return self.thumb.size
    end,function ( self,size )
        self.thumb.size = size
        self.value = self.value
    end},
    ---
    -- 滑块的颜色.
    -- 如果@{#byui.Slider.thumb_image}存在则不会生效。
    -- @field [parent=#byui.Slider] engine#Colorf thumb_color
    thumb_color = {function ( self )
        return self._thumb_color
    end,function ( self,color )
        self._thumb_color = color
        if not self.base_image then
            self.thumb.self_colorf = self._thumb_color
        end
    end},
    ---
    -- 滑块的纹理.
    -- 如果存在则@{#byui.Slider.thumb_color}不会生效。
    -- @field [parent=#byui.Slider] engine#TextureUnit thumb_image
    thumb_image = {function ( self )
        return self._thumb_image
    end,function ( self,image )
        if image == nil then
            self._thumb_image = nil
            self.thumb.unit = units.circle
            self.thumb.size = units.circle.size
            self.thumb.t_border = ui_utils.default_t_border(units.circle)
            self.thumb.self_colorf = self.thumb_color
        elseif image.class == TextureUnit then
            self._thumb_image = image
            self.thumb.unit = image
            self.thumb.size = image.size
            self.thumb.t_border = ui_utils.default_t_border(image)
            self.thumb.self_colorf = Colorf.white
        else
            error('invalid image description')
        end
        self.value = self.value
    end},
    ---
    -- 进度的最小值.
    -- 默认为0.0。
    -- @field [parent=#byui.Slider] #number mininum_value
    mininum_value = {function ( self )
        return self.progress_bar.mininum_value
    end,function ( self,min )
        if min > self.maxinum_value then
            min = self.maxinum_value
        end
        if min ~= self.mininum_value then
            self.progress_bar.mininum_value = min
            if self.value < self.mininum_value then
                self.value = self.mininum_value
            else
                self.value = self.value
            end
        end
    end},
    ---
    -- 滑块的的最大值.
    -- 默认为1。
    -- @field [parent=#byui.Slider] #number maxinum_value
    maxinum_value = {function ( self )
        return self.progress_bar.maxinum_value
    end,function ( self,max )
        if max < self.mininum_value then
            max = self.mininum_value
        end
        if max ~= self.maxinum_value then
            self.progress_bar.maxinum_value = max
            if self.value > self.maxinum_value then
                self.value = self.maxinum_value
            else
                self.value = self.value
            end
        end
    end},
}))

---
-- 创建一个多层控件.
-- @callof #byui.Layers
-- @param #byui.Layers self 
-- @param #table args 
--      drag_direction : 拖拽的方向，可选 kDragToLeft :向左滑动, kDragToRight :向右拖动, kDragToTop :向上拖动, kDragToBottom :向下拖动。
--      drag_length : 可以拖拽的最大距离。现在已经废弃，现在根据背景的大小来决定拖拽距离。尽可能的显示完整的背景。
-- @return #byui.Layers 返回创建的Layers对象.


---
-- 多层控件.
-- 可以有两层，通过制定滑动的方向可以通过滑动显示出另外的一层。
-- @type byui.Layers
-- @extends engine#Widget 


M.Layers = class('Layers', Widget, mixin(M.EventHandler, {
    __init__ = function(self, args)
        super(M.Layers, self).__init__(self, args)
        self._capture = false
        self.clip = true
        self._throw = false
        self._drag_direction = kDragToLeft
        self._drag_length = 0

        self.width = args.width or 0
        self.height = args.height or 0

        
        M.EventHandler.__init__(self, args)

        
        self.drag_direction = args.drag_direction or kDragToLeft
        self.drag_length = args.drag_length or 0
        if self.drag_direction == kDragToLeft or self.drag_direction == kDragToRight then
            self.pos_dimension =  'x'
        else
            self.pos_dimension =  'y'
        end
        
        self._show_status = true
        self._drag_distance = 0

        self._scroll_recognizer = M.ScrollRecognizer{
            min_distance = 5,
            callback = function(touch)
                touch:lock(self.event_widget)
                self._capture = true
            end,
            pos_dimension = self.pos_dimension,
        }

        self:add_recognizer(self._scroll_recognizer)
        self.on_size_changed = function(_)
            self.drag_length = self.drag_length
            if self._background_control then
                if self.pos_dimension == 'x' then
                    self._drag_length = self._background_control.width
                    self._background_control.pos = Point((self.width - self._drag_length)*(1-self.drag_direction.x)/2,0)
                else
                    self._drag_length = self._background_control.height
                    self._background_control.pos = Point(0,(self.height - self._drag_length)*(1-self.drag_direction.y)/2)
                end
            end
        end
        self._touch_data = {
            start_point = nil,
            start_time = nil,
            length = 0,
            direction_change = false
        }
        
        self.anim = anim.Animator()
        
    end,
    min_distance = {function ( self )
        return self._scroll_recognizer.min_distance 
    end,function ( self,v )
        self._scroll_recognizer.min_distance = v
    end},
    _anim_move = function(self, status,duration,timing)
        if self._foreground_control then
            if not status then
                ui_utils.play_attr_anim(self.anim, {

                    {self._foreground_control, self.pos_dimension, 0,timing},
                }, duration or 0.15)
            else
                ui_utils.play_attr_anim(self.anim, {

                    {self._foreground_control, 'pos', Point(self._drag_length * self.drag_direction.x,self._drag_length * self.drag_direction.y),timing},
                }, duration or 0.15)
            end
        end
        self._show_status = not status
        self._throw = true
        if self._on_change_status then
            self._on_change_status(self._show_status)
        end
    end,
    ---
    -- 拖拽的方向.
    -- 可取kDragToRight,kDragToBottom,kDragToLeft,kDragToRight,kDragToTop。默认为kDragToLeft
    -- @field [parent=#byui.Layers] #obj drag_direction 
    drag_direction = {function(self)
        return self._drag_direction
    end, function(self, v)
        self._drag_direction = v
        self:_show_foreground()
        if self._drag_direction.x == 0 then
            self.pos_dimension = 'y'
        else
            self.pos_dimension = 'x'
        end
    end},
    drag_length = {function(self)
        return self._drag_length
    end, function(self, v)
        self._drag_length = v 
        self:_show_foreground()
    end},
    ---
    -- 背景视图.
    -- 背景需要显示的控件。
    -- @field [parent=#byui.Layers] engine#Widget background_view 
    background_view = {function(self)
        return self._background_control
    end,function ( self,w )
        if self._background_control then
            self._background_control:remove_from_parent()
        end
        self._background_control = w
        self._background_control.zorder = -1
        self:add(w)
        self._background_control.on_content_bbox_changed = function(_)
            if self.pos_dimension == 'x' then
                self._drag_length = self._background_control.content_bbox.w
                self._background_control.pos = Point((self.width - self._drag_length)*(1-self.drag_direction.x)/2,0)
            else
                self._drag_length = self._background_control.content_bbox.h
                self._background_control.pos = Point(0,(self.height - self._drag_length)*(1-self.drag_direction.y)/2)
            end
        end
    end
    },
    ---
    -- 前景视图.
    -- 前景需要显示的控件。
    -- @field [parent=#byui.Layers] engine#Widget foreground_view 
    foreground_view = {function(self)
        return self._foreground_control
    end,function ( self,w )
        if self._foreground_control then
            self._foreground_control:remove_from_parent()
        end
        self._foreground_control = w
        self:add(w)
        self._foreground_control.zorder = 1
        self.size = self._foreground_control.size
    end
    },
    ---
    -- 显示状态.
    -- 默认为true，即显示的前景。false则背景为激活状态。
    -- @field [parent=#byui.Layers] #boolean show_status 
    show_status = {function ( self )
        return self._show_status
    end
    },
    _show_foreground = function (self)
        self._show_status = true
        if self._foreground_control then
            self._foreground_control.pos = Point(0,0)
        end
    end,
    ---
    -- 强制显示前景.
    -- 调用此函数后会回到初始状态。
    -- @function [parent=#byui.Layers] show_foreground
    -- @param #byui.Layers self 
    show_foreground = function (self)
        self:_anim_move(false)
        self._throw = false
    end,
    
    set_on_change_status_callback = function (self, callback )
        self._on_change_status = callback
    end,
    ---
    -- 状态变化的监听.
    -- 可以检测背景是否处于激活的状态。
    -- @field [parent=#byui.Layers] #function on_change_status
    -- @usage l.on_change_status = function(status)
    --      print("status:",status)
    -- end
    on_change_status = {function ( self )
        return self._on_change_status
    end,function ( self,value )
        self._on_change_status = value
    end},
    _show_background = function (self, length )
        self._drag_distance = length
        if self._foreground_control then 
            self._foreground_control.pos = Point(self._drag_distance * self.drag_direction.x,self._drag_distance * self.drag_direction.y) 
        end 
    end,

    on_touch_down = function(self, p, t)
        if self._throw then return end 
        self._capture = false
        self._touch_data.start_point = p
        self._touch_data.start_time = t
        if not self._throw and not self.show_status and self._foreground_control and self._foreground_control:point_in(p) then
            self:_anim_move(false)
            self.need_capture = true
        end
    end,
    on_touch_move = function(self, p, t)
        if self._throw then return end 
        if self._capture  and not self._throw then
            local now_point = p
            local length = 0
            length = ( now_point[self.pos_dimension] - self._touch_data.start_point[self.pos_dimension] ) * self.drag_direction[self.pos_dimension]
            if self._touch_data.length and self._touch_data.length < length then
                self._touch_data.direction_change = true
            else
                self._touch_data.direction_change = false
            end

            if length < -30 then
                length = -30
            elseif length >= self.drag_length then
                length = self.drag_length
            end
            self._touch_data.length = length
            if self.show_status then
                self:_show_background(length)
            else
                self:_show_foreground()
            end
        end
    end,
    on_touch_up = function(self, p, t)
        if self._capture  and not self._throw then
            self._capture = false
            if  self._touch_data.direction_change and  (( p[self.pos_dimension] - self._touch_data.start_point[self.pos_dimension] ) * self.drag_direction[self.pos_dimension]  > self._drag_length / 5 ) then 
                self:_anim_move(true)
            elseif ( p[self.pos_dimension] - self._touch_data.start_point[self.pos_dimension] ) * self.drag_direction[self.pos_dimension] < 0 then
                self:_anim_move(false,0.3,anim.overshoot(8))
            else
                self:_anim_move(false)
            end
        end
        self._throw = false
        self._drag_distance = 0
        self.need_capture = false
    end,
    on_touch_cancel = function ( self)
        self._capture = false
        self._throw = false
        self._drag_distance = 0
        self.need_capture = false
    end
}))








---
-- 创建一个指示器.
-- @callof #byui.Loading
-- @param #byui.Loading self 
-- @param #table args 构造参数列表.
--      style : string类型。loading的样式，可取 gray , white_large , white 三种。
--      hides_when_stopped : boolean类型。当停止动画的时候，是否隐藏。默认为true。
-- @return #byui.Loading 返回创建的指示器.


---
-- 指示器.
-- 有三种不同的样式,“white_large”尺寸是37*37,white尺寸是"22*22",gray尺寸是"22*22"。不要手动去改变它的大小和切换它的纹理。
-- 你要显示出来，在创建后必须调用start_animating().开启动画才能显示。在需要销毁的时候请调用stop_animating()。
-- @type byui.Loading

M.Loading = class('Loading', Sprite, {
    __init__ = function(self, args)
        super(M.Loading, self).__init__(self)
        self.style = args.style or 'white'  

        if args.hides_when_stopped then
            self.hides_when_stopped = args.hides_when_stopped
        else
            self.hides_when_stopped = true
        end
        local count = 0
        local t= 0
        self._handle = Clock.instance():schedule(function (dt)
            count  = (count + 1)--%360
            self.rotation = count * 30
        end,0.1)
        self._handle.paused  = true
        self.visible = false
    end,
    ---
    -- 当停止动画的时候，是否隐藏.
    -- 默认为true。
    -- @field [parent=#byui.Loading] #boolean hides_when_stopped 
    hides_when_stopped = {function(self)
        return self._hides_when_stopped
    end,function(self,v)
        if v then
            self._hides_when_stopped = true
        else
            self._hides_when_stopped = false
        end
    end
    },
    ---
    -- 指示器的样式.
    -- 有三种不同的样式,“white_large”尺寸是37*37,white尺寸是"22*22",gray尺寸是"22*22"。不要手动去改变它的大小和切换它的纹理。。
    -- @field [parent=#byui.Loading] #string style
    style = {function(self)
        return self._style
    end,function(self,v)
        self._style = v
        if self._style == 'gray' then
            self.unit = units.loading_gray
        elseif self._style == 'white_large' then
            self.unit = units.loading_white_large
        else
            self.unit = units.loading_white
        end
        self.size_hint = self.unit.size
        self.width_hug = kiwi.REQUIRED
        self.height_hug = kiwi.REQUIRED
        self:update_constraints()
    end
    },
    ---
    -- 开始动画.
    -- 你必须手动开始动画。
    -- @function [parent=#byui.Loading] start_animating
    -- @param #byui.Loading self 
    start_animating = function( self)
        if not self._handle then
            local count = 0
            self._handle = Clock.instance():schedule(function (dt)
                count  = (count + 1)--%360
                self.rotation = count * 30
            end,0.1)
        end
        self._handle.paused = false
        self.visible = true
    end,
    ---
    -- 停止动画.
    -- 在你需要移除指示器时，你必须停止动画，防止内存泄漏。
    -- @function [parent=#byui.Loading] stop_animating
    -- @param #byui.Loading self 
    stop_animating = function( self)
        if self._handle then
            self._handle:cancel() 
        end
        self._handle = nil
        if self._hides_when_stopped then
            self.visible = false
        end
    end,
    ---
    -- 是否在动画中.
    -- @function [parent=#byui.Loading] is_animating
    -- @param #byui.Loading self 
    -- @return #boolean 如果在动画则返回true,否则返回false。
    is_animating = function(self)
        return self._handle and not self._handle.stopped
    end,
})




local MenuItem
MenuItem = class('MenuItem', M.Button, {
    __init__ = function(self, args)
        local multiply = 3/7
        args.margin = args.margin or {CLabel.get_default_line_height(),CLabel.get_default_line_height()*multiply,CLabel.get_default_line_height(),CLabel.get_default_line_height()*multiply}
        -- print("args.title",args.margin[1],args.margin[2],args.margin[3],args.margin[4])
        args.radius = 0
        args.image = {
            normal = {
                unit = units.circle,
                color = Colorf(0.0,0.0,0.0,1.0)
            },
            down = {
                unit = units.circle,
                color = Colorf(0.5,0.5,0.5,1.0)
            },
            disabled = {
                unit = units.circle,
                color = Colorf(0.3,0.3,0.3,1.0)
            },
        }
        self.title = args.title or "MenuItem"
        args.text = args.title
        args.on_click = args.action
        self.args = args
        -- args.size = Point(85,41)
        super(MenuItem, self).__init__(self,args)
        self.v_border = {0,10,0,10}
        self.on_state_changed = function ( self )
            self.image_state = self._state
            -- M.share_menu_controller():_item_status_change(self,self._state)
        end
        -- self:add_rules({AL.height:eq(3*CLabel.get_default_line_height())})
        self.height_hint = CLabel.get_default_line_height() + args.margin[2] + args.margin[4]
    end,
    on_touch_down = function(self, p, t)
        if self.state ~= "disabled" then
            self.state = 'down'
            self._down = p
        end
    end,
    on_touch_move = function(self, p, t)
        if self.state ~= "disabled" then
            if (self._down.x - p.x)^2 +  (self._down.y - p.y)^2  < 100^2 then
                self.state = 'down'
            else
                self.state = 'normal'
            end
        end
    end,
    on_touch_up = function(self, p, t)
        if self.state ~= "disabled" then
            self.state = 'normal'
            if self:point_in(p) and self.on_click then
                if self.title  ~= "&lt;" and self.title  ~= "&gt;" then
                    M.share_menu_controller():set_menu_visible(false,true)
                end
                self:on_click(p, t)
            end
        end
    end,
}, true)
local  MenuController
MenuController = class('MenuController', Widget, mixin(M.EventHandler,{
    __init__ = function(self, args)
        self._label_line_height = CLabel.get_default_line_height()
        -- self._label_line_height  = 25
        super(MenuController, self).__init__(self,args)
        -- M.EventHandler.__init__(self,args)
        self._content = BorderSprite()
        self._content.unit = units.circle
        self._content.self_colorf = Colorf(1.0,1.0,1.0,0.5)
        self._content.t_border = {units.circle.size.x/2,units.circle.size.y/2,units.circle.size.x/2,units.circle.size.y/2}
        self._content.v_border = {15,15,15,15}
        -- self._content.clip = true

        self:add(self._content)

        self._items = {}
        self._page_item = {}
        self._anim = anim.Animator()
        self._menu_visible = false
        self._target_view = Window.instance().drawing_root
        self._arrow_direction = kMenuControllerArrowDefault

        -- 
        self._arrow = BorderSprite()
        self._arrow.unit = units.bottom_triangle
        self._arrow.size = units.bottom_triangle.size
        self._arrow.self_colorf = Colorf(0.0,0.0,0.0,1.0)
        self:add(self._arrow)


        self._items_width = 0
        self._items_size = {}
        self._target_rect = Rect(0,0,0,0)
        self._anim.on_stop = function ( ... )
            if self._menu_visible then
                Window.instance().drawing_root:add(self)
            else
                self:remove_from_parent()
                for k,v in ipairs(self._items) do
                    v:remove_from_parent()
                    v = nil
                end
            end
            self.opacity = 1.0
        end
        self._space = 2
        self._radius = 9
        self.on_size_changed = function ( _ ) 
            self:_update_menu_item()
        end
        -- self:add_rules(AL.rules.fill_parent)
        local multiply = 3/7
        self._left_arrow_item = MenuItem{
                    title  = "&lt;",
                    margin = {self._label_line_height/3,self._label_line_height*multiply,self._label_line_height/3,self._label_line_height*multiply},
                    action = function (  )
                        self:_prev_page()
                    end,
                }
        self._right_arrow_item = MenuItem{
                    title  = "&gt;",
                    margin = {self._label_line_height/3,self._label_line_height*multiply,self._label_line_height/3,self._label_line_height*multiply},
                    action = function (  )
                        self:_next_page()
                    end,
                }
        self._left_arrow_item.v_border = {10,10,0,10}
        self._right_arrow_item.v_border = {0,10,10,10}
        self._left_arrow_item.visible = false
        self._right_arrow_item.visible = false
        self._right_arrow_item.label:update(false)
        self._left_arrow_item.label:update(false)
        self._left_arrow_item_width = self._left_arrow_item.label.width + self._left_arrow_item.margin[1] +self._left_arrow_item.margin[3] 
        self._right_arrow_item_width = self._right_arrow_item.label.width + self._right_arrow_item.margin[1] +self._right_arrow_item.margin[3] 
        self._content:add(self._left_arrow_item)
        self._content:add(self._right_arrow_item)

        self._page_index = 1
        self.zorder = 255
    end,
    set_menu_visible = function ( self,menuVisible,animated )
        animated = false
        -- print("menuVisible",menuVisible,"animated",animated))
        if menuVisible then
            --TODO:pos
            self:_update_menu_item()
            self._menu_visible = true
            if animated then
                self:_anim_visible(true)
            else
                -- self.size = Window.instance().drawing_root.size
                Window.instance().drawing_root:add(self)
            end
        else
            self._menu_visible = false
            if animated then
                self:_anim_visible(false)
            else
                self:remove_from_parent()
                for k,v in ipairs(self._items) do
                    v:remove_from_parent()
                    v = nil
                end
                self._items = {}
                self._page_item = {}
            end
        end
    end,
    set_target_rect = function ( self,rect ,view )
        self._target_rect = rect or Rect(0,0,0,0)
        self._target_view = view or Window.instance().drawing_root
    end,
    _update_menu_item = function ( self )
        local root_width = Window.instance().drawing_root.width
        local root_height = Window.instance().drawing_root.height
        local arrow_pos = Window.instance().drawing_root:from_world(self._target_view:to_world(Point(self._target_rect.x,self._target_rect.y)))
        arrow_pos.x =  arrow_pos.x + self._target_rect.w/2 - self._arrow.width/2
        arrow_pos.y =  arrow_pos.y - self._arrow.height
        if arrow_pos.x < self._radius * 2 + self._label_line_height then
            arrow_pos.x = self._radius * 2 + self._label_line_height
        elseif arrow_pos.x > root_width -  (self._radius * 2 + self._label_line_height + self._arrow.width) then
            arrow_pos.x = root_width -  (self._radius * 2 + self._label_line_height + self._arrow.width)
        end
        if arrow_pos.y - self._content.height <  0 then
            arrow_pos.y = self._target_rect.h + self._arrow.height  + arrow_pos.y
            self._arrow.unit = units.top_triangle
            self._arrow.size = units.top_triangle.size
            self._content.y = arrow_pos.y + self._arrow.height
        else
            self._arrow.unit = units.bottom_triangle
            self._arrow.size = units.bottom_triangle.size
            self._content.y = arrow_pos.y - self._content.height
        end 
        self._arrow.pos = arrow_pos
        self._content.x = self._arrow.x + self._arrow.width/2 - self._content.width/2 

        self._page_index = 1
        self._left_arrow_item.visible = false
        self._right_arrow_item.visible = false 
        for i,v in ipairs(self._items) do
            v.label:update(false)
            if self._items[i-1] then
                v.pos = Point(self._items[i-1].x + self._items_size[i-1].x + self._space   ,0 )
            end
            v.visible = true
            v.size_hint = self._items_size[i]
            v:update_constraints()
        end
        self._items_width = self._items_size[#self._items_size].x  + self._items[#self._items].x
        self._content.size = Point(self._items_width,self._items_size[#self._items_size].y)
        if #self._items  == 1 then
            self._items[1].v_border = {10,10,10,10}
        elseif #self._items ~= 0 then
            self._items[1].v_border = {10,10,0,10}
            self._items[#self._items].v_border = {0,10,10,10} 
        end 
        self:_split_page()
        if self._content.x < self._label_line_height then
            self._content.x = self._label_line_height
        end
        if self._content.x + self._content.width > root_width - self._label_line_height then
            self._content.x = root_width - self._label_line_height - self._content.width
        end
    end,
    update_menu = function ( self )
        if self._arrow_direction == kMenuControllerArrowUp then
            self._arrow.unit = units.top_triangle
            self._arrow.size = units.top_triangle.size
        elseif self._arrow_direction == kMenuControllerArrowLeft then
            self._arrow.unit = units.left_triangle
            self._arrow.size = units.left_triangle.size
        elseif self._arrow_direction == kMenuControllerArrowRight then
            self._arrow.unit = units.right_triangle
            self._arrow.size = units.right_triangle.size
        else
            self._arrow.unit = units.bottom_triangle
            self._arrow.size = units.bottom_triangle.size
        end
    end,
    _split_page = function ( self )
        if self._content.width > Window.instance().drawing_root.width - 2*self._label_line_height then
            self._page_item = {}
            local length = 0
            -- 下一页至少留两个
            local index = #self._items - 2
            for i=1,#self._items - 2 do
                local temp = length + self._items_size[i].x + self._space
                if temp < Window.instance().drawing_root.width - 2*self._label_line_height then
                    length = temp
                    index = i
                else
                    index = i-1
                    break
                end
            end
            length = 0
            self._page_item[1] = {}
            for i=1,index do
                length = length + self._items_size[i].x + self._space
                table.insert(self._page_item[1],self._items[i])
            end
            self._right_arrow_item.pos = Point(length,0)
            self._right_arrow_item.visible = true
            self._right_arrow_item.state = "normal"
            self._content.size = Point(length + self._right_arrow_item_width,self._content.height)
            length = 0
            self._page_item[2] = {}
            for i=index + 1,#self._items do
                self._items[i].visible = false
                local temp = length + self._items_size[i].x + self._space
                if temp < self._content.width - 2*(self._left_arrow_item_width) then
                    length = temp
                else
                    length = self._items_size[i].x + self._space
                    self._page_item[#self._page_item + 1] = {}
                end
                table.insert(self._page_item[#self._page_item],self._items[i])
            end
            for i=2,#self._page_item do
                for key,value in ipairs(self._page_item[i]) do
                    value.width_hint = (self._content.width - 2 * (self._right_arrow_item_width) - (#self._page_item[i] + 1)*self._space)/#self._page_item[i]
                    value.v_border = {0,10,0,10}
                    value.x = value.width_hint *(key - 1) + self._space * key + self._right_arrow_item_width 
                    local size_hint = value.size_hint
                    value:update_constraints()
                    Clock.instance():schedule_once(function ( ) 
                        Clock.instance():schedule_once(function (  ) 
                            Clock.instance():schedule_once(function (  )
                             value.size_hint = size_hint value:update_constraints() 
                             -- print("size_hint",size_hint)
                             end) end) end) end
            end
        end
    end,
    set_menu_items = function ( self ,value )
        for k,v in ipairs(self._items) do
            v:remove_from_parent()
            v = nil
        end
        self._items = {}
        self._items_size = {}
        for i,v in ipairs(value) do
            local item = MenuItem{
                title  = v.title,
                action = v.action,
            }
            item.label:update(false)
            table.insert(self._items,item)
            table.insert(self._items_size,Point(self._items[i].label.width + self._items[i].margin[1] +self._items[i].margin[3],self._items[#self._items].label.height + self._items[#self._items].margin[2] +self._items[#self._items].margin[4]))
            if self._items[i-1] then
                self._items[i].pos = Point(self._items[i-1].x + self._items_size[i-1].x + self._space  ,0 )
            end
            self._content:add(self._items[i])
        end
        self._items_width = self._items_size[#self._items_size].x + self._items[#self._items].x
        self._content.size = Point(self._items_width,self._items_size[#self._items_size].y)
        if #self._items  == 1 then
            self._items[1].v_border = {10,10,10,10}
        elseif #self._items ~= 0 then
            self._items[1].v_border = {10,10,0,10}
            self._items[#self._items].v_border = {0,10,10,10} 
        end 
    end,
    _anim_visible = function(self,status)
        self._anim:stop()
        if status then
            ui_utils.play_attr_anim(self._anim, {
            {self,"opacity", 1.0},
            }, 0.15)
        else
            ui_utils.play_attr_anim(self._anim, {
            {self,"opacity", 0},
            }, 0.15)
        end
    end,
    _prev_page = function ( self )
        for i,v in ipairs(self._page_item[self._page_index]) do
            v.visible = false
        end
        for i,v in ipairs(self._page_item[self._page_index - 1]) do
            v.visible = true
        end
        self._page_index = self._page_index - 1
        
        if self._page_index == 1 then
            self._left_arrow_item.visible = false
        else
            self._left_arrow_item.visible = true
        end
        self._right_arrow_item.state = "normal"
    end,
    _next_page = function ( self )
        for i,v in ipairs(self._page_item[self._page_index]) do
            v.visible = false
        end
        for i,v in ipairs(self._page_item[self._page_index + 1]) do
            v.visible = true
        end
        
        self._page_index = self._page_index + 1
        if self._page_index == #self._page_item then
            self._right_arrow_item.state = "disabled"
        else
            self._right_arrow_item.state = "normal"
        end
        self._left_arrow_item.visible = true
    end,
}), true)

local _share_menu_controller = nil
M.share_menu_controller = function ( )
    if not _share_menu_controller then
        _share_menu_controller = MenuController{}
    end
    return _share_menu_controller
end
local Keyboard
Keyboard = class('Keyboard',nil, {
    __init__ = function(self, args)
        Application.instance().on_keyboard = function(action, arg)
            if action == Application.KeyboardHide then
                self._keyboard_status = false
                -- if self._old_keyboard_delegate and self._old_keyboard_delegate._keyboard_event then
                --     local ret = self._old_keyboard_delegate:_keyboard_event(action, arg)
                --     self._old_keyboard_delegate = nil
                --     return ret
                -- end
                M.share_menu_controller():set_menu_visible(false,false)
            elseif action == Application.KeyboardShow then
                self._keyboard_status = true
            end
            if self._on_keyboard then
                return self._on_keyboard(action, arg)
            end
        end
        self._keyboard_status = false
    end,
    ---
    -- 键盘的状态.
    -- 默认为false,即未开启键盘。为true则键盘处于开启状态。
    -- @field [parent=#byui.Keyboard] #boolean keyboard_status 
    -- @usage
    -- byui.share_keyboard_controller().keyboard_status = false 通知系统关掉键盘.
    keyboard_status = {function ( self )
        return self._keyboard_status
    end,function ( self,v )
        if (v and not self._keyboard_status) or (not v and self._keyboard_status) then
            self._keyboard_status = v
            if v then
                Application.instance():SetKeyboardState(true)
            else
                Application.instance():SetKeyboardState(false)
            end
        end
    end},
    ---
    -- 键盘的配置.
    -- @field [parent=#byui.Keyboard] #table keyboard_config 
    -- @usage
    -- byui.share_keyboard_controller().keyboard_config = {
    --      type = Application.KeyboardTypeDecimalPad, -- 键盘的类型
    --      return_type = Application.ReturnKeySearch,   -- 键盘的返回按键的类型:
    --      appearance = Application.KeyboardAppearanceDark, -- 键盘出现的风格
    --      secure = true,                                            -- 是否为密码框
    --      auto_capitalization = Application.KeyboardAutocapitalizationTypeWords, -- 是否自动大写
    --      }
    keyboard_config = {function ( self )
        return self._keyboard_config
    end,function ( self,v )
        self._keyboard_config = v
        Application.instance():ConfigKeyboard(self._keyboard_config)
    end},
     ---
    -- 键盘事件回调.
    -- @field [parent=#byui.Keyboard] #function on_keyboard 
    -- @usage
    -- M.share_keyboard_controller().on_keyboard = function(action, arg)
    --      if action == Application.KeyboardShow then
    --          -- keyboard is shown
    --      elseif action == Application.KeyboardHide then
    --          -- keyboard is hide
    --      elseif action == Application.KeyboardInsert then
    --          -- arg is the text to be inserted
    --      elseif action == Application.KeyboardDeleteBackward then
    --          -- arg is the number of deletions.
    --      elseif action == Application.KeyboardSetMarkedText then
    --          -- arg is the marked text.
    --      end
    --end
    on_keyboard = {function ( self )
        return self._on_keyboard
    end,function ( self,v )
        self._on_keyboard = v
    end},
    keyboard_delegate = {function ( self )
        return self._keyboard_delegate
    end,function ( self,value )
        if value then
            self._old_keyboard_delegate = self._keyboard_delegate
        else
            self._old_keyboard_delegate = nil
        end
        self._keyboard_delegate = value
    end},
    ---
    -- 模拟键盘的输入事件.
    -- 会给当前有输入焦点的键盘发送模拟的键盘输入事件，从而可以自定义的输入.
    -- @function [parent=#byui.Keyboard]  insert 
    -- @param #byui.Keyboard self
    -- @param #string str 需要插入的文字.
    -- @usage
    -- M.share_keyboard_controller():insert('hello')
    insert = function ( self,str )
        str = str or ''
        assert(type(str) == 'string',"the 'str' must be string (a " .. type(str) .. " value )")
        if Application.instance().on_keyboard then
            Application.instance().on_keyboard(Application.KeyboardInsert,str)
            return true
        end
        return false
    end,
    ---
    -- 模拟键盘的删除事件.
    -- 会给当前有输入焦点的键盘发送模拟的键盘删除事件，在最后的光标处向前删除.
    -- @function [parent=#byui.Keyboard]  delete 
    -- @param #byui.Keyboard self
    -- @param #number count 需要删除的字符个数.默认为1.
    -- @usage
    -- M.share_keyboard_controller():delete()
    delete = function ( self,count )
        count = count or 1
        assert(type(count) == 'number',"the 'count' must be number (a " .. type(count) .. " value )")
        if Application.instance().on_keyboard then
            Application.instance().on_keyboard(Application.KeyboardDeleteBackward,count)
            return true
        end
        return false
    end,
})
local _share_keyboard_controller = nil

---
-- 键盘控制类的实例.
-- @function [parent=#byui] share_keyboard_controller
-- @return #byui.Keyboard 返回键盘控制的实例.
-- @usage 
-- local byui = require 'byui.basic'
-- byui.share_keyboard_controller().keyboard_status = true  开启键盘
-- byui.share_keyboard_controller().on_keyboard = function(action, arg) -- 设置键盘回调事件
--      if action == Application.KeyboardShow then
--          -- keyboard is shown
--      elseif action == Application.KeyboardHide then
--          -- keyboard is hide
--      elseif action == Application.KeyboardInsert then
--          -- arg is the text to be inserted
--      elseif action == Application.KeyboardDeleteBackward then
--          -- arg is the number of deletions.
--      elseif action == Application.KeyboardSetMarkedText then
--          -- arg is the marked text.
--      end
--end
--byui.share_keyboard_controller().keyboard_config = {
--      type = Application.KeyboardTypeDecimalPad, -- 键盘的类型
--      return_type = Application.ReturnKeySearch,   -- 键盘的返回按键的类型:
--      appearance = Application.KeyboardAppearanceDark, -- 键盘出现的风格
--      secure = true,                                            -- 是否为密码框
--      auto_capitalization = Application.KeyboardAutocapitalizationTypeWords, -- 是否自动大写
--      }
--
M.share_keyboard_controller = function ( )
    if not _share_keyboard_controller then
        _share_keyboard_controller = Keyboard{}
    end
    return _share_keyboard_controller
end
return M

end
        

package.preload[ "byui.simple_ui" ] = function( ... )
    return require('byui/simple_ui')
end
            

package.preload[ "byui/tableview" ] = function( ... )
local Scroll = require('byui/scroll');
local class, mixin, super = unpack(require('byui/class'))
local M = {}

M.TableView = class('TableView', Scroll.ScrollView, {
    __init__ = function(self, args)
    	args.dimension = args.dimension == kHorizental and kHorizental or kVertical 
    	super(M.TableView, self).__init__(self, args);
    	self.pos_dimension = args.dimension == kVertical and 'y' or 'x'
    	self.container = Widget()
        self.container.relative = true
        self.content = self.container

    	self._item_length = args.item_length;
    	self._item = args.item;
    	self._item_count = args.item_count;

    	self.create_top_view = args.create_top_view
        self.create_bottom_view = args.create_bottom_view

    	self.min_load_ahead_multiple = args.min_load_ahead_multiple or 1; -- Multiple of content length
    	self.free_back_multiple = args.free_back_multiple or 0;

    	self._cell_spacing = args.cell_spacing or 1;

    	self.size = args.size

    	self._cache = {	cells={},
    					pos={0}, -- the first always be 0 
    					range={1,1}, --[1,1)
						max_count = self:_item_count(),
    					};

    	local length = self:_init_cell_pos();

    	self.container.size = Point(self.width,length);
    	
    	self:on_scroll(Point(0,0),Point(-1,-1),Point(0,0));
    end,

    --return length
    _init_cell_pos = function(self)
    	local cache_pos = self._cache.pos;

    	local cur_cache_count = #cache_pos;
    	local max_count = self._cache.max_count;
    	
		for i=cur_cache_count+1,max_count do 
			cache_pos[i] = cache_pos[i-1] + self:_item_length(i-1) + self._cell_spacing;
		end

		cache_pos[max_count+1] = cache_pos[max_count] + self:_item_length(max_count);
		return cache_pos[max_count+1];
	end,

	_load_one = function(self,i)
		assert(self._cache.cells[i] == nil,"invaild load " .. i);
    	local cell = self:_item(i);
    	self.container:add(cell);
		cell.width = self.width;
		cell.y = self._cache.pos[i];
		self._cache.cells[i] = cell;
    	return cell;
	end,

	_free_one = function(self,i)
		local cell = self._cache.cells[i];
		assert(cell,"invaild free" .. i);
		cell:remove_from_parent();
		self._cache.cells[i] = nil;
	end,

	_load = function(self, from, to)
		local range = self._cache.range;

		local cache_beg = self._cache.pos[range[1]];
		local cache_end = self._cache.pos[range[2]];

		local max_count = self._cache.max_count;

		while range[1] > 1 and from < cache_beg  do -- include range[0]
			print("load");
			range[1] = range[1] - 1;
			local cell = self:_load_one(range[1]);
			-- self.container:add(cell);
			cache_beg = self._cache.pos[range[1]];
		end

		while to > cache_end and range[2] <= max_count do -- exclude range[1]
			print("load");
			local cell = self:_load_one(range[2]);
			range[2] = range[2] + 1;
			cache_end = self._cache.pos[range[2]];
		end
	end,

	_free = function(self, free_to, direction)
		local range = self._cache.range;

		local cache_end = self._cache.pos[range[2]];

		local max_count = self._cache.max_count;

		if direction < 0 then -- from cache_beg to free_to
			local cache_beg_bottom = self._cache.pos[range[1] + 1];

			while range[1] <= max_count and free_to > cache_beg_bottom  do --
				print("free");
				self:_free_one(range[1]);
				range[1] = range[1] + 1;
				cache_beg_bottom = self._cache.pos[range[1] + 1];
			end
		else --from free_to to cache_end
			local cache_end_top = self._cache.pos[range[2]-1];

			while free_to < cache_end_top and range[2] > 1 do
				print("free");
				range[2] = range[2] - 1;
				self:_free_one(range[2]);
				cache_end_top = self._cache.pos[range[2]-1];
			end
		end
	end,

	_dump = function(self)
		print("dump: ")
		for i=1,self._cache.max_count do
			print("" .. i .. " " .. tostring(self._cache.cells[i]));
		end
	end,

	-- _move_item_before = function(self,from_index, to_index, diff_index, diff_length)

	-- 	for i = from_index, to_index, 1 do
	-- 		self._cache.pos[i+diff_index] = self._cache.pos[i] + diff_length;
	-- 		if self._cache.cells[i] ~= nil then
	-- 			self._cache.cells[i+diff_index] =  self._cache.cells[i];
	-- 			self._cache.cells[i+diff_index].y = self._cache.pos[i+diff_index];
	-- 			self._cache.cells[i] = nil;
	-- 		end
	-- 	end

	-- 	return from_index + diff_index;
	-- end,

	_move_item = function(self,from_index, to_index, diff_index, diff_length)
		print("move " .. from_index .. " " .. to_index .. " "..  diff_index);
		local init_value;
		local end_value;
		local acc;
		if diff_index > 0 then
			init_value = to_index;
			end_value = from_index;
			acc = -1;
		else
			init_value = from_index;
			end_value = to_index;
			acc = 1;
		end

		for i = init_value, end_value, acc do
			print("move" .. i);
			self._cache.pos[i+diff_index] = self._cache.pos[i] + diff_length;
			if self._cache.cells[i] ~= nil then
				self._cache.cells[i+diff_index] =  self._cache.cells[i];
				self._cache.cells[i+diff_index].y = self._cache.pos[i+diff_index];
				self._cache.cells[i] = nil;
			end
		end

		return from_index + diff_index;
	end,

	insert = function(self, indices)
		assert(type(indices)=="table")
		table.sort(indices, function(a,b) return a<b end);
		local count = #indices;

		local length_acc = {0};
		for i=2,count+1 do 
			length_acc[i] = length_acc[i-1] + self:_item_length(i) + self._cell_spacing;
		end

		self:_dump();

		indices[count + 1] = self._cache.max_count+1;
		for i = count, 1, -1 do 
			local index = indices[i];
			local next_index = self:_move_item(indices[i],indices[i+1],i,length_acc[i+1]);
			local real_index = index + i - 1;

			self._cache.pos[real_index] = self._cache.pos[next_index] - (length_acc[i+1] - length_acc[i]);

			if index >= self._cache.range[1] and index < self._cache.range[2] then
				self:_load_one(real_index);
				self._cache.range[2] = self._cache.range[2] + 1;
			end
		end

		self._cache.max_count = self._cache.max_count + count;
	end,

	remove = function(self, indices)
		assert(type(indices)=="table")

		table.sort(indices, function(a,b) return a<b end);
		local count = #indices;

		local length_acc = {0};
		for i=2,count+1 do 
			length_acc[i] = length_acc[i-1] + self:_item_length(i) + self._cell_spacing;
		end

		indices[count + 1] = self._cache.max_count + 1;

		for i = 1, count do 
			local index = indices[i];

			if self._cache.cells[index] then
				self:_free_one(index);
			end

			if index+1 < indices[i+1]-1 then
				self:_move_item(index+1,indices[i+1]-1,-i,-length_acc[i+1])

				if index >= self._cache.range[1] and index < self._cache.range[2] then
					for j=1,i do
						self:_load_one(self._cache.range[2]-j);
					end
				end
			end
		end

		self._cache.max_count = self._cache.max_count - count;
	end,

	reload_cell = function(self, indices)
		if not indices then
			local  range = self._cache.range;
			for i=range[1],range[2] do
				if self._cache.cells[v] then
					self:_free_one(v);
					self:_load_one(v);
				end
			end
		else 
			for k,v in ipairs(indices) do 
				if self._cache.cells[v] then
					self:_free_one(v);
					self:_load_one(v);
				end
			end
		end
	end,
	
	on_scroll = function(self, value, direction, velocity)
        local dim_value = self.dimension == kVertical and self.height or self.width
		local load_ahead = math.max(math.abs(math.ceil(velocity[self.pos_dimension] * 0.2)), self.min_load_ahead_multiple*dim_value);
		local free_back = self.free_back_multiple * dim_value;

		if direction[self.pos_dimension] < 0 then 
        	self:_load(-value[self.pos_dimension] + dim_value, -value[self.pos_dimension] + dim_value + load_ahead);
        	self:_free(-value[self.pos_dimension]-free_back,direction[self.pos_dimension])
        else 
        	self:_load(-value[self.pos_dimension], -value[self.pos_dimension] + load_ahead);
        	self:_free(-value[self.pos_dimension]+dim_value+free_back,direction[self.pos_dimension]);
        end
    end,

    on_overscroll = function(self, overscroll)
        if overscroll[self.pos_dimension] == 0 then
            if self.top_view then
                self.top_view.visible = false
            end
            if self.bottom_view then
                self.bottom_view.visible = false
            end
        elseif overscroll[self.pos_dimension] > 0 then
            if self.create_top_view ~= nil and self.top_view == nil then
                self.top_view = self:create_top_view()
                self.top_view.x = self.width / 2
                self.top_view.zorder = -1
                self:add(self.top_view)
            end
            if self.top_view ~= nil then
                self.top_view.visible = true

                if self.top_view.on_overscroll  then
                	self.top_view:on_overscroll(overscroll[self.pos_dimension]);
                end

                if overscroll[self.pos_dimension] > self.top_view.height then
                    -- start refreshing
                    if not self._refreshing then
                    	print("refresh")
                        self.kinetic[self.pos_dimension].max = self.top_view.height
                        self:on_touch_cancel()
                        self._refreshing = true
                        if self.on_refresh then
                            self:on_refresh()
                        end
                    end
                end
            end
        else
            if self.top_view then
                self.top_view.visible = false
            end
            overscroll[self.pos_dimension] = math.abs(overscroll[self.pos_dimension])
            if self.create_bottom_view ~= nil and self.bottom_view == nil then
                self.bottom_view = self:create_bottom_view()
                self.bottom_view[self.pos_dimension] = self.height - 20
                self.bottom_view[self.pos_dimension == 'y' and 'x' or 'y'] = self.width / 2
                self.bottom_view.zorder = -1
                self:add(self.bottom_view)
            end
            if self.bottom_view ~= nil then
                self.bottom_view.visible = true;

                if self.bottom_view.on_overscroll  then
                	self.bottom_view:on_overscroll(overscroll[self.pos_dimension]);
                end

                if overscroll[self.pos_dimension] > self.bottom_view.height then
                    -- start refreshing
                    if not self._refreshing then
                    	print("refresh")
                        self.kinetic[self.pos_dimension].min = self.height - self.container.height - self.bottom_view.height;
                        self:on_touch_cancel()
                        self._refreshing = true
                        if self.on_refresh then
                            self:on_refresh()
                        end
                    end
                end
            end
        end
    end,
    cancel_refresh = function(self)
        -- stop refreshing
        self.kinetic[self.pos_dimension].max = 0
        self.kinetic[self.pos_dimension].min = self.height - self.container.height;
        self:on_touch_cancel()
        self._refreshing = false
    end,


 },true);

return M;

end
        

package.preload[ "byui.tableview" ] = function( ... )
    return require('byui/tableview')
end
            

package.preload[ "byui/test" ] = function( ... )
local M = require('byui/basic')
-- local M = require('byui/tableview')
local layout = require('byui/layout')
local units = require('byui/draw_res')
local AutoLayout = require('byui/autolayout')

local function test(root)
    local btn_image = TextureUnit(TextureCache.instance():get('weixin.png'))
    local btn = M.Button{
        text = '你好吗',
        margin = {10,10,10,10},
        radius = 10,
        image = {
            normal = TextureUnit(TextureCache.instance():get('weixin.png')),
            down = Colorf.red,
            disabled = {
                unit = TextureUnit(TextureCache.instance():get('weixin.png')),
                t_border = {0,0,0,0},
            },
        },
        size = Point(200,50),
    }
    btn.pos = Point(100,100)
    local toggle = true
    function btn:on_click(p, time)
        if toggle then
            self.text ='变长长~~~~~~~~~~~~'
            toggle = false
        else
            self.text = '变短'
            toggle = true
            btn.enabled = false
        end
    end
    root:add(btn)

    local radio1 = M.RadioButton{
        size = Point(50,50),
        checked = false,
    }
    -- chkbox.t_border = {20,20,20,20}
    --radio1.v_border = {25,25,25,25}
    --chkbox.size = Point(50,100)
    function radio1:on_change()
        print('on change', self.checked)
    end
    
    root:add(radio1)
    local radio2 = M.RadioButton{
        size = Point(50,50),
        checked = false,
        radius = 0,
    }
    -- chkbox.t_border = {20,20,20,20}
    --radio2.v_border = {25,25,25,25}
    radio2.pos = Point(50,0)
    
    --chkbox.size = Point(50,100)
    function radio2:on_change()
        print('on change', self.checked)
    end
    root:add(radio2)
    local radioGroup = M.RadioGroup{}
    function radioGroup:on_change(id)
        print('radioGroup on change', id)
    end
    function radioGroup:on_child_add(value)
        print('radioGroup on child add', value)
    end
    function radioGroup:on_child_remove(value)
        print('radioGroup on child remove', value)
    end
    radio2.group = radioGroup
    radio1.group = radioGroup
    local btn2 = M.ToggleButton{
        image = {
            checked_enabled = {
                unit = TextureUnit(TextureCache.instance():get('weixin.png')),
                t_border = {0,0,0,0},
            },
            unchecked_enabled = Colorf.red,
            --checked_disabled = TextureUnit(TextureCache.instance():get('btn_green_2.png')),
            --unchecked_disabled = TextureUnit(TextureCache.instance():get('btn_green_2.png')),
        },
        text = '选项1',
        radius = 10,
        size = Point(200,50),
    }
    btn2.pos = Point(300,0)
    function btn2:on_change()
        print('on change', self.checked)
    end
    root:add(btn2)

    local btn = M.Switch{
        on = false,
        on_tint = Colorf.red,
        on_change = function(self, v)
            print('switch', v)
        end,
    }
    btn.pos = Point(100,150)
    root:add(btn)


end

local function test_slider(root)
    local s = M.Slider{
        size = Point(500,30),
        thumb_size = Point(60,60)
    }
    function s:on_change()
        print('on change', s.value)
    end
    s.pos = Point(100,400)
    root:add(s)
    s.value = 1.0
    s.progress_bar.base_image =TextureUnit(TextureCache.instance():get("sliderBg.png"))
    s.thumb_image = TextureUnit(TextureCache.instance():get("sliderBtn.png"))
    s.maxinum_value = 100
    s.progress_bar.radius = 5
    -- local progressBar = M.ProgressBar{radius = 2,value = 0.5,size = Point(200,20)}
    -- progressBar.base_image = TextureUnit(TextureCache.instance():get("sliderBg.png"))
    -- Clock.instance():schedule(function ( ... )
    --         s.mininum_value = s.mininum_value -1
    -- end,1)
    -- root:add(progressBar)
end

local function test_switch(root)
    local s = M.Switch{
        on = false,
    }
    function s:on_change()
        print('on change', s.on)
    end
    s.pos = Point(100,400)
    root:add(s)
end

local function test_layers(root)
    local s = M.Layers{
        drag_direction = kDragToLeft,
        width = 500,
        height = 300,
        drag_length = 200,
    }
    s.pos = Point(100,400)

    --s.size = Point(300,400)
    local count = 0
    s:set_on_change_status_callback(function ( status)
        count = count +1
        print("count:",count)
        print("status:",status)
        print("status2:",s.show_status)
    end)
    local btn1 = M.Button{
       text = '这是前景',
       margin = {10,10,10,10},
       image = {
           normal = Colorf.green,
           down = Colorf.red,
           disabled = Colorf(0.2,0.2,0.2,1),
       },
       border = true,
       size = Point(200,50),
    }
    local btn2 = M.Button{
       text = '这是背景',
       margin = {10,10,10,10},
       image = {
           normal = Colorf(0.5,0.5,0.5,1.0),
           down = Colorf.red,
           disabled = Colorf(0.2,0.2,0.2,1),
       },
       border = true,
       size = Point(200,50),
    }
     function btn2:on_click(  )
        -- body
        s:show_foreground()
    end
    function btn1:on_click(  )
        -- body
        print("点别人去")
    end

    s.foreground_view = btn1
    s.background_view =btn2
    root:add(s)
end


local function test_tableview(root)
    local v;
    v = M.TableView{
        --dimension = kHorizental,
        row_height = 100,
        max_number = 200,
        item_length = function(self,i) 
        -- if i == 1 then
        --         return 400;
        --     end
            return 100;
        end,

        item_count = function(self,i)
            return 200
        end,


        item = function(self, i)
            print("load : " .. i);
            local c = Widget()
            c.width = 100
            c.height = 100
            local l = Label()
            l:set_rich_text(string.format('<font color=#ff0000>lucy %d</font>', i))
            c.background_color = Colorf.white
            c:add(l)

            local w = M.Switch{
                on = false,
                on_change = function(self, v)
                    print('switch', v)
                end,
            }
            w.need_capture = true
            w.pos = Point(100,10)
            c:add(w)

            local btn = M.Button{
                text = 'click me',
                image = {
                    normal = Colorf.green,
                    down = Colorf.red,
                    disabled = Colorf.black,
                },
                margin = {30,10,30,10},
                v_border = {10,10,10,10},

            }
            btn.pos = Point(230,20)
            function btn:on_click(self)
                    print("on_click")
                    v:reload_cell();
                end
            
            c:add(btn)
            c.cache = true
            c.clip = true
            return c
        end,
        create_top_view = function(self)
            local w = Widget()
            local l = Label()
            l:set_rich_text('top label hahaha')
            w:add(l)
            w.size = Point(1, 100)
            return w
        end,
        create_bottom_view = function(self)
            local l = Label()
            l:set_rich_text('bottom label hahaha')
            return l
        end,
        on_refresh = function(self)
            Clock.instance():schedule_once(function()
                self:cancel_refresh()
            end, 1)
        end,
        cell_spacing = 1,
        size = Point(root.width, root.height),
    }
    v.background_color = Colorf(0.6,0.6,0.6,1)
    root:add(v)
end

local function test_scrollview(root)
    local v = M.ScrollView{
        dimension = kVertical,
        -- event_phase = 'bubbling',
    }
    v.size = Point(300,300)
    local content = layout.FloatLayout{
        spacing = Point(10,10)
    }
    v.min_distance = Point(1,1)
    -- v.background_color = Colorf(1.0,1.0,1.0)
    content:add_rules(AutoLayout.rules.fill_parent)
    content.relative = true
    -- 
    root:add(v)
    v.content = content
    for i=1,10 do
        local s = Sprite(units.circle)
        s.size = Point(100,100)
        content:add(s)
    end
    content:add(M.Button{text='Button'})
    local s = M.Switch{}
    s.need_capture = true
    content:add(s)
    Clock.instance():schedule_once(function (  )
        local content = layout.FloatLayout{
        spacing = Point(10,10)
        }
        content.size = Point(500,500)
        content.relative = true
        for i=1,10 do
            local s = Sprite(units.left_triangle)
            s.size = Point(100,100)
            content:add(s)
        end
        v.content = content
    end,20)
end
local function test_loading( root )
    -- body
    local loading = M.Loading{
        style = 'white_large'
    }

    loading.pos = Point(200,150)
    --loading.colorf = Colorf(1.0,0.0,0.0,1.0)
    root.background_color = Colorf(0.8,0.8,0.8,1.0)
    root:add(loading)
    local btn1 = M.Button{
       text = '开始',
       margin = {10,10,10,10},
       image = {
           normal = Colorf.green,
           down = Colorf.red,
           disabled = Colorf(0.2,0.2,0.2,1),
       },
       border = true,
       size = Point(200,50),
    }
    local btn2 = M.Button{
       text = '停止',
       margin = {10,10,10,10},
       image = {
           normal = Colorf(0.5,0.5,0.5,1.0),
           down = Colorf.red,
           disabled = Colorf(0.2,0.2,0.2,1),
       },
       border = true,
       size = Point(200,50),
    }
    btn2.pos = Point(205,0)
    function btn1:on_click(  )
        -- body
        loading:start_animating()
    end
    function btn2:on_click(  )
        -- body
        loading:stop_animating()
    end
    
    local btn3 = M.Button{
       text = '切换风格',
       margin = {10,10,10,10},
       image = {
           normal = Colorf(0.5,0.5,0.5,1.0),
           down = Colorf.red,
           disabled = Colorf(0.2,0.2,0.2,1),
       },
       border = true,
       size = Point(200,50),
    }
    btn3.pos = Point(410,0)
    local count = 0
    function btn3:on_click(  )
        -- body
        count = (count+1)%3 
        if count == 0 then
            loading.style = 'white_large'
        elseif count ==1 then
            loading.style = 'white'
        else
            loading.style = 'gray'
        end
    end
    loading.hides_when_stopped =false
    root:add(btn1)
    root:add(btn2)
    root:add(btn3)
end

local function test_pageview(root)
    local page_view 
    page_view = M.PageView{
        dimension = kHorizental,
        max_number = 25,
        size = Point(root.width, root.height),
        --dimension = kHorizental,
        is_cache = true
    }
    root:add(page_view)
    -- Clock.instance():schedule_once(function ( ... )
        
    page_view.create_cell = function(self, i)
            local c = Widget()
            c.width = 100
            c.height = 100
            local l = Label()
            -- l:set_rich_text(string.format('<font color=#ff0000>lucy %d</font>', i))
            l:set_data{{
                text = "lucy "..i,
                size = i + 20,
                color = Color.red
            }}
            c.background_color = Colorf.white
            c:add(l)

            local w = M.Switch{
                on = false,
                on_change = function(self, v)
                    page_view.page_num = 199
                end,
            }
            w.need_capture = true
            w.pos = Point(100,100)
            c:add(w)

            local btn = M.Button{
                text = 'click me',
                image = {
                    normal = Colorf.green,
                    down = Colorf.red,
                    disabled = Colorf.black,
                },
                margin = {30,10,30,10},
                v_border = {10,10,10,10},
            }
            btn.pos = Point(230,20)
            c:add(btn)
            c.cache = true
            c.clip = true
            return c
        end
        page_view.background_color = Colorf(0.6,0.6,0.6,1)
        page_view:update_data()
    -- end,5)

    local page_control  = M.PageControl{
        dimension = page_view.dimension,
        number_of_pages = page_view.max_number,
        page_view = page_view,
        -- page_indicator_tint_color = Colorf(0.0,0.0,0.0,0.5),
        -- current_page_indicator_tint_color = Colorf(0.0,0.0,0.0,1.0),
    }
    if page_control.dimension == kVertical then
        page_control:add_rules({AutoLayout.height:eq(AutoLayout.parent('height')),AutoLayout.width:eq(34),AutoLayout.left:eq(AutoLayout.parent('width')  - 34),})
    else
        page_control:add_rules({AutoLayout.width:eq(AutoLayout.parent('width')),AutoLayout.height:eq(34),AutoLayout.top:eq(AutoLayout.parent('height')  - 34),})
    end
    page_view:add(page_control)
    page_control.background_color = Colorf(0.0,0.0,0.0,1.0)
    function page_view:on_page_change( value )
        print("page_control.current_page",value)
        page_control.current_page = value
    end
    local label = Label()
    label:set_data{{ text="fps:" .. tostring(math.ceil(Clock.instance().fps))
                    , color=Color(0,0,0)}}
    label.pos = Point(0,root.height - 40)
    root:add(label)
    Clock.instance():schedule(function (  )
        label:set_data{{ text="fps:" .. tostring(math.ceil(Clock.instance().fps))
                        , color=Color(0,0,0)}}
    end)
    Clock.instance():schedule_once(function ( ... )
        print("---------------------------------")
        page_view.is_cache = false
    end,5)
end
local function test_menu( root )
    -- body
    -- local container = Widget()
    -- local str = {"拷贝"}--,"Define","Share...","Tab"}
    -- local items = {}
    -- local width = 0
    -- local height = 0
    -- for i,v in ipairs(str) do
    --     local btn = M.MenuItem{
    --         title  = v,
    --         action = function (  )
    --             print("on_click:",v)
    --         end
    --         -- margin = {15,10,15,10},
    --         -- radius = 5,
    --         -- image = {
    --         --     normal = {
    --         --         unit = units.circle,
    --         --         color = Colorf(0.0,0.0,0.0,1.0)
    --         --     },
    --         --     down = {
    --         --         unit = units.circle,
    --         --         color = Colorf(0.5,0.5,0.5,1.0)
    --         --     },
    --         -- },
    --     }
    --     --btn.v_border = {0,10,0,10}
    --     btn.label:update(false)

    --     table.insert(items,btn)
    --     if items[i-1] then
    --         local size = items[i-1].label.size + Point(items[i-1].margin[1] + items[i-1].margin[3], items[i-1].margin[2] + items[i-1].margin[4])

    --         -- items[i].x = items[i-1].width + 20
    --         print("width",items[i-1].size.x,"height",height)
    --         items[i].pos = Point(items[i-1].x + size.x + 2  ,0 )
    --         -- print(v)
    --         height = size.y
    --         width = size.x + items[i].x
    --     end

    --     container:add(items[i])
    -- end
    -- print(width,height)
    -- local triangle = BorderSprite()
    -- triangle.unit = units.bottom_triangle
    -- triangle.size = triangle.unit.size
    -- triangle.colorf = Colorf(0.0,0.0,0.0,1.0)
    -- print(triangle.size)
    -- container:add(triangle)
    -- root:add(container)
    -- if items[1] then
    --     items[1].v_border = {10,10,0,10}
    --     items[#items].v_border = {10,10,10,10}
    --     triangle.pos = Point(width/2,height)
    -- end
    -- root:add(btn)
    local btn3 
    btn3= M.Button{
       text = '弹出菜单',
       margin = {10,10,10,10},
       image = {
           normal = Colorf(0.5,0.5,0.5,1.0),
           down = Colorf.red,
           disabled = Colorf(0.2,0.2,0.2,1),
       },
       border = true,
       size = Point(200,50),
       on_click = function (  )
           -- body
            local str = {"Copy","Define","Share...","Tab"}
            local items = {}
            for i,v in ipairs(str) do
                local item = M.MenuItem{
                    title  = v,
                    action = function (  )
                        print("on_click:",v)
                    end
                }
                table.insert(items,item)
            end
            local menu_controller = M.share_menu_controller()
            menu_controller.arrow_direction = kMenuControllerArrowUp
            btn3:to_world(Point(0,0))
            local point = Window.instance().drawing_root:from_world(btn3:to_world(Point(0,0)))
            menu_controller:set_target_rect(Rect(point.x,point.y,btn3.size.x,btn3.size.y))
            menu_controller:set_menu_items(items)
            menu_controller:set_menu_visible(true)
       end
    }
    --btn3.pos = Point(410,930)
    root:add(btn3)

    root.background_color = Colorf(0.5,0.5,1.0,1.0)
end

local function test_text_input(root)
    local lbl = M.TextInput{}
    lbl.pos = Point(10,100)
    lbl:set_rich_text('老师的减肥了<font color=#ff0000>洛杉矶的风景</font>老 师的减肥了\n老师江 东父 老拉开时间到了放假s')
    root:add(lbl)
    
    Clock.instance():schedule(function()
        -- lbl:insert('*')
    end, 1)
end

local function editbox( root )
    local start = os.clock()
    print("editbox begin",start)
    local edit = M.EditBox{background_style = KTextBorderStyleRoundedRect
                            ,icon_style = KTextIconMagnifier,
                            text = "<font color=#000000>hello world</font>",
                            hint_text = "<font color=#777777>Text</font>",
                            margin= {10,10,10,10},keyboard_secure = false}
    edit.pos = Point(100,100)
    -- edit.max_length = 5
    edit.size = Point(200,55)
    edit.name = "edit"
    -- edit.inspection_insert = function ( str )
    --     if not tonumber(str) or tonumber(str) > 7 then
    --         return ""
    --     end
    -- end
    edit.on_keyboard_hide = function ( ... )
        print_string("edit.on_keyboard_hide")
    end
    edit.on_keyboard_show = function ( ... )
        print_string("edit.on_keyboard_show")
    end
    -- edit.keyboard_type = Application.KeyboardTypeNumberPad
    -- edit.keyboard_secure = true
    root:add(edit)
    print("editbox end",os.clock() - start)

    local edit2 = M.EditBox{background_style = KTextBorderStyleBezel,icon_style = KTextIconMagnifier,keyboard_secure = true}
    -- edit2.max_length = 5
    edit2.pos = Point(100,200)
    
    edit2.size = Point(200,50)
    edit2.hint_text = "<font color=#777777>Text</font>"
    edit2.name = "edit2"
    edit2.text = "<font color=#aaaaaa>hello world</font>"
    -- edit2.keyboard_type = Application.KeyboardTypeWebSearch
    root:add(edit2)
print("editbox end",os.clock() - start)
    
    edit2.on_keyboard_hide = function ( ... )
        print_string("edit.on_keyboard_hide")
    end
    edit2.on_keyboard_show = function ( ... )
        print_string("edit.on_keyboard_show")
    end
    local edit3 = M.EditBox{background_style = KTextBorderStyleLine,icon_style = KTextIconDelete
    ,text = {{
    text  = "Text",
    color = Color(255,0.0,0.0)
    }}}
    edit3.pos = Point(100,300)
    
    edit3.size = Point(200,50)
    edit3.hint_text = "<font color=#aaaaaa>Text</font>"
    -- edit3.text = 
    -- edit3.keyboard_type = Application.KeyboardTypeASCIICapable
    root:add(edit3)
    -- Clock.instance():schedule_once(function (  )
    --     edit3.icon_style = KTextIconNone
    --     Clock.instance():schedule_once(function (  )
    --         edit3.icon_style = KTextIconDelete

    --     end,5)
    -- end,5)
    print("editbox end",os.clock() - start)
    local edit4 = M.EditBox{background_style = KTextBorderStyleNone,icon_style = KTextIconDelete}
    edit4.pos = Point(100,400)
    
    edit4.size = Point(200,50)
    edit4.name = "edit4"
    edit4.hint_text = {{
    text  = "Text",
    color = Color(255,0.0,0.0)

}}
    -- edit4.keyboard_type = Application.KeyboardTypeDecimalPad
    root:add(edit4)

    local  button = M.Button{
        margin = {20,20,20,20},
        text = "sssss",
    }
    root:add(button)

    local sss = BorderSprite()
    -- sss.background_color = Colorf(0.0,0.0,0.0)
    sss.pos = Point(500,0)
    sss.unit = units.small_magnifier
    sss.size = sss.unit.size
    root:add(sss)
    print("editbox end",os.clock() - start)

    Clock.instance():schedule_once(function ( ... )
        edit4:cleanup()
    end,2)

end
local function test_multiline_editbox( root )
    local mul_editbox = M.MultilineEditBox{expect_height = 95}--,margin = {0,0,0,0}}
    -- mul_editbox.background_color = Colorf(1.0,0.0,1.0,1.0)
    mul_editbox.size = Point(200,100)
    mul_editbox.pos = Point(100,100)
    mul_editbox.max_height = 300
    mul_editbox.hint_text = "<font color=#aaaaaa>Text</font>"
    print("-----",mul_editbox._label_container.pos)
    root:add(mul_editbox)

    local lbl_insert = Label()
    lbl_insert:set_simple_text('insert')
    lbl_insert.pos = Point(0,0)
    root:add(lbl_insert)

    local lbl_del  = Label()
    lbl_del:set_simple_text('del')
    lbl_del.pos = Point(0,100)
    root:add(lbl_del)

    M.init_simple_event(lbl_insert,function ( ... )
        print("insert")
        mul_editbox:registered_keyboard()
        M.share_keyboard_controller():insert('hello')
    end)

    M.init_simple_event(lbl_del,function ( ... )
        print("delete")
        M.share_keyboard_controller():delete()
    end)

    mul_editbox.on_keyboard_hide = function ( ... )
        lbl_insert:set_simple_text('insert_222')
    end

    
end
local function test_searchview( root )
    -- body
    -- local background_view = BorderSprite()
    -- background_view.unit = units.circle
    -- local tsize = units.circle.size
    -- background_view.t_border = {tsize.x/2,tsize.y/2,tsize.x/2,tsize.y/2}
    -- background_view.v_border = {17,17,17,17}
    -- background_view.colorf = Colorf(1.0,1.0,1.0,1.0)
    -- local edit = M.EditBox{background_style = KTextBorderStyleNone,
    --                         text = "<font color=#000000>hello world</font>",
    --                         hint_text = "<font color=#777777>Text</font>",
    --                         radius = 0}
    -- print(edit.line_height)
    -- -- edit.pos = Point(100,100)
    
    -- edit.size = Point(200,edit.line_height)
    -- edit.x = edit.line_height
    -- edit.y = 2
    -- background_view.size = Point(200 + 2*edit.line_height ,edit.line_height+4)
    -- background_view.pos = Point(100,100)
    -- background_view:add(edit)
    
    -- local left_icon = BorderSprite()
    -- left_icon.unit = units.small_magnifier
    -- tsize = units.small_magnifier.size
    -- left_icon.t_border = {tsize.x/2,tsize.y/2,tsize.x/2,tsize.y/2}
    -- left_icon.v_border = {tsize.x/2,tsize.y/2,tsize.x/2,tsize.y/2}
    -- left_icon.size = tsize
    -- left_icon.y =  (background_view.height - left_icon.height)/2 
    -- left_icon.x =  (background_view.height - left_icon.width)/2 
    -- background_view:add(left_icon)


    -- local right_icon = BorderSprite()
    -- right_icon.unit = units.del_icon_1
    -- tsize = units.del_icon_1.size
    -- right_icon.t_border = {tsize.x/2,tsize.y/2,tsize.x/2,tsize.y/2}
    -- right_icon.v_border = {tsize.x/2,tsize.y/2,tsize.x/2,tsize.y/2}
    -- right_icon.size = tsize
    -- right_icon.y =  (background_view.height - right_icon.height)/2 
    -- right_icon.x =  background_view.width -background_view.height+ (background_view.height - right_icon.width)/2 

    -- background_view:add(right_icon)
    -- root:add(background_view)
    -- local searchview = M.SearchView{text = "<font color=#000000></font>",
    --                         hint_text = "<font color=#777777>搜索</font>",radius = 5}
    -- searchview.size = Point(300,40)
    -- searchview.right_icon_units= nil
    -- root:add(searchview)
    local lbl = Label()
    lbl:set_data{{text = "取消",size = 32,color = Color(37,196,0)}}
    root:add(lbl)
    lbl:update(false)
    print("lbl",lbl.size)
end
local function test1(root)
    -- print("----")
    root.background_color = Colorf(1.0,1.0,1.0,1.0)
    test_slider(root)
    -- test_listview(root)
    --test(root)
    --test_layers(root)
    -- test_text_input(root)
    -- editbox(root)
    -- test_searchview(root)
    -- test_listview(root)
    -- test_multiline_editbox(root)
    Clock.instance():schedule(function (  )
        -- body
        root:invalidate()
    end)
    -- local scroll = M.ScrollView{dimension = kVertical}
    -- scroll.background_color = Colorf(1.0,1.0,0.0,1.0)
    -- scroll.pos = Point(100,100)
    -- local xxx = Widget()
    -- xxx.size = Point(200,1)
    -- -- xxx.relative = true 
    -- scroll.content = xxx
    -- scroll.size = Point(200,300)
    
    
    -- local lbl = Label()
    -- lbl:set_rich_text('fdsfsdfdsfdsfdsfsdfsf')
    -- xxx:add(lbl)
    -- root:add(scroll)
    -- local shadow_margin = 3
    -- thumb_vsize = Point(50,600)
    -- local thumb = RoundedView()
    --     thumb.size = thumb_vsize
    --     thumb.radius = (thumb_vsize.x - shadow_margin*2) / 2
    --     --self.thumb.y = -1
    --     thumb.colorf =  Colorf.white

    --     -- shadow
    --     thumb.need_shadow = true
    --     --self.thumb.need_box = false

    --     thumb.shadow_radius = thumb_vsize.x / 2
    --     thumb.shadow_margin = shadow_margin
    --     thumb.shadow_offset = Point(1,1)
    --     root:add(thumb)
end

function border( root )
    local unit = TextureUnit(TextureCache.instance():get('border.png'))
    local s = BorderSprite()
    s.unit = unit
    s.size = unit.size * 2
    local t_border = {0,0,0,0}
    local v_border = {0,0,0,0}
    s.t_border = t_border
    s.v_border = v_border
    local t_left = M.Slider{
        size = Point(500,30),
        thumb_size = Point(60,60)
    }
    t_left.mininum_value = 0
    t_left.maxinum_value = unit.size.x

    t_left.pos = Point(300,60)
    function t_left:on_change(value)
        t_border[1] = value
        s.t_border = t_border
    end
    local t_top = M.Slider{
        size = Point(500,30),
        thumb_size = Point(60,60)
    }
    t_top.mininum_value = 0
    t_top.maxinum_value = unit.size.y
    t_top.pos = Point(300,130)
    function t_top:on_change(value)
        t_border[2] = value
        s.t_border = t_border
    end
    local t_right = M.Slider{
        size = Point(500,30),
        thumb_size = Point(60,60)
    }
    t_right.pos = Point(300,200)
    t_right.mininum_value = 0
    t_right.maxinum_value = unit.size.x
    function t_right:on_change(value)
        t_border[3] = value
        s.t_border = t_border
    end
    local t_bottom = M.Slider{
        size = Point(500,30),
        thumb_size = Point(60,60)
    }
    t_bottom.pos = Point(300,270)
    t_bottom.mininum_value = 0
    t_bottom.maxinum_value = unit.size.y
    function t_bottom:on_change(value)
        t_border[4] = value
        s.t_border = t_border
    end
    local v_left = M.Slider{
        size = Point(500,30),
        thumb_size = Point(60,60)
    }
    v_left.mininum_value = 0
    v_left.maxinum_value = unit.size.x*2

    v_left.pos = Point(800,60)
    function v_left:on_change(value)
        v_border[1] = value
        s.v_border = v_border
    end
    local v_top = M.Slider{
        size = Point(500,30),
        thumb_size = Point(60,60)
    }
    v_top.mininum_value = 0
    v_top.maxinum_value = unit.size.y*2

    v_top.pos = Point(800,130)
    function v_top:on_change(value)
        v_border[2] = value
        s.v_border = v_border
    end
    local v_right = M.Slider{
        size = Point(500,30),
        thumb_size = Point(60,60)
    }
    v_right.mininum_value = 0
    v_right.maxinum_value = unit.size.x*2

    v_right.pos = Point(800,200)
    function v_right:on_change(value)
        v_border[3] = value
        s.v_border = v_border
    end
    local v_bottom = M.Slider{
        size = Point(500,30),
        thumb_size = Point(60,60)
    }
    function v_bottom:on_change(value)
        v_border[4] = value
        s.v_border = v_border
    end
    v_bottom.mininum_value = 0
    v_bottom.maxinum_value = unit.size.y*2

    v_bottom.pos = Point(800,270)
    root:add(s)
    root:add(t_left)
    root:add(t_top)
    root:add(t_right)
    root:add(t_bottom)
    root:add(v_left)
    root:add(v_top)
    root:add(v_right)
    root:add(v_bottom)

end


function simple_list_view( root )
    -- Clock.instance().maxfps =1 
    local xx_data = {{height = 200,color = Colorf(0.2,0.5,0.3)},
                {height = 300,color = Colorf(0.8,0.5,0.3)},
                {height = 50,color = Colorf(0.2,0.5,0.9)},
                {height = 100,color = Colorf(0.2,0.7,0.3)},
                {color = Colorf(0.2,0.3,0.3)},
                {height = 30,color = Colorf(1.0,0.5,0.3)},

                -- {height = 300,color = Colorf(math.random(),math.random(),math.random())}
            }

    local simple_list = M.ListView{
        -- cell_spacing = 30,
        size = Point(500,600),

        create_cell = function ( data )
            local w = Widget()
            w:add_rules({AutoLayout.width:eq(AutoLayout.parent('width'))})
            -- w.width = 500
            w.height = data.height or 100
            w.background_color = data.color or Colorf.white
            -- w:add(M.Button{text='Button'})
            return w
        end,
        distance_to_refresh = 50,
        -- dimension = kHorizental,
        -- update_cell = function (item, data )
        --     item.height = data.height or 100
        --     item.background_color = data.background_color or Colorf.white
        -- end,
    }
    local loading = M.Loading{
        style = 'white_large'
    }
    loading:add_rules(AutoLayout.rules.align(ALIGN.CENTER))
    simple_list.top_view:add(loading)
    simple_list.min_distance = Point(1,1)
    simple_list.on_refresh = function (flag )

        if flag then
            print("下拉刷新")
            -- simple_list.top_view.background_color = Colorf(1.0,1.0,0.5)
            loading:start_animating()
            Clock.instance():schedule_once(function ( ... )
                -- Clock.instance().maxfps = 1
                -- simple_list:insert({height = 300,color = Colorf(math.random(),math.random(),math.random())},1)
                -- simple_list:insert({height = 300,color = Colorf(math.random(),math.random(),math.random())},1)
                -- simple_list:insert({height = 300,color = Colorf(math.random(),math.random(),math.random())},1)
                -- simple_list:insert({height = 300,color = Colorf(math.random(),math.random(),math.random())},1)
                simple_list:insert({height = 300,color = Colorf(math.random(),math.random(),math.random())},1)
                simple_list:refresh_end(0.0)
                loading:stop_animating()
                -- Clock.instance():schedule_once(function ( ... )
                --     simple_list:scroll_to_bottom(1.0,function ( ... )
                --         print("-------------")
                --     end)
                -- end,2)
            end,5)

        else
            print("上拉刷新")
            simple_list.bottom_view.background_color = Colorf(0.5,1.0,0.5)

            Clock.instance():schedule_once(function ( ... )
                -- 
                -- print("insert refresh before ")
                print("simple_list.kinetic['y'].min before",simple_list.kinetic['y'].min)
                simple_list:insert({height = 300,color = Colorf(math.random(),math.random(),math.random())})
                
                Clock.instance():schedule_once(function ( ... )
                    -- body
                    print("insert refresh after ")
                print("simple_list.kinetic['y'].min",simple_list.kinetic['y'].min)
                
                    Clock.instance():schedule_once(function ( ... )
                    -- body
                    print("simple_list.kinetic['y'].min  2",simple_list.kinetic['y'].min)
                
                    
                    end)
                end)
                
                simple_list:refresh_end()
                print("simple_list.kinetic['y'].min after",simple_list.kinetic['y'].min)
            end,5)
        end
        
    end
    simple_list.background_color = Colorf(0.86,0.86,0.86)
    root:add(simple_list)
    Clock.instance():schedule_once(function (  )
        print("------------------------------------")
        simple_list.data = xx_data
        -- Clock.instance():schedule_once(function (  )
        --     -- body
        --     print('我要更新了')
        --     simple_list:update(3,{height = 600,color = Colorf(0.5,0.0,0.0)})
        --     Clock.instance():schedule_once(function (  )
        --         -- body
        --         print('我要追加了')
        --         simple_list:insert({height = 300,color = Colorf(1.0,0.0,0.0)})
        --          Clock.instance():schedule_once(function (  )
        --             -- body
        --             print('我要删除了')
        --             simple_list:delete(4)

        --             Clock.instance():schedule_once(function (  )
        --             -- body
        --             print('我要插入了')
        --             simple_list:insert({height = 300,color = Colorf(1.0,1.0,0.0)},3)
        --         end,2)
        --         end,2)
        --     end,10)

        -- end,5)
    end,2)
    Clock.instance():schedule(function ( ... )
        -- simple_list:cleanup()
        return true

    end,5)

end

function layout_demo( root )
    -- body
     -- local l = M.GridLayout{
    --     cols = 4,
    --     rows = 6,
    --     dimension = kHorizental,
    -- }

    local l = layout.FloatLayout{
       spacing = Point(0,5),
    }
    l.background_color = Colorf(0.5,0.5,0.5,1.0)
    l.size = Point(300,300)
    for i=1,2 do
        local s = Sprite()
        s.unit = TextureUnit.default_unit()
        s.size = Point(10,10)
        l:add(s)
        M.init_simple_event(s,function ( ... )
            local s = Sprite()
            s.unit = TextureUnit.default_unit()
            s:add_rules({AutoLayout.width:eq(AutoLayout.parent('width')),
                          AutoLayout.height:eq(100)  })
            l:add(s,l.children[1])
            Clock.instance():schedule_once(function ( ... )
                print("l.children[1]",l.children[2].pos)
                Clock.instance():schedule_once(function ( ... )
                    print("l.children[1]",l.children[2].pos)
                end)
            end)
        end)
    end
    -- Clock.instance():schedule(function ( ... )
    --     local s = Sprite()
    --     s.unit = TextureUnit.default_unit()
    --     s.size = Point(100,100)
    --     l:add(s)
        
    -- end,1)

    
    root:add(l)

    -- for k,v in pairs(ALIGN) do
    --     local align = {["k"] = k,["v"]=v}
    --     Clock.instance():schedule_once(function ( ... )
    --         l.align = align.v
    --     end,align.v*2)
    -- end
end
function test_propagate(root)
    local layer = Widget()
    layer:add_rules(AutoLayout.rules.fill_parent)
    layer.touch_enabled = false
    local btn
    btn = M.Button{text='button'}
    btn:add_rules(AutoLayout.rules.align(ALIGN.TOPLEFT))
    layer:add(btn)

    btn = M.Button{text='button'}
    btn:add_rules(AutoLayout.rules.align(ALIGN.TOPRIGHT))
    layer:add(btn)

    btn = M.Button{text='button'}
    btn:add_rules(AutoLayout.rules.align(ALIGN.BOTTOMLEFT))
    layer:add(btn)

    btn = M.Button{text='button'}
    btn:add_rules(AutoLayout.rules.align(ALIGN.BOTTOMRIGHT))
    layer:add(btn)

    btn = M.Button{text='button'}
    btn:add_rules(AutoLayout.rules.align(ALIGN.CENTER))
    Window.instance().drawing_root:add(btn)
    Window.instance().drawing_root:add(layer)
end
function test_bubbling(root)
    local p = Widget()
    p.size_hint = Point(200,200)
    p:add_listener(function(self, touch, canceled)
        print('click on self', touch.target == self)
        print('parent event', touch.action, canceled)
    end)
    local s = Sprite(TextureUnit.default_unit())
    s.size_hint = Point(100,100)
    s:add_listener(function(self, touch, canceled)
        touch:lock(self)
    end)
    p:add(s)
    Window.instance().drawing_root:add(p)
end

function scrollView2( root )
    local scroll1 = M.ScrollView{dimension = kVertical,}
    scroll1.size = Point(300,300)
    local scroll2 = M.ScrollView{dimension = kHorizental,}
    scroll2.size = Point(300,200)
    -- scroll2.min_distance = Point(10,10)
    local w = Widget()
    w.size =Point(300,500)
    w.background_color = Colorf.green
    w:add(scroll2)

    scroll1.content = w

    local w2 = Widget()
    w2.size = Point(600,200)
    w2.background_color = Colorf.red
    scroll2.content = w2
    root:add(scroll1)
end
return simple_list_view


end
        

package.preload[ "byui.test" ] = function( ... )
    return require('byui/test')
end
            

package.preload[ "byui/ui_utils" ] = function( ... )
local anim = require('animation')
local M = {}
local focus = nil
M.set_focus = function  ( obj )
    if focus ~= obj  then
        if focus and focus.on_focus_change then
            focus:on_focus_change(false)
        end
        focus = obj
    end 
    
end
M.get_focus = function ( )
    return focus
end

M.remove_focus = function (  )
    focus = nil
end

M.default_t_border = function (unit)
    return {unit.size.x / 2, unit.size.y / 2, unit.size.x / 2, unit.size.y / 2}
end

M.get_dimension = function (p, d)
    if d == kVertical then
        return p.y
    else
        return p.x
    end
end

M.play_attr_anim = function (animator, desc, duration)
    -- { { widget, name, to } }
    local anims = {}
    for i, d in ipairs(desc) do
        local a = anim.named(i, anim.value(d[1][d[2]], d[3]))
        if d[4] ~= nil then
            a = anim.timing(d[4], a)
        end
        table.insert(anims, a)
    end
    local function upd(v)
        for i, d in ipairs(v) do
            desc[i][1][desc[i][2]] = d
        end
    end
    local a = anim.spawn(unpack(anims))
    animator:start(anim.duration(duration or 1,a), upd)
end
return M
end
        

package.preload[ "byui.ui_utils" ] = function( ... )
    return require('byui/ui_utils')
end
            

package.preload[ "byui/utils" ] = function( ... )
---
-- 公共的工具模块.
-- @module byui.utils
-- @return nil

---
-- @type string
-- @extends string#string

---
-- 判断一个字符串是否为空
-- @function [parent=#string] empty
-- @param #string s 
function string.empty(s)
    return (s == nil) or (s == '')
end


---
-- @type table
-- @extends table#table

---
-- 将一个Table追加到指定的table.
-- @function [parent=#table] append
-- @param #table t
-- @param #table table 
function table.append(t, t1)
    for _, i in ipairs(t1) do
        table.insert(t, i)
    end
end

---
-- 拷贝一个table.
-- **这是一个浅拷贝**
-- @function [parent=#table] copy
-- @param #table t
-- @return #table 返回被拷贝的table.
function table.copy(t)
    local r = {}
    for k, v in pairs(t) do
        r[k] = v
    end
    return r
end

---
-- 合并两个table.
-- @function [parent=#table] merge
-- @param #table t1
-- @param #table t2
-- @param #boolean force 默认为true。如果为true则t2中所有值都会被写到t1中。为false则只有t1中不存在的key才会被写入。
-- @return #table 返回被拷贝的table.
function table.merge(t1, t2, force)
    if force == nil then
        force = true
    end
    for k, v in pairs(t2) do
        if force or t1[k] == nil then
            rawset(t1, k, v)
        end
    end
end

---
-- 连接table.
-- @function [parent=#table] concat_array
-- @param #table ...
-- @return #table 返回合并后的table.
function table.concat_array(...)
    local r = {}
    for _, t in ipairs{...} do
        for _, i in ipairs(t) do
            table.insert(r, i)
        end
    end
    return r
end

---
-- 在table中查找值为i的key.
-- @function [parent=#table] find
-- @param #table t
-- @param #obj i 任意类型的任意值.
-- @return #obj 如果找到则返回key，没有则返回nil.
function table.find(t, i)
    for k, v in pairs(t) do
        if v == i then
            return k
        end
    end
end

---
-- @{#engine.Colorf}转为@{#engine.Color}
-- @function [parent=#global] colorf_to_color
-- @param engine#Colorf x Colorf的对象.
-- @return engine#Color 转换后的Color对象.
function colorf_to_color(x)
    return Color(x.r * 255, x.g * 255, x.b * 255, x.a * 255)
end

---
-- @{#engine.Color}转为@{#engine.Colorf}
-- @function [parent=#global] color_to_colorf
-- @param engine#Color x Color的对象.
-- @return engine#Colorf 转换后的Colorf对象.
function color_to_colorf(x)
    return Colorf(x.r / 255, x.g / 255, x.b / 255, x.a / 255)
end

local trigger_meta = {
    __call = function(self)
        if self.handler == nil or self.handler.stopped then
            self.handler = Clock.instance():schedule_once(function(dt)
                self.handler = nil
                self.fn(dt)
            end, self.interval)
        end
    end,
    cancel = function(self)
        if self.handler ~= nil then
            self.handler:cancel()
            self.handler = nil
        end
    end,
}
function trigger(fn, interval)
    return setmetatable({
        fn = fn,
        handler = nil,
        interval = interval,
    }, trigger_meta)
end

-- object system
-- class, mixin, super = unpack(require('byui/class'))

-- debug
inspect = require('byui/inspect')
dbg = require('byui/debugger')

-- constants

---
-- 手指按下事件
-- @field [parent=#global] #number kFingerDown 
kFingerDown		= 0;

---
-- 手指移动事件
-- @field [parent=#global] #number kFingerMove 
kFingerMove		= 1;

---
-- 手指抬起事件
-- @field [parent=#global] #number kFingerUp 
kFingerUp		= 2;

---
-- 手指事件被取消.
-- @field [parent=#global] #number kFingerCancel 
kFingerCancel	= 3;


---
-- 水平方向.
-- 多用于@{#byui.ScrollView}选择滚动方向。
-- @field [parent=#global] #number kHorizental 
kHorizental     = 1;

---
-- 垂直方向.
-- 多用于@{#byui.ScrollView}选择滚动方向。
-- @field [parent=#global] #number kVertical
kVertical       = 2;

---
-- 水平和垂直方向.
-- 多用于@{#byui.ScrollView}选择滚动方向。
-- @field [parent=#global] #number kBoth
kBoth           = 3;


---
-- 向右拖拽.
-- 用于@{#byui.Layers}选择拖拽方向。
-- @field [parent=#global] engine#Point kDragToRight 
kDragToRight    = Point(1,0)

---
-- 向左拖拽.
-- 用于@{#byui.Layers}选择拖拽方向。
-- @field [parent=#global] engine#Point kDragToLeft 
kDragToLeft     = Point(-1,0)

---
-- 向上拖拽.
-- 用于@{#byui.Layers}选择拖拽方向。
-- @field [parent=#global] engine#Point kDragToTop 
kDragToTop      = Point(0,-1)

---
-- 向下拖拽.
-- 用于@{#byui.Layers}选择拖拽方向。
-- @field [parent=#global] engine#Point kDragToBottom 
kDragToBottom   = Point(0,1)

--- 
-- 菜单的箭头方向.
-- 默认向下，如果不能满足则向上。
-- @field [parent=#global] #number kMenuControllerArrowDefault 
kMenuControllerArrowDefault = 0

--- 
-- 菜单的箭头方向朝上.
-- 默认向上，如果不能满足则向下。
-- @field [parent=#global] #number kMenuControllerArrowUp 
kMenuControllerArrowUp = 1

--- 
-- 菜单的箭头方向朝下.
-- 默认向下，如果不能满足则向上。
-- @field [parent=#global] #number kMenuControllerArrowDown 
kMenuControllerArrowDown = 2

--kMenuControllerArrowLeft = 3
--kMenuControllerArrowRight = 4

kStringSelect = "选择"
kStringSelectAll = "全选"
kStringPaste = "粘贴"
kStringBIU = "<b>B</b><i>I</i><underline color=#ffffff>U</underline>"
kStringIndent = "缩进"
kStringOutdent = "减少缩进"
kStringCut = "裁剪"
kStringCopy = "复制"
kStringDefine = "定义"
kStringAdd = "添加..."
kStringShare = "共享..."
kStringCut = "剪切"

kSelectBegin = 1
kSelectEnd = 2

KTextBorderStyleRoundedRect = 1
KTextBorderStyleBezel = 2
KTextBorderStyleLine = 3
KTextBorderStyleWhite = 4
KTextBorderStyleNone = 0

KTextIconNone = 0
KTextIconDelete = 1
KTextIconMagnifier = 2


---
-- 对齐方式.
-- @field [parent=#global] #ALIGN ALIGN 
ALIGN  =  {
    ---
    -- 居中对齐
    -- @field [parent=#ALIGN]  CENTER
    CENTER        = 15,
    ---
    -- 顶部居中对齐
    -- @field [parent=#ALIGN]  TOP
    TOP           = 7,
    ---
    -- 右上角对齐
    -- @field [parent=#ALIGN]  TOPRIGHT
    TOPRIGHT      = 6,
    ---
    -- 右部居中对齐
    -- @field [parent=#ALIGN]  RIGHT
    RIGHT         = 14,
    ---
    -- 右下角对齐
    -- @field [parent=#ALIGN]  BOTTOMRIGHT
    BOTTOMRIGHT   = 10,
    ---
    -- 下部居中对齐
    -- @field [parent=#ALIGN]  BOTTOM
    BOTTOM        = 11,
    ---
    -- 左下角对齐
    -- @field [parent=#ALIGN]  BOTTOMLEFT
    BOTTOMLEFT    = 9,
    ---
    -- 左部居中对齐
    -- @field [parent=#ALIGN]  LEFT
    LEFT          = 13,
    ---
    -- 左上角对齐
    -- @field [parent=#ALIGN]  TOPLEFT
    TOPLEFT       = 5,
}


function align_h(a)
    return bit.band(a, 3)
end

function align_v(a)
    return bit.band(a, 12)
end

---
-- 水平对齐方式.
-- @field [parent=#global] #ALIGN_H ALIGN_H 
ALIGN_H = {

    ---
    -- 水平居左对齐
    -- @field [parent=#ALIGN_H]  LEFT
    LEFT = align_h(ALIGN.LEFT),
    
    ---
    -- 水平居右对齐
    -- @field [parent=#ALIGN_H]  RIGHT
    RIGHT = align_h(ALIGN.RIGHT),
    
    ---
    -- 水平居中对齐
    -- @field [parent=#ALIGN_H]  CENTER
    CENTER = align_h(ALIGN.CENTER),
}

---
-- 垂直对齐方式.
-- @field [parent=#global] #ALIGN_V ALIGN_V
ALIGN_V = {
    ---
    -- 垂直顶部对齐
    -- @field [parent=#ALIGN_V]  TOP
    TOP = align_v(ALIGN.TOP),
    
    ---
    -- 垂直居中对齐
    -- @field [parent=#ALIGN_V]  CENTER
    CENTER = align_v(ALIGN.CENTER),
    
    ---
    -- 垂直底部对齐
    -- @field [parent=#ALIGN_V]  BOTTOM
    BOTTOM = align_v(ALIGN.BOTTOM),
}


if event_touch_raw == nil then
    -- prevent error log
    function event_touch_raw()
    end
end

end
        

package.preload[ "byui.utils" ] = function( ... )
    return require('byui/utils')
end
            
require("byui.autolayout");
require("byui.basic");
require("byui.bmfont");
require("byui.class");
require("byui.debugger");
require("byui.draw_res");
require("byui.edit");
require("byui.inspect");
require("byui.kinetic");
require("byui.label_config");
require("byui.layout");
require("byui.particle");
require("byui.scroll");
require("byui.simple_ui");
require("byui.tableview");
require("byui.test");
require("byui.ui_utils");
require("byui.utils");