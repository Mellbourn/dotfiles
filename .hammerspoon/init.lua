-- you may need to uncomment the following line to make Hammerspoon show up in Location s https://github.com/Hammerspoon/hammerspoon/issues/3537#issuecomment-1743870568
--print(hs.location.get())

local home = os.getenv("HOME")
local logFilePath = home .. "/Library/Logs/hammerspoon.log"
local function appendToLogFile(str)
    -- Open the file in append mode
    local file = io.open(logFilePath, "a")
    if not file then
        error("Could not open file at " .. logFilePath)
        return
    end
    file:write(os.date("%Y-%m-%dT%H:%M:%S") .. ' - ' .. str .. "\n")
    file:close()
end

local eventTypeToString = {
    [hs.caffeinate.watcher.screensDidWake] = "screensDidWake",
    [hs.caffeinate.watcher.systemDidWake] = "systemDidWake",
    [hs.caffeinate.watcher.screensaverDidStop] = "screensaverDidStop",
    [hs.caffeinate.watcher.screensDidUnlock] = "screensDidUnlock",
    [hs.caffeinate.watcher.sessionDidBecomeActive] = "sessionDidBecomeActive",
    [hs.caffeinate.watcher.screensaverDidStart] = "screensaverDidStart",
    [hs.caffeinate.watcher.screensaverWillStop] = "screensaverWillStop",
    [hs.caffeinate.watcher.screensDidSleep] = "screensDidSleep",
    [hs.caffeinate.watcher.screensDidLock] = "screensDidLock",
    -- Add more event types as needed
}
function eventTypeToStr(eventType)
    return eventTypeToString[eventType] or eventType
end

function areBothDellScreensConnected()
    local screens = hs.screen.allScreens()
    if #screens ~= 3 then
        appendToLogFile("Number of screens is not 3, but " .. #screens)
        return false
    end
    local foundDell1 = false
    local foundDell2 = false

    for _, screen in ipairs(screens) do
        local name = screen:name()
        if name == "DELL U3224KBA (1)" then
            appendToLogFile("Found " .. name)
            foundDell1 = true
        elseif name == "DELL U3224KBA (2)" then
            appendToLogFile("Found " .. name)
            foundDell2 = true
        end
    end

    return foundDell1 and foundDell2
end

-- make sure displays are placed correctly on wakeup, since dual DELL U3224KB are unreliable
local machineName = hs.host.localizedName()
if machineName == 'Klas’s MacBook Pro 16" 2023' then
    watcher = hs.caffeinate.watcher.new(function(eventType)
        -- screensDidWake, systemDidWake, screensaverDidStop, screensDidUnlock
        -- screensDidUnlock worked well, but not 100% of the time, failed once
        -- added sleep 4, failed once again
        -- added sleep 6, failed once again
        -- added sleep 8, failed once again
        appendToLogFile('caffeinte.watcher: ' .. eventTypeToStr(eventType))
        if eventType == hs.caffeinate.watcher.screensDidUnlock then
            hs.timer.doAfter(10, function()
                if(areBothDellScreensConnected()) then
                    local output, status, type, rc = hs.execute("/Users/klas.mellbourn/bin/dp", false)
                    if (output == "" and status and type == "exit" and rc == 0) then
                        appendToLogFile('display placement succeeded quitetly')
                    else
                        appendToLogFile('display placement: output: "' .. output
                        .. '", status: ' .. tostring(status)
                        .. ', type: "' .. type
                        .. '", rc: '.. tostring(rc))
                    end
                else
                    appendToLogFile("The two DELL screens were not detected.")
                end
            end)
        end
    end)
    watcher:start()
end

-- test command
-- hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "W", function()
--   hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
--   appendToLogFile("Hello World")
-- end)

-- reload config automatically
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- Define a table mapping SSIDs to desired volume levels
-- local ssidVolumeMap = {
--     ["Anticimex-Guest"] = 10, -- Example SSID and volume level for work
--     ["Cisco731Router"] = 70  -- Example SSID and volume level for home
-- }
--
-- local function adjustVolumeForSSID(ssid)
--     if ssidVolumeMap[ssid] then
--         appendToLogFile("Setting volume to " .. ssidVolumeMap[ssid] .. " for SSID " .. ssid)
--         -- Set the system volume to the level defined for the current SSID
--         hs.audiodevice.defaultOutputDevice():setVolume(ssidVolumeMap[ssid])
--     else
--         -- Optional: Define a default volume for unknown SSIDs
--         hs.audiodevice.defaultOutputDevice():setVolume(25) -- Example default volume
--     end
-- end
--
-- -- Create a WiFi watcher to monitor for SSID changes
-- local wifiWatcher = hs.wifi.watcher.new(function()
--     local currentSSID = hs.wifi.currentNetwork()
--     if currentSSID then
--         adjustVolumeForSSID(currentSSID)
--     end
-- end)
--
-- -- Start the WiFi watcher
-- wifiWatcher:start()


hs.alert.show("Config loaded")
