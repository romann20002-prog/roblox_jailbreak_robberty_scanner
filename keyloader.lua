-- HEIST_SCANNER_MARKER

local env = (getgenv and getgenv()) or _G
if env.KeyLoaderJob == game.JobId then return end
env.KeyLoaderJob = game.JobId

local CONFIG = {
    WORKER_URL = "https://keysystem-eight-gray.vercel.app/",
    FOLDER     = "Scanner",
    KEY_FILE   = "key.txt",
}

local BASE = (CONFIG.WORKER_URL:gsub("/+$", "")) -- адреса без кінцевого "/"

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
    if #HWID < 8 then return nil, "Could not read your HWID" end
    local ok, res = pcall(function()
        return req({
            Url = BASE .. "/api/script",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ key = key, hwid = HWID }),
        })
    end)
    if not ok or type(res) ~= "table" then return nil, "Server is down right now, try again later" end
    if res.StatusCode == 200 and type(res.Body) == "string" and res.Body ~= "" then
        return res.Body
    end
    local okJ, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
    if okJ and type(data) == "table" and data.reason then return nil, tostring(data.reason) end
    return nil, "Server error (" .. tostring(res.StatusCode) .. ")"
end

local function runScript(src)
    local f, err = loadstring(src)
    if not f then
        warn("[KeyLoader] Error 2")
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
local offColor = Color3.fromRGB(38, 40, 46)       -- колір вимкненого провайдера
local offText = Color3.fromRGB(110, 112, 120)     -- колір тексту вимкненого провайдера

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
    Size = UDim2.fromOffset(300, 342),
    Position = UDim2.new(0.5, -150, 0.5, -171),
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

-- ============================================================
-- ПРОВАЙДЕРИ
-- enabled = true  -> можна вибрати
-- enabled = false -> кнопка сіра, натиснути не можна (вимкнено)
-- ============================================================
local PROVIDERS = {
    { id = "linkvertise", label = "Linkvertise", enabled = true,  image = "https://consumersiteimages.trustpilot.net/business-units/5fada0839a033e00010810e6-198x149-1x.jpg" },
    { id = "workink",     label = "Work.ink",    enabled = true,  image = "https://work.ink/favicon.png" },
    { id = "lootlabs",    label = "Lootlabs",    enabled = true,  image = "https://creators.lootlabs.gg/assets/svg/logo.svg" },
}
-- hours = строк ключа, steps = скільки разів треба пройти посилання (24h = 1 крок, 48h = 2, 72h = 3)
local DURATIONS = { 24, 48, 72 }

-- обираємо першого ввімкненого провайдера за замовчуванням
local provider = nil
for _, p in ipairs(PROVIDERS) do
    if p.enabled then provider = p.id break end
end

local hours = DURATIONS[1]
local provBtns = {}
local provImgs = {}
local durBtns = {}

local linkBox, statusLabel
local setStatus = function() end -- буде визначено нижче (потрібно заздалегідь, бо кнопки його викликають)

local function currentLink()
    return ("%s/start?hwid=%s&p=%s&h=%d"):format(BASE, HWID, provider, hours)
end

local function refreshProviders()
    for _, p in ipairs(PROVIDERS) do
        local b = provBtns[p.id]
        if not p.enabled then
            b.BackgroundColor3 = offColor
            b.TextColor3 = offText
        else
            b.BackgroundColor3 = (p.id == provider) and onColor or btnColor
            b.TextColor3 = white
        end
    end
    for _, h in ipairs(DURATIONS) do
        durBtns[h].BackgroundColor3 = (h == hours) and onColor or btnColor
    end
    if linkBox then linkBox.Text = "" end
end

-- Roblox не вміє показувати картинки за URL: завантажуємо іконку (через wsrv.nl, який перетворює
-- jpg/svg у png), зберігаємо у папку Scanner і показуємо через getcustomasset.
-- Якщо executor цього не вміє - кнопка просто лишається без картинки (лише текст).
local function loadIcon(p, imgLabel)
    local gca = getcustomasset or getsynasset
    if not gca or not req then return end
    local file = P("icon_" .. p.id .. ".png")
    local okE, exists = pcall(function() return isfile and isfile(file) end)
    if not (okE and exists) then
        local url = ("https://wsrv.nl/?url=%s&w=64&h=64&fit=contain&output=png"):format(HttpService:UrlEncode(p.image))
        local ok, res = pcall(req, { Url = url, Method = "GET" })
        if not ok or type(res) ~= "table" or res.StatusCode ~= 200
            or type(res.Body) ~= "string" or #res.Body < 100 then return end
        if not pcall(writefile, file, res.Body) then return end
    end
    local okA, asset = pcall(gca, file)
    if okA and asset and imgLabel.Parent then imgLabel.Image = asset end
end

