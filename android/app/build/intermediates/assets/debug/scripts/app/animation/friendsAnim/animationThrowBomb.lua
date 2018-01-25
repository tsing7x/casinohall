-- 好友 扔炸弹动画
local AnimCurve = require("app.animation/friendsAnim/animCurve");

require("app.animation/friendsAnim/friendAnim_pin");


local AnimationThrowBomb = class(Node);


function AnimationThrowBomb.ctor( self, p1, p2, fromId, toId)

	self.m_p1 = p1;
	self.m_p2 = p2;
	self.m_fromId = fromId;
	self.m_toId = toId;
	self.m_h = 50;	--弧线高度
	self.m_pnum = 55;
	self.isPlaying = false;
	self.baseSequence = 10;

	self:load();
	--创建飞行路径
	self.m_rockCurve_1 = {};
	if math.abs(p1.x-p2.x) <=100 then
		self.m_rotateFlag = true;
		self.m_p2.y = self.m_p2.y - 33;
		self.m_p2.x = self.m_p2.x + 20 ;
		self.m_rockCurve_1 = AnimCurve.createLineCurve(self.m_p1, self.m_p2, self.m_pnum);
	else
		self.m_rockCurve_1 = AnimCurve.createParabolaCurve(self.m_p1, self.m_p2, self.m_h, self.m_pnum);
	end

	--创建玻璃渣路径
	self.starsEndPos = {};
	for i=1,7 do
		self.starsEndPos[i] = {};
	end
	self.starsEndPos[1].x = -90;
	self.starsEndPos[1].y = 0;
	self.starsEndPos[2].x = -60;
	self.starsEndPos[2].y = 80;
	self.starsEndPos[3].x = -70;
	self.starsEndPos[3].y = -50;
	
	self.starsEndPos[4].x = 0;
	self.starsEndPos[4].y = -110;

	self.starsEndPos[5].x = 80;
	self.starsEndPos[5].y = 10;
	self.starsEndPos[6].x = 80;
	self.starsEndPos[6].y = 100;
	self.starsEndPos[7].x = 90;
	self.starsEndPos[7].y = 40;

	self.arryPos = {};

	for i=1,7 do
		self.arryPos[i] = {};
		self.arryPos[i].pos = AnimCurve.createLineCurve({x=0,y=0} ,self.starsEndPos[i], 10);
	end
end

function AnimationThrowBomb.load( self )
	self.m_root = new(Node);
	self.m_root:addToRoot();

	--bomb
	self.m_rock = UIFactory.createImage(throwBomb_pin_map["bomb.png"]);
	self.m_rock:setVisible(false);
	self.m_rock:setPos(self.m_p1.x, self.m_p1.y);
	local rW, rH = self.m_rock:getSize();

	--玻璃裂纹
	self.m_glassCrack = UIFactory.createImage(throwRock_pin_map["glass_crack.png"]);
	self.m_root:addChild(self.m_glassCrack);
	self.m_root:addChild(self.m_rock);
	self.m_glassCrack:setVisible(false);
	local gW, gH = self.m_glassCrack:getSize();
	self.m_glassCrack:setPos(self.m_p2.x - gW/2 + rW/2, self.m_p2.y - gH/2 + rH/2);
	
	--7个玻璃碎片
	self.m_glassFlake = {};
	for i=1,7 do
		self.m_glassFlake[i] = UIFactory.createImage(throwRock_pin_map["glass_flake.png"]);
		self.m_glassCrack:addChild(self.m_glassFlake[i]);
		self.m_glassFlake[i]:setAlign(kAlignCenter);
		self.m_glassFlake[i]:setVisible(false);
	end

	--爆炸效果
	local dirs = {};
	for i=1,5 do
		table.insert(dirs, throwBomb_pin_map[string.format("end_%d.png",i)]);
	end	
	self.m_ends = UIFactory.createImages(dirs);
	self.m_root:addChild(self.m_ends);
	self.m_ends:setVisible(false);
	local gW, gH = self.m_ends:getSize();
	self.m_ends:setPos(self.m_p2.x - gW/2 + rW/2, self.m_p2.y - gH*2/3 + rH/3);

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

