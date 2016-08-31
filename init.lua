
---- -----------------------------------------------------------------------
--                         ** TESTING **                       --
-- -----------------------------------------------------------------------
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
--   hs.alert.show("Jay Swaminarayan Tilakdas!")
-- end)

---- -----------------------------------------------------------------------
--                         ** MUTE AUDIO **                       --
-- -----------------------------------------------------------------------
muteAudio = function()
    hs.audiodevice.defaultOutputDevice():setVolume(0)
end

hs.timer.doAt("9:30", "1d", muteAudio)
---- -----------------------------------------------------------------------
--                         ** FIND MOUSE **                       --¬
-- -----------------------------------------------------------------------
-- local mouseCircle = nil
-- local mouseCircleTimer = nil

-- function mouseHighlight()
--     -- Delete an existing highlight if it exists
--     if mouseCircle then
--         mouseCircle:delete()
--         if mouseCircleTimer then
--             mouseCircleTimer:stop()
--         end
--     end
--     -- Get the current co-ordinates of the mouse pointer
--     mousepoint = hs.mouse.getAbsolutePosition()
--     -- Prepare a big red circle around the mouse pointer
--     mouseCircle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-40, mousepoint.y-40, 80, 80))
--     mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1})
--     mouseCircle:setFill(false)
--     mouseCircle:setStrokeWidth(5)
--     mouseCircle:show()

--     -- Set a timer to delete the circle after 3 seconds
--     mouseCircleTimer = hs.timer.doAfter(3, function() mouseCircle:delete() end)
-- end
-- hs.hotkey.bind({"cmd","alt","shift"}, "D", mouseHighlight)
---- -----------------------------------------------------------------------
--                         ** CAFFINE **                       --
-- -----------------------------------------------------------------------
local caffeine = hs.menubar.new()
function setCaffeineDisplay(state)
    if state then
        caffeine:setIcon("caffine-awake.png")
    else
        caffeine:setIcon("caffine-sleepy.png")
    end
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end
---- -----------------------------------------------------------------------
--                         ** LOCK/SLEEP MAC **                       --
-- -----------------------------------------------------------------------
function lockScreen()
    hs.caffeinate.lockScreen()
end

function sleep()
    hs.caffeinate.systemSleep()
end

---- -----------------------------------------------------------------------
--                         ** RELOAD CONFIG **                       --
---- -----------------------------------------------------------------------
function reload()
  hs.reload()
end
hs.alert.show("Config loaded")

---- -----------------------------------------------------------------------
--                         ** WINDOW MANAGEMENT **                       --
-- -----------------------------------------------------------------------
---- -----------------------------------------------------------------------
--                         ** Something Global **                       --
-- -----------------------------------------------------------------------
  -- Uncomment this following line if you don't wish to see animations
hs.window.animationDuration = 0
grid = require "hs.grid"
grid.setMargins('0, 0')

-- Set screen watcher, in case you connect a new monitor, or unplug a monitor
screens = {}
local screenwatcher = hs.screen.watcher.new(function()
  screens = hs.screen.allScreens()
end)
screenwatcher:start()

-- Set screen grid depending on resolution
for index,screen in pairs(hs.screen.allScreens()) do
  if screen:frame().w / screen:frame().h > 2 then
    -- 10 * 4 for ultra wide screen
    grid.setGrid('10 * 4', screen)
  else
    if screen:frame().w < screen:frame().h then
      -- 4 * 8 for vertically aligned screen
      grid.setGrid('4 * 8', screen)
    else
      -- 8 * 4 for normal screen
      grid.setGrid('8 * 4', screen)
    end
  end
end

-- Some constructors, just for programming
function Cell(x, y, w, h)
  return hs.geometry(x, y, w, h)
end

-- Please leave a comment if you have any suggestions
-- I know this looks weird, but it works :C
current = {}
function init()
  current.win = hs.window.focusedWindow()
  current.scr = hs.window.focusedWindow():screen()
end

function current:new()
  init()
  o = {}
  setmetatable(o, self)
  o.window, o.screen = self.win, self.scr
  o.screenGrid = grid.getGrid(self.scr)
  o.windowGrid = grid.get(self.win)
  return o
end

-- -----------------------------------------------------------------------
--            ** Keybinding configurations locate at bottom **          --
-- -----------------------------------------------------------------------

