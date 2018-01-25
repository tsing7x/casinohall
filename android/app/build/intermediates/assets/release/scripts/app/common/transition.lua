-- 简单动画工具类
--[[
	transition.moveTo
	transition.scaleTo
	transition.rotateTo
	transition.fadeTo
	transition.fadeIn
	transition.fadeOut
	transition.tintTo
	transition.moveBy
	transition.scaleBy
	
	if not card then
		card = UIFactory.createImage("ui/image.png")
		card:addToRoot()
	end
	card:pos(display.cx, display.cy)
	transition.moveTo(card, {
		sequence = 1001,
		easing = "bounceOut",
		time = 1500,
		x = 200,
		y = 100,
		onComplete = function()
			transition.scaleBy(card, {
				scale = 1.8,
				easing = "bounceOut",
				sequence = 1002,
				time = 1500,
				onComplete = function(value)
					printInfo("value = ")
					transition.fadeTo(card, {
						sequence = 1003,
						easing = "bounceOut",
						opacity = 0.0,
						time = 1000,
						onComplete = function()
							transition.rotateTo(card, {
								sequence = 1005,
								angle = 180,
								easing = "bounceOut",
								time = 1000,
							})
						end,
					})
				end,
			})
		end,
	})
]]
transition = {}

local ACTION_EASING = {}
ACTION_EASING["ELASTICIN"]        = ResDoubleArrayElasticIn
ACTION_EASING["ELASTICOUT"]       = ResDoubleArrayElasticOut
ACTION_EASING["ELASTICINOUT"]     = ResDoubleArrayElasticInOut
ACTION_EASING["BOUNCEIN"]         = ResDoubleArrayBounceIn
ACTION_EASING["BOUNCEOUT"]        = ResDoubleArrayBounceOut
ACTION_EASING["BOUNCEINOUT"]      = ResDoubleArrayBounceInOut
ACTION_EASING["BACKIN"]           = ResDoubleArrayBackIn
ACTION_EASING["BACKOUT"]          = ResDoubleArrayBackOut
ACTION_EASING["BACKINOUT"]        = ResDoubleArrayBackInOut
ACTION_EASING["SININ"]            = ResDoubleArraySinIn
ACTION_EASING["SINOUT"]           = ResDoubleArraySinOut
ACTION_EASING["SININOUT"]         = ResDoubleArraySinInOut
ACTION_EASING["CURVE"]        	  = ResDoubleArrayCurve
ACTION_EASING["ELLIPSEX"]         = ResDoubleArrayEllipseX
ACTION_EASING["ELLIPSEY"]         = ResDoubleArrayEllipseY
ACTION_EASING["JUMPX"]         	  = ResDoubleArrayJumpX
ACTION_EASING["JUMPY"]         	  = ResDoubleArrayJumpY


-- 增加可选参数
-- setDebugName 调试名称
-- onComplete 回调函数
local function addArgs(anim, args, compete)
	if not anim then return end
	if args.debugName then
		anim:setDebugName(args.debugName)
	end
	anim:setEvent(nil, function()
		compete()
		if args.onComplete then
			args.onComplete()
		end
	end)
end

local function getEasing(ease)
	if not ease then return end
	ease = string.upper(tostring(ease))
	return ACTION_EASING[ease]
end

local function createCompeteFunc(target, sequence, isEase, func)
	return function()
		if target then
			if isEase then
				target:removePropEase(sequence)
			else
				target:removeProp(sequence)
			end
			if func then func() end
		end
	end
end

-- 移动到指定位置
function transition.moveTo(target, args)
	-- 公共参数
	local time 		= args.time or 1000
	local delay 	= args.delay or 0
	local sequence 	= args.sequence
	local animType 	= args.animType or kAnimNormal

	-- 位移参数
	local tx, ty = target:getPos()
	local x = args.x or tx
	local y = args.y or ty

	-- 变速参数
	local easing   = args.easing

	assert(tonumber(sequence), "sequence参数有误！")

	local easeCls = getEasing(easing)
	local anim
	if easeCls then
		anim = target:addPropTranslateEase(sequence, animType, easeCls, time, delay, 0, x - tx, 0, y - ty)
	else
		anim = target:addPropTranslate(sequence, animType, time, delay, 0, x - tx, 0, y - ty)
	end
	addArgs(anim, args, createCompeteFunc(target, sequence, easeCls, function()
			-- target:addPropTranslateSolid(sequence, x - tx, y - ty)
			printInfo("设置坐标 x = %d, y = %d", x, y)
			target:setPos(x, y)
		end))
	return anim
end

-- 移动指定距离
function transition.moveBy(target, args)
	local diffX = args.diffX
	local diffY = args.diffY
	local tx, ty = target:getPos()
	args.x = tx + diffX
	args.y = ty + diffY
	
	return transition.moveTo(target, args, createCompeteFunc(target, sequence, easeCls))