function AnimationThrowBomb.play( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;
	self:playSmogAnim();
	self:throwRockAnim();
end

--[[播放烟圈动画]]
function AnimationThrowBomb.playSmogAnim( self )

	if self.m_smogAnim then
		delete(self.m_smogAnim);
		self.m_smogAnim = nil;
	end
	self.imgIndex = 0;
	self.m_smogAnim = self.m_smogs:addPropRotate(0,kAnimRepeat,120,0,0,0,kCenterDrawing);
	self.m_smogAnim:setDebugName("AnimationThrowBomb || self.m_smogAnim");
	self.m_smogAnim:setEvent(self, self.showSmogsOnTime);
	self.m_smogs:setVisible(false);
	
  	kEffectPlayer:play(Effects.PropBomb1);
end

function AnimationThrowBomb.showSmogsOnTime( self )
	if self.m_smogs.m_reses then
		local index = self.imgIndex;
		if index > 4 and not self.m_bombFlag then
			index = 4;
			self.m_smogs:setVisible(false);
		elseif index > 4 and self.m_bombFlag then
			index = 4;
			self.m_ends:setVisible(false);
		elseif self.m_bombFlag then
			if not self.brokeGlassFlag then
				self:brokeGlassAnim();
				self.brokeGlassFlag = true;
			end
			self.m_ends:setImageIndex(index);
			self.m_ends:setVisible(true);
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
	if self.imgIndex > 31 then
		delete(self.m_smogs);
		self.m_smogs = nil;
		self:stop();
	end

end

--[[丢石头]]
function AnimationThrowBomb.throwRockAnim( self )

	self.m_index = 1;
	self.m_speed = 50;	-- 速度
	self.m_curveFlag = true;
	self.m_rock:addPropRotate(0,kAnimRepeat,500,0,0,360,kCenterDrawing);

	if self.m_rockAnim then
		delete(self.m_rockAnim);
	end
	self.m_rockAnim = new(EaseMotion, kEaseOut, 5, 200, 0);
	self.m_rockAnim:setDebugName("AnimationThrowBomb || self.m_rockAnim");
  	kEffectPlayer:play(Effects.PropBomb2);
	self.m_rock:setVisible(true)
	self.m_rockAnim:setEvent(nil, function()
		
		if self.m_curveFlag then
			if self.m_rotateFlag then
				self.m_rockCurve_1[self.m_index].y = self.m_rockCurve_1[self.m_index].y + self.m_speed*self.m_rockAnim.m_process;
			else
				self.m_rockCurve_1[self.m_index].x = self.m_rockCurve_1[self.m_index].x + self.m_speed*self.m_rockAnim.m_process;
			end
			self.m_rock:setPos(self.m_rockCurve_1[self.m_index].x, self.m_rockCurve_1[self.m_index].y);
		end
		self.m_index = self.m_index + 1;
		
		if self.m_index >= #self.m_rockCurve_1 and self.m_curveFlag then
			self.m_index = 1;
			self.m_curveFlag = false;
			self.imgIndex = 0;
			self.m_bombFlag = true;	-- 炸弹爆炸
			self.m_rock:setVisible(false);
			delete(self.m_rockAnim);
			self.m_rockAnim = nil;
		end
	end);
end


--[[砸玻璃]]
function AnimationThrowBomb.brokeGlassAnim( self )
  	kEffectPlayer:play(Effects.PropBomb3);
	self.m_glassCrack:setVisible(true);
	self.m_glassCrack:addPropScale(self.baseSequence, kAnimNormal, 50, 0, 0.5, 1, 0.5, 1, kCenterDrawing);
	self.m_glassCrack:addPropTransparency(self.baseSequence+1, kAnimNormal, 1000, 1500, 1, 0);
	self:glassFlakesAnim();
end


--[[玻璃渣散开动画]]
function AnimationThrowBomb.glassFlakesAnim( self )
	for i=1,7 do
		self.m_glassFlake[i]:setVisible(true);
	end

	self.m_glassFlakeAnim = new(EaseMotion, kCCEaseOut, 20, 200, 0);
	self.m_glassFlakeAnim:setDebugName("AnimationThrowBomb--self.m_glassFlakeAnim")
	self.m_glassFlakeIndex = 1;
	self.m_glassFlakeAnim:setEvent(nil, function()

		-- 更新坐标
		for i=1,7 do
			-- self.arryPos[i].pos[self.m_glassFlakeIndex].x = self.arryPos[i].pos[self.m_glassFlakeIndex].x 
			-- 	+ math.random(10,20)*self.m_glassFlakeAnim.m_process;
			self.m_glassFlake[i]:setPos(self.arryPos[i].pos[self.m_glassFlakeIndex].x, self.arryPos[i].pos[self.m_glassFlakeIndex].y);
		end
		self.m_glassFlakeIndex = self.m_glassFlakeIndex + 1;

		if self.m_glassFlakeIndex >= #(self.arryPos[1].pos) then
			self.m_glassFlakeIndex = #(self.arryPos[1].pos);
			delete(self.m_glassFlakeAnim);
			self.m_glassFlakeAnim = nil;
		end
	end);
end


function AnimationThrowBomb.stop( self )
	self.isPlaying = false;
	self:dtor();
end

function AnimationThrowBomb.dtor( self )

	if self.m_rockAnim then
		delete(self.m_rockAnim);
		self.m_rockAnim = nil;
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

return AnimationThrowBomb