Blob = class()
Blobs = List.new()

function Blob:init(pos, area, id)
	local numVertices = 32
	self.id = id
	self.pos = pos
	self.velocity = Vector2.new()
	self.area = area
	self.radius = math.sqrt(area/math.pi) * 10
	self.vertices = {}
	self.tweenedVertices = {}
	self.controlVec = Vector2.new()

	--Distances from center
	for i = 1, numVertices do
		self.vertices[i] = self.radius
		self.tweenedVertices[i] = self.radius
	end

	Blobs:add(self)
end

function Blob:update(dt)
	local force = self.controlVec:unit() * 10000

	--Check if can be devoured
	for _, other in pairs(Blobs:get()) do
		local distance = (other.pos - self.pos).magnitude
		local minDist = other.radius + self.radius
		if other ~= self and distance < minDist then
			if self.radius * 1.2 < other.radius then
				local squishDist = ((distance*distance - other.radius*other.radius + self.radius*self.radius) / (2*distance))
				if distance < (distance - squishDist) then
					Blobs:removeValue(self)
					other:setArea(other.area + self.area)
					return
				end
			elseif other.radius * 1.2 > self.radius then
				--apply force
				force = force + ((self.pos - other.pos):unit() * (minDist^2 - distance^2))
			end
		end
	end

	--Phyics
	force = force + self.velocity * -(self.radius*2*math.pi)/20 --friction
	self.velocity = self.velocity + (force / (self.area*10))
	self.pos = self.pos + self.velocity * dt

	self:deformShape()
end

function Blob:draw(offset)
	local color = math.min(200, self.realArea/80) + 55
	self.color = color
	love.graphics.setColor(color/2, color, color,100)
	local poly = {}
	for i = 1, #self.vertices do
		local theta = math.pi*2*i/#self.vertices
		local distance = self.vertices[i]

		--[[Smooth out blob shape
		local avgsum = 0
		local avgcount = 0
		local avgwidth = math.floor(#self.vertices * 0.2)
		for j = -avgwidth, avgwidth do
			local k = j
			if i + j < 1 then
				k = j + #self.vertices
			elseif i + j > #self.vertices then
				k = j - #self.vertices
			end
			avgsum = avgsum + self.vertices[i + k]*(avgwidth + 1 - math.abs(j))
			avgcount = avgcount + (avgwidth + 1 - math.abs(j))
		end
		distance = math.min(distance, avgsum/avgcount)
		--]]

		poly[2*i - 1] = math.cos(theta) * distance + self.pos.x + offset.x
		poly[2*i] = math.sin(theta) * distance + self.pos.y + offset.y
	end
	--love.graphics.polygon("fill", poly)
	--love.graphics.setColor(0,0,0,255)
	love.graphics.setLineWidth(1)
	love.graphics.polygon("line", poly)

	love.graphics.setColor(255,0,0,250)
	--love.graphics.circle("line", self.pos.x + offset.x, self.pos.y + offset.y, self.radius)
end

function Blob:drawPrev(offset)
	if self.prev then
		love.graphics.line(self.pos.x + offset.x, self.pos.y + offset.y, self.prev.pos.x + offset.x, self.prev.pos.y + offset.y)
	end
end

function Blob:setArea(area)
	self.area = area
	self.radius = math.sqrt(area/math.pi) * 10
end

function Blob:setRadius(radius)
	self.radius = radius
	self.area = math.pi*self.radius*self.radius
end


function Blob:checkIfBurst()
	for _, other in pairs(Blobs:get()) do
		local distance = (other.pos - self.pos).magnitude
		local minDist = other.radius + self.radius
		if other ~= self and distance < minDist then
			--if self.radius * 1.2 < other.radius then
				local squishDist = ((distance*distance - other.radius*other.radius + self.radius*self.radius) / (2*distance))
				if distance < (distance - squishDist) then
					return true
				end
				local squishDist = ((distance*distance - self.radius*self.radius + other.radius*other.radius) / (2*distance))
				if distance < (distance - squishDist) then
					return true
				end
			--end
		end
	end
end

function Blob:deformShape()
	--Maximize blob radius
	for i, d in pairs(self.vertices) do
		self.vertices[i] = self.radius
	end

	--Calculate blob deformation
	for _, other in pairs(Blobs:get()) do
		if other ~= self then
			local distance = (other.pos - self.pos).magnitude
			local minDist = other.radius + self.radius
			local overlap = math.abs(other.radius + self.radius - distance)
			if distance < minDist then
				local squishDist = ((distance*distance - other.radius*other.radius + self.radius*self.radius) / (2*distance))
				local angleOfSquish = math.acos(squishDist/self.radius)
				local directionOfSquish = math.atan2(other.pos.y - self.pos.y, other.pos.x - self.pos.x)

				if distance > (distance - squishDist) then
				--if self.radius > overlap/2 and other.radius > overlap/2 then
					--Things get weird if trying to draw something that is practically engulfed by another blob.
					for i, d in pairs(self.vertices) do
						local theta = math.pi*2*i/#self.vertices
						local thetaOffset = ((directionOfSquish - theta) + math.pi) % (math.pi*2) - math.pi
						if math.abs(thetaOffset) <= angleOfSquish then
							--squishDist = distance - overlap/2
							self.vertices[i] = math.min(self.vertices[i], self.radius, squishDist/math.cos(thetaOffset))
						end
					end
				end
				
			end
		end
	end

	--Calculate real area
	local area = 0
	local x = 0.5 * math.sin(math.pi*2/#self.vertices)
	for i = 1, #self.vertices - 1 do
		local j = i + 1
		area = area + x * self.vertices[i] * self.vertices[j]
	end
	self.realArea = area
end

function Blob:dither()
	for i, d in pairs(self.vertices) do
		if d > self.radius * 0.99 then
			local max = d
			local min = self.radius * 0.8
			self.vertices[i] = max - (math.random() * (max - min))
		end
	end
end
