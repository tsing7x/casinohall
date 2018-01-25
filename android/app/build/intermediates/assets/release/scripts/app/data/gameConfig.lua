local GameConfig = class()

addProperty(GameConfig, "lastType", 0)
addProperty(GameConfig, "lastSuffix", "")
addProperty(GameConfig, "lastUserType", UserType.Visitor)
addProperty(GameConfig, "lastLoginData", nil)

function GameConfig:load()
	self.m_set = new(Dict, "gameConfig")
	self.m_set:load()
	local lastType = self.m_set:getInt("lastType")
	local lastSuffix = self.m_set:getString("lastSuffix")
	local lastUserType = self.m_set:getInt("lastUserType", UserType.Visitor)
	-- 默认国标麻将
	self:setLastType(lastType or 0)
	self:setLastSuffix(lastSuffix or "")
	self:setLastUserType(lastUserType or UserType.Visitor)
end

function GameConfig:save()
	self.m_set = new(Dict, "gameConfig")
	
	self.m_set:setInt("lastType", self:getLastType())
	self.m_set:setString("lastSuffix", self:getLastSuffix())
	self.m_set:setInt("lastUserType", self:getLastUserType())
	self.m_set:save()
end

return GameConfig