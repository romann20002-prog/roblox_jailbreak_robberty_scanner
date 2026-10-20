-- HEIST_SCANNER_MARKER

local env = (getgenv and getgenv()) or _G
if env.KeyLoaderJob == game.JobId then return end
env.KeyLoaderJob = game.JobId

local CONFIG = {
    WORKER_URL = "https://keysystem-eight-gray.vercel.app/",
    FOLDER     = "Scanner",
    KEY_FILE   = "key.txt",
}

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")
local LP          = Players.LocalPlayer
local req = (syn and syn.request) or http_request or request

if not game:IsLoaded() then game.Loaded:Wait() end

local folderOk = false
pcall(function()
    if isfolder and not isfolder(CONFIG.FOLDER) then makefolder(CONFIG.FOLDER) end
    folderOk = isfolder and isfolder(CONFIG.FOLDER) or false
end)

local function P(name)
    return folderOk and (CONFIG.FOLDER .. "/" .. name) or name
end

local function readKey()
    local ok, data = pcall(readfile, P(CONFIG.KEY_FILE))
    if ok and type(data) == "string" then
        data = data:gsub("%s+", "")
        if data ~= "" then return data end
    end
    return nil
end

local function saveKey(key)
    pcall(writefile, P(CONFIG.KEY_FILE), key)
end

local function getHwid()
    local id
    pcall(function() id = game:GetService("RbxAnalyticsService"):GetClientId() end)
    if (not id or id == "") and gethwid then
        pcall(function() id = gethwid() end)
    end
    id = tostring(id or ""):gsub("[^%w%-]", "")
    return id:sub(1, 80)
end

local HWID = getHwid()

local function fetchScript(key)
    if #HWID < 8 then return nil, "Could not read your device id (HWID)" end
    local ok, res = pcall(function()
        return req({
            Url = CONFIG.WORKER_URL .. "/api/script",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ key = key, hwid = HWID }),
        })
    end)
    if not ok or type(res) ~= "table" then return nil, "No connection to the key server" end
    if res.StatusCode == 200 and type(res.Body) == "string" and res.Body ~= "" then
        return res.Body
    end
    local okJ, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
    if okJ and type(data) == "table" and data.reason then return nil, tostring(data.reason) end
    return nil, "Key server error (" .. tostring(res.StatusCode) .. ")"
end

local function runScript(src)
    local f, err = loadstring(src)
    if not f then
        warn("[KeyLoader] Script failed to compile: " .. tostring(err))
        return false
    end
    task.spawn(f)
    return true
end

do
    local saved = readKey()
    if saved then
        local src = fetchScript(saved)
        if src and runScript(src) then return end
    end
end

local white = Color3.new(1, 1, 1)
local btnColor = Color3.fromRGB(50, 53, 62)
local onColor = Color3.fromRGB(50, 150, 80)

local function make(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end

local gui = Instance.new("ScreenGui")
gui.Name = "KeyLoaderGui"
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000
do
    local parent
    pcall(function() parent = (gethui and gethui()) or game:GetService("CoreGui") end)
    local ok = parent and pcall(function() gui.Parent = parent end)
    if not ok then gui.Parent = LP:WaitForChild("PlayerGui") end
end

local frame = make("Frame", {
    Size = UDim2.fromOffset(300, 290),
    Position = UDim2.new(0.5, -150, 0.5, -145),
    BackgroundColor3 = Color3.fromRGB(28, 30, 36),
    BorderSizePixel = 0, Active = true, Draggable = true,
}, gui)
make("UICorner", { CornerRadius = UDim.new(0, 8) }, frame)

make("TextLabel", {
    Size = UDim2.new(1, -50, 0, 28), Position = UDim2.fromOffset(10, 0),
    BackgroundTransparency = 1, Text = "🔑 Key System", TextColor3 = white,
    Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
}, frame)

local closeBtn = make("TextButton", {
    Size = UDim2.fromOffset(28, 22), Position = UDim2.new(1, -34, 0, 3),
    BackgroundColor3 = Color3.fromRGB(180, 60, 60), Text = "X", TextColor3 = white,
    Font = Enum.Font.GothamBold, TextSize = 13, BorderSizePixel = 0,
}, frame)

make("TextLabel", {
    Size = UDim2.fromOffset(280, 16), Position = UDim2.fromOffset(10, 34),
    BackgroundTransparency = 1, Text = "Get your key via:", TextColor3 = Color3.fromRGB(180, 180, 190),
    Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
}, frame)

local PROVIDERS = {
    { id = "linkvertise", label = "Linkvertise" },
    { id = "workink",     label = "Work.ink" },
    { id = "lootlabs",    label = "Lootlabs" },
}
local provider = PROVIDERS[1].id
local provBtns = {}

local linkBox, statusLabel

local function currentLink()
    return ("%s/start?hwid=%s&p=%s"):format(CONFIG.WORKER_URL, HWID, provider)
end

local function refreshProviders()
    for _, p in ipairs(PROVIDERS) do
        provBtns[p.id].BackgroundColor3 = (p.id == provider) and onColor or btnColor
    end
    if linkBox then linkBox.Text = "" end
end

for i, p in ipairs(PROVIDERS) do
    local b = make("TextButton", {
        Size = UDim2.fromOffset(88, 28), Position = UDim2.fromOffset(10 + (i - 1) * 96, 52),
        BackgroundColor3 = btnColor, Text = p.label, TextColor3 = white,
        Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0,
    }, frame)
    make("UICorner", { CornerRadius = UDim.new(0, 6) }, b)
    provBtns[p.id] = b
    b.MouseButton1Click:Connect(function()
        provider = p.id
        refreshProviders()
    end)
end

local linkBtn = make("TextButton", {
    Size = UDim2.fromOffset(280, 28), Position = UDim2.fromOffset(10, 88),
    BackgroundColor3 = Color3.fromRGB(65, 95, 145), Text = "Get Link", TextColor3 = white,
    Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0,
}, frame)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, linkBtn)

