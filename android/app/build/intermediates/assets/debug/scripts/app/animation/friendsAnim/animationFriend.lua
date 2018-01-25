local AnimationFriend = class()

AnimationFriend.sAnimation = {
	[2001] = 'app.animation/friendsAnim/animationThrowEgg2',
	[2002] = 'app.animation/friendsAnim/animationPourwater2',
	[2003] = 'app.animation/friendsAnim/animationSendRose2',
	[2004] = 'app.animation/friendsAnim/animationSendKiss2',
	[2005] = 'app.animation/friendsAnim/animationCheers2',
	[2006] = 'app.animation/friendsAnim/animationTomato2',
	[2007] = 'app.animation/friendsAnim/animationDog2',
	[2008] = 'app.animation/friendsAnim/animationHammer2',
	[2009] = 'app.animation/friendsAnim/animationBomb2',
	[2010] = 'app.animation/friendsAnim/animationSendtissue2',
	[3000] = 'app.animation/friendsAnim/animationAddFriend',

}
function AnimationFriend:ctor( parent )
	-- body
	self.mRootNode = parent
end

function AnimationFriend:dtor(  )
	-- body
end

function AnimationFriend:play(id, src, dst)
	-- body
	local path = AnimationFriend.sAnimation[id]
	if path then
		animNode = new(require(path), src, dst);
		self.mRootNode:addChild(animNode)
		animNode:play();
	end
end

return AnimationFriend