local json = require "json"
local valueController = require "valueController"

options = {
    WebSocket = true,
}

local connectionISOpen = false

function WSHandler(conn)
    connectionISOpen = true
    while connectionISOpen do
        local wsMsg = conn.read()

        if connectionISOpen == false then
            return
        end

        local msg = json.Decode(wsMsg.data)

        if msg.msgType == "connect" then
            local users = valueController.getValue("activeUsers")

            if msg.id > #users then
                local sendData = {
                    msgType = "connect",
                    code = 0,
                }

                conn.write(wsMsg.mt, json.Encode(sendData))
                return
            end

            if users[msg.id].Key == msg.key then
                local sendData = {
                    msgType = "connect",
                    code = 101,
                }

                users[msg.id].WSConn = conn
                valueController.updateValue("activeUsers", users)
                conn.write(wsMsg.mt, json.Encode(sendData))
            else
                local sendData = {
                    msgType = "connect",
                    code = 0,
                }

                conn.write(wsMsg.mt, json.Encode(sendData))
                return
            end
        elseif msg.msgType == "message" then
            print("New message")
            local users = valueController.getValue("activeUsers")
            local user
            if users[msg.id].Key == msg.key then
                user = users[msg.id]
            end

            local sendData = {
                msgType = "message",
                code = 202,

                userName = user.UserName,
                msgText = msg.msgText,
            }

            if msg.key == "" or msg.key == nil then
                sendData.msgType = "sendMessageError"
                sendData.code = 0
            end

            if msg.msgText == "" or msg.msgText == nil then
                sendData.msgType = "sendMessageError"
                sendData.code = 0
            end

            local sendDataString = json.Encode(sendData)

            if msg.id == nil then
                sendData.msgType = "sendMessageError"
                sendData.code = 0
            end

            if sendData.code == 0 then
                conn.write(wsMsg.mt, json.Encode(sendData))
                return
            end

            for i = 1, #users do
                if users[i].WSConn ~= nil then
                    users[i].WSConn.write(wsMsg.mt, sendDataString)
                    print("I'm print message to "..users[i].UserName.."/"..i)
                end
            end
        end
    end
end

function onClose(data)
    local msg = json.Decode(data.data)

    if msg.userID == nil then
        return
    else
        local users = valueController.getValue("activeUsers")

        users[msg.userID] = nil

        valueController.updateValue("activeUsers", users)
    end
    connectionISOpen = false
end