linkBox = make("TextBox", {
    Size = UDim2.fromOffset(280, 24), Position = UDim2.fromOffset(10, 122),
    BackgroundColor3 = Color3.fromRGB(40, 43, 52), TextColor3 = Color3.fromRGB(200, 200, 210),
    PlaceholderText = "Your link appears here", PlaceholderColor3 = Color3.fromRGB(120, 120, 130),
    Text = "", ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 10,
    TextTruncate = Enum.TextTruncate.AtEnd, BorderSizePixel = 0,
}, frame)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, linkBox)

local keyBox = make("TextBox", {
    Size = UDim2.fromOffset(280, 30), Position = UDim2.fromOffset(10, 156),
    BackgroundColor3 = Color3.fromRGB(40, 43, 52), TextColor3 = white,
    PlaceholderText = "Paste your key here", PlaceholderColor3 = Color3.fromRGB(140, 140, 150),
    Text = "", ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 12, BorderSizePixel = 0,
}, frame)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, keyBox)

local checkBtn = make("TextButton", {
    Size = UDim2.fromOffset(280, 32), Position = UDim2.fromOffset(10, 194),
    BackgroundColor3 = onColor, Text = "Check Key", TextColor3 = white,
    Font = Enum.Font.GothamBold, TextSize = 13, BorderSizePixel = 0,
}, frame)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, checkBtn)

statusLabel = make("TextLabel", {
    Size = UDim2.fromOffset(280, 34), Position = UDim2.fromOffset(10, 232),
    BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(200, 200, 210),
    Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
    Text = "Choose a provider, press Get Link, open the link in your browser.",
}, frame)

make("TextLabel", {
    Size = UDim2.fromOffset(280, 14), Position = UDim2.fromOffset(10, 270),
    BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(110, 115, 130),
    Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left,
    Text = "HWID: " .. HWID:sub(1, 8) .. "...",
}, frame)

local function setStatus(t) statusLabel.Text = tostring(t) end

refreshProviders()

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

linkBtn.MouseButton1Click:Connect(function()
    if #HWID < 8 then
        setStatus("Could not read your device id (HWID).")
        return
    end
    local link = currentLink()
    linkBox.Text = link
    local copied = false
    local clip = setclipboard or toclipboard or (syn and syn.write_clipboard)
    if clip then copied = pcall(clip, link) end
    setStatus(copied
        and "Link copied! Open it in your browser (same browser for the whole process), finish the steps, then paste the key here."
        or "Copy the link above, open it in your browser, finish the steps, then paste the key here.")
end)

local checking = false
checkBtn.MouseButton1Click:Connect(function()
    if checking then return end
    local key = (keyBox.Text:gsub("%s+", ""))
    if key == "" then
        setStatus("Paste your key first.")
        return
    end
    checking = true
    checkBtn.Text = "Checking..."
    setStatus("Checking key...")
    task.spawn(function()
        local src, reason = fetchScript(key)
        checking = false
        checkBtn.Text = "Check Key"
        if not src then
            setStatus(reason or "Invalid key")
            return
        end
        saveKey(key)
        setStatus("Key accepted. Loading...")
        gui:Destroy()
        runScript(src)
    end)
end)
