-- script that retrieves an authentication token to send in all future requests

-- use token for at most maxRequests, default throughout test
local counter = 0
local maxRequests = -1

-- request access necessary for both reading and writing by default
local username = "writer@example.com"

-- marker that we have completed the first request
local token = nil

function init(args)
    if args[1] ~= nil then
        maxRequests = args[1]
        print("Max requests: " .. maxRequests)
    end
    if args[2] ~= nil then
        username = args[2]
    end

    local path = "/token?username=" .. username
    print("Requesting token from: " .. path)

    -- initialize first (empty) request
    req = wrk.format("GET", path, headers: nil, body: "")
end

function response(status, headers, body)
    if not token and status == 200 then
        token = body
        wrk.headers["Authentication"] = "Bearer " .. token
        req = wrk.format()
        return
    end

    if not token then
        print("Failed initial request! status: " .. status)
        wrk.thread:stop()
    end

    if counter == maxRequests then
        wrk.thread:stop()
    end

    counter = counter + 1
    if counter % 500 == 0 then
        print("Counter:" .. counter)
    end
end
