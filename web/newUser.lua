local valueController = require "valueController"
local random = require "random"

options = {
    Address = "/newUser", -- Web path
}

-- Function called on HTTP request
function Handler (request)
    if request.method == "POST" then
        local formData = request.getFormData({"userName"})

        local aUsers = valueController.getValue("activeUsers")

        local key = random.randomString("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789.`!~^%:", 10)

        for i = 1, #aUsers do
            if aUsers[i] == nil then
                aUsers[i] = {
                    UserName = formData.userName,
                    Key = key,
                    WSConn = nil,
                }

                valueController.updateValue("activeUsers", aUsers)

                request.redirect("/?key="..key)
                return
            end
        end

        aUsers[#aUsers+1] = {
            UserName = formData.userName,
            Key = key,
            WSConn = nil,
        }

        valueController.updateValue("activeUsers", aUsers)

        request.redirect("/?key="..key)
    end
end