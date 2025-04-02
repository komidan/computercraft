-- Updates all files on system.
URLS = {
	"https://raw.githubusercontent.com/komidan/komi_cc/refs/heads/main/lib/klib.lua",
	"https://raw.githubusercontent.com/komidan/komi_cc/refs/heads/main/turtle/startup.lua",
	"https://raw.githubusercontent.com/komidan/komi_cc/refs/heads/main/turtle/install.lua",
}

term.clear()
term.setCursorPos(1, 1)

print("ChocolatOS (Turtle) Install/Update")
term.setTextColor(colors.yellow)
print("WARNING: It is suggested to kill any scripts before installing/updating!")
term.setTextColor(colors.white)
print("\nPress any button to continue...")
read()

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
fs.copy("startup.lua", "chocolat/turtle/startup_copy.lua") -- incase you want to transfer the OS between systems on the disk itself
fs.move("install.lua", "chocolat/turtle/update.lua")

os.reboot()