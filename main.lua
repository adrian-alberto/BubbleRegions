function love.load()
	require "oop"
	require "vector"
	require "blobs"
	require "tilemaps"
	print("Hello, world!")

	InitialBlob = Blob.new(Vector2.new(0,0), 40)
	math.randomseed(love.timer.getTime())
	repeat
		local totalArea = 0
		local numBlobs = #Blobs:get()
		for i = 1, numBlobs do
			blobA = Blobs:get()[i]

			local angle = math.random() * math.pi * 2
			local dist1 = math.random(blobA.radius*0.3, blobA.radius*0.8) --do not change the 0.3
			local dist2 = math.random(blobA.radius*0.5, blobA.radius*1.4)
			local pos2 = Vector2.new(math.cos(angle)*(dist1+dist2), math.sin(angle)*(dist1+dist2)) + blobA.pos

			blobB = Blob.new(pos2, 1)
			blobB:setRadius(dist2)
			blobB.prev = blobA
			if blobB:checkIfBurst() or dist2 < 20 then
				Blobs:removeValue(blobB)
			end
		end
		for _, blob in pairs(Blobs:get()) do
			blob:deformShape()
			totalArea = totalArea + blob.realArea
			blob:dither()
		end
	until totalArea > 400^2

	maps = {}

	for i, blob in pairs(Blobs:get()) do
		table.insert(maps, TileMap.fromBlob(blob, 3))
	end
end


function love.draw()
	love.graphics.print("Hello, world", 10, 10)

	love.graphics.setColor(255,255,255,255)
	for _, map in pairs(maps) do
		map:draw(Vector2.new(love.window.getWidth()/2, love.window.getHeight()/2), 3)
	end

	for _, blob in pairs(Blobs:get()) do
		blob:draw(Vector2.new(love.window.getWidth()/2, love.window.getHeight()/2))
	end
end
