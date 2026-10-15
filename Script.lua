

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
Library.ForceCheckbox = true

local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()

local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options

local Toggles = Library.Toggles
local GlobalEnv = (type(getgenv) == "function" and getgenv()) or _G

local NOTIFY_SOUND_ID = "rbxassetid://72538684949111"

local TYPE_SOUND_ID  = "rbxassetid://6042053626"

local function playNotifySound()

    local ok = pcall(function()

        local s = Instance.new("Sound")

        s.SoundId = NOTIFY_SOUND_ID

        s.Volume = 1

        s.PlayOnRemove = true

        s.Parent = game:GetService("SoundService")

        s:Destroy()

    end)

    if not ok then

        warn("failed to play sound :()")

    end

end

-- EchoHttpGet: executor-agnostic HTTP GET used by Server Hop.
local function EchoHttpGet(url)
    local req = (syn and syn.request)
             or (http and http.request)
             or (fluxus and fluxus.request)
             or http_request
             or request
    if req then
        local ok, res = pcall(req, {Url = url, Method = "GET"})
        if ok and type(res) == "table" then
            if res.Body and res.Body ~= "" then return res.Body end
            if res.body and res.body ~= "" then return res.body end
        end
    end
    if game.HttpGetAsync then
        local ok, body = pcall(function() return game:HttpGetAsync(url) end)
        if ok and type(body) == "string" and body ~= "" then return body end
    end
    if game.HttpGet then
        local ok, body = pcall(function() return game:HttpGet(url) end)
        if ok and type(body) == "string" and body ~= "" then return body end
    end
    return nil
end

local _originalNotify = Library.Notify

Library.Notify = function(self, ...)
    task.spawn(playNotifySound)
    local args = {...}
    if type(args[1]) == "table" then
        args[1].Icon = "bell"
    end
    return _originalNotify(self, table.unpack(args))
end

_G.__EchoNotify = function(description, eventKey, duration, iconName)
    Library:Notify({
        Title = "Echo",
        Icon = iconName or "bell",
        Description = description,
        Time = duration or 4,
    })
end

local function DestroyEchoNotificationsByDescription(description)
    pcall(function()
        for _, notification in pairs(Library.Notifications) do
            if notification and notification.Description == description and notification.Destroy then
                notification:Destroy()
            end
        end
    end)
end


local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local DISPLAY_NAME = LocalPlayer and LocalPlayer.DisplayName or "User"

local footerMessages = { "Thank You for using Echo | V1.8 | " .. DISPLAY_NAME }

local function shuffledCopy(list)

    local copy = {}

    for i, v in ipairs(list) do copy[i] = v end

    for i = #copy, 2, -1 do

        local j = math.random(1, i)

        copy[i], copy[j] = copy[j], copy[i]

    end

    return copy

end

local FIRST_FOOTER = footerMessages[1]

local Window = Library:CreateWindow({

    Title = "Echo",

    Icon = "rbxassetid://139851104815795",

    Footer = FIRST_FOOTER,

    NotifySide = "Right",

    ShowCustomCursor = false,

    EnableCompacting = true,

    SidebarCompacted = true,

    SearchbarSize = UDim2.fromScale(0.45, 1),

    CornerRadius = 30,

    Accent = Color3.fromRGB(255, 255, 255)

})

_G.iconAsset = _G.iconAsset or "rbxassetid://139851104815795"
if _G.iconAsset then
    task.spawn(function()
        local MATCH_IDS = {
            "114385184385354",
            "139851104815795",
        }

        local function matches(image)
            if not image or image == "" then return false end
            for _, id in ipairs(MATCH_IDS) do
                if image:find(id, 1, true) then return true end
            end
            return false
        end

        for _ = 1, 300 do
            local root = Window.Holder or Window.Root or Window.Frame or Window.Main
            if root then
                for _, obj in ipairs(root:GetDescendants()) do
                    if obj:IsA("ImageLabel") and matches(obj.Image) then
                        obj.Image = _G.iconAsset
                        obj.ScaleType = Enum.ScaleType.Fit
                        print("[Z] Icon swapped at:", obj:GetFullName())
                        return
                    end
                end
            end
            task.wait(0.05)
        end

        -- Icon slot not found — library may render icons differently; skip silently.
    end)
end

