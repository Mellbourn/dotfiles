-- make sure displays are placed correctly on wakeup
function printf(s,...)  print(s:format(...)) end
wather = hs.caffeinate.watcher.new(function(eventType)
    -- screensDidWake, systemDidWake, screensDidUnlock
    if eventType == hs.caffeinate.watcher.screensDidUnlock then
        local output = hs.execute("/Users/klas.mellbourn/bin/dp", false)
        -- hs.notify.new({title="TestTitle", informativeText=output}):send()
        -- printf("%s, world", output)
    end
end)
wather:start()
