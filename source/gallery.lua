import "./utils"

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

function Gallery:setup()
	artworkIndex = 1
	artworks = playdate.file.listFiles("images/artworks/")
	artworksLength = tableLength(artworks)
	scale = 1
	showInfo = true

	data = json.decodeFile("artworks.json")

	changeArtwork(0)
end

function Gallery:update()
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
		showInfo = not showInfo
	end
end

function Gallery:postupdate()
	if showInfo then
		x, y, w, h = 4, 4, 100, 100
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
	artworkSprite:setScale(scale)
	print(scale)
end
