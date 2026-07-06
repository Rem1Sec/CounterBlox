--[[
    CounterBlox Reloaded v2.0
    Loadstring Script for Roblox
    Features: Silent Aim, ESP, Rage Bot, Kill Aura, Trigger Bot, Anti Aim
    Tabs: Legit, Rage, Settings, Themes, Config
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local Camera = WS.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

local CurrentTheme = "Default"
local Themes = {
    Default = { Main = Color3.fromRGB(25,25,30), Main2 = Color3.fromRGB(35,35,45), Accent = Color3.fromRGB(0,170,255), BG = Color3.fromRGB(15,15,20), Red = Color3.fromRGB(255,60,60), Green = Color3.fromRGB(60,255,60), Text = Color3.fromRGB(230,230,230), Text2 = Color3.fromRGB(150,150,150) },
    Dark    = { Main = Color3.fromRGB(15,15,20), Main2 = Color3.fromRGB(22,22,28), Accent = Color3.fromRGB(120,80,200), BG = Color3.fromRGB(10,10,14), Red = Color3.fromRGB(200,40,40), Green = Color3.fromRGB(40,200,40), Text = Color3.fromRGB(200,200,210), Text2 = Color3.fromRGB(130,130,140) },
    Blood   = { Main = Color3.fromRGB(35,10,10), Main2 = Color3.fromRGB(45,15,15), Accent = Color3.fromRGB(255,30,30), BG = Color3.fromRGB(25,5,5), Red = Color3.fromRGB(255,20,20), Green = Color3.fromRGB(20,200,20), Text = Color3.fromRGB(230,200,200), Text2 = Color3.fromRGB(170,120,120) },
    Ocean   = { Main = Color3.fromRGB(10,25,35), Main2 = Color3.fromRGB(15,35,45), Accent = Color3.fromRGB(0,200,220), BG = Color3.fromRGB(8,18,25), Red = Color3.fromRGB(255,50,50), Green = Color3.fromRGB(50,255,50), Text = Color3.fromRGB(200,230,240), Text2 = Color3.fromRGB(120,150,160) },
    Nebula  = { Main = Color3.fromRGB(18,8,32), Main2 = Color3.fromRGB(28,15,45), Accent = Color3.fromRGB(180,80,255), BG = Color3.fromRGB(12,5,22), Red = Color3.fromRGB(255,50,100), Green = Color3.fromRGB(50,255,120), Text = Color3.fromRGB(220,200,240), Text2 = Color3.fromRGB(140,120,160) },
}
local C = Themes.Default

local Opt = {
    -- Legit
    SilentAim = {Enabled=false,HitChance=65,FOV=90,IgnoreTeam=true,WallCheck=true,VisibleOnly=true},
    TriggerBot = {Enabled=false,Delay=0.1,HitChance=70,Key="MouseButton2"},
    Crosshair = {Enabled=true,Color=Color3.fromRGB(0,255,0),Size=12,Gap=4,T=1.5,Dot=false,Outline=true},
    -- Visuals
    ESP = {Enabled=false,Boxes=true,BoxColor=Color3.fromRGB(0,170,255),Outline=true,HealthBar=true,HealthText=true,Name=true,Distance=true,Tracer=false,TracerOrigin="Bottom"},
    -- Rage
    RageBot = {Enabled=false,HitChance=40,AutoShoot=false,TargetMode="Closest",Hitbox="Head",MaxDist=5000,VizCheck=true},
    KillAura = {Enabled=false,Range=25,HitChance=50,TargetMode="Closest",Delay=0.05},
    AntiAim = {Enabled=false,Pitch="Down",Yaw="Spin",SpinSpeed=20,Jitter=false},
    -- Misc
    MenuKey = Enum.KeyCode.RightShift,
    MenuOpen = false,
    Watermark = true,
    Theme = "Default",
}

local function Round(v,d) d=d or 0 return math.floor(v*(10^d)+0.5)/(10^d) end
local function GetChar(p) return p.Character end
local function GetRoot(p) local c=GetChar(p) return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum(p) local c=GetChar(p) return c and c:FindFirstChildOfClass("Humanoid") end
local function Alive(p) local h=GetHum(p) return h and h.Health>0 and GetRoot(p) end
local function TeamMate(p) if not Opt.SilentAim.IgnoreTeam then return false end return LP.Team and p.Team and LP.Team==p.Team end
local function W2S(pos) local v,z=Camera:WorldToViewportPoint(pos) return Vector2.new(v.X,v.Y),z end
local function Targets() local t={} for _,p in pairs(Players:GetPlayers()) do if p~=LP and Alive(p) and not TeamMate(p) then t[#t+1]=p end end return t end
local function HC(n) return math.random(1,100)<=n end
local function Vis(s,e,ig) local p=RaycastParams.new() p.FilterType=Enum.RaycastFilterType.Blacklist p.FilterDescendantsInstances=ig or {LP.Character,Camera} local r=WS:Raycast(s,(e-s).Unit*(e-s).Magnitude,p) if r then return (r.Position-s).Magnitude>=(e-s).Magnitude-2 end return true end

-- Drawing helpers
local function D(t,p) local d=Drawing.new(t) for k,v in pairs(p) do d[k]=v end return d end

--[[ UI LIBRARY ]]
local UI = {}
UI.Window = nil
UI.HoveredObj = nil

function UI:Window(title, w, h)
    local scr = Camera.ViewportSize
    local wx, wy = scr.X/2-w/2, scr.Y/2-h/2
    local win = {
        x=wx, y=wy, w=w, h=h, title=title,
        tabs={}, activeTab=1, scroll=0, maxScroll=0,
        drag=false, dragOffX=0, dragOffY=0,
        objs={}, tabObjs={}, contentObjs={},
        elemCache={},
    }
    UI.Window = win

    win.bg = D("Square",{Size=Vector2.new(w,h),Position=Vector2.new(wx,wy),Color=C.Main,Filled=true,Thickness=0,Transparency=0,ZIndex=100})
    win.brd = D("Square",{Size=Vector2.new(w,h),Position=Vector2.new(wx,wy),Color=C.Accent,Filled=false,Thickness=1.5,Transparency=0,ZIndex=101})
    win.tbar = D("Square",{Size=Vector2.new(w,26),Position=Vector2.new(wx,wy),Color=C.Main2,Filled=true,Thickness=0,Transparency=0,ZIndex=102})
    win.ttxt = D("Text",{Position=Vector2.new(wx+8,wy+5),Text=title,Color=C.Accent,Size=16,Center=false,Outline=true,Transparency=0,ZIndex=103})
    win.close = D("Square",{Size=Vector2.new(22,22),Position=Vector2.new(wx+w-26,wy+2),Color=Color3.fromRGB(50,20,20),Filled=true,Thickness=0,Transparency=0,ZIndex=103})
    win.cltxt = D("Text",{Position=Vector2.new(wx+w-15,wy+5),Text="X",Color=C.Red,Size=13,Center=true,Outline=false,Transparency=0,ZIndex=104})
    win.tabBar = D("Square",{Size=Vector2.new(w,30),Position=Vector2.new(wx,wy+26),Color=C.BG,Filled=true,Thickness=0,Transparency=0,ZIndex=102})
    win.cbg = D("Square",{Size=Vector2.new(w-4,h-64),Position=Vector2.new(wx+2,wy+58),Color=C.Main,Filled=true,Thickness=0,Transparency=0,ZIndex=100})

    local function clearTab()
        if win.activeTab and win.tabs[win.activeTab] then
            for _,o in pairs(win.tabs[win.activeTab].objs) do o.Transparency=1 end
        end
        for _,o in pairs(win.contentObjs) do o.Transparency=1 end
        win.contentObjs = {}
        win.elemCache = {}
    end

    local function showTab(idx)
        clearTab()
        win.activeTab = idx
        for i, t in ipairs(win.tabs) do
            if t.btn then
                t.btn.Color = (i==idx) and C.Accent or C.Main2
            end
            if t.txt then
                t.txt.Color = (i==idx) and C.Text or C.Text2
            end
        end
        if win.tabs[idx] then
            win.tabs[idx]:render()
        end
    end

    function win:AddTab(name)
        local idx = #self.tabs + 1
        local bx = self.x + 6 + (idx-1)*96
        local btn = D("Square",{Size=Vector2.new(92,24),Position=Vector2.new(bx,self.y+29),Color=(idx==1) and C.Accent or C.Main2,Filled=true,Thickness=0,Transparency=0,ZIndex=103})
        local txt = D("Text",{Position=Vector2.new(bx+46,self.y+41),Text=name,Color=(idx==1) and C.Text or C.Text2,Size=13,Center=true,Outline=false,Transparency=0,ZIndex=104})
        local tab = {name=name, idx=idx, btn=btn, txt=txt, sections={}, objs={btn,txt}, rendered=false, scroll=0}
        self.tabs[idx] = tab

        function tab:AddSection(title, cols)
            local s = {title=title, cols=cols or 1, elements={}}
            table.insert(self.sections, s)
            return s
        end

        function tab:render()
            clearTab()
            local y = self.x + 8 + 4
            local _, h = self.w, self.h
            local startY = self.y + 62
            local maxH = h - 70

            for _, sec in ipairs(self.sections) do
                if sec.title and sec.title~="" then
                    local st = D("Text",{Position=Vector2.new(self.x+12,y-startY+self.scroll),Text=sec.title:upper(),Color=C.Accent,Size=11,Center=false,Outline=true,Transparency=0,ZIndex=110})
                    table.insert(self.contentObjs, st)
                    y = y + 16
                end

                local cw = (self.w - 28) / sec.cols
                for _, el in ipairs(sec.elements) do
                    local ey = y + self.scroll
                    el.y = ey

                    if el.t == "Toggle" then
                        local bg = D("Square",{Size=Vector2.new(cw-4,26),Position=Vector2.new(self.x+10,ey),Color=el.v and C.Accent or C.Main2,Filled=true,Thickness=0,Transparency=0,ZIndex=110})
                        local tx = D("Text",{Position=Vector2.new(self.x+18,ey+5),Text=el.label,Color=C.Text,Size=12,Center=false,Outline=false,Transparency=0,ZIndex=111})
                        local ind = D("Square",{Size=Vector2.new(8,8),Position=Vector2.new(bg.Position.X+cw-18,bg.Position.Y+9),Color=el.v and C.Green or C.Red,Filled=true,Thickness=0,Transparency=0,ZIndex=111})
                        el.bg, el.tx, el.ind = bg, tx, ind
                        table.insert(self.contentObjs, bg); table.insert(self.contentObjs, tx); table.insert(self.contentObjs, ind)
                        y = y + 28

                    elseif el.t == "Slider" then
                        local cw2 = cw-4
                        local bg = D("Square",{Size=Vector2.new(cw2,26),Position=Vector2.new(self.x+10,ey),Color=C.Main2,Filled=true,Thickness=0,Transparency=0,ZIndex=110})
                        local pct = (el.v-el.min)/(el.max-el.min)
                        local fill = D("Square",{Size=Vector2.new(cw2*pct,26),Position=bg.Position,Color=C.Accent,Filled=true,Thickness=0,Transparency=0.6,ZIndex=111})
                        local tx = D("Text",{Position=Vector2.new(bg.Position.X+cw2/2,bg.Position.Y+5),Text=el.label..": "..Round(el.v,el.dec or 0),Color=C.Text,Size=12,Center=true,Outline=false,Transparency=0,ZIndex=112})
                        el.bg, el.fill, el.tx = bg, fill, tx
                        el._cw = cw2
                        table.insert(self.contentObjs, bg); table.insert(self.contentObjs, fill); table.insert(self.contentObjs, tx)
                        y = y + 28

                    elseif el.t == "Dropdown" then
                        local cw2 = cw-4
                        local bg = D("Square",{Size=Vector2.new(cw2,26),Position=Vector2.new(self.x+10,ey),Color=C.Main2,Filled=true,Thickness=0,Transparency=0,ZIndex=110})
                        local tx = D("Text",{Position=Vector2.new(self.x+18,ey+5),Text=el.label..": "..el.v,Color=C.Text,Size=12,Center=false,Outline=false,Transparency=0,ZIndex=112})
                        local ar = D("Text",{Position=Vector2.new(bg.Position.X+cw2-14,bg.Position.Y+4),Text="v",Color=C.Text2,Size=14,Center=true,Outline=false,Transparency=0,ZIndex=112})
                        el.bg, el.tx, el.ar = bg, tx, ar
                        el._cw = cw2
                        table.insert(self.contentObjs, bg); table.insert(self.contentObjs, tx); table.insert(self.contentObjs, ar)
                        y = y + 28

                    elseif el.t == "Button" then
                        local cw2 = cw-4
                        local bg = D("Square",{Size=Vector2.new(cw2,26),Position=Vector2.new(self.x+10,ey),Color=C.Accent,Filled=true,Thickness=0,Transparency=0,ZIndex=110})
                        local tx = D("Text",{Position=Vector2.new(bg.Position.X+cw2/2,bg.Position.Y+5),Text=el.label,Color=C.Text,Size=13,Center=true,Outline=false,Transparency=0,ZIndex=112})
                        el.bg, el.tx = bg, tx
                        table.insert(self.contentObjs, bg); table.insert(self.contentObjs, tx)
                        y = y + 28

                    elseif el.t == "Color" then
                        local cw2 = cw-4
                        local bg = D("Square",{Size=Vector2.new(cw2,26),Position=Vector2.new(self.x+10,ey),Color=C.Main2,Filled=true,Thickness=0,Transparency=0,ZIndex=110})
                        local tx = D("Text",{Position=Vector2.new(self.x+18,ey+5),Text=el.label,Color=C.Text,Size=12,Center=false,Outline=false,Transparency=0,ZIndex=112})
                        local cb = D("Square",{Size=Vector2.new(14,14),Position=Vector2.new(bg.Position.X+cw2-20,bg.Position.Y+6),Color=el.v,Filled=true,Thickness=0,Transparency=0,ZIndex=111})
                        el.bg, el.tx, el.cb = bg, tx, cb
                        table.insert(self.contentObjs, bg); table.insert(self.contentObjs, tx); table.insert(self.contentObjs, cb)
                        y = y + 28

                    elseif el.t == "Label" then
                        local tx = D("Text",{Position=Vector2.new(self.x+14,ey),Text=el.text,Color=C.Text2,Size=12,Center=false,Outline=false,Transparency=0,ZIndex=110})
                        el.tx = tx
                        table.insert(self.contentObjs, tx)
                        y = y + 16
                    end
                end
            end
            self.maxScroll = math.max(0, y - startY + 6 - maxH)
            self.rendered = true
        end

        return tab
    end

    showTab(1)
    return win
end

--[[ FEATURES ]]

-- Silent Aim
local function SilentAim()
    local __idx
    __idx = hookmetamethod(game,"__index",function(s,k)
        if not checkcaller() and k=="Hit" and Opt.SilentAim.Enabled then
            local best, bestD = nil, math.huge
            local mp = Vector2.new(Mouse.X, Mouse.Y)
            for _,p in pairs(Targets()) do
                local r = GetRoot(p)
                if r then
                    local sp, on = Camera:WorldToViewportPoint(r.Position)
                    if on then
                        local d = (Vector2.new(sp.X,sp.Y)-mp).Magnitude
                        if d < Opt.SilentAim.FOV and d < bestD then
                            if Opt.SilentAim.VisibleOnly then
                                if not Vis(Camera.CFrame.Position, r.Position, {LP.Character,Camera}) then continue end
                            end
                            if Opt.SilentAim.WallCheck then
                                if not Vis(Camera.CFrame.Position, r.Position, {LP.Character,Camera}) then continue end
                            end
                            best, bestD = p, d
                        end
                    end
                end
            end
            if best and HC(Opt.SilentAim.HitChance) then
                local r = GetRoot(best)
                if r then return r.Position end
            end
        end
        return __idx(s,k)
    end)
end

-- Trigger Bot
local function TriggerBot()
    RunService.Heartbeat:Connect(function()
        if not Opt.TriggerBot.Enabled then return end
        local best, bestD = nil, 30
        local mp = Vector2.new(Mouse.X, Mouse.Y)
        for _,p in pairs(Targets()) do
            local r = GetRoot(p)
            if r then
                local sp, on = Camera:WorldToViewportPoint(r.Position)
                if on then
                    local d = (Vector2.new(sp.X,sp.Y)-mp).Magnitude
                    if d < bestD then best, bestD = p, d end
                end
            end
        end
        if best and HC(Opt.TriggerBot.HitChance) then
            task.wait(Opt.TriggerBot.Delay)
            mouse1click()
        end
    end)
end

-- Rage Bot
local function RageBot()
    RunService.Heartbeat:Connect(function()
        if not Opt.RageBot.Enabled then return end
        local best, bestD = nil, math.huge
        local cp = Camera.CFrame.Position
        for _,p in pairs(Targets()) do
            local r = GetRoot(p)
            if r then
                local d = (r.Position-cp).Magnitude
                if d < Opt.RageBot.MaxDist and d < bestD then
                    if Opt.RageBot.VizCheck then
                        if not Vis(cp, r.Position, {LP.Character,Camera}) then continue end
                    end
                    best, bestD = p, d
                end
            end
        end
        if best and HC(Opt.RageBot.HitChance) and Opt.RageBot.AutoShoot then
            local r = GetRoot(best)
            local hr = Opt.RageBot.Hitbox=="Head" and (best.Character:FindFirstChild("Head") or r)
                or Opt.RageBot.Hitbox=="Torso" and (best.Character:FindFirstChild("UpperTorso") or r)
                or r
            if hr then
                -- Weapon fire simulation
                local args = {[1] = hr.Position}
                LP.Character:FindFirstChildOfClass("Tool"):FindFirstChildOfClass("RemoteEvent"):FireServer(unpack(args))
            end
        end
    end)
end

-- Kill Aura
local function KillAura()
    RunService.Heartbeat:Connect(function()
        if not Opt.KillAura.Enabled then return end
        local cp = Camera.CFrame.Position
        for _,p in pairs(Targets()) do
            local r = GetRoot(p)
            if r and (r.Position-cp).Magnitude <= Opt.KillAura.Range and HC(Opt.KillAura.HitChance) then
                local hr = p.Character:FindFirstChild("Head") or r
                local args = {[1] = hr.Position}
                local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local re = tool:FindFirstChildOfClass("RemoteEvent") or tool:FindFirstChildOfClass("RemoteFunction")
                    if re then re:FireServer(unpack(args)) end
                end
            end
        end
    end)
end

-- Anti Aim
local function AntiAim()
    RunService.RenderStepped:Connect(function()
        if not Opt.AntiAim.Enabled then return end
        local c = LP.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        local p = Opt.AntiAim.Pitch
        local y = Opt.AntiAim.Yaw
        local pitch = p=="Down" and 90 or p=="Up" and -90 or p=="Zero" and 0 or p=="Jitter" and math.random(-80,80) or 0
        local yaw = y=="Spin" and (tick()*Opt.AntiAim.SpinSpeed%360) or y=="Back" and 180 or y=="Jitter" and (math.random(0,1)==0 and 0 or 180)+math.random(-20,20) or y=="Side" and 90 or 0
        if Opt.AntiAim.Jitter then pitch=pitch+math.random(-5,5) yaw=yaw+math.random(-5,5) end
        local neck = c:FindFirstChild("Neck",true)
        if neck and neck:IsA("Motor6D") then
            neck.C0 = CFrame.Angles(math.rad(pitch), math.rad(yaw), 0)
        end
    end)
end

--[[ ESP ]]
local ESPData = {}

local function MakeESP()
    for _,p in pairs(Players:GetPlayers()) do
        if p==LP then continue end
        if ESPData[p] then for _,o in pairs(ESPData[p]) do o:Remove() end end
        local objs = {}
        local box = D("Square",{Thickness=1,Filled=false,Color=Opt.ESP.BoxColor,Transparency=1,ZIndex=90})
        local outline = D("Square",{Thickness=3,Filled=false,Color=Color3.new(0,0,0),Transparency=1,ZIndex=89})
        local hbBG = D("Square",{Thickness=0,Filled=true,Color=Color3.fromRGB(30,30,30),Transparency=1,ZIndex=91})
        local hbFill = D("Square",{Thickness=0,Filled=true,Color=Color3.fromRGB(0,255,0),Transparency=1,ZIndex=92})
        local name = D("Text",{Size=13,Center=true,Outline=true,Color=C.Text,Transparency=1,ZIndex=92})
        local dist = D("Text",{Size=11,Center=true,Outline=true,Color=C.Text2,Transparency=1,ZIndex=92})
        local health = D("Text",{Size=11,Center=true,Outline=true,Color=C.Text2,Transparency=1,ZIndex=92})
        local tracer = D("Line",{Thickness=1.5,Color=Opt.ESP.BoxColor,Transparency=1,ZIndex=90})
        objs = {box,outline,hbBG,hbFill,name,dist,health,tracer}
        ESPData[p] = objs
    end
end

local function UpdateESP()
    if not Opt.ESP.Enabled then
        for _,obs in pairs(ESPData) do for _,o in pairs(obs) do o.Transparency=1 end end
        return
    end
    for p,obs in pairs(ESPData) do
        if not Alive(p) then for _,o in pairs(obs) do o.Transparency=1 end continue end
        local c = p.Character
        local r = c:FindFirstChild("HumanoidRootPart")
        local h = c:FindFirstChildOfClass("Humanoid")
        if not r or not h then for _,o in pairs(obs) do o.Transparency=1 end continue end
        local top, tz = W2S(r.Position+Vector3.new(0,3,0))
        local btm, bz = W2S(r.Position-Vector3.new(0,3,0))
        if tz<0 or bz<0 then for _,o in pairs(obs) do o.Transparency=1 end continue end
        local height = (top-btm).Magnitude
        local width = height*0.6
        local bp = Vector2.new(top.X-width/2, top.Y)
        local bs = Vector2.new(width, height)
        local bc = TeamMate(p) and C.Green or Opt.ESP.BoxColor
        local hp = math.clamp(h.Health/h.MaxHealth,0,1)
        local hc = Color3.fromRGB(math.floor(255*(1-hp)), math.floor(255*hp), 0)

        if Opt.ESP.Boxes then
            obs[1].Position=bp; obs[1].Size=bs; obs[1].Color=bc; obs[1].Transparency=0
            if Opt.ESP.Outline then obs[2].Position=bp; obs[2].Size=bs; obs[2].Transparency=0 else obs[2].Transparency=1 end
        else obs[1].Transparency=1; obs[2].Transparency=1 end

        if Opt.ESP.HealthBar then
            local hx = bp.X-6
            obs[3].Position=Vector2.new(hx,bp.Y); obs[3].Size=Vector2.new(4,bs.Y); obs[3].Transparency=0
            obs[4].Position=Vector2.new(hx,bp.Y+bs.Y*(1-hp)); obs[4].Size=Vector2.new(4,bs.Y*hp); obs[4].Color=hc; obs[4].Transparency=0
        else obs[3].Transparency=1; obs[4].Transparency=1 end

        if Opt.ESP.Name then obs[5].Position=Vector2.new(bp.X+bs.X/2,bp.Y-14); obs[5].Text=p.Name; obs[5].Transparency=0 else obs[5].Transparency=1 end
        if Opt.ESP.Distance then
            local d = math.floor((r.Position-Camera.CFrame.Position).Magnitude)
            obs[6].Position=Vector2.new(bp.X+bs.X/2,bp.Y+bs.Y+2); obs[6].Text=tostring(d).."m"; obs[6].Transparency=0
        else obs[6].Transparency=1 end
        if Opt.ESP.HealthText then
            obs[7].Position=Vector2.new(bp.X+bs.X/2,bp.Y+bs.Y+14); obs[7].Text=math.floor(h.Health).."/"..math.floor(h.MaxHealth); obs[7].Transparency=0
        else obs[7].Transparency=1 end
        if Opt.ESP.Tracer then
            local ox = Opt.ESP.TracerOrigin=="Bottom" and Camera.ViewportSize.Y or Camera.ViewportSize.Y/2
            obs[8].From=Vector2.new(Camera.ViewportSize.X/2,ox); obs[8].To=Vector2.new(bp.X+bs.X/2,bp.Y+bs.Y/2); obs[8].Color=bc; obs[8].Transparency=0
        else obs[8].Transparency=1 end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(MakeESP)
end)
Players.PlayerRemoving:Connect(function(p)
    if ESPData[p] then for _,o in pairs(ESPData[p]) do o:Remove() end ESPData[p]=nil end
end)

--[[ CROSSHAIR ]]
local CH = {}

local function MakeCH()
    for _,o in pairs(CH) do o:Remove() end
    CH = {
        D("Line",{Thickness=Opt.Crosshair.T,Color=Opt.Crosshair.Color,Transparency=1,ZIndex=200}),
        D("Line",{Thickness=Opt.Crosshair.T,Color=Opt.Crosshair.Color,Transparency=1,ZIndex=200}),
        D("Line",{Thickness=Opt.Crosshair.T,Color=Opt.Crosshair.Color,Transparency=1,ZIndex=200}),
        D("Line",{Thickness=Opt.Crosshair.T,Color=Opt.Crosshair.Color,Transparency=1,ZIndex=200}),
        D("Square",{Size=Vector2.new(3,3),Filled=true,Color=Opt.Crosshair.Color,Transparency=1,ZIndex=200}),
        D("Line",{Thickness=Opt.Crosshair.T+2,Color=Color3.new(0,0,0),Transparency=1,ZIndex=199}),
        D("Line",{Thickness=Opt.Crosshair.T+2,Color=Color3.new(0,0,0),Transparency=1,ZIndex=199}),
        D("Line",{Thickness=Opt.Crosshair.T+2,Color=Color3.new(0,0,0),Transparency=1,ZIndex=199}),
        D("Line",{Thickness=Opt.Crosshair.T+2,Color=Color3.new(0,0,0),Transparency=1,ZIndex=199}),
    }
end

local function UpdateCH()
    if not Opt.Crosshair.Enabled then for _,o in pairs(CH) do o.Transparency=1 end return end
    local cx,cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    local g,s,t = Opt.Crosshair.Gap, Opt.Crosshair.Size, Opt.Crosshair.T
    if Opt.Crosshair.Outline then
        local o=1
        CH[6].From=Vector2.new(cx,cy-g-s-o); CH[6].To=Vector2.new(cx,cy-g+o); CH[6].Transparency=0
        CH[7].From=Vector2.new(cx,cy+g-o); CH[7].To=Vector2.new(cx,cy+g+s+o); CH[7].Transparency=0
        CH[8].From=Vector2.new(cx-g-s-o,cy); CH[8].To=Vector2.new(cx-g+o,cy); CH[8].Transparency=0
        CH[9].From=Vector2.new(cx+g-o,cy); CH[9].To=Vector2.new(cx+g+s+o,cy); CH[9].Transparency=0
    else for i=6,9 do CH[i].Transparency=1 end end
    CH[1].From=Vector2.new(cx,cy-g); CH[1].To=Vector2.new(cx,cy-g-s); CH[1].Transparency=0
    CH[2].From=Vector2.new(cx,cy+g); CH[2].To=Vector2.new(cx,cy+g+s); CH[2].Transparency=0
    CH[3].From=Vector2.new(cx-g,cy); CH[3].To=Vector2.new(cx-g-s,cy); CH[3].Transparency=0
    CH[4].From=Vector2.new(cx+g,cy); CH[4].To=Vector2.new(cx+g+s,cy); CH[4].Transparency=0
    if Opt.Crosshair.Dot then CH[5].Position=Vector2.new(cx-1.5,cy-1.5); CH[5].Transparency=0 else CH[5].Transparency=1 end
end

--[[ CONFIG ]]
local function SaveCfg(n)
    local d = HttpService:JSONEncode(Opt)
    writefile("CB_"..n..".json", d)
end

local function LoadCfg(n)
    local p = "CB_"..n..".json"
    if isfile(p) then
        local d = HttpService:JSONDecode(readfile(p))
        for k,v in pairs(d) do if Opt[k]~=nil then Opt[k]=v end end
        return true
    end
    return false
end

local function ListCfgs()
    local f = listfiles()
    local r = {}
    for _,v in pairs(f) do
        local n = v:match("CB_(.+)%.json")
        if n then r[#r+1]=n end
    end
    return r
end

--[[ WATERMARK ]]
local WM = D("Text",{Position=Vector2.new(8,6),Text="CounterBlox Reloaded v2.0",Color=Color3.fromRGB(0,170,255),Size=13,Center=false,Outline=true,Transparency=1,ZIndex=999})

--[[ BUILD MENU ]]
local function BuildMenu()
    local w = UI:Window("CounterBlox Reloaded v2.0", 620, 450)

    -- LEGIT
    local legit = w:AddTab("Legit")

    local aim = legit:AddSection("Aim Assist", 2)
    table.insert(aim.elements, {t="Toggle",label="Silent Aim",v=Opt.SilentAim.Enabled,set=function(v) Opt.SilentAim.Enabled=v end})
    table.insert(aim.elements, {t="Slider",label="FOV",v=Opt.SilentAim.FOV,min=1,max=180,dec=0,set=function(v) Opt.SilentAim.FOV=v end})
    table.insert(aim.elements, {t="Slider",label="Hit Chance",v=Opt.SilentAim.HitChance,min=1,max=100,dec=0,set=function(v) Opt.SilentAim.HitChance=v end})
    table.insert(aim.elements, {t="Dropdown",label="Priority",v=Opt.SilentAim.Priority,items={"Closest","Mouse","LowestHP"},set=function(v) Opt.SilentAim.Priority=v end})
    table.insert(aim.elements, {t="Toggle",label="Ignore Team",v=Opt.SilentAim.IgnoreTeam,set=function(v) Opt.SilentAim.IgnoreTeam=v end})
    table.insert(aim.elements, {t="Toggle",label="Wall Check",v=Opt.SilentAim.WallCheck,set=function(v) Opt.SilentAim.WallCheck=v end})
    table.insert(aim.elements, {t="Toggle",label="Visible Only",v=Opt.SilentAim.VisibleOnly,set=function(v) Opt.SilentAim.VisibleOnly=v end})

    local trig = legit:AddSection("Trigger Bot", 2)
    table.insert(trig.elements, {t="Toggle",label="Trigger Bot",v=Opt.TriggerBot.Enabled,set=function(v) Opt.TriggerBot.Enabled=v end})
    table.insert(trig.elements, {t="Slider",label="Delay (s)",v=Opt.TriggerBot.Delay,min=0,max=0.5,dec=2,set=function(v) Opt.TriggerBot.Delay=v end})
    table.insert(trig.elements, {t="Slider",label="Hit Chance",v=Opt.TriggerBot.HitChance,min=1,max=100,dec=0,set=function(v) Opt.TriggerBot.HitChance=v end})

    local vis = legit:AddSection("Visuals", 2)
    table.insert(vis.elements, {t="Toggle",label="ESP",v=Opt.ESP.Enabled,set=function(v) Opt.ESP.Enabled=v end})
    table.insert(vis.elements, {t="Toggle",label="Boxes",v=Opt.ESP.Boxes,set=function(v) Opt.ESP.Boxes=v end})
    table.insert(vis.elements, {t="Color",label="Box Color",v=Opt.ESP.BoxColor,set=function(v) Opt.ESP.BoxColor=v end})
    table.insert(vis.elements, {t="Toggle",label="Box Outline",v=Opt.ESP.Outline,set=function(v) Opt.ESP.Outline=v end})
    table.insert(vis.elements, {t="Toggle",label="Health Bar",v=Opt.ESP.HealthBar,set=function(v) Opt.ESP.HealthBar=v end})
    table.insert(vis.elements, {t="Toggle",label="Health Text",v=Opt.ESP.HealthText,set=function(v) Opt.ESP.HealthText=v end})
    table.insert(vis.elements, {t="Toggle",label="Name",v=Opt.ESP.Name,set=function(v) Opt.ESP.Name=v end})
    table.insert(vis.elements, {t="Toggle",label="Distance",v=Opt.ESP.Distance,set=function(v) Opt.ESP.Distance=v end})
    table.insert(vis.elements, {t="Toggle",label="Tracer",v=Opt.ESP.Tracer,set=function(v) Opt.ESP.Tracer=v end})
    table.insert(vis.elements, {t="Dropdown",label="Tracer Origin",v=Opt.ESP.TracerOrigin,items={"Bottom","Middle"},set=function(v) Opt.ESP.TracerOrigin=v end})

    local ch = legit:AddSection("Crosshair", 2)
    table.insert(ch.elements, {t="Toggle",label="Crosshair",v=Opt.Crosshair.Enabled,set=function(v) Opt.Crosshair.Enabled=v end})
    table.insert(ch.elements, {t="Color",label="Color",v=Opt.Crosshair.Color,set=function(v) Opt.Crosshair.Color=v end})
    table.insert(ch.elements, {t="Slider",label="Size",v=Opt.Crosshair.Size,min=2,max=30,dec=0,set=function(v) Opt.Crosshair.Size=v end})
    table.insert(ch.elements, {t="Slider",label="Gap",v=Opt.Crosshair.Gap,min=1,max=15,dec=0,set=function(v) Opt.Crosshair.Gap=v end})
    table.insert(ch.elements, {t="Toggle",label="Dot",v=Opt.Crosshair.Dot,set=function(v) Opt.Crosshair.Dot=v end})
    table.insert(ch.elements, {t="Toggle",label="Outline",v=Opt.Crosshair.Outline,set=function(v) Opt.Crosshair.Outline=v end})

    -- RAGE
    local rage = w:AddTab("Rage")

    local rb = rage:AddSection("Rage Bot", 2)
    table.insert(rb.elements, {t="Toggle",label="Rage Bot",v=Opt.RageBot.Enabled,set=function(v) Opt.RageBot.Enabled=v end})
    table.insert(rb.elements, {t="Slider",label="Hit Chance",v=Opt.RageBot.HitChance,min=1,max=100,dec=0,set=function(v) Opt.RageBot.HitChance=v end})
    table.insert(rb.elements, {t="Dropdown",label="Target",v=Opt.RageBot.TargetMode,items={"Closest","LowestHP","HighestHP"},set=function(v) Opt.RageBot.TargetMode=v end})
    table.insert(rb.elements, {t="Dropdown",label="Hitbox",v=Opt.RageBot.Hitbox,items={"Head","Torso","Random"},set=function(v) Opt.RageBot.Hitbox=v end})
    table.insert(rb.elements, {t="Toggle",label="Auto Shoot",v=Opt.RageBot.AutoShoot,set=function(v) Opt.RageBot.AutoShoot=v end})
    table.insert(rb.elements, {t="Toggle",label="Visibility Check",v=Opt.RageBot.VizCheck,set=function(v) Opt.RageBot.VizCheck=v end})
    table.insert(rb.elements, {t="Slider",label="Max Distance",v=Opt.RageBot.MaxDist,min=100,max=10000,dec=0,set=function(v) Opt.RageBot.MaxDist=v end})

    local ka = rage:AddSection("Kill Aura", 2)
    table.insert(ka.elements, {t="Toggle",label="Kill Aura",v=Opt.KillAura.Enabled,set=function(v) Opt.KillAura.Enabled=v end})
    table.insert(ka.elements, {t="Slider",label="Range",v=Opt.KillAura.Range,min=5,max=100,dec=0,set=function(v) Opt.KillAura.Range=v end})
    table.insert(ka.elements, {t="Slider",label="Hit Chance",v=Opt.KillAura.HitChance,min=1,max=100,dec=0,set=function(v) Opt.KillAura.HitChance=v end})
    table.insert(ka.elements, {t="Dropdown",label="Target",v=Opt.KillAura.TargetMode,items={"Closest","Random"},set=function(v) Opt.KillAura.TargetMode=v end})
    table.insert(ka.elements, {t="Slider",label="Delay (s)",v=Opt.KillAura.Delay,min=0,max=1,dec=2,set=function(v) Opt.KillAura.Delay=v end})

    local aa = rage:AddSection("Anti Aim", 2)
    table.insert(aa.elements, {t="Toggle",label="Anti Aim",v=Opt.AntiAim.Enabled,set=function(v) Opt.AntiAim.Enabled=v end})
    table.insert(aa.elements, {t="Dropdown",label="Pitch",v=Opt.AntiAim.Pitch,items={"Down","Up","Zero","Jitter"},set=function(v) Opt.AntiAim.Pitch=v end})
    table.insert(aa.elements, {t="Dropdown",label="Yaw",v=Opt.AntiAim.Yaw,items={"Spin","Back","Jitter","Side"},set=function(v) Opt.AntiAim.Yaw=v end})
    table.insert(aa.elements, {t="Slider",label="Spin Speed",v=Opt.AntiAim.SpinSpeed,min=1,max=100,dec=0,set=function(v) Opt.AntiAim.SpinSpeed=v end})
    table.insert(aa.elements, {t="Toggle",label="Jitter",v=Opt.AntiAim.Jitter,set=function(v) Opt.AntiAim.Jitter=v end})

    -- SETTINGS
    local set = w:AddTab("Settings")

    local uis = set:AddSection("UI", 2)
    table.insert(uis.elements, {t="Toggle",label="Watermark",v=Opt.Watermark,set=function(v) Opt.Watermark=v end})
    table.insert(uis.elements, {t="Label",text="Menu Key: RightShift"})

    local cfg = set:AddSection("Config", 2)
    table.insert(cfg.elements, {t="Button",label="Save Config",cb=function() SaveCfg("config") end})
    table.insert(cfg.elements, {t="Button",label="Load Config",cb=function() LoadCfg("config") end})

    -- THEMES
    local thm = w:AddTab("Themes")
    local ths = thm:AddSection("Theme Presets", 2)
    for name,_ in pairs(Themes) do
        table.insert(ths.elements, {t="Button",label=name,cb=function()
            C = Themes[name]
            Opt.Theme = name
            w.bg.Color = C.Main
            w.brd.Color = C.Accent
            w.tbar.Color = C.Main2
            w.ttxt.Color = C.Accent
            w.cltxt.Color = C.Red
            w.tabBar.Color = C.BG
            w.cbg.Color = C.Main
            for i,t in ipairs(w.tabs) do
                t.btn.Color = (i==w.activeTab) and C.Accent or C.Main2
                t.txt.Color = (i==w.activeTab) and C.Text or C.Text2
            end
            if w.activeTab and w.tabs[w.activeTab] then
                w.tabs[w.activeTab]:render()
            end
        end})
    end

    -- CONFIG TAB
    local cft = w:AddTab("Config")
    local cfs = cft:AddSection("Config Manager", 1)
    table.insert(cfs.elements, {t="Button",label="Save Current",cb=function() SaveCfg("config") end})
    table.insert(cfs.elements, {t="Button",label="Refresh List",cb=function()
        local cfgs = ListCfgs()
        -- re-render config list
    end})

    return w
end

--[[ INPUT / INTERACTION ]]

local window = BuildMenu()
MakeESP()
MakeCH()

-- Re-render on tab click
UIS.InputBegan:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mp = Vector2.new(Mouse.X, Mouse.Y)
        if not Opt.MenuOpen then return end
        local w = window

        -- Close button
        if mp.X >= w.close.Position.X and mp.X <= w.close.Position.X+22 and mp.Y >= w.close.Position.Y and mp.Y <= w.close.Position.Y+22 then
            Opt.MenuOpen = false
            return
        end

        -- Tab buttons
        for i, t in ipairs(w.tabs) do
            local bx, by = t.btn.Position.X, t.btn.Position.Y
            if mp.X >= bx and mp.X <= bx+92 and mp.Y >= by and mp.Y <= by+24 then
                -- Switch tab
                if w.activeTab and w.tabs[w.activeTab] then
                    for _,o in pairs(w.tabs[w.activeTab].objs) do o.Transparency=1 end
                end
                for _,o in pairs(w.contentObjs) do o.Transparency=1 end
                w.contentObjs = {}
                w.elemCache = {}

                w.activeTab = i
                for j, t2 in ipairs(w.tabs) do
                    t2.btn.Color = (j==i) and C.Accent or C.Main2
                    t2.txt.Color = (j==i) and C.Text or C.Text2
                end
                w.tabs[i]:render()
                return
            end
        end

        -- Drag title bar
        if mp.Y >= w.y and mp.Y <= w.y+26 and mp.X >= w.x and mp.X <= w.x+w.w then
            w.drag = true
            w.dragOffX = mp.X - w.x
            w.dragOffY = mp.Y - w.y
            return
        end

        -- Element clicks
        if w.activeTab and w.tabs[w.activeTab] then
            local tab = w.tabs[w.activeTab]
            local cx = w.x + 8
            local startY = w.y + 62

            for _, sec in ipairs(tab.sections) do
                local cw = (w.w - 28) / (sec.cols or 1)
                for _, el in ipairs(sec.elements) do
                    local ey = el.y
                    if not ey then continue end

                    if el.t == "Toggle" and el.bg then
                        local bg = el.bg
                        if mp.X >= bg.Position.X and mp.X <= bg.Position.X+cw-4 and mp.Y >= bg.Position.Y and mp.Y <= bg.Position.Y+26 then
                            el.v = not el.v
                            el.bg.Color = el.v and C.Accent or C.Main2
                            el.ind.Color = el.v and C.Green or C.Red
                            if el.set then el.set(el.v) end
                            return
                        end

                    elseif el.t == "Slider" and el.bg then
                        local bg = el.bg
                        if mp.X >= bg.Position.X and mp.X <= bg.Position.X+el._cw and mp.Y >= bg.Position.Y and mp.Y <= bg.Position.Y+26 then
                            local pct = math.clamp((mp.X - bg.Position.X) / el._cw, 0, 1)
                            el.v = el.min + pct * (el.max - el.min)
                            if el.dec and el.dec > 0 then
                                el.v = Round(el.v, el.dec)
                            else
                                el.v = math.floor(el.v)
                            end
                            el.fill.Size = Vector2.new(el._cw * pct, 26)
                            el.tx.Text = el.label..": "..Round(el.v, el.dec or 0)
                            if el.set then el.set(el.v) end
                            return
                        end

                    elseif el.t == "Dropdown" and el.bg then
                        local bg = el.bg
                        if mp.X >= bg.Position.X and mp.X <= bg.Position.X+el._cw and mp.Y >= bg.Position.Y and mp.Y <= bg.Position.Y+26 then
                            local idx = 1
                            for i, item in ipairs(el.items) do
                                if item == el.v then idx = i; break end
                            end
                            idx = (idx % #el.items) + 1
                            el.v = el.items[idx]
                            el.tx.Text = el.label..": "..el.v
                            if el.set then el.set(el.v) end
                            return
                        end

                    elseif el.t == "Button" and el.bg then
                        local bg = el.bg
                        if mp.X >= bg.Position.X and mp.X <= bg.Position.X+cw-4 and mp.Y >= bg.Position.Y and mp.Y <= bg.Position.Y+26 then
                            if el.cb then el.cb() end
                            return
                        end

                    elseif el.t == "Color" and el.bg then
                        local bg = el.bg
                        if mp.X >= bg.Position.X and mp.X <= bg.Position.X+cw-4 and mp.Y >= bg.Position.Y and mp.Y <= bg.Position.Y+26 then
                            local r = math.random(0,255)
                            local g = math.random(0,255)
                            local b = math.random(0,255)
                            el.v = Color3.fromRGB(r,g,b)
                            el.cb.Color = el.v
                            if el.set then el.set(el.v) end
                            return
                        end
                    end
                end
            end
        end

    elseif input.UserInputType == Enum.UserInputType.MouseMovement then
        if window and window.drag then
            local mp = Vector2.new(Mouse.X, Mouse.Y)
            local dx = mp.X - window.dragOffX
            local dy = mp.Y - window.dragOffY
            local ox, oy = window.x, window.y
            window.x, window.y = dx, dy
            local offX, offY = dx-ox, dy-oy

            -- Move all window drawings
            local function mv(d, xo, yo)
                if not d then return end
                d.Position = d.Position + Vector2.new(xo, yo)
            end
            mv(window.bg, offX, offY)
            mv(window.brd, offX, offY)
            mv(window.tbar, offX, offY)
            mv(window.ttxt, offX, offY)
            mv(window.close, offX, offY)
            mv(window.cltxt, offX, offY)
            mv(window.tabBar, offX, offY)
            mv(window.cbg, offX, offY)

            for _, t in ipairs(window.tabs) do
                if t.btn then mv(t.btn, offX, offY) end
                if t.txt then mv(t.txt, offX, offY) end
            end

            -- Move rendered content objects
            for _, o in pairs(window.contentObjs) do
                mv(o, offX, offY)
            end
        end

    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        if window then window.drag = false end
    end

    -- Menu key toggle
    if not gpe and input.KeyCode == Opt.MenuKey then
        Opt.MenuOpen = not Opt.MenuOpen
    end
end)

-- Input ended (drag release)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if window then window.drag = false end
    end
end)

--[[ MAIN RENDER LOOP ]]

RunService.RenderStepped:Connect(function(dt)
    UpdateESP()
    UpdateCH()

    -- Window visibility
    local v = Opt.MenuOpen and 1 or 0
    local w = window
    local function sv(d) if d then d.Transparency = 1 - v end end
    sv(w.bg); sv(w.brd); sv(w.tbar); sv(w.ttxt); sv(w.close); sv(w.cltxt); sv(w.tabBar); sv(w.cbg)
    for _, t in ipairs(w.tabs) do sv(t.btn); sv(t.txt) end
    for _, o in pairs(w.contentObjs) do sv(o) end

    -- Watermark
    WM.Transparency = (Opt.Watermark and Opt.MenuOpen) and 0 or 1
end)

-- Start features
SilentAim()
TriggerBot()
RageBot()
KillAura()
AntiAim()

-- Init ESP for all players
MakeESP()
for _,p in pairs(Players:GetPlayers()) do
    if p~=LP then
        p.CharacterAdded:Connect(MakeESP)
    end
end

-- Notification
print("CounterBlox Reloaded v2.0 loaded! Press RightShift to open menu.")
