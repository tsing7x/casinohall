-- 好友 扔石头动画
local AnimCurve = require("app.animation/friendsAnim/animCurve");

require("app.animation/friendsAnim/friendAnim_pin");

local AnimationThrowSoap = class(Node);


function AnimationThrowSoap.ctor( self, p1, p2, fromId, toId)

	self.m_p1 = p1;
	self.m_p2 = p2;
	self.m_fromId = fromId;
	self.m_toId = toId;
	self.m_h = 40;	--弧线高度
	self.m_pnum = 55;
	self.isPlaying = false;
	self.baseSequence = 10;

	self:load();
	--创建肥皂飞行路径
	self.m_soapCurve_1 = {};
	if math.abs(p1.x-p2.x) <=100 then
		self.m_rotateFlag = true;
		self.m_p2.x = self.m_p2.x + 20;
		self.m_p2.y = self.m_p2.y - 33;
		self.m_soapCurve_1 = AnimCurve.createLineCurve(self.m_p1, self.m_p2, self.m_pnum);
	else
		self.m_soapCurve_1 = AnimCurve.createParabolaCurve(self.m_p1, self.m_p2, self.m_h, self.m_pnum);
	end
	
end

function AnimationThrowSoap.load( self )
	self.m_root = new(Node);
	self.m_root:addToRoot();

	local handFile_1 = throwSoap_pin_map["handa.png"];
	local handFile_2 = throwSoap_pin_map["handb.png"];
	local posFlag = false;
	if self.m_fromId == kSeatOppo or ( self.m_toId == kSeatMy) then	
		handFile_1 = throwSoap_pin_map["handa.png"];
		handFile_2 = throwSoap_pin_map["handb.png"];
	elseif self.m_fromId == kSeatMy or ( self.m_toId == kSeatOppo) then
		handFile_1 = throwSoap_pin_map["handc.png"];
		handFile_2 = throwSoap_pin_map["handd.png"];
		posFlag = true;
	end

	--肥皂
	self.m_soap = UIFactory.createImage(throwSoap_pin_map["soap.png"]);
	self.m_root:addChild(self.m_soap);
	self.m_soap:setVisible(false);
	local rW, rH = self.m_soap:getSize();
	self.m_soap:setPos(self.m_p1.x+ rW/4, self.m_p1.y);

	--肥皂A
	self.m_soap_A = UIFactory.createImage(throwSoap_pin_map["soap.png"]);
	self.m_root:addChild(self.m_soap_A);
	self.m_soap_A:setVisible(false);
	self.m_soap_A:setPos(self.m_p1.x+ rW/4, self.m_p1.y);

	--手A
	self.m_hand_a = UIFactory.createImage(handFile_1);
	self.m_soap:addChild(self.m_hand_a);
	self.m_hand_a:setVisible(false);
	self.m_hand_a:setAlign(kAlignCenter);

	--手B
	self.m_hand_b = UIFactory.createImage(handFile_2);
	self.m_root:addChild(self.m_hand_b);
	self.m_hand_b:setVisible(false);
	self.m_hand_b:setPos(self.m_p1.x+ rW/4, self.m_p1.y+10);

	--肥皂花
	local dirs = {};
	for i=1,6 do
		table.insert(dirs, throwSoap_pin_map[string.format("soap_spray_%d.png",i)]);
	end	
	self.m_soap_spray = UIFactory.createImages(dirs);
	self.m_root:addChild(self.m_soap_spray);
	self.m_soap_spray:setVisible(false);
	if not posFlag then
		self.m_soap_spray:setPos(self.m_p1.x-30+ rW/4, self.m_p1.y-20);
	else
		self.m_soap_spray:setPos(self.m_p1.x+5+ rW/4, self.m_p1.y-20);
	end

	--击中后水花
	local dirs = {};
	for i=1,15 do
		table.insert(dirs, throwSoap_pin_map[string.format("soap_end_%d.png",i)]);
	end	
	self.soap_end_spray = UIFactory.createImages(dirs);
	self.m_root:addChild(self.soap_end_spray);
	self.soap_end_spray:setVisible(false);
	local gW, gH = self.soap_end_spray:getSize();
	self.soap_end_spray:setPos(self.m_p2.x - gW/2 + rW*2/3, self.m_p2.y-rH/3);
end

function AnimationThrowSoap.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:shakeHandWithSoap();
	self:playSoapSprayAnim();	--播放肥皂花
	self:throwSoapAnim();
end

--[[手拿肥皂抖动]]
function AnimationThrowSoap.shakeHandWithSoap( self )
	self.m_soap:setVisible(true);
	self.m_hand_a:setVisible(true);
	self.m_soap:addPropScale(self.baseSequence, kAnimLoop, 300, 0, 1, 1.1, 1, 1.1, kCenterDrawing);

  	kEffectPlayer:play(Effects.PropEgg1);
end

