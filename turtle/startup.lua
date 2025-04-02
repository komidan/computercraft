-- Startup Sequence, Customizable
local cc   = require("cc.strings")

-- Customize These Variables
local osName = "ChocolatOS (Turtle)"
local progressBarStart  = "["
local progressBarMiddle = ":"
local progressBarEnd    = "]"

local width, height = term.getSize()
local w_center = width * 0.5
local h_center = height * 0.5

local osProgressBar = ""
for i = 1, width * 0.33 do
	local osProgressBarEnsured = cc.ensure_width(progressBarStart .. osProgressBar, width * 0.33 - 1)
	term.clear()
	term.setCursorPos(w_center - (#osName * 0.5 - 1), h_center - 1)
	term.write(osName)
	term.setCursorPos(w_center - (#osProgressBarEnsured * 0.5), h_center + 1)
	print(osProgressBarEnsured .. progressBarEnd)
	osProgressBar = osProgressBar .. progressBarMiddle

	-- This is the speed of the "loading" bar.
	sleep(math.random(0, 1) / 25)
end
term.setCursorPos(1, height)