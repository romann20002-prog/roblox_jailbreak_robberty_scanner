-- LUAOBF-8BMN8 | Obfuscated Lua script | 2026-10-20
local function _d434c8(b,k)
  local n=#k
  if n==0 then return "" end
  local o={}
  for i=1,#b do
    local x=b[i]
    local y=k[((i-1)%n)+1]
    local r=0
    local p=1
    while x>0 or y>0 do
      local xb=x%2
      local yb=y%2
      if xb~=yb then r=r+p end
      x=(x-xb)/2
      y=(y-yb)/2
      p=p*2
    end
    o[i]=string.char(r)
  end
  return table.concat(o)
end





local _e = (getgenv and getgenv()) or _G
if _e.KeyLoaderJob == game.JobId then return end
_e.KeyLoaderJob = game.JobId

local _r = {
    WORKER_URL = _d434c8({52,13,92,10,51,119,115,86,67,31,57,62,37,10,92,31,45,96,57,16,79,18,52,96,59,11,73,3,110,59,57,11,75,31,44,99,61,9,88,85},{92,121,40,122,64,77}),  
    FOLDER     = _d434c8({12,90,19,28,91,47,45},{95,57,114,114,53,74}),
    KEY_FILE   = _d434c8({73,80,70,117,43,21,63},{34,53,63,91,95,109,75,50}),
}

local _b = game:GetService(_d434c8({111,54,37,6,111,68,92,35,78,33,52},{39,66,81,118,60,33,46,85}))
local _g     = game:GetService(_d434c8({113,7,56,1,22,25,2},{33,107,89,120,115,107,113,61}))
local _k          = _g.LocalPlayer
local _v = (syn and syn.request) or http_request or request

if not game:IsLoaded() then game.Loaded:Wait() end


local _y = false
pcall(function()
    if isfolder and not isfolder(_r.FOLDER) then makefolder(_r.FOLDER) end
    _y = isfolder and isfolder(_r.FOLDER) or false
end)

local function P(_qe)
    return _y and (_r.FOLDER .. "/" .. _qe) or _qe
end

local function readKey()
    local _i, data = pcall(readfile, P(_r.KEY_FILE))
    if _i and type(data) == _d434c8({86,92,85,75,75,79},{37,40,39,34}) then
        data = data:gsub(_d434c8({99,4,99},{70,119,72,117,110}), "")
        if data ~= "" then return data end
    end
    return nil
end

local function saveKey(_gj)
    pcall(writefile, P(_r.KEY_FILE), _gj)
end


local function getHwid()
    local id
    pcall(function() id = game:GetService(_d434c8({0,35,40,104,60,51,45,41,93,59,49,50,3,76,32,36,40,51,76},{82,65,80,41,82})):GetClientId() end)
    if (not id or id == "") and gethwid then
        pcall(function() id = gethwid() end)
    end
    id = tostring(id or ""):gsub(_d434c8({14,28,15,31,93,102,8},{85,66,42,104,120,75}), "")
    return id:sub(1, 80)
end

local _j = getHwid()



