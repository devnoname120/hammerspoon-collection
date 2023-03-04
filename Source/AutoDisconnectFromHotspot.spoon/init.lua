--- === AutoDisconnectFromHotspot ===
---
--- Automatically disconnects from my mobile hotspot when my home Wi-Fi is detected.
---
--- Download: [https://github.com/devnoname120/hammerspoon-collection/raw/build/Spoons/AutoDisconnectFromHotspot.spoon.zip](https://github.com/devnoname120/hammerspoon-collection/raw/build/Spoons/AutoDisconnectFromHotspot.spoon.zip)


local obj={}
obj.__index = obj

-- Metadata
obj.name = "AutoDisconnectFromHotspot"
obj.version = "1.0"
obj.author = "devnoname120 <devnoname120@gmail.com>"
obj.homepage = "https://github.com/devnoname120/hammerspoon-collection"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Config: name of the hotspot to disconnect from
obj.hotspotName = ""
-- Config: name of the Wi-Fi to connect to when disconnecting from hotspot
obj.wifiName = ""
-- Config: password of the Wi-Fi to connect to (due to a limitation of macOS's API the password has to be provided even if macOS already has it).
obj.wifiPassword = ""


local function wifiInRange(name)
   local cachedScanResults = hs.wifi.interfaceDetails().cachedScanResults
   for k, v in pairs(cachedScanResults) do
      if v.ssidData == name then
         return true
      end
   end
   return false
end

obj.wifiwatcher = nil

function obj:wifiwatcher(watcher, event, interface)
    local current_ssid = hs.wifi.currentNetwork()
    if current_ssid == obj.hotspotName and wifiInRange(obj.wifiName) then
        hs.wifi.associate(obj.wifiName, obj.wifiPassword)
    end
end

function obj:init()
    self.wifiwatcher = hs.wifi.watcher.new(hs.fnutils.partial(self.wifiwatcher, self))
    self.wifiwatcher:watchingFor({"scanCacheUpdated"})
end

function obj:start()
    self.wifiwatcher:start()
end

function obj:stop()
    self.sleepWatcher:stop()
end

return obj
