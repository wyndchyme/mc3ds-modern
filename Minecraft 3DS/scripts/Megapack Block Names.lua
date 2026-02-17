---@type BlangParser
local blang_parser = dofile(Core.getModpath("lunacoreapi") .. "/src/utils/blang_parser.lua")
local titleId = Core.getTitleId()

local localeFile = Core.Filesystem.open(string.format("sdmc:/luma/titles/%s/romfs/loc/en_US-pocket.blang", titleId), "r+")

local localeParser = blang_parser.newParser(localeFile)

localeParser:addText("tile.reserved6.name", "Mud")
localeParser:addText("tile.info_update2.name", "Mud Bricks")
localeParser:addText("tile.info_update.name", "Polished Deepslate")
localeParser:addText("tile.netherreactor.name", "Deepslate Bricks")
localeParser:addText("tile.stonecutter.name", "Deepslate Tiles")

localeParser:dumpFile(localeFile)
collectgarbage("collect")

localeFile:close()

local localeFile = Core.Filesystem.open(string.format("sdmc:/luma/titles/%s/romfs/loc/en_GB-pocket.blang", titleId), "r+")

local localeParser = blang_parser.newParser(localeFile)

localeParser:addText("tile.reserved6.name", "Mud")
localeParser:addText("tile.info_update2.name", "Mud Bricks")
localeParser:addText("tile.info_update.name", "Polished Deepslate")
localeParser:addText("tile.netherreactor.name", "Deepslate Bricks")
localeParser:addText("tile.stonecutter.name", "Deepslate Tiles")

localeParser:dumpFile(localeFile)
collectgarbage("collect")

localeFile:close()

local localeFile = Core.Filesystem.open(string.format("sdmc:/luma/titles/%s/romfs/loc/ru_RU-pocket.blang", titleId), "r+")

local localeParser = blang_parser.newParser(localeFile)

localeParser:addText("tile.reserved6.name", "Mud") 
localeParser:addText("tile.info_update2.name", "Mud Bricks")
localeParser:addText("tile.info_update.name", "Polished Deepslate")
localeParser:addText("tile.netherreactor.name", "Deepslate Bricks")
localeParser:addText("tile.stonecutter.name", "Deepslate Tiles")

localeParser:dumpFile(localeFile)
collectgarbage("collect")

localeFile:close()