--- === AutoBTDisconnectOnSleep ===
---
--- Automatically disconnect my Quietcomfort QC 45 when system goes to sleep. Avoids annoying playback issues on my phone (QC 45 multipoint connection is mediocre).
---
--- Download: [https://github.com/devnoname120/hammerspoon-collection/raw/build/Spoons/AutoBTDisconnectOnSleep.spoon.zip](https://github.com/devnoname120/hammerspoon-collection/raw/build/Spoons/AutoBTDisconnectOnSleep.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "AutoBTDisconnectOnSleep"
obj.version = "1.0"
obj.author = "devnoname120 <devnoname120@gmail.com>"
obj.homepage = "https://github.com/devnoname120/hammerspoon-collection"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.sleepWatcher = nil

--- Reconnect these devices when coming back from sleep
obj.devicesToReconnect = {}

function obj:checkBluetoothList(rc, stdout, stderr)
--- Filter and keep only devices containing QC45 / QC35 in the name
    local devices = hs.json.decode(stdout)
    
    local devicesToDisconnect = {}
    
    for _, device in ipairs(devices) do
        if string.find(device.name, "QC") or string.find(device.name, "QuietComfort") then
            print("[BT] Disconnecting: " .. device.name .. "...")
            table.insert(obj.devicesToReconnect, device)
          -- Adding --info works around a bug in blueutil, see https://github.com/toy/blueutil/issues/58
          local t = hs.task.new("/opt/homebrew/bin/blueutil", nil, {"--disconnect", device.address, "--info", device.address})
          t:start()
        end
    end


--- Put the id of these devices in obj.devicesToReconnect
--- Do for each device id: /usr/local/bin/blueutil --disconnect ID --info ID
end

function obj:sleepWatcherCB(state)
    local callback = function(rc, stdout, stderr)
        obj:checkBluetoothList(rc, stdout, stderr)
    end

    if state == hs.caffeinate.watcher.systemWillSleep then
        local t = hs.task.new("/opt/homebrew/bin/blueutil", callback, {"--connected", "--format", "json-pretty"})
        t:start()
    elseif state == hs.caffeinate.watcher.systemDidWake then
        for _, device in ipairs(obj.devicesToReconnect) do
            print("[BT] Reconnecting: " .. device.name .. "...")
            -- TODO: Figure out why this sometimes doesn't do anything'
            local t = hs.task.new("/opt/homebrew/bin/blueutil", nil, {"--connect", device.address, "--info", device.address, "--format", "json-pretty"})
            t:start()
        end
        
        obj.devicesToReconnect = {}
            
    end
end


function obj:init()
    local callback = function(state)
        obj:sleepWatcherCB(state)
    end

    self.sleepWatcher = hs.caffeinate.watcher.new(callback)
end

function obj:start()
    self.sleepWatcher:start()
end

function obj:stop()
    self.sleepWatcher:stop()
end

return obj