## komidan's CC: Tweaked Code

A repo for all (useful... maybe?) code I've written. Written on MC Fabric 1.21.1.

[CC: Tweaked](https://www.curseforge.com/minecraft/mc-mods/cc-tweaked) Mod Pages: [Modrinth](https://modrinth.com/mod/cc-tweaked), [Curseforge](https://www.curseforge.com/minecraft/mc-mods/cc-tweaked)

Use this command in any turtle/computer terminal to get the `klib.lua` file.
```txt
wget https://raw.githubusercontent.com/komidan/komi_cc/refs/heads/main/klib.lua
```
Requiring `klib.lua` in a lua script:
```lua
local klib = require(path_to_file)
```
Requiring the file updates the `rednet` table with more functions:
```lua
rednet.message(data, status_code?)
rednet.log(from, to, message, protocol)
rednet.formatMessage(from, to, message, protocol)
```
| Function | Description |
|:-:|:-|
|`rednet.message`| Returns a table that adds more data such as a UTC timestamp and an optional status code.|
|`rednet.log`| Prints a formatted message sent over rednet. `Uses rednet.message()`|
|`rednet.formatMessage`| Takes in the `rednet.message()` return table for `message`.|

---
I'm always open to learning better ways to write code!