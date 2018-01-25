-- 好友 干杯动画
local AnimCurve = require("app.animation/friendsAnim/animCurve");
require("app.animation/friendsAnim/friendAnim_pin");

local AnimationCheers = class(Node);


function AnimationCheers.ctor( self, p1, p2, fromId, toId)

	self.m_p1 = p1;
	self.m_p2 = p2;
	self.m_h = 200;	--弧线高度
	self.m_pnum = 55;
	self.isPlaying = false;
	self.baseSequence = 10;

	self:load();
	--创建飞行路径
	self.m_flyCurve_1 = {};
	self.m_p2 = {x=p2.x-45, y=p2.y};
	if math.abs(p1.x-p2.x) <=100 then
		self.m_flyCurve_1 = AnimCurve.createLineCurve(self.m_p1, self.m_p2, self.m_pnum);
	else
		self.m_flyCurve_1 = AnimCurve.createParabolaCurve(self.m_p1, self.m_p2, self.m_h, self.m_pnum);
	end
end

function AnimationCheers.load( self )
	self.m_root = new(Node);
	self.m_root:addToRoot();

	--酒杯
	self.m_target = UIFactory.createImage(cheers_pin_map["cup.png"]);
	self.m_root:addChild(self.m_target);
	self.m_target:setVisible(false);
	self.m_target:setPos(self.m_p1.x, self.m_p1.y);
	local rW, rH = self.m_target:getSize();

	--干杯
	local dirs = {};
	for i=1,9 do
		table.insert(dirs, cheers_pin_map[string.format("cheers_%d.png",i)]);
	end	
	self.m_cheers = UIFactory.createImages(dirs);
	self.m_root:addChild(self.m_cheers);
	self.m_cheers:setVisible(false);
	local gW, gH = self.m_cheers:getSize();
	self.m_cheers:setPos(self.m_p2.x - gW/2 + rW/2+10, self.m_p2.y - gH/2 + rH/2);


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

function AnimationCheers.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playSmogAnim();
	self:throwTargetAnim();
	self.m_time = os.time();
end

--[[播放烟圈动画]]
function AnimationCheers.playSmogAnim( self )

	if self.m_smogAnim then
		delete(self.m_smogAnim);
		self.m_smogAnim = nil;
	end
	self.imgIndex = 0;

	self.m_smogAnim = self.m_smogs:addPropRotate(0,kAnimRepeat,120,0,0,0,kCenterDrawing);
	self.m_smogAnim:setDebugName("AnimationCheers || self.m_smogAnim");
	self.m_smogAnim:setEvent(self, self.showSmogsOnTime);

  	kEffectPlayer:play(Effects.PropCheer1);
end

function AnimationCheers.showSmogsOnTime( self )
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


function AnimationCheers.throwTargetAnim( self )

	self.m_index = 1;
	self.m_speed = 50;	-- 速度
	self.m_targetAnim = new(AnimInt, kAnimRepeat, 0, 1, 20, 0);
	self.m_targetAnim:setDebugName("AnimationCheers || m_targetAnim")
  	kEffectPlayer:play(Effects.PropCheer2);
	self.m_targetAnim:setEvent(nil, function()
		
		self.m_target:setVisible(true)
		self.m_target:setPos(self.m_flyCurve_1[self.m_index].x, self.m_flyCurve_1[self.m_index].y);

		self.m_index = self.m_index + 1;
		
		if self.m_index >= #self.m_flyCurve_1 then
			self.m_index = 1;
			self.m_target:setVisible(false);
			delete(self.m_targetAnim);
			self.m_targetAnim = nil;
			self:cheersAnim();
		end

	end);
end

--[[干杯]]
function AnimationCheers.cheersAnim( self )

	if self.m_cheersAnim then
		delete(self.m_cheersAnim);
		self.m_cheersAnim = nil;
	end
	self.imgIndex2 = 0;
  	kEffectPlayer:play(Effects.PropCheer3);
	self.m_cheersAnim = self.m_cheers:addPropRotate(0,kAnimRepeat,120,0,0,0,kCenterDrawing);
	-- self.m_cheersAnim = new(AnimInt, kAnimRepeat, 0, 1, 120, 0);
	self.m_cheersAnim:setDebugName("AnimationCheers || self.m_cheersAnim");
	self.m_cheersAnim:setEvent(self, self.showEggsOnTime);

end

function AnimationCheers.showEggsOnTime( self )
	if self.m_cheers.m_reses then
		local index = self.imgIndex2;
		if index > 8 then
			if index == 9 then
				self.m_cheers:addPropTransparency(1, kAnimNormal, 1000, 10, 1, 0);
			end
		else
			self.m_cheers:setImageIndex(index);
			self.m_cheers:setVisible(true);
		end
	else
		delete(self.m_cheers);
		self.m_cheers = nil;
		self:stop();
		return;
	end
	self.imgIndex2 = self.imgIndex2 + 1;
	if self.imgIndex2 > 25 then
		delete(self.m_cheers);
		self.m_cheers = nil;
		self:stop();
	end
end


function AnimationCheers.stop( self )
	self.m_time = os.time() - self.m_time ;
	print("AnimationCheers passed time : " .. self.m_time)
	self.isPlaying = false;

	self:dtor();
end

function AnimationCheers.dtor( self )

	if self.m_targetAnim then
		delete(self.m_targetAnim);
		self.m_targetAnim = nil;
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

return AnimationCheers