local function maximizeWindow()
  local this = current:new()
  hs.grid.maximizeWindow(this.window)
end

local function centerOnScreen()
  local this = current:new()
  this.window:centerOnScreen(this.screen)
end

local function throwLeft()
  local this = current:new()
  this.window:moveOneScreenWest()
end

local function throwRight()
  local this = current:new()
  this.window:moveOneScreenEast()
end

local function leftHalf()
  local this = current:new()
  local cell = Cell(0, 0, 0.5 * this.screenGrid.w, this.screenGrid.h)
  grid.set(this.window, cell, this.screen)
  this.window.setShadows(true)
end

local function rightHalf()
  local this = current:new()
  local cell = Cell(0.5 * this.screenGrid.w, 0, 0.5 * this.screenGrid.w, this.screenGrid.h)
  grid.set(this.window, cell, this.screen)
end

local function topHalf()
  local this = current:new()
  local cell = Cell(0, 0, this.screenGrid.w, 0.5 * this.screenGrid.h)
  grid.set(this.window, cell, this.screen)
end

local function bottomHalf()
  local this = current:new()
  local cell = Cell(0, 0.5 * this.screenGrid.h, this.screenGrid.w, 0.5 * this.screenGrid.h)
  grid.set(this.window, cell, this.screen)
end

local function rightToLeft()
  local this = current:new()
  local cell = Cell(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w - 1, this.windowGrid.h)
  if this.windowGrid.w > 1 then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show("Small Enough :)")
  end
end

local function rightToRight()
  local this = current:new()
  local cell = Cell(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w + 1, this.windowGrid.h)
  if this.windowGrid.w < this.screenGrid.w - this.windowGrid.x then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show("Touching Right Edge :|")
  end
end


local function bottomUp()
  local this = current:new()
  local cell = Cell(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w, this.windowGrid.h - 1)
  if this.windowGrid.h > 1 then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show("Small Enough :)")
  end
end

local function bottomDown()
  local this = current:new()
  local cell = Cell(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w, this.windowGrid.h + 1)
  if this.windowGrid.h < this.screenGrid.h - this.windowGrid.y then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show("Touching Bottom Edge :|")
  end
end

local function leftToLeft()
  local this = current:new()
  local cell = Cell(this.windowGrid.x - 1, this.windowGrid.y, this.windowGrid.w + 1, this.windowGrid.h)
  if this.windowGrid.x > 0 then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show("Touching Left Edge :|")
  end
end

local function leftToRight()
  local this = current:new()
  local cell = Cell(this.windowGrid.x + 1, this.windowGrid.y, this.windowGrid.w - 1, this.windowGrid.h)
  if this.windowGrid.w > 1 then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show("Small Enough :)")
  end
end

local function topUp()
  local this = current:new()
  local cell = Cell(this.windowGrid.x, this.windowGrid.y - 1, this.windowGrid.w, this.windowGrid.h + 1)
  if this.windowGrid.y > 0 then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show("Touching Top Edge :|")
  end
end

local function topDown()
  local this = current:new()
  local cell = Cell(this.windowGrid.x, this.windowGrid.y + 1, this.windowGrid.w, this.windowGrid.h - 1)
  if this.windowGrid.h > 1 then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show("Small Enough :)")
  end
end


-- local function topUp()
--   local this = current:new()
--   -- local cell

--   -- if this.windowGrid.h == 1 then
--   --   hs.alert.show("Already Small Like You!")
--   -- end

--   -- if this.windowGrid.h < 4 and this.windowGrid.y ~= 0 then
--   --   hs.alert.show("IF UP " .. this.windowGrid.h)
--   --   cell = Cell(this.windowGrid.x, 0, this.windowGrid.w, 4)
--   --   grid.set(this.window, cell, this.screen)
--   -- else
--   --   hs.alert.show("TEST UP" .. this.windowGrid.y)
--   --   cell = Cell(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w, this.windowGrid.h - 1)
--   --   grid.set(this.window, cell, this.screen)
--   -- end
--   -- local cell = Cell(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w, this.windowGrid.h - 1)
--   if this.windowGrid.y > 0 then
--     grid.set(this.window, cell, this.screen)
--   else
--     hs.alert.show("Touching Top Edge :|")
--   end
--   grid.set(this.window, cell, this.screen)
-- end

-- local function topDown()
--   local this = current:new()
--   -- local cell