for i, p in ipairs(PROVIDERS) do
    local b = make("TextButton", {
        Size = UDim2.fromOffset(88, 46), Position = UDim2.fromOffset(10 + (i - 1) * 96, 52),
        BackgroundColor3 = btnColor, Text = p.label, TextColor3 = white,
        Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        AutoButtonColor = p.enabled,
    }, frame)
    make("UICorner", { CornerRadius = UDim.new(0, 6) }, b)
    local img = make("ImageLabel", {
        Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0.5, -12, 0, 4),
        BackgroundTransparency = 1, Image = "", ScaleType = Enum.ScaleType.Fit,
        ImageTransparency = p.enabled and 0 or 0.65,
    }, b)
    if p.enabled then
        task.spawn(loadIcon, p, img) -- для вимкненого провайдера іконку не вантажимо
    end
    provBtns[p.id] = b
    provImgs[p.id] = img
    b.MouseButton1Click:Connect(function()
        if not p.enabled then
            setStatus(p.label .. " is temporarily unavailable. Choose another provider.")
            return
        end
        provider = p.id
        refreshProviders()
    end)
end

for i, h in ipairs(DURATIONS) do
    local b = make("TextButton", {
        Size = UDim2.fromOffset(88, 26), Position = UDim2.fromOffset(10 + (i - 1) * 96, 106),
        BackgroundColor3 = btnColor, Text = ("%dh · %d step%s"):format(h, h / 24, h > 24 and "s" or ""),
        TextColor3 = white, Font = Enum.Font.GothamBold, TextSize = 10, BorderSizePixel = 0,
    }, frame)
    make("UICorner", { CornerRadius = UDim.new(0, 6) }, b)
    durBtns[h] = b
    b.MouseButton1Click:Connect(function()
        hours = h
        refreshProviders()
    end)
end

local linkBtn = make("TextButton", {
    Size = UDim2.fromOffset(280, 28), Position = UDim2.fromOffset(10, 140),
    BackgroundColor3 = Color3.fromRGB(65, 95, 145), Text = "Get Link", TextColor3 = white,
    Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0,
}, frame)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, linkBtn)

linkBox = make("TextBox", {
    Size = UDim2.fromOffset(280, 24), Position = UDim2.fromOffset(10, 174),
    BackgroundColor3 = Color3.fromRGB(40, 43, 52), TextColor3 = Color3.fromRGB(200, 200, 210),
    PlaceholderText = "Copy link here", PlaceholderColor3 = Color3.fromRGB(120, 120, 130),
    Text = "", ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 10,
    TextTruncate = Enum.TextTruncate.AtEnd, BorderSizePixel = 0,
}, frame)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, linkBox)

local keyBox = make("TextBox", {
    Size = UDim2.fromOffset(280, 30), Position = UDim2.fromOffset(10, 208),
    BackgroundColor3 = Color3.fromRGB(40, 43, 52), TextColor3 = white,
    PlaceholderText = "Paste your key here", PlaceholderColor3 = Color3.fromRGB(140, 140, 150),
    Text = "", ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 12, BorderSizePixel = 0,
}, frame)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, keyBox)

local checkBtn = make("TextButton", {
    Size = UDim2.fromOffset(280, 32), Position = UDim2.fromOffset(10, 246),
    BackgroundColor3 = onColor, Text = "Check Key", TextColor3 = white,
    Font = Enum.Font.GothamBold, TextSize = 13, BorderSizePixel = 0,
}, frame)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, checkBtn)

statusLabel = make("TextLabel", {
    Size = UDim2.fromOffset(280, 34), Position = UDim2.fromOffset(10, 284),
    BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(200, 200, 210),
    Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
    Text = "Choose a provider and key duration, press Get Link, open the link in your browser. Longer keys need more steps.",
}, frame)

make("TextLabel", {
    Size = UDim2.fromOffset(280, 14), Position = UDim2.fromOffset(10, 322),
    BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(110, 115, 130),
    Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left,
    Text = "HWID: " .. HWID:sub(1, 8) .. "...",
}, frame)

setStatus = function(t) statusLabel.Text = tostring(t) end

refreshProviders()

if not provider then
    setStatus("All providers are temporarily unavailable. Try again later.")
end

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

linkBtn.MouseButton1Click:Connect(function()
    if not provider then
        setStatus("All providers are temporarily unavailable. Try again later.")
        return
    end
    if #HWID < 8 then
        setStatus("Could not read your HWID")
        return
    end
    local link = currentLink()
    linkBox.Text = link
    local copied = false
    local clip = setclipboard or toclipboard or (syn and syn.write_clipboard)
    if clip then copied = pcall(clip, link) end
    setStatus(copied
        and "Link copied!"
        or "Copy the link above")
end)

local checking = false
checkBtn.MouseButton1Click:Connect(function()
    if checking then return end
    local key = (keyBox.Text:gsub("%s+", ""))
    if key == "" then
        setStatus("Enter your key first")
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
            setStatus(reason or "Wrong key or HWID")
            return
        end
        saveKey(key)
        setStatus("Loading script...")
        gui:Destroy()
        runScript(src)
    end)
end)
