--[[
Memory Forever - a fork of Memory by Adriano Castro, ported to WoW: Forever.
Copyright (C) 2021-2024 Adriano Castro, 2026 Jacob Rozell. Licensed under GPLv3.

Namespace bootstrap. Every file receives (ADDON, ns) from the client; nothing
else is exposed as a global except the SavedVariables, slash command and the
addon compartment callback.
]]
local ADDON, ns = ...

ns.ADDON = ADDON
ns.NAME = 'Memory Forever'
ns.HIGHLIGHT_COLOR = 'ffee77'
ns.MUTED_COLOR = '999999'

local function readVersion()
  local getter = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
  if type(getter) ~= 'function' then return 'dev' end
  local ok, version = pcall(getter, ADDON, 'Version')
  if ok and type(version) == 'string' and version ~= '' then return version end
  return 'dev'
end

ns.VERSION = readVersion()

--[[
Wraps a value in a WoW color escape sequence.
]]
function ns.highlight(value, hexColor)
  return '|cff' .. (hexColor or ns.HIGHLIGHT_COLOR) .. tostring(value) .. '|r'
end

function ns.muted(value)
  return ns.highlight(value, ns.MUTED_COLOR)
end

--[[
Prints a line in the default chat frame, prefixed with the addon name.
]]
function ns.print(message)
  local line = ns.highlight(ns.NAME .. ':') .. ' ' .. tostring(message)
  if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
    DEFAULT_CHAT_FRAME:AddMessage(line)
  elseif print then
    print(line)
  end
end

--[[
Prints only when the debug setting is on.
]]
function ns.debug(message)
  if ns.Settings and ns.db and ns.Settings.get('debug') then
    ns.print(ns.muted('[debug] ' .. tostring(message)))
  end
end
