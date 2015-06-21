function love.load()
	require "oop"
	require "vector"
	require "blobs"
	require "tilemaps"
	print("Hello, world!")

	InitialBlob = Blob.new(Vector2.new(0,0), 70)
	math.randomseed(love.timer.getTime())
	repeat
		local totalArea = 0
		local numBlobs = #Blobs:get()
		for i = 1, numBlobs do
			blobA = Blobs:get()[i]

			local angle = math.random() * math.pi * 2
			local dist1 = math.random(blobA.radius*0.7, blobA.radius*0.9)
			local dist2 = math.random(blobA.radius*0.1, blobA.radius*1.5)
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
	until totalArea > 600^2

	maps = {}

	for i, blob in pairs(Blobs:get()) do
		table.insert(maps, TileMap.fromBlob(blob, 4))
	end
end


function love.draw()
	love.graphics.print("Hello, world", 10, 10)

	love.graphics.setColor(100,255,255,255)
	for _, map in pairs(maps) do
		local alpha = map.blob.realArea/70
		love.graphics.setColor(alpha,255-alpha,200,255)
		map:draw(Vector2.new(love.window.getWidth()/2, love.window.getHeight()/2), 4)
	end

	for _, blob in pairs(Blobs:get()) do
		blob:draw(Vector2.new(love.window.getWidth()/2, love.window.getHeight()/2))
	end
end
