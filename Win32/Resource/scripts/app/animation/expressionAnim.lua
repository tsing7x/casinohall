-- file: 'ExpressionAnim.lua'
local MJAnim_map = require("app.room.chat.expression");

local ExpressionAnim = {};
ExpressionAnim.loaded = false;
ExpressionAnim.time=2500;
ExpressionAnim.playCount = 1;
ExpressionAnim.sprites={};
ExpressionAnim.coords = {

    [1] = {70,200,120,120}, --mine
    [2] = {70,90,120,120},  --other
};

--private
ExpressionAnim.onTimer=function(sp,anim_type, anim_id, repeat_or_loop_num)
	if repeat_or_loop_num >= sp.playCount-1 then
		ExpressionAnim.releaseSprite(sp);
	end
end

--private
ExpressionAnim.releaseSprite=function(sp)
	local sprite 
	if type(sp) == "table" then 
		sprite = sp;
	else
		sprite = ExpressionAnim.sprites[sp];
	end
	if not sprite then 
	    return;
	end
    if sprite.drawing and sprite.prop then 
        sprite.drawing:removePropByID(sprite.prop.m_propID);
    end;
    delete(sprite.prop);
    sprite.prop = nil;
    delete(sprite.anim);
    sprite.anim = nil;
	
    if sprite.res then
        for k,v in pairs(sprite.res) do 
            delete(v);
        end
    end
    sprite.res = nil;
    if sprite.drawing then
        ExpressionAnim.root:removeChild(sprite.drawing);
        delete(sprite.drawing);
        sprite.drawing = nil;
    end
end

ExpressionAnim.loadRes = function(formatName,startIndex,num)
	local res = {};
	for i=0,num-1 do
		local strTmp=string.format(formatName,i+startIndex);

        strTmp = MJAnim_map[strTmp];

		res[i] = new(ResImage,strTmp);
	end
	return res;
end

ExpressionAnim.createDrawing = function(res,x,y,w,h)
	local drawing = new(DrawingImage,res[0]);
	-- drawing:setPos(x,y);
	drawing:setSize(w,h);
	for i=1,#res do
		drawing:addImage(res[i],i);
	end
	
	return drawing;
end

ExpressionAnim.play = function(seat,formatName,startIndex,num,duration,playCount,x,y,w,h)	
   	if not tonumber(seat) or seat <= 0 or seat > 4 then
   		return;
   	end

    if ExpressionAnim.coords and ExpressionAnim.coords[seat] then 
        x = x or ExpressionAnim.coords[seat][1];
        y = y or ExpressionAnim.coords[seat][2];
        w = w or ExpressionAnim.coords[seat][3];
        h = h or ExpressionAnim.coords[seat][4];
    end
    ExpressionAnim.releaseSprite(seat);

    if not ExpressionAnim.loaded then
    	ExpressionAnim.loaded = true;
    	ExpressionAnim.root = new(Node);
        ExpressionAnim.root:setLevel(10);
    end

	local sprite = {};
	sprite.playCount = playCount or ExpressionAnim.playCount;
    sprite.res = ExpressionAnim.loadRes(formatName,startIndex,num);
	sprite.drawing = ExpressionAnim.createDrawing(sprite.res,x,y,w,h);
	ExpressionAnim.root:addChild(sprite.drawing);
	ExpressionAnim.root:setPos(x, y);
	sprite.anim = new(AnimInt,kAnimRepeat,0,#sprite.res,duration or ExpressionAnim.time,-1);
    sprite.anim:setDebugName("sprite.anim");
	sprite.anim:setEvent(sprite,ExpressionAnim.onTimer);
	sprite.prop = new(PropImageIndex,sprite.anim);
	sprite.drawing:addProp(sprite.prop,0);
	
	ExpressionAnim.sprites[seat] = sprite;

	return ExpressionAnim.root;
end

ExpressionAnim.stop = function()
    for k,v in pairs(ExpressionAnim.sprites) do 
        ExpressionAnim.releaseSprite(k);
        ExpressionAnim.sprites[k] = nil;
    end
    ExpressionAnim.sprites = {};
end

--public
ExpressionAnim.release=function()
    ExpressionAnim.stop();
    
    if ExpressionAnim.root then
    	local parent = ExpressionAnim.root:getParent();
    	if parent then
    		parent:removeChild(ExpressionAnim.root);
    	end
    	delete(ExpressionAnim.root);
    	ExpressionAnim.root = nil;
    end

    ExpressionAnim.loaded = false;
end

return ExpressionAnim