-- The config module.
--
-- Loads the configuration file.

local fs = require("filesystem")

local path = "/etc/ut-serv.conf"

local function existsDir(path)
  return fs.exists(path) and fs.isDirectory(path)
end

local function existsFile(path)
  return fs.exists(path) and not fs.isDirectory(path)
end

local DEFAULT_CONFIG = [==[
-- < Settings related to network >----------------------------------------------
-- Modem strength
network.modem.strength = 400

-- Port to listen on and send to.
network.modem.port = 12345

-- < World interaction settings > ----------------------------------------------

-- The bonus items that can be spawned
world.bonuses = {
  --↓ chance
  --    ↓ id
  --                      ↓ meta
  --                         ↓ nbt
  --                             ↓ lifetime
  {0.5, "minecraft:coal", 0, "", 30}
}

-- The bonus spawn area
world.field.x = -17
world.field.y = 65
world.field.z = -17
world.field.w = 17
world.field.h = 4
world.field.l = 17

-- < Game settings > -----------------------------------------------------------
-- Sync message interval
game.syncMsgInterval = 10

-- The default game time
game.totalGameTime = 600

-- People who can control the server
game.admins = {"Fingercomp", "Totoro"}
]==]

local function loadConfig(contents)
  local base = {
    network = {
      modem = {}
    },
    world = {
      bonuses = {},
      field = {}
    },
    game = {}
  }

  local default = {
    network = {
      modem = {
        strength = 400,
        port = 12345
      }
    },
    world = {
      bonuses = {
        {0.5, "minecraft:coal", 0, "", 30}
      },
      field = {
        x = -17,
        y = 65,
        z = -17,
        w = 17,
        h = 4,
        l = 17
      }
    },
    game = {
      syncMsgInterval = 10,
      totalGameTime = 600,
      admins = {"Fingercomp", "Totoro"}
    }
  }

  local config = {}

  local function deepCopy(value)
    if type(value) ~= "table" then
      return value
    end
    local result = {}
    for k, v in pairs(value) do
      result[k] = deepCopy(v)
    end
    return result
  end

  local function createEnv(base, default, config)
    return setmetatable({}, {
      __newindex = function(self, k, v)
        if base[k] then
          return nil
        end
        if default[k] then
          config[k] = v
        end
        return nil
      end,
      __index = function(self, k)
        if base[k] then
          config[k] = config[k] or {}
          return createEnv({}, default[k], config[k])
        end
        if default[k] then
          return config[k] or deepCopy(default[k])
        end
      end
    })
  end

  local env = createEnv(base, default, config)
  load(contents, "config", "t", env)

  local function setGet(base, default, config)
    return setmetatable({}, {
      __index = function(self, k)
        if base[k] then
          config[k] = config[k] or {}
          return setGet(base[k], default[k], config[k])
        elseif config[k] then
          return config[k]
        elseif default[k] then
          return default[k]
        end
      end
    })
  end

  return setGet(base, default, config)
end

if not existsFile(path) then
  local dirPath = fs.path(path)
  if not existsDir(dirPath) then
    local result, reason = fs.makeDirectory(dirPath)
    if not result then
      error("failed to create '" .. tostring(dirPath) .. "' directory for the config file: " .. tostring(reason))
    end
  end
  local file, reason = io.open(path, "w")
  if file then
    file:write(DEFAULT_CONFIG)
    file:close()
  else
    error("failed to open config file for writing: " .. tostring(reason))
  end
end
local file, reason = io.open(path, "r")
if not file then
  error("failed to open config file for reading: " .. tostring(reason))
end
local content = file:read("*all")
file:close()

return loadConfig(content)
