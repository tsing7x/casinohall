require("ui/node");
require("ui/image");
require("ui/text");
require("core/anim");
require("core/system");

-- 提示信息动画：游戏中任何地方都可能调用，
-- 接口：play：播放动画
--       load: 加载资源
--       stop: 停止动画，删除anim和prop
--       relsease: 释放资源
-- 说明：调用动画会返回该动画中所有绘制对象的根节点，可以将其加入场景中的任一节点作为其子节点，也可忽视；
--       动画播放完毕的时候会自行调用release接口释放资源。
-- 调用示例：AlarmTip.play("message",nil,50,nil,-50);

AlarmTip = {};
AlarmTip.ms = 3000; -- 动画总时常
AlarmTip.loaded = false; -- 加载状态
AlarmTip.spaceX = 50;
AlarmTip.translateX = 0;
AlarmTip.translateY = 80;

--msg :需要显示的提示信息     type：string
--translateX,translateY:分别表示该动画在x和y方向上移动的距离
--x,y :动画的位置，默认值都为屏幕上方
AlarmTip.play = function(msg, ...)
    if not msg or msg == "" then
      return
    end
    msg = string.format(msg, ...)
    local needTranslate, diffX = AlarmTip.load(msg)

    AlarmTip.stop()

    AlarmTip.root:setVisible(true)

    -- local timeStamp = needTranslate and diffX * 20 or AlarmTip.ms

    if not needTranslate then
        AlarmTip.onTimer(AlarmTip.ms)
    else
        AlarmTip.animIndex = new(AnimInt, kAnimNormal, 0, 1, AlarmTip.ms / 8, 0)
        AlarmTip.animIndex:setDebugName("AlarmTip | AlarmTip.animIndex2")
        AlarmTip.animIndex:setEvent(diffX , AlarmTip.startTranslate)
    end
    return AlarmTip.root
end

AlarmTip.play2Btn = function(msg, btnFile1, btnFile2, obj, func)
    if not msg or msg == "" then
      return;
    end

    local needTranslate, diffX = AlarmTip.load(msg, btnFile1, btnFile2, obj, func);
    --当提示框在未播放完动画的时候再次调用play,则先强制清除prop , anim;(重入)
    AlarmTip.stop();

    AlarmTip.root:setVisible(true);

    local timeStamp = needTranslate and diffX * 20 or AlarmTip.ms;
    if not needTranslate then
        AlarmTip.onTimer(AlarmTip.ms);
    else
        AlarmTip.animIndex = new(AnimInt, kAnimNormal, 0, 1, AlarmTip.ms / 8, 0)
        AlarmTip.animIndex:setDebugName("AlarmTip | AlarmTip.animIndex2")
        AlarmTip.animIndex:setEvent(diffX , AlarmTip.startTranslate)
    end
    return AlarmTip.root;
end

