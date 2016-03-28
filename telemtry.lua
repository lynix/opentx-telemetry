--[[
               OpenTX Telemetry Script for Taranis X9D Plus / X8R
               --------------------------------------------------

                       Alexander Koch <lynix47@gmail.com>

             Based on 'olimetry.lua' by Ollicious <bowdown@gmx.net>
--]]


-- settings  -------------------------------------------------------------------

local widgets  = { {"battery"},
                   {"fm", "gps","timer"},
                   {"dist", "alt", "speed"},
                   {"rssi"} }
local cellMaxV = 4.20
local cellMinV = 3.60


-- globals  --------------------------------------------------------------------

local displayWidth      = 212
local displayHeight     = 64
local widgetWidthSingle = 35
local widgetWidthMulti  = 0
local battCellRange     = cellMaxV - cellMinV
local widgetTable       = {}


-- widget functions  -----------------------------------------------------------

local function batteryWidget(xCoord, yCoord)

    lcd.drawFilledRectangle(xCoord+13, yCoord+7, 5, 2, 0)
    lcd.drawRectangle(xCoord+10, yCoord+9, 11, 40)

    local cellVolt = getValue("Cell")

    local availV = 0
    if cellVolt > cellMaxV then
        availV = battCellRange
    elseif cellVolt > cellMinV then
        availV = cellVolt - cellMinV
    end
    local availPerc = math.floor(availV / battCellRange * 100)

    local myPxHeight = math.floor(availPerc * 0.37)
    local myPxY = 11 + 37 - myPxHeight
    if availPerc > 0 then
        lcd.drawFilledRectangle(xCoord+11, myPxY, 9, myPxHeight, 0)
    end

    local i = 36
    while (i > 0) do
        lcd.drawLine(xCoord+12, yCoord+10+i, xCoord+18, yCoord+10+i, SOLID,
                     GREY_DEFAULT)
        i = i-2
    end

    local style = PREC2 + LEFT
    if (cellVolt < cellMinV) then
        style = style + BLINK
    end
    lcd.drawNumber(xCoord+5, yCoord+54, cellVolt*100, style)
    lcd.drawText(lcd.getLastPos(), yCoord+54, "V", 0)

end


local function rssiWidget(xCoord,yCoord)

    local db = getValue("RSSI")
    local percent = 0

    if db > 38 then
        percent = (math.log(db-28, 10) - 1) / (math.log(72, 10) - 1) * 100
    end

    local pixmap = "/SCRIPTS/TELEMETRY/GFX/RSSIh00.bmp"
    if percent > 90 then pixmap = "/SCRIPTS/TELEMETRY/GFX/RSSIh10.bmp"
    elseif percent > 80 then pixmap = "/SCRIPTS/TELEMETRY/GFX/RSSIh09.bmp"
    elseif percent > 70 then pixmap = "/SCRIPTS/TELEMETRY/GFX/RSSIh08.bmp"
    elseif percent > 60 then pixmap = "/SCRIPTS/TELEMETRY/GFX/RSSIh07.bmp"
    elseif percent > 50 then pixmap = "/SCRIPTS/TELEMETRY/GFX/RSSIh06.bmp"
    elseif percent > 40 then pixmap = "/SCRIPTS/TELEMETRY/GFX/RSSIh05.bmp"
    elseif percent > 30 then pixmap = "/SCRIPTS/TELEMETRY/GFX/RSSIh04.bmp"
    elseif percent > 20 then pixmap = "/SCRIPTS/TELEMETRY/GFX/RSSIh03.bmp"
    elseif percent > 10 then pixmap = "/SCRIPTS/TELEMETRY/GFX/RSSIh02.bmp"
    elseif percent > 0  then pixmap = "/SCRIPTS/TELEMETRY/GFX/RSSIh01.bmp"
    end

    lcd.drawPixmap(xCoord+4, yCoord+1, pixmap)
    lcd.drawText(xCoord+6, yCoord+54, db .. "dB", 0)

end


local function distWidget(xCoord, yCoord)

    lcd.drawPixmap(xCoord+1, yCoord+2, "/SCRIPTS/TELEMETRY/GFX/dist.bmp")

    local dist = getValue("Dist")
    if simModeOn == 1 then
        dist = tdist
    end

    lcd.drawNumber(xCoord+18, yCoord+7, dist, LEFT)
    lcd.drawText(lcd.getLastPos(), yCoord+7, "m", 0)

end


local function altitudeWidget(xCoord, yCoord)

    lcd.drawPixmap(xCoord+1, yCoord+2, "/SCRIPTS/TELEMETRY/GFX/hgt.bmp")

    local height = getValue("GAlt")
    if simModeOn == 1 then
        height = theight
    end

    lcd.drawNumber(xCoord+18, yCoord+7, height, LEFT)
    lcd.drawText(lcd.getLastPos(), yCoord+7, "m", 0)

end


local function speedWidget(xCoord, yCoord)

    lcd.drawPixmap(xCoord+1, yCoord+2, "/SCRIPTS/TELEMETRY/GFX/speed.bmp")

    local speed = getValue("GSpd") * 3.6

    lcd.drawNumber(xCoord+18, yCoord+7, speed, LEFT)
    lcd.drawText(lcd.getLastPos(), yCoord+7, "kmh", 0)