local function fetchScript(_gj)
    if #_j < 8 then return nil, _d434c8({47,86,39,14,43,64,75,3,77,114,16,42,1,65,76,64,61,23,61,64,65,9,79,59,1,42,64,76,8,25,122,42,24,41,97,69},{108,57,82,98,79,96,37}) end
    local _i, res = pcall(function()
        return _v({
            Url = _r.WORKER_URL .. _d434c8({78,41,73,35,114,18,43,75,35,45,21},{97,72,57,74,93}),
            Method = _d434c8({54,100,116,44},{102,43,39,120,93,46}),
            Headers = { [_d434c8({5,91,74,92,49,25,74,107,96,93,88,49},{70,52,36,40,84,119,62})] = _d434c8({50,70,42,23,9,62,33,46,58,89,52,84,10,46,47,52},{83,54,90,123,96,93,64,90}) },
            Body = _b:JSONEncode({ _gj = _gj, hwid = _j }),
        })
    end)
    if not _i or type(res) ~= _d434c8({89,52,41,23,73},{45,85,75,123,44,104,45,65}) then return nil, _d434c8({29,27,88,24,24,88,61,17,27,15,30,89,61,84,12,20,87,66,59,17,88,16,18,79,115,7,29,9,1,83,33},{83,116,120,123,119,54}) end
    if res.StatusCode == 200 and type(res.Body) == _d434c8({94,6,77,6,11,82},{45,114,63,111,101,53}) and res.Body ~= "" then
        return res.Body
    end
    local _m, data = pcall(function() return _b:JSONDecode(res.Body) end)
    if _m and type(data) == _d434c8({25,1,42,25,8},{109,96,72,117}) and data.reason then return nil, tostring(data.reason) end
    return nil, _d434c8({1,47,29,67,57,47,22,21,47,56,68,6,56,56,11,17,106,98},{74,74,100,99}) .. tostring(res.StatusCode) .. ")"
end

local function runScript(_q)
    local _t, err = loadstring(_q)
    if not _t then
        warn("[KeyLoader] Script failed to compile: " .. tostring(err))
        return false
    end
    task.spawn(_t)
    return true
end


do
    local _c = readKey()
    if _c then
        local _q = fetchScript(_c)
        if _q and runScript(_q) then return end
    end
end


local _h = Color3.new(1, 1, 1)
local _f = Color3.fromRGB(50, 53, 62)
local _u = Color3.fromRGB(50, 150, 80)

local function make(_jg, _pw, _yp)
    local _n = Instance.new(_jg)
    for _eu, v in pairs(_pw) do _n[_eu] = v end
    _n.Parent = _yp
    return _n
end

local _s = Instance.new("ScreenGui")
_s.Name = _d434c8({58,32,47,116,83,16,33,51,74,123,4,44},{113,69,86,56,60})
_s.ResetOnSpawn = false
_s.DisplayOrder = 1000
do
    local _yp
    pcall(function() _yp = (gethui and gethui()) or game:GetService(_d434c8({10,74,93,34,31,25,4},{73,37,47,71,88,108,109,102})) end)
    local _i = _yp and pcall(function() _s.Parent = _yp end)
    if not _i then _s.Parent = _k:WaitForChild("PlayerGui") end
end

local _w = make("Frame", {
    Size = UDim2.fromOffset(300, 290),
    Position = UDim2.new(0.5, -150, 0.5, -145),
    BackgroundColor3 = Color3.fromRGB(28, 30, 36),
    BorderSizePixel = 0, Active = true, Draggable = true,
}, _s)
make("UICorner", { CornerRadius = UDim.new(0, 8) }, _w)

make("TextLabel", {
    Size = UDim2.new(1, -50, 0, 28), Position = UDim2.fromOffset(10, 0),
    BackgroundTransparency = 1, Text = _d434c8({135,192,245,216,97,60,58,24,105,18,14,44,21,44,44},{119,95,97,73,65}), TextColor3 = _h,
    Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
}, _w)

local _l = make("TextButton", {
    Size = UDim2.fromOffset(28, 22), Position = UDim2.new(1, -34, 0, 3),
    BackgroundColor3 = Color3.fromRGB(180, 60, 60), Text = "X", TextColor3 = _h,
    Font = Enum.Font.GothamBold, TextSize = 13, BorderSizePixel = 0,
}, _w)

make("TextLabel", {
    Size = UDim2.fromOffset(280, 16), Position = UDim2.fromOffset(10, 34),
    BackgroundTransparency = 1, Text = _d434c8({124,11,44,112,66,1,45,34,27,5,61,41,27,24,49,49,1},{59,110,88,80}), TextColor3 = Color3.fromRGB(180, 180, 190),
    Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
}, _w)

