local gfx = playdate.graphics

import "achievements/all"

-- Copied from the comments in the other file...
---@type game_data
local achievementData = {
    gameID = "com.example.achievementtest",
    name = "My Awesome Game",
    author = "You, Inc",
    description = "The next (r)evolution in cranking technology.",
    achievements = {
        {
            id = "test_achievement",
            name = "Achievement 1 Name",
            description = "Achievement 1 Description",
            -- isSecret = false,
            icon = "test",
            iconLocked = "test_locked",
        },
        {
            id = "test_achievement_2",
            name = "Achievement 2 Name",
            description = "Achievement 2 Description",
            -- isSecret = false,
	    scoreValue = 0,
            icon = "test",
            iconLocked = "test_locked",
        },
        {
            id = "test_achievement_3",
            name = "Achievement 3 Name",
            description = "Achievement 3 Description",
            -- isSecret = false,
            icon = "test",
            iconLocked = nil,
            progressMax = 5,
        },
        {
            id = "test_achievement_4",
            name = "Achievement 4 Name",
            description = "Achievement 4 Description",
            isSecret = true,
            progressMax = 5,
        },
        {
            id = "test_achievement_5",
            name = "Achievement 5 Name",
            description = "Achievement 5 Description",
            isSecret = true,
            icon = nil,
            iconLocked = "test_locked",
        },
    }
}

achievements.initialize(achievementData)

gfx.setColor(gfx.kColorBlack)

Scenes = {}
Scenes.fallback = {
    update = function()
       playdate.graphics.clear()
        playdate.graphics.drawText("error: please switch to an actual scene", 10, 20)
    end
}
local CURRENT_SCENE = "fallback"

function CHANGE_SCENE(new_scene, ...)
    assert(type(new_scene) == "string", "argument[1] 'new_scene' must be a string")
    assert(Scenes[new_scene], "attempt to switch to an invalid scene: " .. new_scene)
    playdate.inputHandlers.pop()
    playdate.inputHandlers.push(Scenes[new_scene])
    CURRENT_SCENE = Scenes[new_scene]
    if Scenes[new_scene].enter then
        Scenes[new_scene].enter(...)
    end
end

import "CoreLibs/ui"
import "generate_data"
local TOAST_MODE = "auto"  -- can also use "sprite" or "manual", for testing

-- Set numDescriptionLines to 2 (or 3) if you have longer achievement
-- descriptions.
achievements.viewer.initialize({ enableAboutScreen = true,
				 numDescriptionLines = 1 }) 

achievements.toasts.initialize({ miniMode = false,
				 invert = false,  -- set to true to try dark toasts
				 numDescriptionLines = 1,
				 toastOnGrant = true,
				 toastOnAdvance = 0.5,
				 renderMode = TOAST_MODE })

local mainSprite

local main_screen = playdate.ui.gridview.new(0, 20)
local options = {
    {"GENERATE RANDOM DATA", function() 
        CHANGE_SCENE("GENERATE_DATA")
    end},
    {"LAUNCH VIEWER", function()
	achievements.viewer.launch{gameData = achievements.gameData}
    end},
    {"launch viewer test1" , function()
        local gamedata = achievements.crossgame.getData("com.example.achievementtest_generated_1")
        achievements.viewer.launch{gameData = gamedata}
    end},
    {"set to regular toasts", function()
	achievements.toasts.initialize({ miniMode = false })
    end},
    {"set to mini toasts", function()
	achievements.toasts.initialize({ miniMode = true })
    end},
    {"grant/revoke 1", function() 
        if achievements.isGranted("test_achievement") then
            print("revoking example achievement 1")
            achievements.revoke("test_achievement")
        else
            print("granting example achievement 1")
            achievements.grant("test_achievement")
        end
    end},
    {"grant/revoke 2", function() 
        if achievements.isGranted("test_achievement_2") then
            print("revoking example achievement 2")
            achievements.revoke("test_achievement_2")
        else
            print("granting example achievement 2")
            achievements.grant("test_achievement_2")
        end
    end},
    {"achievement 3 progress -1", function() 
        print("achiement 3: -1 completion")
        achievements.advance("test_achievement_3", -1)
    end},
    {"achievement 3 progress +1", function() 
        print("achiement 3: +1 completion")
        achievements.advance("test_achievement_3", 1)
    end},
    {"achievement 4 progress -1", function() 
        print("achiement 4: -1 completion")
        achievements.advance("test_achievement_4", -1)
    end},
    {"achievement 4 progress +1", function() 
        print("achiement 4: +1 completion")
        achievements.advance("test_achievement_4", 1)
    end},
    {"grant/revoke 5", function() 
        if achievements.isGranted("test_achievement_5") then
            print("revoking example achievement 5")
            achievements.revoke("test_achievement_5")
        else
            print("granting example achievement 5")
            achievements.grant("test_achievement_5")
        end
    end},
    {"grant invalid", function() 
        print("granting invalid achievement")
        achievements.grant("invalid")
    end},
    {"revoke invalid", function() 
        print("revoking invalid achievement")
        achievements.revoke("invalid")
    end},
    {"save/export data", function() 
        print("saving/exporting")
        achievements.save()
    end},
}
main_screen:setNumberOfRows(#options)
function main_screen:drawCell(section, row, column, selected, x, y, width, height)
    gfx.pushContext()
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setColor(gfx.kColorWhite)
    if selected then
        gfx.fillCircleInRect(x, y + (height/2) - 3, 6, 6, 3)
    end
    playdate.graphics.drawText(options[row][1], x + 10, y)
    gfx.popContext()
end
Scenes.MAIN_DEBUG = {
    downButtonDown = function()
        main_screen:selectNextRow(true)
    end,
    upButtonDown = function()
        main_screen:selectPreviousRow(true)
    end,
    AButtonDown = function()
        options[main_screen:getSelectedRow()][2]()
    end,
    update = function()
       gfx.fillRect(0, 0, 400, 240)
       main_screen:drawInRect(10, 10, 390, 230)
       playdate.drawFPS(0,0)
    end
}

if TOAST_MODE == "sprite" then
   mainSprite = gfx.sprite.new(gfx.image.new(400, 240))
   mainSprite:add()
   mainSprite:setCenter(0, 0)
   mainSprite:moveTo(0, 0)
   mainSprite:setUpdatesEnabled(true)
   mainSprite.update = function()
      gfx.pushContext(mainSprite:getImage())
      CURRENT_SCENE.update()
      gfx.popContext()
      mainSprite:markDirty()
   end
end

function playdate.update()
   if TOAST_MODE == "sprite" then
      gfx.sprite.update()
   else
      CURRENT_SCENE.update()
   end
   playdate.timer.updateTimers()
   if TOAST_MODE == "manual" then
      achievements.toasts.manualUpdate()
   end
end

CHANGE_SCENE("MAIN_DEBUG")
