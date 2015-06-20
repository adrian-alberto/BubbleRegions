function love.load()
	require "oop"
	require "vector"
	require "blobs"
	print("Hello, world!")

	InitialBlob = Blob.new(Vector2.new(0,0), 5)
	math.randomseed(love.timer.getTime())
	while #Blobs:get() < 100 do
		local numBlobs = #Blobs:get()
		for i = 1, numBlobs do
			blobA = Blobs:get()[i]

			local angle = math.random() * math.pi * 2
			local dist1 = math.random(blobA.radius*0.3, blobA.radius*0.9)
			local dist2 = math.random(blobA.radius*0.5, blobA.radius*1.5)
			local pos2 = Vector2.new(math.cos(angle)*(dist1+dist2), math.sin(angle)*(dist1+dist2)) + blobA.pos

			blobB = Blob.new(pos2, 1)
			blobB:setRadius(dist2)
			blobB.prev = blobA
			if blobB:checkIfBurst() then
				Blobs:removeValue(blobB)
			end
		end
	end
end

--[[
function love.update(dt)
	TestBlob.controlVec = Vector2.new((love.keyboard.isDown("d") and 1 or 0) - (love.keyboard.isDown("a") and 1 or 0), (love.keyboard.isDown("s") and 1 or 0) - (love.keyboard.isDown("w") and 1 or 0))
	for _, blob in pairs(Blobs:get()) do
		blob:update(dt)
	end
end
--]]

function love.draw()
	love.graphics.print("Hello, world", 10, 10)
	for _, blob in pairs(Blobs:get()) do
		blob:deformShape()
		blob:draw(Vector2.new(love.window.getWidth()/2, love.window.getHeight()/2))
	end
end
