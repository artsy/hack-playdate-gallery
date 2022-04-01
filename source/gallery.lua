import "CoreLibs/sprites"

import "./utils"
import "./frames"

local gfx<const> = playdate.graphics -- shorthand

Gallery = {}

local function changeArtwork(diff, px, cx, nx)
	artworkIndex = artworkIndex + diff
	if artworkIndex > artworksLength then
		artworkIndex = 1
	end
	if artworkIndex < 1 then
		artworkIndex = artworksLength
	end

	artworkIndexNext = artworkIndex + 1
	if artworkIndexNext > artworksLength then
		artworkIndexNext = 1
	end
	if artworkIndexNext < 1 then
		artworkIndexNext = artworksLength
	end

	artworkIndexPrev = artworkIndex - 1
	if artworkIndexPrev > artworksLength then
		artworkIndex = 1
	end
	if artworkIndexPrev < 1 then
		artworkIndexPrev = artworksLength
	end

	scale = 1
	slug = string.sub(artworks[artworkIndex], 1, -5)
	artworkTitle = data[slug]["title"]
	artistName = data[slug]["artistNames"]

	-- art will be displayed here:
	--            400
	-- ┌──────────────────────────┐
	-- │           10             │
	-- │  ┌────────────────────┐  │
	-- │10│      380x180       │10│
	-- │  │                    │  │ 240
	-- │  └────────────────────┘  │
	-- │           50             │
	-- └──────────────────────────┘
	DeviceWidth = 400
	DeviceHeight = 240
	infoBoxHeight = 64
	amx = 10 -- artwork margin horizontal
	amt = 10 -- artwork margin top
	apx = 7 -- artwork padding horizontal
	apy = 7 -- artwork padding vertical

	local artworkImage = gfx.image.new("images/artworks/small/" .. artworks[artworkIndex])
	assert(artworkImage)

	if artwork then
		artwork:setImage(artworkImage)
	else
		artwork = gfx.sprite.new(artworkImage)
	end
	artwork:setScale(scale)
	artwork:setZIndex(300)
	artwork:moveTo(DeviceWidth / 2, DeviceHeight / 2 - infoBoxHeight + amt + apy * 2)
	-- artwork:add()

	if not frame then
		frame = gfx.sprite.new()
	end
	frame:setSize(artwork.width + 2 * apx, artwork.height + 2 * apy)
	frame:setZIndex(200)
	-- frame:moveTo(frame.width / 2 + amx, frame.height / 2 + amt)
	frame:moveTo(DeviceWidth / 2, DeviceHeight / 2 - infoBoxHeight + amt * 2 + 8)
	function frame:draw(x, y, w, h)
		gfx.clear()
		Frames.poke:drawInRect(x, y, w, h)
		-- gfx.setColor(gfx.kColorBlack)
		-- gfx.fillRect(x, y, w, h)
		-- gfx.setColor(gfx.kColorWhite)
		-- gfx.fillRect(x + 2, y + 2, w - 4, h - 4)
	end
	-- frame:add()
	----- group sprites?

	local artworkFullImage = gfx.image.new("images/artworks/full/" .. artworks[artworkIndex])
	assert(artworkFullImage)
	if artworkFull then
		artworkFull:setImage(artworkFullImage)
	else
		artworkFull = gfx.sprite.new(artworkFullImage)
	end
	artworkFull:setScale(scale)
	if diff == 1 then
		artworkFull:moveTo(nx, DeviceHeight / 2)
	elseif diff == -1 then
		artworkFull:moveTo(px, DeviceHeight / 2)
	else
		artworkFull:moveTo(DeviceWidth / 2, DeviceHeight / 2)
	end
	artworkFull:add()

	local artworkFullNextImage = gfx.image.new("images/artworks/full/" .. artworks[artworkIndexNext])
	assert(artworkFullNextImage)
	if artworkFullNext then
		artworkFullNext:setImage(artworkFullNextImage)
	else
		artworkFullNext = gfx.sprite.new(artworkFullNextImage)
	end
	artworkFullNext:setScale(scale)
	if diff == -1 then
		artworkFullNext:moveTo(cx, DeviceHeight / 2)
	end
	artworkFullNext:moveTo(artworkFull.x + DeviceWidth, DeviceHeight / 2)
	artworkFullNext:add()

	local artworkFullPrevImage = gfx.image.new("images/artworks/full/" .. artworks[artworkIndexPrev])
	assert(artworkFullPrevImage)
	if artworkFullPrev then
		artworkFullPrev:setImage(artworkFullPrevImage)
	else
		artworkFullPrev = gfx.sprite.new(artworkFullPrevImage)
	end
	artworkFullPrev:setScale(scale)
	if diff == 1 then
		artworkFullPrev:moveTo(cx, DeviceHeight / 2)
	else
		artworkFullPrev:moveTo(artworkFull.x - DeviceWidth, DeviceHeight / 2)
	end
	artworkFullPrev:add()
end

showCrankIndicator = true
function Gallery:setup()
	artworkIndex = 1
	artworks = playdate.file.listFiles("images/artworks/small/")
	artworksLength = tableLength(artworks)
	scale = 1
	showInfo = true
	fullScreen = true

	data = json.decodeFile("artworks.json")

	changeArtwork(0)

	playdate.ui.crankIndicator:start()
	playdate.timer.performAfterDelay(2000, function()
		showCrankIndicator = false
	end)
end

--- portrait layout, put the infobox on the side, and the artwork a bit to the right
--- make the infobox smaller, fit the text

function Gallery:update()
	if playdate.buttonIsPressed("down") then
		artworkFull:moveBy(0, 2)
	elseif playdate.buttonIsPressed("up") then
		artworkFull:moveBy(0, -2)
	end
	if playdate.buttonJustPressed("right") then
		changeArtwork(1)
	elseif playdate.buttonJustPressed("left") then
		changeArtwork(-1)
	end
	if playdate.buttonJustPressed("B") then
		showInfo = not showInfo
	end
	if playdate.buttonJustPressed("A") then
		fullScreen = not fullScreen
	end
end

function Gallery:postupdate()
	if showInfo then
		textWidthArtist = gfx.getSystemFont():getTextWidth(artistName)
		textWidthTitle = gfx.getSystemFont():getTextWidth("_" .. artworkTitle .. "_")
		textWidth = math.min(math.max(textWidthArtist, textWidthTitle) + 6, DeviceWidth - 2 * amx)
		x, y, w, h = amx, DeviceHeight - infoBoxHeight - amt, textWidth, infoBoxHeight
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(x - 1, y - 1, w + 2, h + 2)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(x, y, w, h)
		gfx.drawTextInRect(artistName .. "\n_" .. artworkTitle .. "_\n" .. artworkIndex .. "/" .. artworksLength, x + 2,
						y + 2, w - 4, h - 4)
		-- gfx.drawTextInRect(, 340, y + 2, 60 - amx - 4, h - 4, nil, nill,
		-- 				kTextAlignment.right)
	end
	if showCrankIndicator then
		playdate.ui.crankIndicator:update()
	end
end

function Gallery:cranked(change, acceleratedChange)
	artworkFull:moveBy(-change, 0)
	artworkFullNext:moveBy(-change, 0)
	artworkFullPrev:moveBy(-change, 0)

	if artworkFull.x < 0 then
		changeArtwork(1, artworkFullPrev.x, artworkFull.x, artworkFullNext.x)
	elseif artworkFull.x > DeviceWidth then
		changeArtwork(-1, artworkFullPrev.x, artworkFull.x, artworkFullNext.x)
	end
end
