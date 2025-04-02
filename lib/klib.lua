-- komidan, https://github.com/komidan 
-- Library built for CC: Tweaked 1.21.1

--- @alias message table
--- | 'data' your data...
--- | 'timestamp' MM/DD/YYYY HH:MM:SS
--- | 'status_code' a message's status code for communication

---@enum STATUS_CODES
local STATUS_CODES = {
	-- success
	OK        = 200,
	CREATED   = 201,
	ACCEPTED  = 202,

	-- error
	BAD_REQUEST  = 400,
	UNAUTHORIZED = 401,
	FORBIDDEN    = 403,
	NOT_FOUND    = 404
}

local net = {}
--- Formats a Message into a loggable/printable string
--- @param from integer
--- @param to integer
--- @param message message
--- @return string
function net.formatMessage(from, to, message, protocol)
	local log = (
		message.timestamp .. ","  ..
		tostring(from)    .. "->" ..
		tostring(to)      .. ","  ..
		protocol          .. ","  ..
		textutils.serialize(message.data, { compact = true })
	)
	return log
end

--- Prints a message formatted using `net.formatMessage()`
--- @param from integer
--- @param to integer
--- @param message message
--- @return nil
function net.log(from, to, message, protocol)
	print(net.formatMessage(from, to, message, protocol))
end

--- Creates a message, adding relevent data to each message
--- because having some form of order to this makes sense.
--- @param data table  table of the data you wish to trasmit
--- @param status_code integer status code provided by `STATUS_CODES` table
--- @return message # returns the data + the 'relevant data'
--- @overload fun(data: table)
function net.message(data, status_code)
	---@type message
	local message = {
		data = data,
		timestamp = os.date("%D %T", math.floor(os.epoch("utc") / 1000)),
		status_code = status_code,
	}
	return message
end

local util = {}
--- ### Usage:
--- ```lua
--- local p = util.getPeripherals()
--- rednet.open(peripheral.getName(p.modem))
--- ```
--- Possible peripheral keys are:
--- `command`, `computer`, `drive`, `drive`, `modem`, `monitor`, `printer`, `redstone_relay`, `speaker`
--- @return table # list of all peripherals connected
function util.getPeripherals()
	local peripherals = {}
	local names = peripheral.getNames()
	for i = 0, #names do
		if names[i] ~= nil then
			peripherals[peripheral.getType(names[i])] = peripheral.wrap(names[i])
		end
	end
	return peripherals
end

local function _command()
	return "connected"
end

local function _computer(computer)
	return {
		label = computer.getLabel(),
		id    = computer.getID(),
		isOn  = computer.isOn(),
	}
end

local function _drive(drive)
	local hasData = drive.hasData()
	local mountPath = nil
	if hasData then
		mountPath = "/" .. tostring(drive.getMountPath())
	end


	return {
		label     = drive.getDiskLabel(),
		id        = drive.getDiskID(),
		hasData   = hasData,
		mountPath = mountPath,
	}
end

local function _modem(modem)
	local oc = {}
	for i = 1, 65535 do
		if modem.isOpen(i) then
			table.insert(oc, i)
		end
	end

	return {
		isWireless   = modem.isWireless(),
		channels     = oc,
		channelsOpen = #oc,
	}
end

local function _monitor(monitor)
	local width, height = monitor.getSize()
	local pos_x, pos_y = monitor.getCursorPos()

	return {
		textScale = monitor.getTextScale(),
		cursorPos = { pos_x, pos_y },
		size      = { width, height },
		isColor   = monitor.isColor(),
	}
end

local function _printer(printer)
	return {
		paperLevel = printer.getPaperLevel(),
		inkLevel   = printer.getInkLevel(),
	}
end

local function _redstone_relay()
	return "connected"
end

local function _speaker()
	return "connected"
end

--- Pass any of these peripheral names as parameters to get info on them:\
--- `command`, `computer`, `drive`, `modem`, `monitor`, `printer`, `redstone_relay`, `speaker`\
--- @return table # System info and info about specified peripherals
function util.getSystemInfo(...)
	local args = {...}
	local peripherals = {}

	local handlers = {
		command  	   = _command,
		computer 	   = _computer,
		drive    	   = _drive,
		modem          = _modem,
		monitor        = _monitor,
		printer        = _printer,
		redstone_relay = _redstone_relay,
		speaker        = _speaker
	}

	for _, value in ipairs(args) do
		local peripheral_param = peripheral.find(value)
		if handlers[value] then
			peripherals[value] = handlers[value](peripheral_param)
		end
	end

	return {
		label       = os.getComputerLabel(),
		id          = os.getComputerID(),
		version     = os.version(),
		uptime      = os.clock(),
		peripherals = peripherals,
	}
end

--- @param table table
--- @return table
function util.getTableKeys(table)
	local keys = {}
	for key, _ in pairs(table) do
		keys[#keys + 1] = key
	end
	return keys
end

-- TURTLE FUNCTIONS
local inv = {}
--- @return table # returns table 1,16 of items & count
function inv.get()
    local inventory = {}
    for slot = 1,16 do
        local item = turtle.getItemDetail(slot)
        if item then
            inventory[slot] = {
                name = item.name,
                count = item.count
            }
        end
    end
    return inventory
end

--- @param slotA integer ranged 1,16
--- @param slotB integer ranged 1,16
--- @param count integer ranged 1,64 defaults to entire stack
--- @return boolean # true if successful
function inv.transfer(slotA, slotB, count)
    if slotA > 16 or slotB > 16 or (count and count > 64) then return false end
    turtle.select(slotA)
    -- default to max count if count `nil`
    count = count or turtle.getItemCount()
    return turtle.transferTo(slotB, count)
end

--- @param slot integer ranged 1,16
--- @param count integer ranged 1,16 defaults to entire stack
--- @return boolean # true if successful 
function inv.drop(slot, count)
	if slot > 16 or (count and count > 64) then return false end
    -- default to max count if count `nil`
    count = count or turtle.getItemCount(slot)
    turtle.select(slot)
    return turtle.drop(count)
end

--- @param itemName string name of item
--- @return integer # slot of item, -1 if item doesn't exist
function inv.find(itemName)
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
		if item and item.name == itemName then
            return slot
        end
    end
    return -1
end

--- Takes into account non-stackables or 16-stack items and subtracts the "no longer possible" space from `remaining`
--- @return table # info about space taken up/left over
function inv.getCapacityInfo()
	local remaining    = 1024 -- 64 * 16
	local usedCapacity = 0

	local verbose = {}
	for slot = 1, 16 do
		local item = turtle.getItemDetail(slot)

		-- Skip empty slots
		if item == nil then goto skip end

		-- Take remaining and subtract the "possible missing". For example a max 16 stack item forces
		-- a loss of 48 possible items (1024 - 48) - 12 = 964. Subtracting another 4 from the total
		-- would be the difference between a 16 max stack and item.count.
		local itemSpaceRemaining = turtle.getItemSpace(slot)
		if item.count > 0 and itemSpaceRemaining == 0 then
			remaining = remaining - 64
		elseif item.count > 0 and itemSpaceRemaining < 16 then
			remaining = (remaining - 48) - item.count
		else
			remaining = remaining - item.count
		end

		usedCapacity = usedCapacity + item.count
		verbose[item.name] = item.count
		::skip::
	end

	return {
		remaining = remaining,
		usedCapacity = usedCapacity,
		verbose = verbose,
	}
end

-- End of library
-- insert functions to tables
turtle["inv"] = inv

for key, value in pairs(net) do
	rednet[key] = value
end

return {
	util = util,
	STATUS_CODES = STATUS_CODES,
}