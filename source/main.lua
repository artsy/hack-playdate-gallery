import "CoreLibs/animator"
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/easing"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/ui"

local kModeLogoDrop, kModeMain = 0, 1
gameMode = kModeMain

local menu = playdate.getSystemMenu()
local menuItem, error = menu:addMenuItem("Lol", function()
	print("lol indeed")
end)

local gfx<const> = playdate.graphics -- shorthand

function tableLength(tbl)
	count = 0
	for _ in pairs(tbl) do
		count = count + 1
	end
	return count
end

function setupLogoDrop()
	playdate.ui.crankIndicator:start()
	-- playdate.ui.crankIndicator:update()
	-- show this a bit later than the logo drop

	local logoImage = gfx.image.new("images/cropped")
	assert(logoImage)

	logoSprite = gfx.sprite.new(logoImage)
	logoSprite:moveTo(200, -60)
	logoSprite:add()

	dling = playdate.sound.sampleplayer.new("sounds/dling")
end

function changeArtwork(diff)
	artworkIndex = artworkIndex + diff
	if artworkIndex > artworksLength then
		artworkIndex = 1
	end
	if artworkIndex < 1 then
		artworkIndex = artworksLength
	end
	scale = 1
	slug = string.sub(artworks[artworkIndex], 1, -5)
	artworkTitle = data[slug]["title"]
	artistName = data[slug]["artistNames"]

	local artworkImage = gfx.image.new("images/artworks/" .. artworks[artworkIndex])
	assert(artworkImage)

	if artworkSprite then
		artworkSprite:setImage(artworkImage)
	else
		artworkSprite = gfx.sprite.new(artworkImage)
	end
	artworkSprite:setScale(scale)
	artworkSprite:moveTo(200, 120)
	artworkSprite:add()
end

function toggleInfo()
	showInfo = not showInfo
end

function setupMain()
	artworkIndex = 1
	artworks = playdate.file.listFiles("images/artworks/")
	artworksLength = tableLength(artworks)
	scale = 1
	showInfo = true

	data = json.decodeFile("artworks.json")

	changeArtwork(0)
end

-- setupLogoDrop()

setupMain()

function playdate.update()
	if gameMode == kModeLogoDrop then
		-- move logo lower
		local newY = logoSprite.y + 1
		print("newY", newY)
		if newY > 120 then
			-- logoSprite:remove()
		else
			logoSprite:moveBy(0, 2)
			if newY == 111 then
				dling:play()
			end
		end
	elseif gameMode == kModeMain then
		if playdate.buttonIsPressed("down") then
			artworkSprite:moveBy(0, 2)
		elseif playdate.buttonIsPressed("up") then
			artworkSprite:moveBy(0, -2)
		end
		if playdate.buttonJustPressed("right") then
			changeArtwork(1)
		elseif playdate.buttonJustPressed("left") then
			changeArtwork(-1)
		end
		if playdate.buttonJustPressed("A") then
			toggleInfo()
		end
	end

	gfx.sprite.update()
	playdate.timer.updateTimers()

	if showInfo then
		x, y, w, h = 4, 4, 100, 100
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(x - 1, y - 1, w + 2, h + 2)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(x, y, w, h)
		gfx.drawTextInRect(artistName .. "\n_" .. artworkTitle .. "_", x + 2, y + 2, w - 4, h - 4)
	end

	-- playdate.drawFPS(2, 224)
end

function playdate.cranked(change, acceleratedChange)
	if gameMode == kModeLogoDrop then
		logoSprite:moveBy(change, 0)
	elseif gameMode == kModeMain then
		scale = scale + change / 100
		if scale < 0.01 then
			scale = 0.01
		end
		artworkSprite:setScale(scale)
		print(scale)
	end
end

function playdate.gameWillPause()
	local img = gfx.image.new("images/woop")
	playdate.setMenuImage(img)
end
