import "./utils"

local gfx<const> = playdate.graphics -- shorthand

LogoDrop = {}

function LogoDrop:setup()
	local logoImage = gfx.image.new("images/cropped")
	assert(logoImage)

	logoSprite = gfx.sprite.new(logoImage)
	logoSprite:moveTo(200, -60)
	logoSprite:add()

	dling = playdate.sound.sampleplayer.new("sounds/dling")
end

function LogoDrop:cleanup()
	logoSprite:remove()
end

function LogoDrop:update()
	local finalY = 120

	local newY = logoSprite.y + 1
	if newY <= 120 then
		logoSprite:moveBy(0, 2)
		if newY == 111 then
			once("dling", function()
				dling:play()
				playdate.timer.performAfterDelay(2000, function()
					setGameMode(kModeGallery)
				end)
			end)
		end
	end
end

function LogoDrop:cranked(change, acceleratedChange)
	logoSprite:moveBy(change, 0)
end
