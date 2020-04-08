package.path  = package.path..";.\\LuaSocket\\?.lua;"..'.\\Scripts\\?.lua;'.. '.\\Scripts\\UI\\?.lua;'
package.cpath = package.cpath..";.\\LuaSocket\\?.dll;"

local JSON = require("json")
local socket = require("socket")
local playerList = {}
local dataToSend = {}

local udpEventHost = "walsh.systems"
local udpEventPort = 9696
local udpBoardPort = 9697

local function sendBotBoard(dataToSend)
    local udp = assert(socket.udp())
    udp:settimeout(0.01)
    assert(udp:setsockname("*", 0))
    assert(udp:setpeername(udpEventHost, udpBoardPort))
    local jsonEventTableForBot = JSON:encode(dataToSend) --Encode the event table
    assert(udp:send(jsonEventTableForBot))
    --net.log(jsonEventTableForBot)
end

local function sendBotEvent(dataToSend)
    local udp = assert(socket.udp())
    udp:settimeout(0.01)
    assert(udp:setsockname("*", 0))
    assert(udp:setpeername(udpEventHost, udpEventPort))
    local jsonEventTableForBot = JSON:encode(dataToSend) --Encode the event table
    assert(udp:send(jsonEventTableForBot))
    --net.log(jsonEventTableForBot)
end


--SIDE 1 = red, SIDE 2 = Blue, SIDE 0 = spectator
playerList.onPlayerChangeSlot = function(playerID)
    if  DCS.isServer() and DCS.isMultiplayer() then
        local playerDetails = net.get_player_info(playerID)
        dataToSend.name = playerDetails.name
        dataToSend.side = playerDetails.side
        dataToSend.ucid = playerDetails.ucid
		dataToSend.clientid = playerID
        --net.log(JSON:encode(dataToSend))
        sendBotBoard(dataToSend)
    end
end


--on player stop to remove from the board: SIDE = 4 <-- denotes the player is disconnected! 
playerList.onPlayerDisconnect = function(playerID)
	dataToSend.name = 'disconnect'
	dataToSend.side = 4
	dataToSend.ucid = 'nil'
	dataToSend.clientid = playerID
    sendBotBoard(dataToSend)
end

-- BOT EVENT STRUCT.
--	ID                 int     `json:"ID"
--	Time               float64 `json:"Time"
--	Initiator          string  `json:"Initiator"
--	Weapon             string  `json:"Weapon"
---	Target             string  `json:"Target"
--	InitiatorCoalition int     `json:"InitiatorCoalition"
--	TargetCoalition    int     `json:"TargetCoalition"

--DCS EVENT DATA
    --"friendly_fire", playerID, weaponName, victimPlayerID
    --"mission_end", winner, msg
    --"kill", killerPlayerID, killerUnitType, killerSide, victimPlayerID, victimUnitType, victimSide, weaponName
    --"self_kill", playerID
    --"change_slot", playerID, slotID, prevSide
    --"connect", playerID, name
    --"disconnect", playerID, name, playerSide, reason_code
    --"crash", playerID, unit_missionID
    --"eject", playerID, unit_missionID
    --"takeoff", playerID, unit_missionID, airdromeName
    --"landing", playerID, unit_missionID, airdromeName
    --"pilot_death", playerID, unit_missionID


playerList.onGameEvent = function(eventName,arg1,arg2,arg3,arg4,arg5,arg6,arg7) 
    if eventName == "kill" then
        local eventData = {}
        
        --initiator - if you cant get the player_info of the id, it means they are AI. probably ground target or awacs (ill count em as the same)
        if net.get_player_info(arg1) ~= nil then
            local initiatorDetails = net.get_player_info(arg1)
            eventData.Initiator = initiatorDetails.name
        else    
            eventData.Initiator = "AI"
        end
        eventData.InitiatorCoalition = arg3

        --target - if you cant get the player_info of the id, it means they are AI.
        if net.get_player_info(arg4) ~= nil then
            local targetDetails = net.get_player_info(arg4)
            eventData.Target = targetDetails.name
        else    
            eventData.Target = "AI"
        end
        eventData.TargetCoalition = arg6

        --weapon/misc
        eventData.id = 28
        eventData.Weapon = arg7
        eventData.Time = 1.1
        sendBotEvent(eventData)
    end

    if eventName == "pilot_death" then
        local eventData = {}
        --initiator
        if net.get_player_info(arg1) ~= nil then
            local initiatorDetails = net.get_player_info(arg1)
            eventData.Initiator = initiatorDetails.name
        else    
            eventData.Initiator = "AI"
        end
        eventData.InitiatorCoalition = arg3

        --weapon/misc
        eventData.id = 9
        eventData.Time = 1.1
        sendBotEvent(eventData)
    end

    if eventName == "crash" then
        local eventData = {}

        --initiator
        if net.get_player_info(arg1) ~= nil then
            local playerDetails = net.get_player_info(arg1)
            eventData.Initiator = playerDetails.name
        else    
            eventData.Initiator = "AI"
        end
        eventData.InitiatorCoalition = arg3

        --weapons/misc
        eventData.id = 5
        eventData.Time = 1.1
        sendBotEvent(eventData)
    end

    if eventName == "eject" then
        local eventData = {}

        --initiator
        if net.get_player_info(arg1) ~= nil then
            local playerDetails = net.get_player_info(arg1)
            eventData.Initiator = playerDetails.name
        else    
            eventData.Initiator = "AI"
        end
        eventData.InitiatorCoalition = arg3
        
        --weapon/misc
        eventData.id = 6
        eventData.Time = 1.1
        sendBotEvent(eventData)
    end

    if eventName == "takeoff" then
        local eventData = {}

        --initiator
        if net.get_player_info(arg1) ~= nil then
            local playerDetails = net.get_player_info(arg1)
            eventData.Initiator = playerDetails.name
        else    
            eventData.Initiator = "AI"
        end
        eventData.InitiatorCoalition = arg3

        --weapon/misc
        eventData.id = 3
        eventData.Time = 1.1
        sendBotEvent(eventData)
    end

    if eventName == "landing" then
        local eventData = {}

        --initiator
        if net.get_player_info(arg1) ~= nil then
            local playerDetails = net.get_player_info(arg1)
            eventData.Initiator = playerDetails.name
        else    
            eventData.Initiator = "AI"
        end
        eventData.InitiatorCoalition = arg3
        
        --weapon/misc
        eventData.id = 4
        eventData.Time = 1.1
        sendBotEvent(eventData)
    end

end

-- send an 'empty' payload to get bot to wipe the db on restarts
local emptyIt = {}
emptyIt.name = "clear"
emptyIt.side = 3
emptyIt.ucid = "clear"
emptyIt.Clientid = 0
sendBotBoard(emptyIt)
--net.log(JSON:encode(emptyIt))
DCS.setUserCallbacks(playerList)
net.log("#######################################################################Loaded PlayerList by n0xy #######################################################################")