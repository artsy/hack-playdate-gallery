import "CoreLibs/sprites"

import "./utils"
import "./frames"

local gfx<const> = playdate.graphics -- shorthand

Gallery = {}

local function changeArtwork(diff)
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
	infoBoxHeight = 44
	amx = 10 -- artwork margin horizontal
	amt = 6 -- artwork margin top
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
	artwork:add()

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
	frame:add()

	-- group sprites?

end

function Gallery:setup()
	artworkIndex = 1
	artworks = playdate.file.listFiles("images/artworks/small/")
	artworksLength = tableLength(artworks)
	scale = 1
	showInfo = true
	fullScreen = true

	data = json.decodeFile("artworks.json")

	changeArtwork(0)
end

function Gallery:update()
	if playdate.buttonIsPressed("down") then
		artwork:moveBy(0, 2)
	elseif playdate.buttonIsPressed("up") then
		artwork:moveBy(0, -2)
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
		x, y, w, h = amx, DeviceHeight - infoBoxHeight - amt, DeviceWidth - 2 * amx, infoBoxHeight
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(x - 1, y - 1, w + 2, h + 2)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(x, y, w, h)
		gfx.drawTextInRect(artistName .. "\n_" .. artworkTitle .. "_", x + 2, y + 2, w - 4, h - 4)
	end
end

function Gallery:cranked(change, acceleratedChange)
	scale = scale + change / 100
	if scale < 0.01 then
		scale = 0.01
	end
	artwork:setScale(scale)
end
