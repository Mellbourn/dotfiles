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

-- make sure displays are placed correctly on wakeup, since dual DELL U3224KB are unreliable
local machineName = hs.host.localizedName()
if machineName == 'Klas’s MacBook Pro 16" 2023' then
    watcher = hs.caffeinate.watcher.new(function(eventType)
        -- screensDidWake, systemDidWake, screensaverDidStop, screensDidUnlock
        -- screensDidUnlock worked well, but not 100% of the time
        -- screensDidWake did not work well
        appendToLogFile('caffeinte.watcher: ' .. eventTypeToStr(eventType))
        if eventType == hs.caffeinate.watcher.screensDidUnlock then
            os.execute("sleep " .. 4)
            local output = hs.execute("/Users/klas.mellbourn/bin/dp", false)
            appendToLogFile('display placement: ' .. output)
        end
    end)
    watcher:start()
end

-- test command
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "W", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
  appendToLogFile("Hello World")
end)

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
hs.alert.show("Config loaded")
