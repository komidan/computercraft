-- komi library
-- built for CC: Tweaked 1.21.1

local net = {}
local util = {}

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
function net.msg(data, status_code)
	---@type message
	local message = {
		data = data,
		timestamp = os.date("%D %T"),
		status_code = status_code,
	}
	return message
end

--- Sends a message over rednet with a message created with `net.msg()`
--- @param recipient integer id of the computer receiving the message
--- @param message message
--- @param protocol string | nil protocol to send message over
--- @return boolean # returns true if message was sent successfully
function net.send(recipient, message, protocol)
	local success = nil
	if protocol then
		success = rednet.send(recipient, message)
	end
	success = rednet.send(recipient, message, protocol)
	return success
end

--- Receives a message or broadcast over rednet.
--- @param timeout number how long should you wait before eventually returning nil
--- @return integer sender, message message, string protocol
function net.receive(timeout)
	-- set timeout to 0 if not provided
	timeout = timeout or 0

	return rednet.receive(timeout)
end

--- This is pretty much useless, could just do
--- `rednet.broadcast()` and pass my message type. But hey, why not?
--- @param message message
--- @param protocol string | nil
function net.broadcast(message, protocol)
	if protocol then
		rednet.broadcast(message)
	end
	rednet.broadcast(message, protocol)
end

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

-- funktyouns
return {
	net = net,
	util = util,

	STATUS_CODES = STATUS_CODES,
}