--[[更换手型并抖动]]
function AnimationThrowSoap.shakeHandB( self )
	self.m_hand_b:setVisible(true);
	self.m_hand_b:addPropScale(self.baseSequence, kAnimNormal, 250, 0, 1, 1.1, 1, 1.1, kCenterDrawing);
	self.m_hand_b:addPropTransparency(self.baseSequence+1, kAnimNormal, 900, 800, 1, 0);
end


--[[播放肥皂花动画]]
function AnimationThrowSoap.playSoapSprayAnim( self )

	if self.m_soapAnim then
		delete(self.m_soapAnim);
		self.m_soapAnim = nil;
	end
	self.imgIndex = 0;

	self.m_soapAnim = self.m_soap_spray:addPropRotate(0,kAnimRepeat,80,900,0,0,kCenterDrawing);
	self.m_soapAnim:setDebugName("AnimationThrowSoap || self.m_soapAnim");
	self.m_soapAnim:setEvent(self, self.showSoapOnTime);
	self.m_soap_spray:setVisible(false);

end

function AnimationThrowSoap.showSoapOnTime( self )
	if self.m_soap_spray.m_reses then
		local index = self.imgIndex;
		if index > 5 then
			index = 5;
			self.m_soap_spray:setVisible(false);
		else
			self.m_soap_spray:setImageIndex(index);
			self.m_soap_spray:setVisible(true);
		end
	else
		delete(self.m_soap_spray);
		self.m_soap_spray = nil;
		self:stop();
		return;
	end
	self.imgIndex = self.imgIndex + 1;
	if self.imgIndex > 6 then
		delete(self.m_soap_spray);
		self.m_soap_spray = nil;
	end

end

--[[丢肥皂]]
function AnimationThrowSoap.throwSoapAnim( self )

	self.m_index = 1;
	self.m_speed = 50;	-- 速度
	self.m_soap_A:addPropRotate(0, kAnimRepeat, 900, 1000, 360, 0, kCenterDrawing);
	self.m_rockAnim = new(EaseMotion, kEaseOut, 5, 200, 1000);
	self.m_rockAnim:setDebugName("AnimationThrowSoap || self.m_rockAnim");

  	kEffectPlayer:play(Effects.PropEgg2);

	self.m_rockAnim:setEvent(nil, function()
		
		if self.m_soap then
			self:shakeHandB();
			delete(self.m_soap);
			self.m_soap = nil;
		end
		
		self.m_soap_A:setVisible(true);
		if self.m_rotateFlag then
			self.m_soapCurve_1[self.m_index].y = self.m_soapCurve_1[self.m_index].y + self.m_speed*self.m_rockAnim.m_process;
		else
			self.m_soapCurve_1[self.m_index].x = self.m_soapCurve_1[self.m_index].x + self.m_speed*self.m_rockAnim.m_process;
		end
		self.m_soap_A:setPos(self.m_soapCurve_1[self.m_index].x, self.m_soapCurve_1[self.m_index].y);

		self.m_index = self.m_index + 1;
		
		if self.m_index >= #self.m_soapCurve_1 then
			self.m_index = 1;
			self.m_soap_A:setVisible(false);
			delete(self.m_rockAnim);
			self.m_rockAnim = nil;
			self:playSoapEndSprayAnim();
		end

	end);
end


--[[播放肥皂击中后动画]]
function AnimationThrowSoap.playSoapEndSprayAnim( self )

	if self.m_soapEndAnim then
		delete(self.m_soapEndAnim);
		self.m_soapEndAnim = nil;
	end
	self.imgIndex2 = 0;
  	kEffectPlayer:play(Effects.PropEgg3);
	self.m_soapEndAnim = self.soap_end_spray:addPropRotate(0,kAnimRepeat, 150, 0, 0, 0,kCenterDrawing);
	self.m_soapEndAnim:setDebugName("AnimationThrowSoap || self.m_soapEndAnim");
	self.m_soapEndAnim:setEvent(self, self.showSoapEndOnTime);
end

function AnimationThrowSoap.showSoapEndOnTime( self )
	if self.soap_end_spray.m_reses then
		local index = self.imgIndex2;
		if index > 14 then
			if index == 15 then
				self.soap_end_spray:addPropTransparency(1, kAnimNormal, 1000, 10, 1, 0);
			end
		else
			self.soap_end_spray:setImageIndex(index);
			self.soap_end_spray:setVisible(true);
		end
	else
		delete(self.soap_end_spray);
		self.soap_end_spray = nil;
		self:stop();
		return;
	end
	self.imgIndex2 = self.imgIndex2 + 1;
	if self.imgIndex2 > 32 then
		delete(self.soap_end_spray);
		self.soap_end_spray = nil;
		self:stop();
	end
end

function AnimationThrowSoap.stop( self )
	self.isPlaying = false;
	self:dtor();
end

function AnimationThrowSoap.dtor( self )

	if self.m_rockAnim then
		delete(self.m_rockAnim);
		self.m_rockAnim = nil;
	end	

	if self.m_soap_spray then
		delete(self.m_soap_spray);
		self.m_soap_spray = nil;
	end

	if self.m_root then
		delete(self.m_root);
		self.m_root = nil;
	end
end

return AnimationThrowSoap