-- 好友 扔鸡蛋动画
local AnimCurve = require("app.animation/friendsAnim/animCurve");
--require("animation/friendsAnim/friendAnim_pin");

local AnimationThrowEgg = class(Node);

function AnimationThrowEgg.ctor( self, p1, p2, fromId, toId)
	self.m_p1 = p1;
	self.m_p2 = p2;
	self.m_h = 30;	--弧线高度
	self.m_pnum = 55;
	self.isPlaying = false;
	self.baseSequence = 10;

	self:load();
	--创建鸡蛋飞行路径
	self.m_eggCurve_1 = {};
	if math.abs(p1.x-p2.x) <=100 then
		self.m_rotateFlag = true;
		self.m_p2.y = self.m_p2.y - 33;
		self.m_p2.x = self.m_p2.x + 20 ;
		self.m_eggCurve_1 = AnimCurve.createLineCurve(self.m_p1, self.m_p2, self.m_pnum);
	else
		self.m_eggCurve_1 = AnimCurve.createParabolaCurve(self.m_p1, self.m_p2, self.m_h, self.m_pnum);
	end
end

function AnimationThrowEgg.load( self )
	self.m_root = new(Node);
	self.m_root:addToRoot();

	--鸡蛋
	self.m_egg = UIFactory.createImage(throwEgg_pin_map["egg.png"]);
	self.m_root:addChild(self.m_egg);
	self.m_egg:setVisible(false);
	self.m_egg:setPos(self.m_p1.x, self.m_p1.y);
	local rW, rH = self.m_egg:getSize();

	--鸡蛋破碎
	local dirs = {};
	for i=1,6 do
		table.insert(dirs, throwEgg_pin_map[string.format("eggEx_%d.png",i)]);
	end	
	self.m_breakEggs = UIFactory.createImages(dirs);
	self.m_root:addChild(self.m_breakEggs);
	self.m_breakEggs:setVisible(false);
	local gW, gH = self.m_breakEggs:getSize();
	self.m_breakEggs:setPos(self.m_p2.x - gW/2 + rW/2, self.m_p2.y - gH/2+ rH/2);


	--烟雾
	local dirs = {};
	for i=1,5 do
		table.insert(dirs, smogs_pin_map[string.format("smog%d.png",i)]);
	end	
	self.m_smogs = UIFactory.createImages(dirs);
	self.m_root:addChild(self.m_smogs);
	self.m_smogs:setVisible(false);
	self.m_smogs:setPos(self.m_p1.x, self.m_p1.y);

end

function AnimationThrowEgg.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playSmogAnim();
	self:throwEggAnim();
end

--[[播放烟圈动画]]
function AnimationThrowEgg.playSmogAnim( self )

	if self.m_smogAnim then
		delete(self.m_smogAnim);
		self.m_smogAnim = nil;
	end
	self.imgIndex = 0;

	self.m_smogAnim = self.m_smogs:addPropRotate(0,kAnimRepeat,120,0,0,0,kCenterDrawing);
	self.m_smogAnim:setDebugName("AnimationThrowEgg || self.m_smogAnim");
	self.m_smogAnim:setEvent(self, self.showSmogsOnTime);
	self.m_smogs:setVisible(false);
  	kEffectPlayer:play(Effects.PropEgg1);
end

function AnimationThrowEgg.showSmogsOnTime( self )
	if self.m_smogs.m_reses then
		local index = self.imgIndex;
		if index > 4 then
			index = 4;
			self.m_smogs:setVisible(false);
		else
			self.m_smogs:setImageIndex(index);
			self.m_smogs:setVisible(true);
		end
	else
		delete(self.m_smogs);
		self.m_smogs = nil;
		self:stop();
		return;
	end
	self.imgIndex = self.imgIndex + 1;
	if self.imgIndex > 8 then
		delete(self.m_smogs);
		self.m_smogs = nil;
	end

end

--[[丢鸡蛋]]
function AnimationThrowEgg.throwEggAnim( self )

	self.m_index = 1;
	self.m_speed = 50;	-- 速度
	self.m_egg:addPropRotate(0,kAnimRepeat,500,0,0,360,kCenterDrawing);
	self.m_eggAnim = new(EaseMotion, kEaseOut, 5, 200, 0);
  	kEffectPlayer:play(Effects.PropEgg2);

	self.m_eggAnim:setEvent(nil, function()
		
		self.m_egg:setVisible(true)

		if self.m_rotateFlag then
			self.m_eggCurve_1[self.m_index].y = self.m_eggCurve_1[self.m_index].y + self.m_speed*self.m_eggAnim.m_process;
		else
			self.m_eggCurve_1[self.m_index].x = self.m_eggCurve_1[self.m_index].x + self.m_speed*self.m_eggAnim.m_process;
		end
		self.m_egg:setPos(self.m_eggCurve_1[self.m_index].x, self.m_eggCurve_1[self.m_index].y);

		self.m_index = self.m_index + 1;
		
		if self.m_index >= #self.m_eggCurve_1 then
			self.m_index = 1;
			self.m_egg:setVisible(false);
			delete(self.m_eggAnim);
			self.m_eggAnim = nil;
			self:brokeEggAnim();
		end

	end);
end

--[[鸡蛋炸开]]
function AnimationThrowEgg.brokeEggAnim( self )
  	kEffectPlayer:play(Effects.PropEgg3);
	if self.m_brokeEggAnim then
		delete(self.m_brokeEggAnim);
		self.m_brokeEggAnim = nil;
	end
	self.imgIndex2 = 0;

	self.m_brokeEggAnim = self.m_breakEggs:addPropRotate(0,kAnimRepeat,120,0,0,0,kCenterDrawing);
	self.m_brokeEggAnim:setDebugName("AnimationThrowEgg || self.m_brokeEggAnim");
	self.m_brokeEggAnim:setEvent(self, self.showEggsOnTime);

end

function AnimationThrowEgg.showEggsOnTime( self )
	if self.m_breakEggs.m_reses then
		local index = self.imgIndex2;
		if index == 6 then
			self.m_breakEggs:addPropTransparency(self.baseSequence+1, kAnimNormal, 1000, 100, 1, 0);
		elseif index <= 5 then
			self.m_breakEggs:setImageIndex(index);
			self.m_breakEggs:setVisible(true);
		end
	else
		delete(self.m_breakEggs);
		self.m_breakEggs = nil;
		self:stop();
		return;
	end
	self.imgIndex2 = self.imgIndex2 + 1;
	if self.imgIndex2 > 25 then
		delete(self.m_breakEggs);
		self.m_breakEggs = nil;
		self:stop();
	end
end


function AnimationThrowEgg.stop( self )
	self.isPlaying = false;
	self:dtor();
end

function AnimationThrowEgg.dtor( self )

	if self.m_eggAnim then
		delete(self.m_eggAnim);
		self.m_eggAnim = nil;
	end	

	if self.m_smogs then
		delete(self.m_smogs);
		self.m_smogs = nil;
	end

	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
end

return AnimationThrowEgg