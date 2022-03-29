import "CoreLibs/animator"
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/easing"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/ui"



local menu = playdate.getSystemMenu()
local menuItem, error = menu:addMenuItem("Lol", function()
print("lol indeed")
end)

local gfx <const> = playdate.graphics -- shorthand

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

setupLogoDrop()

function playdate.update()
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


    -- housekeeping
    gfx.sprite.update()
    playdate.timer.updateTimers()
end

function playdate.cranked(change, acceleratedChange)
    logoSprite:moveBy(change, 0)
end


function playdate.gameWillPause()
	local img = gfx.image.new('images/woop')
	playdate.setMenuImage(img)
end
