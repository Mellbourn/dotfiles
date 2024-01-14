local home = os.getenv("HOME")
local logFilePath = home .. "/Library/Logs/hammerspoon.log"
local function appendToLogFile(str)
    -- Open the file in append mode
    local file = io.open(logFilePath, "a")
    if not file then
        error("Could not open file at " .. logFilePath)
        return
    end
    file:write(os.date("!%Y-%m-%dT%H:%M:%S") .. ' - ' .. str .. "\n")
    file:close()
end

-- make sure displays are placed correctly on wakeup, since dual DELL U3224KB are unreliable
local machineName = hs.host.localizedName()
if machineName == 'Klas’s MacBook Pro 16" 2023' then
    watcher = hs.caffeinate.watcher.new(function(eventType)
        -- screensDidWake, systemDidWake, screensDidUnlock
        if eventType == hs.caffeinate.watcher.screensDidUnlock then
            local output = hs.execute("/Users/klas.mellbourn/bin/dp", false)
            appendToLogFile('display placement: ' .. output)
        end
    end)
    watcher:start()
end

-- test command
-- hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "W", function()
--   hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
--   appendToLogFile("Hello World")
-- end)