--   -- if this.windowGrid.h == 1 then
--   --   hs.alert.show("Already Small Like You!")
--   -- end

--   -- if this.windowGrid.h < 4 and this.windowGrid.y == 0 then
--   --   hs.alert.show("IF " .. this.windowGrid.h)
--   --   cell = Cell(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w, 4)
--   --   grid.set(this.window, cell, this.screen)
--   -- else
--   --   hs.alert.show("TEST " .. this.windowGrid.y)
--   --   cell = Cell(this.windowGrid.x, this.windowGrid.y + 1, this.windowGrid.w, this.windowGrid.h)
--   --   grid.set(this.window, cell, this.screen)
--   -- end
--   if this.windowGrid.h > 1 then
--     grid.set(this.window, cell, this.screen)
--   else
--     hs.alert.show("Small Enough :)")
--   end
--   grid.set(this.window, cell, this.screen)
-- end

-- -----------------------------------------------------------------------
--                           ** Key Binding **                          --
-- -----------------------------------------------------------------------
key = require "hs.hotkey"
------------------------ * Move window to screen * -----------------------
hs.hotkey.bind({"cmd", "alt"}, "left", throwLeft)
hs.hotkey.bind({"cmd", "alt"}, "right", throwRight)
-------------------- * Set Window Position on screen* --------------------
hs.hotkey.bind({"ctrl", "alt", "cmd" }, "m", maximizeWindow)    -- ⌃⌥⌘ + M
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "c", centerOnScreen)     -- ⌃⌥⌘ + C
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "left", leftHalf)        -- ⌃⌥⌘ + ←
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "right", rightHalf)      -- ⌃⌥⌘ + →
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "up", topHalf)           -- ⌃⌥⌘ + ↑
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "down", bottomHalf)      -- ⌃⌥⌘ + ↓
-------------------- * Set Window Position on screen* --------------------
hs.hotkey.bind({"ctrl", "alt", "shift"}, "left", rightToLeft)   -- ⌃⌥⇧ + ←
hs.hotkey.bind({"ctrl", "alt", "shift"}, "right", rightToRight) -- ⌃⌥⇧ + →
hs.hotkey.bind({"ctrl", "alt", "shift"}, "up", bottomUp)        -- ⌃⌥⇧ + ↑
hs.hotkey.bind({"ctrl", "alt", "shift"}, "down", bottomDown)    -- ⌃⌥⇧ + ↓
-------------------- * Set Window Position on screen* --------------------
hs.hotkey.bind({"alt", "cmd", "shift"}, "left", leftToLeft)     -- ⌥⌘⇧ + ←
hs.hotkey.bind({"alt", "cmd", "shift"}, "right", leftToRight)   -- ⌥⌘⇧ + →
hs.hotkey.bind({"alt", "cmd", "shift"}, "up", topUp)            -- ⌥⌘⇧ + ↑
hs.hotkey.bind({"alt", "cmd", "shift"}, "down", topDown)        -- ⌥⌘⇧ + ↓

hs.hotkey.bind({"cmd", "alt"}, "L", lockScreen)
hs.hotkey.bind({"ctrl", "alt", "cmd" }, "S", sleep)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", reload)
---- -----------------------------------------------------------------------
--                         ** TIMER **                       --
---- -----------------------------------------------------------------------
function startLaundryTimer()
  hs.timer.doAfter(35 * 60, function ()
    hs.notify.new({
        title="Laundry time!",
        informativeText="Your laundry is ready!"
    }):send()
  end)
  hs.alert("Laundry timer started!")
end

--Bind timer to `hammerspoon://laundrytime`:
hs.urlevent.bind("laundrytime", startLaundryTimer)

function startDryerTimer()
  hs.timer.doAfter(60 * 60, function ()
    hs.notify.new({
        title="Dryer time!",
        informativeText="Your clothes are dry!"
    }):send()
  end)
  hs.alert("Dryer timer started!")
end

--Bind timer to `hammerspoon://dryertime`:
hs.urlevent.bind("dryertime", startDryerTimer)

function startPizzaTimer()
  hs.timer.doAfter(12 * 60, function ()
    hs.notify.new({
        title="Pizza time!",
        informativeText="Your pizza is ready!"
    }):send()
  end)
  hs.alert("Pizza timer started!")
end

--Bind timer to `hammerspoon://pizzatimes`:
hs.urlevent.bind("pizzatime", startPizzaTimer)