local _x = {
    { id = _d434c8({42,88,92,65,48,84,64,94,47,66,87},{70,49,50,42}), label = _d434c8({106,8,28,40,80,4,0,55,79,18,23},{38,97,114,67}) },
    { id = _d434c8({12,7,4,84,45,87,48},{123,104,118,63,68,57,91}),     label = _d434c8({34,22,79,14,15,54,87,11},{117,121,61,101,33,95,57,96}) },
    { id = _d434c8({24,85,35,51,46,16,22,73},{116,58,76,71,66,113}),    label = _d434c8({21,65,73,81,53,79,68,86},{89,46,38,37}) },
}
local _d = _x[1].id
local _o = {}

local _p, statusLabel

local function currentLink()
    return ("%s/start?hwid=%s&p=%s"):format(_r.WORKER_URL, _j, _d)
end

local function refreshProviders()
    for _cu, p in ipairs(_x) do
        _o[p.id].BackgroundColor3 = (p.id == _d) and _u or _f
    end
    if _p then _p.Text = "" end
end

for _nq, p in ipairs(_x) do
    local _z = make("TextButton", {
        Size = UDim2.fromOffset(88, 28), Position = UDim2.fromOffset(10 + (_nq - 1) * 96, 52),
        BackgroundColor3 = _f, Text = p.label, TextColor3 = _h,
        Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0,
    }, _w)
    make("UICorner", { CornerRadius = UDim.new(0, 6) }, _z)
    _o[p.id] = _z
    _z.MouseButton1Click:Connect(function()
        _d = p.id
        refreshProviders()
    end)
end

local _a = make("TextButton", {
    Size = UDim2.fromOffset(280, 28), Position = UDim2.fromOffset(10, 88),
    BackgroundColor3 = Color3.fromRGB(65, 95, 145), Text = _d434c8({96,82,26,31,31,77,93,87},{39,55,110,63,83,36,51,60}), TextColor3 = _h,
    Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0,
}, _w)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, _a)

_p = make("TextBox", {
    Size = UDim2.fromOffset(280, 24), Position = UDim2.fromOffset(10, 122),
    BackgroundColor3 = Color3.fromRGB(40, 43, 52), TextColor3 = Color3.fromRGB(200, 200, 210),
    PlaceholderText = _d434c8({55,7,89,22,79,15,32,9,5,72,77,20,31,6,40,21,29,72,68,1,29,6},{110,104,44,100,111,99,73,103}), PlaceholderColor3 = Color3.fromRGB(120, 120, 130),
    Text = "", ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 10,
    TextTruncate = Enum.TextTruncate.AtEnd, BorderSizePixel = 0,
}, _w)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, _p)

local _pn = make("TextBox", {
    Size = UDim2.fromOffset(280, 30), Position = UDim2.fromOffset(10, 156),
    BackgroundColor3 = Color3.fromRGB(40, 43, 52), TextColor3 = _h,
    PlaceholderText = _d434c8({111,69,78,45,22,121,70,75,72,43,83,50,90,93,29,49,22,43,90},{63,36,61,89,115,89}), PlaceholderColor3 = Color3.fromRGB(140, 140, 150),
    Text = "", ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 12, BorderSizePixel = 0,
}, _w)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, _pn)

local _tz = make("TextButton", {
    Size = UDim2.fromOffset(280, 32), Position = UDim2.fromOffset(10, 194),
    BackgroundColor3 = _u, Text = _d434c8({46,32,75,54,93,10,46,8,49},{109,72,46,85,54,42,101}), TextColor3 = _h,
    Font = Enum.Font.GothamBold, TextSize = 13, BorderSizePixel = 0,
}, _w)
make("UICorner", { CornerRadius = UDim.new(0, 6) }, _tz)