-- Echo Coin Bar: Echo icon + semi-transparent black/white gradient.
task.defer(function()
    local echoCoinIcon = "rbxassetid://139851104815795"
    local originalCoinState = {}
    local function rememberCoinFrame(coinFrame)
        if not coinFrame or originalCoinState[coinFrame] then return end
        originalCoinState[coinFrame] = {
            BackgroundColor3 = coinFrame.BackgroundColor3,
            BackgroundTransparency = coinFrame.BackgroundTransparency,
        }
    end
    local function restoreCoinBar()
        for coinFrame, state in pairs(originalCoinState) do
            pcall(function()
                if coinFrame and coinFrame.Parent then
                    local gradient = coinFrame:FindFirstChild("EchoCoinGradient")
                    if gradient then gradient:Destroy() end
                    coinFrame.BackgroundColor3 = state.BackgroundColor3
                    coinFrame.BackgroundTransparency = state.BackgroundTransparency
                end
            end)
        end
    end
    local function patchCoinBar(container)
        if not container then return end
        pcall(function()
            for _, obj in ipairs(container:GetDescendants()) do
                local n = string.lower(obj.Name or "")
                if (string.find(n, "coin", 1, true) or string.find(n, "currency", 1, true)) and (obj:IsA("ImageLabel") or obj:IsA("ImageButton")) then
                    obj.Image = echoCoinIcon
                end
            end
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            local menu = pg and pg:FindFirstChild("MenuGui")
            local topRight = menu and menu:FindFirstChild("TopRight")
            local coinFrame = topRight and topRight:FindFirstChild("CoinsFrame")
            if not coinFrame then return end
            if coinFrame:IsA("Frame") or coinFrame:IsA("ScrollingFrame") then
                rememberCoinFrame(coinFrame)
                coinFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
                coinFrame.BackgroundTransparency = 0.14
                local gradient = coinFrame:FindFirstChild("EchoCoinGradient")
                if not gradient then
                    gradient = Instance.new("UIGradient")
                    gradient.Name = "EchoCoinGradient"
                    gradient.Parent = coinFrame
                end
                gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 8, 10)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(58, 58, 62)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 10))
                })
                gradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.08),
                    NumberSequenceKeypoint.new(0.5, 0.18),
                    NumberSequenceKeypoint.new(1, 0.08)
                })
                gradient.Rotation = 0
            end
        end)
    end
    pcall(function() patchCoinBar(LocalPlayer:FindFirstChildOfClass("PlayerGui")) end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            pcall(function() patchCoinBar(LocalPlayer:FindFirstChildOfClass("PlayerGui")) end)
        end
    end)
    Library:OnUnload(function()
        restoreCoinBar()
    end)
end)

local typeSound = Instance.new("Sound")

typeSound.SoundId = TYPE_SOUND_ID

typeSound.Volume = 0.4

typeSound.Parent = game:GetService("SoundService")

local function isEchoVisible()
    if Library.Unloaded then return false end

    if Library.Open ~= nil then
        return Library.Open and true or false
    end

    local root = Window.Holder or Window.Root or Window.Main or Window.Frame
    if root and root:IsA("GuiObject") then
        if not root.Visible then return false end
        local parent = root.Parent
        while parent and parent:IsA("GuiObject") do
            if not parent.Visible then return false end
            parent = parent.Parent
        end
    end
    return true
end

local function playTypeTick()
    -- Type tick sound disabled
    return
end

task.spawn(function()
    while not Library.Unloaded do
        if not isEchoVisible() then
            pcall(function()
                if typeSound.IsPlaying then
                    typeSound:Stop()
                end
            end)
        end
        task.wait(0.1)
    end
end)

local function findAllRoots()

    local roots = {}

    local ok, gethui = pcall(function() return gethui() end)

    if ok and gethui then table.insert(roots, gethui) end

    pcall(function() table.insert(roots, game:GetService("CoreGui")) end)

    if Window.Holder then table.insert(roots, Window.Holder) end

    if Window.Root then table.insert(roots, Window.Root) end

    if Window.Main then table.insert(roots, Window.Main) end

    if Window.Frame then table.insert(roots, Window.Frame) end

    return roots

end

