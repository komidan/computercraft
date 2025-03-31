## komidan's CC: Tweaked Code

A repo for all (useful... maybe) code I've written. Currently written on MC Fabric 1.21.1 

[CC: Tweaked](https://www.curseforge.com/minecraft/mc-mods/cc-tweaked) Mod Pages: [Modrinth](https://modrinth.com/mod/cc-tweaked), [Curseforge](https://www.curseforge.com/minecraft/mc-mods/cc-tweaked)

Use this command in any turtle/computer terminal to get the `klib.lua` file.
```txt
wget https://raw.githubusercontent.com/komidan/komi_cc/refs/heads/main/klib.lua
```
Requiring `klib.lua` in a lua script:
```lua
local klib = require(path_to_file)
```
Requiring the file updates `rednet` table with extra functions:
```lua
rednet.message(data, status_code?) 
rednet.log(from, to, message, protocol) 
rednet.formatMessage(from, to, message, protocol)
```
`rednet.message` - Returns a table that adds more data such as a UTC timestamp and an optional status code.\
`rednet.log` - Prints a formatted 'packet' sent over rednet.\
`rednet.formatMessage` - Takes in rednet.msg() return table for `message`.

--- 
For more information on the library (and other code) check out the (WIP) [wiki](https://github.com/komidan/komi_cc/wiki).

I'm always open to learning better ways to write code!