end

-- 缩放到指定比例
function transition.scaleTo(target, args)
	-- 公共参数
	local time 		= args.time or 1000
	local delay 	= args.delay or 0
	local sequence 	= args.sequence
	local animType 	= args.animType or kAnimNormal

	-- 缩放参数
	local scaleX 	= args.scaleX or args.scale
	local scaleY 	= args.scaleY or args.scale
	local align 	= args.align or kCenterDrawing
	local centerX   = args.centerX
	local centerY 	= args.centerY

	local startScaleX = args.startScaleX or args.startScale or 1.0
	local startScaleY = args.startScaleY or args.startScale or 1.0

	-- 变速参数
	local easing 	= args.easing

	assert(tonumber(sequence), "sequence参数有误！")

	local anim
	local easeCls = getEasing(easing)
	local params = { time, delay, startScaleX, scaleX, startScaleY, scaleY, align, centerX, centerY }
	if easeCls then
		anim = target:addPropScaleEase(sequence, animType, easeCls, unpack(params))
	else
		anim = target:addPropScale(sequence, animType, unpack(params))
	end
	addArgs(anim, args, createCompeteFunc(target, sequence, easeCls, function()
			target:addPropScaleSolid(sequence, scaleX, scaleY, align, centerX, centerY)
		end))
	return anim
end

-- 移动指定距离
function transition.scaleBy(target, args)

	local scaleX = args.scaleX or args.scale
	local scaleY = args.scaleY or args.scale

	local tScaleX, tScaleY = target:getScale()

	local scaleX = tScaleX * scaleX
	local scaleY = tScaleY * scaleY

	args.scaleX = scaleX
	args.scaleY = scaleY

	return transition.scaleTo(target, args)
end

-- 透明度渐变
function transition.fadeTo(target, args)
	-- 公共参数
	local time 		= args.time or 1000
	local delay 	= args.delay or 0
	local sequence 	= args.sequence
	local animType 	= args.animType or kAnimNormal

	-- 缩放参数
	local opacity 	= args.opacity
	local tOpacity  = target:getTransparency()

	-- 变速参数
	local easing 	= args.easing

	assert(tonumber(sequence), "sequence参数有误！")
	
	local anim
	local easeCls = getEasing(easing)
	local params = { time, delay, tOpacity, opacity }
	if easeCls then
		anim = target:addPropTransparencyEase(sequence, animType, easeCls, unpack(params))
	else
		anim = target:addPropTransparency(sequence, animType, unpack(params))
	end
	addArgs(anim, args, createCompeteFunc(target, sequence, easeCls, function()
			target:setTransparency(opacity)
		end))
	return anim
end

-- 淡出
function transition.fadeOut(target, args)
	args.opacity = 0.0
	return transition.fadeTo(target, args)
end

-- 淡入
function transition.fadeIn(target, args)
	args.opacity = 1.0
	return transition.fadeTo(target, args)
end

-- 变色动画
function transition.tintTo(target, args)
		-- 公共参数
	local time 		= args.time or 1000
	local delay 	= args.delay or 0
	local sequence 	= args.sequence
	local animType 	= args.animType or kAnimNormal

	-- 变色参数
	local color 	= args.color
	local tColor  	= c3b(target:getColor())

	-- 变速参数
	local easing 	= args.easing

	assert(tonumber(sequence), "sequence参数有误！")
	
	local anim
	local easeCls = getEasing(easing)
	local params = { time, delay, tColor.r, color.r, tColor.g, color.g, tColor.b, color.b }
	if easeCls then
		anim = target:addPropColorEase(sequence, animType, easeCls, unpack(params))
	else
		anim = target:addPropColor(sequence, animType, unpack(params))
	end
	addArgs(anim, args, createCompeteFunc(target, sequence, easeCls, function()
			target:setColor(color.r, color.g, color.b)
		end))
	return anim
end

-- 旋转动画
function transition.rotateTo(target, args)
		-- 公共参数
	local time 		= args.time or 1000
	local delay 	= args.delay or 0
	local sequence 	= args.sequence
	local animType 	= args.animType or kAnimNormal

	-- 旋转参数
	local angle		= args.angle or 360
	local align 	= args.align or kCenterDrawing
	local centerX	= args.centerX
	local centerY	= args.centerY

	-- 变速参数
	local easing 	= args.easing

	assert(tonumber(sequence), "sequence参数有误！")
	
	local anim
	local easeCls = getEasing(easing)
	local params = { time, delay, 0, angle, align, centerX, centerY }
	if easeCls then
		anim = target:addPropRotateEase(sequence, animType, easeCls, unpack(params))
	else
		anim = target:addPropRotate(sequence, animType, unpack(params))
	end
	addArgs(anim, args, createCompeteFunc(target, sequence, easeCls, function()
		target:addPropRotateSolid(sequence, angle, align, centerX, centerY)
	end))
	return anim
end