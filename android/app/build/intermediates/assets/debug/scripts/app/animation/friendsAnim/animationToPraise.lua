-- 好友 点赞动画
local AnimCurve = require("app.animation/friendsAnim/animCurve");
require("app.animation/friendsAnim/friendAnim_pin");


local AnimationToPraise = class(Node);

kSeatMy = 1;
kSeatOppo = 2;

function AnimationToPraise.ctor( self, p1, p2, fromId, toId)

	self.m_p1 = p1;
	self.m_p2 = p2;
	self.m_fromId = fromId;
	self.m_toId = toId;
	self.m_h = 90;	--弧线高度
	self.m_pnum = 55;
	self.isPlaying = false;
	self.baseSequence = 10;

	self:load();
	--创建飞行路径
	self.m_flyCurve_1 = {};
	if math.abs(p1.x-p2.x) <=100 then
		self.m_flyCurve_1 = AnimCurve.createLineCurve(self.m_p1, self.m_p2, self.m_pnum);
	else
		self.m_flyCurve_1 = AnimCurve.createParabolaCurve(self.m_p1, self.m_p2, self.m_h, self.m_pnum);
	end
  	kEffectPlayer:play(Effects.PropCheer1);
end

function AnimationToPraise.load( self )
	self.m_root = new(Node);
	self.m_root:addToRoot();

	--光球a
	self.m_target = UIFactory.createImage(toPraise_pin_map["ball_a.png"]);
	self.m_root:addChild(self.m_target);
	self.m_target:setVisible(false);
	self.m_target:setPos(self.m_p1.x, self.m_p1.y);
	local rW, rH = self.m_target:getSize();

	--endAnim
	local dirs = {};
	for i=1,9 do
		table.insert(dirs, toPraise_pin_map[string.format("end_%d.png",i)]);
	end	
	self.m_ends = UIFactory.createImages(dirs);
	self.m_root:addChild(self.m_ends);
	self.m_ends:setVisible(false);
	local gW, gH = self.m_ends:getSize();
	self.m_ends:setPos(self.m_p2.x - gW/2 + rW/2+5, self.m_p2.y - gH/2 + rH/2);


	--startAnim
	local dirs = {};
	for i=1,9 do
		table.insert(dirs, toPraise_pin_map[string.format("start_%d.png",i)]);
	end	
	self.m_starts = UIFactory.createImages(dirs);
	self.m_root:addChild(self.m_starts);
	self.m_starts:setVisible(false);
	local gW, gH = self.m_starts:getSize();
	self.m_starts:setPos(self.m_p1.x - gW/2 + rW/2 + 10, self.m_p1.y - gH/2 + rH/2 +10);

end

function AnimationToPraise.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;

	-- if (self.m_fromId == self.m_toId ~= nil) then 	-- 自己给自己点赞
	-- 	self:showEndAnim();
	-- else 	-- 自己给别人点赞
		self:playStartAnim();
	-- end
end

--[[播放动画]]
function AnimationToPraise.playStartAnim( self )

	if self.m_startAnim then
		delete(self.m_startAnim);
		self.m_startAnim = nil;
	end
	self.imgIndex = 0;

	self.m_startAnim = self.m_starts:addPropRotate(0,kAnimRepeat, 90,0,0,0,kCenterDrawing);
	self.m_startAnim:setDebugName("AnimationToPraise || self.m_startAnim");
	self.m_startAnim:setEvent(self, self.showStartOnTime);

end

function AnimationToPraise.showStartOnTime( self )
	if self.m_starts.m_reses then
		local index = self.imgIndex;
		if index > 6 then
			index = 6;
			self.m_starts:setVisible(false);
		else
			self.m_starts:setImageIndex(index);
			self.m_starts:setVisible(true);
		end
	else
		delete(self.m_starts);
		self.m_starts = nil;
		self:stop();
		return;
	end
	self.imgIndex = self.imgIndex + 1;
	if self.imgIndex > 8 then
		delete(self.m_starts);
		self.m_starts = nil;
		self:throwTargetAnim();
	end

end

--[[]]
function AnimationToPraise.throwTargetAnim( self )

	self.m_index = 1;
	self.m_speed = 250;	-- 速度
	self.m_flag = false;
	if self.m_fromId == kSeatOppo or ( self.m_toId == kSeatMy) then	
		self.m_speed = -250;
	elseif self.m_fromId == kSeatMy or ( self.m_toId == kSeatOppo) then
		self.m_speed = 250;
	else
		self.m_flag = true;
	end
	
	if self.m_targetAnim then
		delete(self.m_targetAnim);
	end
	self.m_targetAnim = new(EaseMotion, kAnticipate, 9, 200, 0);
	self.m_targetAnim:setDebugName("AnimationToPraise || self.m_targetAnim");

  	kEffectPlayer:play(Effects.PropCheer2);

	self.m_targetAnim:setEvent(self, function()
		
		self.m_target:setVisible(true);
		
		if self.m_flag then
			self.m_index = self.m_index + 1;
			self.m_target:setPos(self.m_flyCurve_1[self.m_index].x, self.m_flyCurve_1[self.m_index].y);
		else
			self.m_target:setPos(self.m_flyCurve_1[self.m_index].x + self.m_speed*self.m_targetAnim.m_process, 
				self.m_flyCurve_1[self.m_index].y );
		end	

		if self.m_index >= #self.m_flyCurve_1 then
			self.m_index = 1;
			delete(self.m_target);
			self.m_target = nil;
			delete(self.m_targetAnim);
			self.m_targetAnim = nil;
			self:showEndAnim();
			return;
		elseif self.m_flyCurve_1[self.m_index].x + 750*self.m_targetAnim.m_process >= self.m_flyCurve_1[1].x and not self.m_flag then
			self.m_flag = true;
		end

	end);
end

--[[]]
function AnimationToPraise.showEndAnim( self )

	if self.m_endAnim then
		delete(self.m_endAnim);
		self.m_endAnim = nil;
	end
  	kEffectPlayer:play(Effects.PropCheer3);
	self.imgIndex2 = 0;
	self.m_endAnim = self.m_ends:addPropRotate(0,kAnimRepeat,120,0,0,0,kCenterDrawing);
	self.m_endAnim:setDebugName("AnimationToPraise || self.m_endAnim");
	self.m_endAnim:setEvent(self, self.showEndAnimOnTime);

end

function AnimationToPraise.showEndAnimOnTime( self )
	if self.m_ends.m_reses then
		local index = self.imgIndex2;
		if index > 8 then
			if index == 9 then
				self.m_ends:addPropTransparency(1, kAnimNormal, 1000, 10, 1, 0);
			end
		else
			self.m_ends:setImageIndex(index);
			self.m_ends:setVisible(true);
		end
	else
		delete(self.m_ends);
		self.m_ends = nil;
		self:stop();
		return;
	end
	self.imgIndex2 = self.imgIndex2 + 1;
	if self.imgIndex2 > 15 then
		delete(self.m_ends);
		self.m_ends = nil;
		self:stop();
	end
end


function AnimationToPraise.stop( self )
	self.isPlaying = false;
	self:dtor();
end

function AnimationToPraise.dtor( self )

	if self.m_targetAnim then
		delete(self.m_targetAnim);
		self.m_targetAnim = nil;
	end

	if self.m_starts then
		delete(self.m_starts);
		self.m_starts = nil;
	end

	if self.m_ends then
		delete(self.m_ends);
		self.m_ends = nil;
	end

	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
end

return AnimationToPraise