-- 加载资源
AlarmTip.load = function(msg, btnFile1, btnFile2, obj, func)
    if not AlarmTip.loaded then
        AlarmTip.loaded=true

        AlarmTip.root = new(Node)
        AlarmTip.root:addToRoot()
        AlarmTip.root:setLevel(100)
        
        AlarmTip.bg = new(Image,"animation/alarmNoticeBg.png")
        
        local w, h = AlarmTip.bg:getSize()

        local screenW = System.getScreenScaleWidth()
        local screenH = System.getScreenScaleHeight()
        AlarmTip.root:setSize(w, h)

        AlarmTip.root:addChild(AlarmTip.bg)
        AlarmTip.root:setAlign(kAlignTop)

        -- 隐藏drawing
        AlarmTip.root:setVisible(false)
    end

    AlarmTip.bg:removeAllChildren()

    local w, h = AlarmTip.bg:getSize()

    AlarmTip.textAnimNode = new(Node)
    AlarmTip.textAnimNode:setAlign(kAlignCenter)
    AlarmTip.bg:addChild(AlarmTip.textAnimNode)

    AlarmTip.text = new(Text, msg, 0, h, kAlignCenter, "", 32, 0xf2, 0xc9, 0x17)
    AlarmTip.textAnimNode:addChild(AlarmTip.text)

    -- 滚动适配
    local m_width, m_height = AlarmTip.text:getSize()
    local widthDiff = w - AlarmTip.spaceX*2

    if m_width <= widthDiff then
        AlarmTip.text:setAlign(kAlignCenter)
        local x, y  = AlarmTip.text:getPos()
        local btnPos = x + AlarmTip.text.m_res.m_width-100
        if btnFile1 then
            AlarmTip.text:setPos(-(112 + 85 + 112) / 2, 0)
            x, y  = AlarmTip.text:getPos()
            btnPos = x + AlarmTip.text.m_res.m_width-80
            AlarmTip.btn1 = new(Button, btnFile1)
            AlarmTip.textAnimNode:addChild(AlarmTip.btn1);
            -- AlarmTip.bg:addChild(AlarmTip.btn1);
            AlarmTip.btn1:setAlign(kAlignCenter)
            AlarmTip.btn1:setPos(btnPos, 0)
            btnPos = btnPos + AlarmTip.btn1.m_res.m_width+3
            AlarmTip.btn1:setOnClick(self, function ()
                -- body
                if func then
                    func(obj, 1)
                end

            end)
        end

        if btnFile2 then
            AlarmTip.btn2 = new(Button, btnFile2)
            AlarmTip.textAnimNode:addChild(AlarmTip.btn2);
            AlarmTip.btn2:setAlign(kAlignCenter)
            AlarmTip.btn2:setPos(btnPos, 0)
            AlarmTip.btn2:setOnClick(self, function ()
                -- body
                if func then
                    func(obj, 2)
                end

            end)
        end

        return false
    elseif m_width > widthDiff then
        local diffX = m_width - w + AlarmTip.spaceX * 3
        AlarmTip.textAnimNode:setClip(AlarmTip.spaceX, 0, w - AlarmTip.spaceX * 2 , h)
        AlarmTip.text:pos(- widthDiff / 2, - h / 2)
        return true, diffX
    end
end

AlarmTip.startTranslate = function(diffX)

    delete(AlarmTip.animIndex)
    AlarmTip.animIndex = nil
    AlarmTip.animText = AlarmTip.textAnimNode:addPropTranslate(1, kAnimNormal, diffX * 15, 0, 0, - diffX, 0, 0)
    if AlarmTip.animText then
        AlarmTip.animText:setDebugName("AlarmTip | AlarmTip.animText")
        AlarmTip.animText:setEvent(AlarmTip.ms / 2, AlarmTip.onTimer)
    end
end

-- 定时器
AlarmTip.onTimer = function(time)
    --删除anim
    local anim = AlarmTip.root:addPropTranslate(0, kAnimNormal, AlarmTip.ms / 8, time or AlarmTip.ms, 0, -AlarmTip.translateX, 0,-AlarmTip.translateY);
    if anim then
        anim:setDebugName("AlarmTip | anim")
        anim:setEvent(nil, AlarmTip.stop)
    end
end

-- 暂停动画
AlarmTip.stop =function()
    if  AlarmTip.loaded then   
        AlarmTip.root:setVisible(false);  
        if not AlarmTip.root:checkAddProp(0) then
            AlarmTip.root:removeProp(0);  -- 移除属性
        end
    end

    --删除anim
    if AlarmTip.animIndex then
        delete(AlarmTip.animIndex);
        AlarmTip.animIndex = nil;   
    end
end

-- 释放资源
AlarmTip.release = function()
    AlarmTip.stop(); 

    if AlarmTip.root then
        local parent = AlarmTip.root:getParent();
        if parent then
            parent:removeChild(AlarmTip.root);
        end
        delete(AlarmTip.root);
        AlarmTip.root = nil;
    end

    AlarmTip.loaded = false;
end