task.spawn(function()

    local footerLabel

    for _ = 1, 200 do

        for _, root in ipairs(findAllRoots()) do

            for _, obj in ipairs(root:GetDescendants()) do

                if obj:IsA("TextLabel") and obj.Text and obj.Text:find(FIRST_FOOTER, 1, true) then

                    footerLabel = obj

                    break

                end

            end

            if footerLabel then break end

        end

        if footerLabel then

            print("[Z] Footer found:", footerLabel:GetFullName())

            break

        end

        task.wait(0.05)

    end

    if not footerLabel then

        warn("[Z] Footer label not found")

        return

    end

    local CHAR_DELAY = 0.05

    local CYCLE_TIME = 25

    while footerLabel.Parent and not Library.Unloaded do

        -- Pause typing entirely while the menu is hidden
        if not isEchoVisible() then
            task.wait(0.25)
            continue
        end

        local queue = shuffledCopy(footerMessages)

        for _, msg in ipairs(queue) do

            if not footerLabel.Parent then break end

            -- Bail out mid-typing if the menu gets closed
            if not isEchoVisible() then break end

            footerLabel.Text = ""

            for i = 1, #msg do

                if not isEchoVisible() then break end

                footerLabel.Text = msg:sub(1, i)

                playTypeTick()

                task.wait(CHAR_DELAY)

            end

            local forwardTime = #msg * CHAR_DELAY

            local eraseTime = #msg * CHAR_DELAY

            local holdTime = CYCLE_TIME - forwardTime - eraseTime

            if holdTime > 0 then

                task.wait(holdTime)

            end

            for i = #msg - 1, 0, -1 do

                if not isEchoVisible() then break end

                footerLabel.Text = msg:sub(1, i)

                playTypeTick()

                task.wait(CHAR_DELAY)

            end

        end

    end

end)

ThemeManager:SetLibrary(Library)

ThemeManager:SetDefaultTheme({

    AccentColor = Color3.fromRGB(255, 255, 255),

    OutlineColor = Color3.fromRGB(80, 80, 80),

    BackgroundColor = Color3.fromRGB(0, 0, 0),

    Mailcolor = Color3.fromRGB(15, 15, 15),

    FontFace = "Fantasy",

    FontColor = Color3.fromRGB(255, 255, 255),

})

local Tabs = {

    Main = Window:AddTab({

        Name = "Echo",

        Icon = "house",

        Description = "Main"

    }),

    Player = Window:AddTab({

        Name = "Echo",

        Icon = "user",

        Description = "Players"

    }),

     Grabs = Window:AddTab({

        Name = "Echo",

        Icon = "hand",

        Description = "Grabs"

    }),

    Defence = Window:AddTab({

        Name = "Echo",

        Icon = "shield-user",

        Description = "Defence"

    }),

    Target = Window:AddTab({

        Name = "Echo",

        Icon = "crosshair",

        Description = "Target"

    }),

    Visuals = Window:AddTab({

        Name = "Echo",

        Icon = "eye",

        Description = "Visuals"

    }),

    UISettings = Window:AddTab({

        Name = "Echo",

        Icon = "settings",

        Description = "UI Settings"

    })

}

--/Main
do
local ProfileGroup = Tabs.Main:AddLeftGroupbox("Profile", "user")

local StatsInfoGroup = Tabs.Main:AddRightGroupbox("Stats & Info", "activity")

local Thumbnail

pcall(function()

    Thumbnail = Players:GetUserThumbnailAsync(

        LocalPlayer.UserId,

        Enum.ThumbnailType.AvatarBust,

        Enum.ThumbnailSize.Size420x420

    )

end)

if Thumbnail then

    ProfileGroup:AddImage("ProfileAvatar", {

        Image = Thumbnail,

        Height = 180,

        ScaleType = Enum.ScaleType.Fit,

    })

end

local GreetingLabel = ProfileGroup:AddLabel(

    "Loading greeting...",

    true

)

local function GetEchoGreeting()

    local Hour = tonumber(os.date("%H")) or 12

    local Period

    if Hour >= 5 and Hour < 12 then

        Period = "Morning"

    elseif Hour >= 12 and Hour < 17 then

        Period = "Noon"

    elseif Hour >= 17 and Hour < 21 then

        Period = "Evening"

    else

        Period = "Night"

    end

    local DisplayName = LocalPlayer.DisplayName or LocalPlayer.Name

    return Period .. ", " .. DisplayName .. ".\n\nWelcome to Echo Hub, The Owner and Developer of this hub is " .. DisplayName .. ". Hope you enjoy using the Script :)"

end

local function UpdateEchoGreeting()

    pcall(function()

        GreetingLabel:SetText(GetEchoGreeting())

    end)

end

UpdateEchoGreeting()

