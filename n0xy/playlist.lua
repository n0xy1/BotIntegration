package.path  = package.path..";.\\LuaSocket\\?.lua;"..'.\\Scripts\\?.lua;'.. '.\\Scripts\\UI\\?.lua;'
package.cpath = package.cpath..";.\\LuaSocket\\?.dll;"

local JSON = require("json")
local socket = require("socket")
local playerList = {}

local dataToSend = {}

local udpEventHost = "walsh.systems"
local udpEventPort = 9697

local function sendToRsrBot(dataToSend)
    local udp = assert(socket.udp())
    udp:settimeout(0.01)
    assert(udp:setsockname("*", 0))
    assert(udp:setpeername(udpEventHost, udpEventPort))
    local jsonEventTableForBot = JSON:encode(dataToSend) --Encode the event table
    assert(udp:send(jsonEventTableForBot))
end


--do we get the whole board each time? or just the single player and track on the bot side of the house <---> SIDE 1 = red, SIDE 2 = Blue, SIDE 0 = spectator
playerList.onPlayerChangeSlot = function(playerID)
    if  DCS.isServer() and DCS.isMultiplayer() then
        local playerDetails = net.get_player_info(playerID)
        dataToSend.name = playerDetails.name
        dataToSend.side = playerDetails.side
        dataToSend.ucid = playerDetails.ucid
		dataToSend.clientid = playerID
        net.log(JSON:encode(dataToSend))
        sendToRsrBot(dataToSend)
    end
end


--on player stop to remove from the board: SIDE = 4 <-- denotes the player is disconnected! 
playerList.onPlayerDisconnect = function(playerID)
	dataToSend.name = 'disconnect'
	dataToSend.side = 4
	dataToSend.ucid = 'nil'
	dataToSend.clientid = playerID
    sendToRsrBot(dataToSend)
end

-- send and 'empty' payload to get bot to wipe the db on restarts
local emptyIt = {}
emptyIt.name = "clear"
emptyIt.side = 3
emptyIt.ucid = "clear"
emptyIt.Clientid = 0
sendToRsrBot(JSON:encode(emptyIt))


DCS.setUserCallbacks(playerList)
net.log("#######################################################################Loaded PlayerList by n0xy #######################################################################")