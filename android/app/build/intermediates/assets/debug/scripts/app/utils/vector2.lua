Vector2 = class()

function Vector2:ctor (x, y)
	self.x = x or 0
	self.y = y or 0
end

function Vector2:length ()
	return math.sqrt((self.x ^ 2) + (self.y ^ 2))
end

function Vector2:lengthSq ()
	return (self.x ^ 2) + (self.y ^ 2)
end

function Vector2:normalize ()
	local length = self:length()
	if length > 0 then
		self.x = self.x / length
		self.y = self.y / length
	end
end

function Vector2:dot (other)
	return (self.x * other.x) + (self.y * other.y)
end

function Vector2:rotate(a)
	-- body
	local x = self.x * math.cos(a) - self.y * math.sin(a)
 	local y = self.x * math.sin(a) + self.y * math.cos(a)
 	return new(Vector2, x, y)
end