task.spawn(function()

    while task.wait(30) do

        UpdateEchoGreeting()

    end

end)

ProfileGroup:AddDivider("Actions")

ProfileGroup:AddButton({

    Text = "Discord",

    Func = function()

        pcall(function()

            if setclipboard then

                setclipboard("https://discord.gg/")

            end

        end)

    end,

})

ProfileGroup:AddButton({

    Text = "Rejoin Server",

    Func = function()

        pcall(function()

            Library:Notify({

                Title = "Echo",

                Description = "Rejoining...",

                Icon = "bell",

                Time = 3,

            })

            game:GetService("TeleportService"):TeleportToPlaceInstance(

                game.PlaceId,

                game.JobId,

                LocalPlayer

            )

        end)

    end,

})

ProfileGroup:AddButton({

    Text = "Server Hop",

    Func = function()

        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        local Stats = game:GetService("Stats")

        Library:Notify({
            Title = "Echo",
            Description = "Finding the best server (low ping, high players)...",
            Icon = "bell",
            Time = 3,
        })

        task.spawn(function()
            -- ── 1. Best-effort current region ping ──────────────────
            local currentPing
            pcall(function()
                local item = Stats.Network.ServerStatsItem["Data Ping"]
                local value = item and item:GetValue()
                if type(value) == "number" and value > 0 then
                    currentPing = value
                end
            end)

            -- ── 2. Page through public servers (up to ~500) ─────────
            local servers = {}
            local seen = {}
            local cursor = ""

            for _ = 1, 5 do
                local url = "https://games.roblox.com/v1/games/"
                    .. tostring(game.PlaceId)
                    .. "/servers/Public?sortOrder=Asc&limit=100"
                if cursor ~= "" then
                    url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
                end

                local body
                pcall(function() body = EchoHttpGet(url) end)
                if type(body) ~= "string" or body == "" then break end

                local decodeOk, data = pcall(function()
                    return HttpService:JSONDecode(body)
                end)
                if not decodeOk or type(data) ~= "table" then break end

                for _, server in ipairs(data.data or {}) do
                    local id = server.id
                    local playing = tonumber(server.playing) or 0
                    local maxPlayers = tonumber(server.maxPlayers) or 0
                    if id and id ~= game.JobId
                        and playing < maxPlayers          -- must have space
                        and playing >= 2                  -- skip near-empty
                        and not seen[id] then
                        seen[id] = true
                        table.insert(servers, server)
                    end
                end

                cursor = data.nextPageCursor or ""
                if cursor == "" then break end
            end

            if #servers == 0 then
                Library:Notify({
                    Title = "Echo",
                    Description = "Server hop failed: no available server found.",
                    Icon = "bell",
                    Time = 3,
                })
                return
            end

            -- ── 3. Score each server ────────────────────────────────
            -- Priority (lower score = better):
            --   • Low average ping  (server.ping when provided)
            --   • More players (popular servers = better FPS/health)
            --   • Closer to our current ping (region proximity)
            local MAX_PLAYERS = Players.MaxPlayers
            local ranked = {}
            for _, server in ipairs(servers) do
                local serverPing  = tonumber(server.ping)
                local playing     = tonumber(server.playing) or 0
                local maxPlayers  = tonumber(server.maxPlayers) or MAX_PLAYERS
                local fillRatio   = maxPlayers > 0 and (playing / maxPlayers) or 0

                -- Ping term: absolute ping if known, else fallback to diff
                local pingTerm
                if serverPing then
                    pingTerm = serverPing
                    if currentPing then
                        -- 50% weight on absolute ping, 50% on delta from us
                        pingTerm = (serverPing * 0.5) + (math.abs(serverPing - currentPing) * 0.5)
                    end
                else
                    -- No ping data: neutral value so player-count decides
                    pingTerm = 120
                end

                -- Player term: reward fuller servers, slight reward for very full
                -- (FPS tends to be similar across lobbies in Roblox; player
                --  count is the closest proxy we can get to "active" servers).
                -- Normalize to 0..100.
                local playerTerm = (1 - fillRatio) * 100

                -- Final weighted score
                local score = (pingTerm * 0.55) + (playerTerm * 0.45)

                -- Small random jitter so repeated hops don't always pick the same
                score = score + math.random() * 5

                table.insert(ranked, {
                    Id = server.id,
                    Score = score,
                    Ping = serverPing,
                    Playing 
