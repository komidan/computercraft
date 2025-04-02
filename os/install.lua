-- komidan, https://github.com/komidan
-- Main OS Install Script

local isDiskPresent = peripheral.find("drive").isDiskPresent()

URLS = {
	"https://raw.githubusercontent.com/komidan/komi_cc/refs/heads/main/lib/klib.lua",
	"https://raw.githubusercontent.com/komidan/komi_cc/refs/heads/main/os/startup.lua",
	"https://raw.githubusercontent.com/komidan/komi_cc/refs/heads/main/os/chocolat.lua",
	"https://raw.githubusercontent.com/komidan/komi_cc/refs/heads/main/install.lua",
}

term.clear()
term.setCursorPos(1, 1)

print("ChocolatOS Install/Update")
term.setTextColor(colors.yellow)
print("WARNING: It is suggested to kill any scripts before installing/updating!")
term.setTextColor(colors.white)
print("\nPress any button to continue...")
read()

local onDisk = nil
if isDiskPresent then
	::diskInstall::
	print("Install to disk? (y/n)")
	local input = string.lower(read())
	if input == "y" then
		onDisk = true
	elseif input == "n" then
		onDisk = false
	else
		print("Invalid Input '" .. input .. "' try again.")
		goto diskInstall
	end
end

-- remove old files
print("removing old files...")
fs.delete("disk/chocolat/")
fs.delete("chocolat/")

-- get all the new files from github
print("retrieving files from github...")
for i = 1, #URLS do
	shell.run("wget " .. URLS[i])
end

-- move all files to correct paths
print("moving files from /root/ to /chocolat/")
fs.move("klib.lua", "chocolat/klib.lua")
fs.move("chocolat.lua", "chocolat/os/chocolat.lua")
fs.copy("startup.lua", "chocolat/os/startup_copy.lua") -- incase you want to transfer the OS between systems on the disk itself
fs.move("install.lua", "chocolat/os/install.lua")
if onDisk then
	print("copying over to /disk/")
	fs.move("chocolat", "disk/chocolat")
end

os.reboot()