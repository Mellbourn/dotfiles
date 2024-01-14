-- make sure displays are placed correctly on wakeup
function printf(s,...)  print(s:format(...)) end
local machineName = hs.host.localizedName()
if machineName == 'Klas’s MacBook Pro 16" 2023' then
    watcher = hs.caffeinate.watcher.new(function(eventType)
        -- screensDidWake, systemDidWake, screensDidUnlock
        if eventType == hs.caffeinate.watcher.screensDidUnlock then
            local output = hs.execute("/Users/klas.mellbourn/bin/dp", false)
            -- hs.notify.new({title="TestTitle", informativeText=output}):send()
            -- printf("%s, world", output)
        end
    end)
    watcher:start()
end
