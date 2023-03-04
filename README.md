Add this to `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.repos.devnoname120 = {
   url = "https://github.com/devnoname120/hammerspoon-collection",
   branch = "build",
}

spoon.SpoonInstall:andUse("AutoMuteOnSleep", {repo="devnoname120", start=true})
spoon.SpoonInstall:andUse("AutoBTDisconnectOnSleep", {repo="devnoname120", start=true})
spoon.SpoonInstall:andUse("AutoDisconnectFromHotspot", {repo="devnoname120", start=true, config={hotspotName="mysuperhotspot", wifiName="mysuperwifi", wifiPassword="mysuperpassword"}})
```
