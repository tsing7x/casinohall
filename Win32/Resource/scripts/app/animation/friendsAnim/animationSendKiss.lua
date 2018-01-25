-- 好友 kiss动画
local AnimCurve = require("app.animation/friendsAnim/animCurve");
require("animation/friendsAnim/friendAnim_pin");

local AnimationSendKiss = class(Node);


function AnimationSendKiss.ctor( self, p1, p2, fromId, toId)

	self.m_p1 = p1;
	self.m_p2 = p2;
	self.m_h = 200;	--弧线高度
	self.m_pnum = 55;
	self.isPlaying = false;
	self.baseSequence = 10;

	self:load();
	--创建飞行路径
	self.m_kissCurve_1 = {};
	if math.abs(p1.x-p2.x) <=100 then
		self.m_kissCurve_1 = AnimCurve.createLineCurve(self.m_p1, self.m_p2, self.m_pnum);
	else
		self.m_kissCurve_1 = AnimCurve.createParabolaCurve(self.m_p1, self.m_p2, self.m_h, self.m_pnum);
	end
end

function AnimationSendKiss.load( self )
	self.m_root = new(Node);
	self.m_root:addToRoot();

	--嘴唇
	self.m_lip = UIFactory.createImage(sendKiss_pin_map["redLip_start_6.png"]);
	self.m_root:addChild(self.m_lip);
	self.m_lip:setVisible(false);
	self.m_lip:setPos(self.m_p1.x, self.m_p1.y);
	local rW, rH = self.m_lip:getSize();

	--loveHeart
	local dirs = {};
	for i=1,5 do
		table.insert(dirs, sendKiss_pin_map[string.format("loveHeart_%d.png",i)]);
	end	
	self.m_loveHearts = UIFactory.createImages(dirs);
	self.m_root:addChild(self.m_loveHearts);
	self.m_loveHearts:setVisible(false);
	local gW, gH = self.m_loveHearts:getSize();
	self.m_loveHearts:setPos(self.m_p1.x - gW/2 + rW/2-10, self.m_p1.y - gH/2 + rH/2);

	--redLip_start
	local dirs = {};
	for i=1,6 do
		table.insert(dirs, sendKiss_pin_map[string.format("redLip_start_%d.png",i)]);
	end	
	self.m_redLip_starts = UIFactory.createImages(dirs);
	self.m_loveHearts:addChild(self.m_redLip_starts);
	self.m_redLip_starts:setVisible(false);
	self.m_redLip_starts:setAlign(kAlignCenter);

	--kiss end
	local dirs = {};
	for i=1,8 do
		table.insert(dirs, sendKiss_pin_map[string.format("kiss_end_%d.png",i)]);
	end	
	self.m_kissEnds = UIFactory.createImages(dirs);
	self.m_root:addChild(self.m_kissEnds);
	self.m_kissEnds:setVisible(false);
	local gW, gH = self.m_kissEnds:getSize();
	self.m_kissEnds:setPos(self.m_p2.x - gW/2 + rW/2-10, self.m_p2.y - gH/2+ rH/2);

end

function AnimationSendKiss.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playRedLipStartAnim();
end

--[[播放嘴唇出现动画]]
function AnimationSendKiss.playRedLipStartAnim( self )

	if self.m_redLipAnim then
		delete(self.m_redLipAnim);
		self.m_redLipAnim = nil;
	end
	self.imgIndex1 = 0;
	self.imgIndex2 = 0;

	self.m_redLipAnim = self.m_redLip_starts:addPropRotate(0,kAnimRepeat,120,0,0,0,kCenterDrawing);
	self.m_redLipAnim:setDebugName("AnimationSendKiss || self.m_redLipAnim");
	self.m_redLipAnim:setEvent(self, self.showRedLipOnTime);

  	kEffectPlayer:play(Effects.PropRose1);
end

function AnimationSendKiss.showRedLipOnTime( self )
	if self.m_redLip_starts.m_reses then
		local index1 = self.imgIndex1;
		local index2 = self.imgIndex2;
		if index1 > 5 then
			index1 = 5;
		elseif index2 > 4 then
			index2 = 4; 
		else
			self.m_redLip_starts:setImageIndex(index1);
			self.m_redLip_starts:setVisible(true);
			self.m_loveHearts:setImageIndex(index2);
			self.m_loveHearts:setVisible(true);
		end
	else
		delete(self.m_redLip_starts);
		self.m_redLip_starts = nil;
		self:stop();
		return;
	end
	self.imgIndex1 = self.imgIndex1 + 1;
	self.imgIndex2 = self.imgIndex2 + 1;
	if self.imgIndex2 > 4 then
		delete(self.m_redLip_starts);
		self.m_redLip_starts = nil;
		delete(self.m_loveHearts);
		self.m_loveHearts = nil;
		self:sendKissAnim();
	end

end

--[[send kiss]]
function AnimationSendKiss.sendKissAnim( self )

	self.m_index = 1;
	self.m_speed = 50;	-- 速度
	self.m_lip:addPropScale(self.baseSequence+1, kAnimLoop, 800, 0, 1.1, 0.7, 1.1, 0.7, kCenterDrawing);
	
	self.m_lipAnim = self.m_lip:addPropRotate(self.baseSequence+2,kAnimRepeat,20,0,0,0,kCenterDrawing);
  	kEffectPlayer:play(Effects.PropRose2);

	self.m_lipAnim:setEvent(nil, function()
		
		self.m_lip:setVisible(true);
		self.m_lip:setPos(self.m_kissCurve_1[self.m_index].x, self.m_kissCurve_1[self.m_index].y);

		self.m_index = self.m_index + 1;
		
		if self.m_index >= #self.m_kissCurve_1 then
			self.m_index = 1;
			delete(self.m_lip);
			self.m_lip = nil;
			self:kissEndAnim();
		end

	end);
end

--[[kiss end]]
function AnimationSendKiss.kissEndAnim( self )

	if self.m_kissEndAnim then
		delete(self.m_kissEndAnim);
		self.m_kissEndAnim = nil;
	end
	self.imgIndex3 = 0;
  	kEffectPlayer:play(Effects.PropRose3);
	-- self.m_kissEndAnim = new(AnimInt, kAnimRepeat, 0, 1, 150, 0);
	self.m_kissEndAnim = self.m_kissEnds:addPropRotate(0,kAnimRepeat,150,0,0,0,kCenterDrawing);
	self.m_kissEndAnim:setDebugName("AnimationSendKiss || self.m_kissEndAnim");
	self.m_kissEndAnim:setEvent(self, self.showEggsOnTime);

end

function AnimationSendKiss.showEggsOnTime( self )
	if self.m_kissEnds.m_reses then
		local index = self.imgIndex3;
		if index > 7 then
			if index == 8 then
				self.m_kissEnds:addPropTransparency(1, kAnimNormal, 1000, 10, 1, 0);
			end
		else
			self.m_kissEnds:setImageIndex(index);
			self.m_kissEnds:setVisible(true);
		end
	else
		delete(self.m_kissEnds);
		self.m_kissEnds = nil;
		self:stop();
		return;
	end
	self.imgIndex3 = self.imgIndex3 + 1;
	if self.imgIndex3 > 15 then
		delete(self.m_kissEnds);
		self.m_kissEnds = nil;
		self:stop();
	end

end


function AnimationSendKiss.stop( self )
	self.isPlaying = false;
	self:dtor();
end

function AnimationSendKiss.dtor( self )

	if self.m_loveHearts then
		delete(self.m_loveHearts);
		self.m_loveHearts = nil;
	end

	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
end

return AnimationSendKiss