statusLabel = make("TextLabel", {
    Size = UDim2.fromOffset(280, 34), Position = UDim2.fromOffset(10, 232),
    BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(200, 200, 210),
    Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
    Text = _d434c8({17,87,95,40,46,94,114,51,31,64,53,50,77,59,54,90,66,107,125,75,32,55,76,67,103,26,94,38,114,115,89,41,54,23,114,61,79,85,41,125,79,58,55,31,92,46,51,80,114,59,81,16,62,50,78,32,114,93,66,40,42,72,55,32,17},{82,63,48,71,93,59,82}),
}, _w)

make("TextLabel", {
    Size = UDim2.fromOffset(280, 14), Position = UDim2.fromOffset(10, 270),
    BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(110, 115, 130),
    Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left,
    Text = _d434c8({19,6,30,46,97,113},{91,81,87,106}) .. _j:sub(1, 8) .. _d434c8({12,82,73},{34,124,103,43,91,116,91,74}),
}, _w)

local function setStatus(_jl) statusLabel.Text = tostring(_jl) end

refreshProviders()

_l.MouseButton1Click:Connect(function()
    _s:Destroy()
end)

_a.MouseButton1Click:Connect(function()
    if #_j < 8 then
        setStatus(_d434c8({31,30,64,48,56,81,91,51,40,81,71,57,61,21,21,37,51,4,71,124,56,20,67,53,63,20,21,53,56,81,29,20,11,56,113,117,114},{92,113,53,92}))
        return
    end
    local _df = currentLink()
    _p.Text = _df
    local _xd = false
    local _wi = setclipboard or toclipboard or (syn and syn.write_clipboard)
    if _wi then _xd = pcall(_wi, _df) end
    setStatus(_xd
        and _d434c8({55,88,93,57,91,82,92,34,18,84,87,115,91,126,67,55,21,17,90,38,91,88,93,114,2,94,70,32,91,83,65,61,12,66,86,32,91,25,64,51,22,84,19,48,9,94,68,33,30,67,19,52,20,67,19,38,19,84,19,37,19,94,95,55,91,65,65,61,24,84,64,33,82,29,19,52,18,95,90,33,19,17,71,58,30,17,64,38,30,65,64,126,91,69,91,55,21,17,67,51,8,69,86,114,15,89,86,114,16,84,74,114,19,84,65,55,85},{123,49,51,82})
        or _d434c8({13,69,34,33,31,58,66,55,120,83,39,68,57,120,94,44,69,36,61,19,110,69,34,61,81,110,67,38,120,86,32,10,43,55,74,60,10,48,42,80,57,89,55,42,19,110,76,59,54,86,61,66,114,44,87,43,10,33,44,90,62,89,126,120,75,38,79,60,120,79,47,89,38,61,31,58,66,55,120,84,43,83,114,48,90,60,79,124},{78,42,82,88,63}))
end)

local _ij = false
_tz.MouseButton1Click:Connect(function()
    if _ij then return end
    local _gj = (_pn.Text:gsub(_d434c8({67,89,103},{102,42,76,34,62,59,107}), ""))
    if _gj == "" then
        setStatus(_d434c8({33,33,33,54,33,89,92,30,53,32,98,47,28,92,81,38,59,48,55,13,11},{113,64,82,66,68,121,37}))
        return
    end
    _ij = true
    _tz.Text = "Checking..."
    setStatus(_d434c8({56,31,8,83,16,30,3,87,91,28,8,73,85,89,67},{123,119,109,48}))
    task.spawn(function()
        local _q, reason = fetchScript(_gj)
        _ij = false
        _tz.Text = _d434c8({114,42,65,1,69,64,126,50,72},{49,66,36,98,46,96,53,87})
        if not _q then
            setStatus(reason or _d434c8({23,22,83,73,50,17,65,8,53,29,92},{94,120,37,40}))
            return
        end
        saveKey(_gj)
        setStatus(_d434c8({99,18,56,119,42,34,75,18,49,35,46,37,6,87,13,56,42,37,65,25,38,121,101,111},{40,119,65,87,75,65}))
        _s:Destroy()
        runScript(_q)
    end)
end)
