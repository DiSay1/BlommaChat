local valueController = require "valueController"
local time = require "time"

-- Handler Options
options = {
    Address = "/", -- Web path to handler
}

valueController.newValue("activeUsers", {})

-- Function called on request
function Handler (request)
    local key = request.getQuery("key")

    local users = valueController.getValue("activeUsers")

    if #users == 0 then
        request.redirect("/login.html")
        return
    end

    for i = 1, #users do
        if users[i].Key == key then
            request.redirect("./chat.html?key="..key.."&".."id="..i)
            return
        end
    end

    request.redirect("/login.html")
end