end


local function headingWidget(xCoord, yCoord)

    lcd.drawPixmap(xCoord+1, yCoord+2, "/SCRIPTS/TELEMETRY/GFX/compass.bmp")

    local heading = getValue("Hdg")

    lcd.drawNumber(xCoord+18, yCoord+7, heading, LEFT)
    lcd.drawText(lcd.getLastPos(), yCoord+7, "dg", 0)

end


local function fmWidget(xCoord, yCoord)

    lcd.drawPixmap(xCoord+1, yCoord+2, "/SCRIPTS/TELEMETRY/GFX/fm.bmp")

    local mode  = " ?"
    local style = MIDSIZE

    if getValue("RSSI") <= 20 then
        mode = "N/A"
        style = style + BLINK
    elseif getValue("ch8") > 0 then
        mode = "COFF"
        style = style + BLINK + INVERS
    elseif getValue("ch7") > 0 then
        mode = "RTH"
    elseif getValue("ch5") < 0 then
        mode = "POS"
    elseif getValue("ch5") == 0 then
        mode = "STA"
    elseif getValue("ch5") > 0 then
        mode = "ALT"
    end

    lcd.drawText(xCoord+20, yCoord+4, mode, style)

end


local function timerWidget(xCoord, yCoord)

    lcd.drawPixmap(xCoord+1, yCoord+3, "/SCRIPTS/TELEMETRY/GFX/timer_1.bmp")
    lcd.drawTimer(xCoord+18, yCoord+8, getValue(196), 0)

end


local function gpsWidget(xCoord,yCoord)

    local sats = (simModeOn == 1) and tsats or getValue("Sats")
    local fix  = (simModeOn == 1) and tfix or getValue("Fix")

    local fixImg = "/SCRIPTS/TELEMETRY/GFX/sat0.bmp"
    if fix == 2 then fixImg = "/SCRIPTS/TELEMETRY/GFX/sat1.bmp"
    elseif fix == 3 then fixImg = "/SCRIPTS/TELEMETRY/GFX/sat2.bmp"
    elseif fix == 4 then fixImg = "/SCRIPTS/TELEMETRY/GFX/sat3.bmp"
    end

    local satImg = "/SCRIPTS/TELEMETRY/GFX/gps_0.bmp"
    if sats > 5 then satImg = "/SCRIPTS/TELEMETRY/GFX/gps_6.bmp"
    elseif sats > 4 then satImg = "/SCRIPTS/TELEMETRY/GFX/gps_5.bmp"
    elseif sats > 3 then satImg = "/SCRIPTS/TELEMETRY/GFX/gps_4.bmp"
    elseif sats > 2 then satImg = "/SCRIPTS/TELEMETRY/GFX/gps_3.bmp"
    elseif sats > 1 then satImg = "/SCRIPTS/TELEMETRY/GFX/gps_2.bmp"
    elseif sats > 0 then satImg = "/SCRIPTS/TELEMETRY/GFX/gps_1.bmp"
    end

    lcd.drawPixmap(xCoord+1, yCoord+1, fixImg)
    lcd.drawPixmap(xCoord+13, yCoord+3, satImg)
    lcd.drawNumber(xCoord+19, yCoord+1, sats, SMLSIZE)

 end


-- main logic  -----------------------------------------------------------------

local function callWidget(name, xPos, yPos)

    if (xPos == nil) or (yPos == nil) then
        return
    end

    if widgetTable[name] == nil then
        return
    end

    widgetTable[name](xPos, yPos)

end


local function run(event)

    lcd.clear()

    local tempSumX = -1
    local tempSumY = -1
    local xOffset

    for col=1, #widgets, 1
    do
        if (#widgets[col] == 1) then
            xOffset = widgetWidthSingle
        else
            xOffset = widgetWidthMulti
        end

        for row=1, #widgets[col], 1
        do
            lcd.drawLine(tempSumX, tempSumY, tempSumX+xOffset, tempSumY, SOLID,
                         GREY_DEFAULT)
            callWidget(widgets[col][row], tempSumX+1, tempSumY+1)
            tempSumY = tempSumY + math.floor(displayHeight/#widgets[col])
        end

        tempSumY = -1
        tempSumX = tempSumX + xOffset
    end

end


local function init()

    widgetTable["alt"] = altitudeWidget
    widgetTable["battery"] = batteryWidget
    widgetTable["fm"] = fmWidget
    widgetTable["gps"] = gpsWidget
    widgetTable["timer"] = timerWidget
    widgetTable["dist"] = distWidget
    widgetTable["rssi"] = rssiWidget
    widgetTable["heading"] = headingWidget
    widgetTable["speed"] = speedWidget

    local numSingleCols = 0
    local numMultiCols  = 0
    for i=1, #widgets, 1
    do
        if (#widgets[i] == 1) then
            numSingleCols = numSingleCols + 1
        else
            numMultiCols = numMultiCols + 1
        end
    end

    widgetWidthMulti = (displayWidth - (numSingleCols * widgetWidthSingle))
    widgetWidthMulti = widgetWidthMulti / numMultiCols

end


-- module definition  ----------------------------------------------------------

return {init=init, run=run}

