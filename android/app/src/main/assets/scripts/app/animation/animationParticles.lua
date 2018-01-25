require("particle/particleSystem");
require("particle/particleFireWork");
require("particle/particleRadialLine");
require("particle/particleBubble");
require("particle/particleFlower");
require("particle/particleRain");
require("particle/particleLeaf");
require("particle/particleMoney");
require("particle/particleSnow");


-- 离子动画
AnimationParticles = class();

AnimationParticles = {
	DropCoin = 1;
	DropSnow = 2;	
}

AnimationParticles.ctor = function()
	
end

AnimationParticles.play = function(type)
	
	if not type then
		Log.w("离子动画类型为空!!")
		return;
	end

	if type == AnimationParticles.DropSnow then
		AnimationParticles.playDropSnow();
	elseif type == AnimationParticles.DropCoin then
		AnimationParticles.playDropCoin();
	end

end

AnimationParticles.playDropCoin = function()
	if AnimationParticles.particleMoney then
		delete(AnimationParticles.particleMoney);
	end	
	AnimationParticles.particleMoney = ParticleSystem.getInstance():create(coin_pin_map,ParticleMoney,0,0,nil,kParticleTypeBlast,50+20*math.random(),{["h"] = System.getScreenHeight()/2,["w"] = System.getScreenWidth();["rotation"]=4;["scale"]=0.8;["maxIndex"]=7;});
	AnimationParticles.particleMoney:resume();
	AnimationParticles.particleMoney:addToRoot();
	AnimationParticles.particleMoney:setLevel(60);
	kEffectPlayer:play(Effects.AudioGetGold);
end

AnimationParticles.playDropSnow = function()
	if AnimationParticles.particleSnow then
		delete(AnimationParticles.particleSnow);
	end

	local str = "animation/snow/snow_1.png"
	AnimationParticles.particleSnow = 
	ParticleSystem.getInstance():create(str, ParticleSnow, 0, 0, nil, kParticleTypeForever, 40,{["h"] = 800*System.getLayoutScale(),["w"] = System.getScreenWidth();["rotation"]=4;["scale"]=1;});
	AnimationParticles.particleSnow:start();
	AnimationParticles.particleSnow:addToRoot();
	AnimationParticles.particleSnow:setLevel(60);
end

AnimationParticles.stopDropSnow = function()
	if AnimationParticles.particleSnow then
		delete(AnimationParticles.particleSnow);
	end
end


AnimationParticles.dtor = function()
	if AnimationParticles.particleSnow then
		delete(AnimationParticles.particleSnow);
	end
	if AnimationParticles.particleMoney then
		delete(AnimationParticles.particleMoney);
	end
end