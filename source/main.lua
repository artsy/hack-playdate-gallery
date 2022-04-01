import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/nineslice"
import "CoreLibs/ui"

import "./utils"
import "./logoDrop"
import "./gallery"

local gfx<const> = playdate.graphics -- shorthand

-- game mode stuff
kModeLogoDrop, kModeGallery = 0, 1
local gameMode
function setGameMode(mode)
	if gameMode == mode then
		return
	end

	gameMode = mode

	if gameMode == kModeLogoDrop then
		LogoDrop:setup()
	elseif gameMode == kModeGallery then
		LogoDrop:cleanup()
		Gallery:setup()
	end
end

showFPS = false
local function mainSetup()
	local img = gfx.image.new("images/woop")

	gfx.lockFocus(img)
	gfx.drawTextAligned("Ⓑ️ toggle artwork info", 10, 190)
	-- gfx.drawTextAligned("Ⓐ view full screen", 10, 214)
	gfx.drawTextAligned("🎣 rotate me!", 10, 214)
	gfx.unlockFocus()

	playdate.setMenuImage(img)

	local menu = playdate.getSystemMenu()
	local menuItem, error = menu:addCheckmarkMenuItem("Show FPS", showFPS, function()
		showFPS = not showFPS
	end)

	setGameMode(kModeLogoDrop)
end
mainSetup()

function playdate.update()
	if gameMode == kModeLogoDrop then
		LogoDrop:update()
	elseif gameMode == kModeGallery then
		Gallery:update()
	end

	gfx.sprite.update()
	playdate.timer.updateTimers()

	if gameMode == kModeLogoDrop then
		LogoDrop:postupdate()
	elseif gameMode == kModeGallery then
		Gallery:postupdate()
	end

	if showFPS then
		playdate.drawFPS(2, 224)
	end
end

function playdate.cranked(change, acceleratedChange)
	if gameMode == kModeLogoDrop then
		LogoDrop:cranked(change, acceleratedChange)
	elseif gameMode == kModeGallery then
		Gallery:cranked(change, acceleratedChange)
	end
end
