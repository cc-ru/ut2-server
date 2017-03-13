local bit32 = require("bit32")
local com = require("component")

local module = require("ut2-serv.modules")
local config = module.load("config")
local db = module.load("db")
local events = module.load("events")

local glasses = com.glasses

local EventEngine = events.engine

local function convColor(color)
  local b = bit32.band(color, 0xff)
  local g = bit32.band(bit32.rshift(color, 8), 0xff)
  local r = bit32.band(bit32.rshift(color, 16), 0xff)
  return r / 0xff, g / 0xff, b / 0xff
end

local objects = {}

local function addObject(...)
  local args = {...}
  if args[2] == "addBox" then
    local rect = glasses.addRect()
    rect.setPosition(args[3], args[4])
    rect.setSize(args[6], args[5])
    rect.setColor(convColor(args[7]))
    if args[8] then
      rect.setAlpha(args[8])
    end
    objects[args[1]] = rect
    return rect
  elseif args[2] == "addText" then
    local text = glasses.addTextLabel()
    text.setPosition(args[3], args[4])
    text.setText(args[5])
    text.setColor(convColor(args[6]))
    text.setScale(1)
    objects[args[1]] = text
    return text
  elseif args[2] == "addHLine" or args[2] == "addVLine" then
    local quad = glasses.addQuad()
    local dx, dy
    if args[2] == "addHLine" then
      dx, dy = 0, 1
    else
      dx, dy = 1, 0
    end
    quad.setVertex(1, args[3].x, args[3].y)
    quad.setVertex(2, args[4].x, args[4].y)
    quad.setVertex(3, args[4].x + dx, args[4].y + dy)
    quad.setVertex(4, args[3].x + dx, args[3].y + dy)
    quad.setColor(convColor(args[5]))
    objects[args[1]] = quad
    return quad
  elseif args[2] == "addPolygon" then
    local quad = glasses.addQuad()
    quad.setColor(convColor(args[3]))
    quad.setAlpha(args[4])
    for i = 1, #args - 4, 1 do
      quad.setVertex(i, args[i + 4].x, args[i + 4].y)
    end
    if #args > 8 then
      local quad2 = glasses.addQuad()
      quad.setVertex(1, args[5].x, args[5].y)
      quad.setVertex(2, args[8].x, args[8].y)
      quad.setVertex(3, args[9].x, args[9].y)
      if args[10] then
        quad.setVertex(4, args[10].x, args[10].y)
      else
        quad.setVertex(4, args[9].x, args[9].y)
      end
      return {quad, quad2}
    end
    return {quad}
  end
end

local function drawUI()
  -- SCORE
  addObject("score.green.box", "addBox", 55, 5, 50, 50, 0x20ff20, .33)
  addObject("score.blue.box", "addBox", 5, 5, 50, 50, 0x20afff, .33)
  addObject("score.red.box", "addBox", 105, 5, 50, 50, 0xff2020, .33)
  addObject("score.yellow.box", "addBox", 155, 5, 50, 50, 0xffff20, .33)

  local score1 = addObject("score.blue.text", "addText", 14.5 / 3, 20 / 3, "00", 0xffffff)
  score1.setScale(3)

  local score2 = addObject("score.green.text", "addText", 64.5 / 3, 20 / 3, "00", 0xffffff)
  score2.setScale(3)

  local score3 = addObject("score.red.text", "addText", 114.5 / 3, 20 / 3, "00", 0xffffff)
  score3.setScale(3)

  local score4 = addObject("score.yellow.text", "addText", 164.5 / 3, 20 / 3, "00", 0xffffff)
  score4.setScale(3)

  -- SCORE PRBAR
  addObject("score.yellow.bar", "addBox", 5, 57, 200, 1, 0xffff20)
  addObject("score.red.bar", "addBox", 5, 57, 150, 1, 0xff2020)
  addObject("score.green.bar", "addBox", 5, 57, 100, 1, 0x20ff20)
  addObject("score.blue.bar", "addBox", 5, 57, 50, 1, 0x20afff)

  -- TIME BOX
  addObject("time.box", "addBox", 5, 60, 200, 50, 0xffffff, .5)

  addObject("time.separator", "addVLine", {x=105, y=63}, {x=105, y=107}, 0x606060)

  local passed = addObject("time.passed.time", "addText", 18 / 3, 75 / 3, "00:00", 0x000000)
  passed.setScale(3)
  addObject("time.passed.label", "addText", 18, 65, "Time passed", 0x000000)

  local total = addObject("time.total.time", "addText", 118 / 1.75, 70 / 1.75, "00:00", 0x000000)
  total.setScale(1.75)
  local totalLabel = addObject("time.total.label", "addText", 118 / 0.8, 63 / 0.8, "Total", 0x000000)
  totalLabel.setScale(0.8)

  local remaining = addObject("time.remaining.time", "addText", 118 / 1.75, 95 / 1.75, "00:00", 0x000000)
  remaining.setScale(1.75)
  local remainingLabel = addObject("time.remaining.label", "addText", 118 / 0.8, 88 / 0.8, "Remaining", 0x000000)
  remainingLabel.setScale(0.8)

  -- TIME PRBAR
  addObject("time.bar.total", "addBox", 5, 112, 200, 1, 0xffffff)
  addObject("time.bar.passed", "addBox", 5, 112, 0, 1, 0x20afff)

  -- NICKS
  addObject("nicks.blue.box.small", "addBox", 210, 5, 5, 11, 0x20afff)
  addObject("nicks.blue.box", "addBox", 215, 5, 150, 11, 0x20afff, .5)

  addObject("nicks.green.box.small", "addBox", 210, 18, 5, 11, 0x20ff20)
  addObject("nicks.green.box", "addBox", 215, 18, 150, 11, 0x20ff20, .5)

  addObject("nicks.red.box.small", "addBox", 210, 31, 5, 11, 0xff2020)
  addObject("nicks.red.box", "addBox", 215, 31, 150, 11, 0xff2020, .5)

  addObject("nicks.yellow.box.small", "addBox", 210, 44, 5, 11, 0xffff20)
  addObject("nicks.yellow.box", "addBox", 215, 44, 150, 11, 0xffff20, .5)

  addObject("nicks.blue.text", "addText", 217, 7, "", 0xffffff)
  addObject("nicks.green.text", "addText", 217, 20, "", 0xffffff)
  addObject("nicks.red.text", "addText", 217, 33, "", 0xffffff)
  addObject("nicks.yellow.text", "addText", 217, 46, "", 0xffffff)
end

EventEngine:subscribe("init", events.priority.normal, function(handler, evt)
  glasses.removeAll()
  drawUI()
  events.engine:push(events.UIUpdate())
end)

EventEngine:subscribe("stop", events.priority.normal, function(handler, evt)
  glasses.removeAll()
end)

return {
  objects = objects
}
