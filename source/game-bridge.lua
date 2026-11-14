local Native = assert(loadstring(game:HttpGet("https://raw.githubusercontent.com/lofaif1234/axisui/041cf38/source/library.lua"), "Axis UI"))()
Native.FontSize = 14
Native.WeaponPreview = function(window, params)
    local input = game:GetService("UserInputService")
    local function part(class, parent, properties)
        local object = Instance.new(class)
        for key,value in pairs(properties) do object[key] = value end
        object.Parent = parent
        return object
    end
    local frame = part("Frame", Native.Holder.Instance, {Size=UDim2.fromOffset(380,320),BackgroundColor3=Native.Theme.Background,BorderSizePixel=0,Visible=false})
    part("UICorner",frame,{CornerRadius=UDim.new(0,6)})
    local top = part("Frame",frame,{Size=UDim2.new(1,0,0,32),BackgroundColor3=Native.Theme["Section Top"],BorderSizePixel=0})
    part("TextLabel",top,{Text=params.Name,FontFace=Native.Font,TextSize=14,TextColor3=Native.Theme.Text,BackgroundTransparency=1,Size=UDim2.new(1,-40,1,0)})
    local bottom = part("Frame",frame,{Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,1,-32),BackgroundColor3=Native.Theme["Section Top"],BorderSizePixel=0})
    local viewport = part("ViewportFrame",frame,{Size=UDim2.new(1,-12,1,-76),Position=UDim2.fromOffset(6,38),BackgroundTransparency=1,Ambient=Color3.new(1,1,1),LightColor=Color3.new(1,1,1)})
    local camera = part("Camera",viewport,{FieldOfView=40})
    viewport.CurrentCamera=camera
    local view={Viewport=viewport,Camera=camera,Items={Top={Instance=top},Bottom={Instance=bottom}}}
    local holder={Instance=frame}
    function holder:ConvertAnchor() frame.AnchorPoint=Vector2.zero end
    function holder:MakeDraggable()
        local start,position,drag
        Native:Connect(top.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then start=i.Position position=frame.Position drag=true end end)
        Native:Connect(input.InputChanged,function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-start frame.Position=position+UDim2.fromOffset(d.X,d.Y) end end)
        Native:Connect(input.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    end
    view.Items.ESPPreview=holder
    function view:SetVisibility(value) frame.Visible=value end
    function view:SetModel(model)
        if self.Player then self.Player:Destroy() end
        self.Player=model:Clone()
        for _,item in ipairs(self.Player:GetDescendants()) do if item:IsA("BasePart") then item.Anchored=true item.CanCollide=false end end
        self.Player.Parent=viewport
        self.Player:PivotTo(CFrame.new())
        local cf,size=self.Player:GetBoundingBox()
        local distance=math.max(size.X,size.Y,size.Z)*1.8
        camera.CFrame=CFrame.lookAt(cf.Position+Vector3.new(distance*.6,distance*.25,distance),cf.Position)
    end
    table.insert(Native.ToClean,frame)
    return view
end
local env = getgenv()
env.Toggles, env.Options = {}, {}
local Bridge = {ScreenGui = Native.Holder.Instance, KeybindFrame = {Visible = false}, Native = Native}
local Labels = {
    ["Rapid fire (client)"] = "Rapid fire",
    ["Fire-rate multiplier"] = "Fire rate",
    ["Automatic semi-auto"] = "Full auto",
    ["Automatic reload"] = "Auto reload",
    ["Weapon actions"] = "Firing",
    ["Target handling"] = "Checks",
    ["Visible body fallback"] = "Find visible hitbox",
    ["Skip protected players"] = "Ignore protected players",
    ["Custom third person"] = "Third person",
    ["Local speed boost"] = "Speed boost",
    ["Activation key"] = "Key",
    ["Bunny hop activation"] = "Bunny hop",
    ["Camlock activation"] = "Camlock",
    ["Weapon offset"] = "Viewmodel",
    ["Response"] = "Speed",
    ["2D boxes"] = "Boxes",
    ["Distance labels"] = "Distance",
    ["Draw FOV"] = "Show FOV",
    ["Target tracer"] = "Target line",
    ["Chams material"] = "Material",
    ["Chams transparency"] = "Transparency",
    ["Render distance"] = "Max distance",
    ["Open 3D preview"] = "Open preview",
    ["Range (studs)"] = "Range",
    ["Hit chance (%)"] = "Hit chance",
}
local function label(text) return Labels[text] or text end
local unloadCallback, closing
function Bridge:OnUnload(fn) unloadCallback = fn end
local nativeExit = Native.Unload
function Native:Unload()
    if closing then return end
    closing = true
    if unloadCallback then pcall(unloadCallback) end
    nativeExit(self)
end
function Bridge:Unload() Native:Unload() end
function Bridge:SetWatermarkVisibility() end
local function option(id, value, native, kind)
    local o = {Value = value, Native = native, Changed = {}}
    function o:OnChanged(fn) table.insert(self.Changed, fn) end
    function o:Emit(v)
        self.Value = v
        for _, fn in ipairs(self.Changed) do fn(v) end
    end
    function o:SetValue(v) setthreadidentity(8) self.Native:Set(v) setthreadidentity(8) end
    function o:SetValues(v) self.Native:Refresh(v) end
    function o:SetText(v) self.Native:SetText(v) end
    env[kind == "toggle" and "Toggles" or "Options"][id] = o
    return o
end
local wrap
wrap = function(native, section)
    section = section or native
    local group = {Native = native}
    function group:SetText(text) self.Native:SetText(text) end
    function group:AddToggle(id, data)
        local o
        local n = self.Native:Toggle({Name = label(data.Text), Flag = id, Default = data.Default,
            Callback = function(v) if o then o:Emit(v) end end})
        o = option(id, data.Default, n, "toggle")
        return setmetatable(o, {__index = wrap(n, section)})
    end
    function group:AddSlider(id, data)
        local o
        local n = self.Native:Slider({Name = label(data.Text), Flag = id, Default = data.Default,
            Min = data.Min, Max = data.Max, Decimals = 10 ^ -(data.Rounding or 0),
            Callback = function(v) if o then o:Emit(v) end end})
        o = option(id, data.Default, n)
        return o
    end
    function group:AddDropdown(id, data)
        local o
        local n = self.Native:Dropdown({Name = label(data.Text), Flag = id, Default = data.Default,
            Items = data.Values, Callback = function(v) if o then o:Emit(v) end end})
        o = option(id, data.Default, n)
        return o
    end
    function group:AddLabel(text) return wrap(self.Native:Label(label(text)), section) end
    function group:AddButton(data) return self.Native:Button({Name = label(data.Text), Callback = data.Func}) end
    function group:AddColorPicker(id, data)
        local o
        local n = self.Native:Colorpicker({Flag = id, Default = data.Default, Alpha = 1,
            Callback = function(v) if o then o:Emit(v) end end})
        o = option(id, data.Default, n)
        return o
    end
    function group:AddKeyPicker(id, data)
        local aliases = {MB1 = Enum.UserInputType.MouseButton1, MB2 = Enum.UserInputType.MouseButton2, None = Enum.KeyCode.Backspace}
        local key = aliases[data.Default] or Enum.KeyCode[data.Default] or Enum.KeyCode.Backspace
        local o = {Value = data.Default, Toggled = false, Changed = {}, Clicked = {}}
        local n = section:Keybind({Name = label(data.Text), Flag = id, Default = key, Mode = data.Mode,
            Callback = function(v)
                o.Toggled = v
                if o.Native then
                    local value = o.Native.Value
                    if value == "MouseButton1" then value = "MB1" elseif value == "MouseButton2" then value = "MB2" end
                    if value and o.Value ~= value then
                        o.Value = value
                        for _, fn in ipairs(o.Changed) do fn(value) end
                    end
                    if id == "UR_MenuKey" then Native.MenuKeybind = o.Native.Key end
                end
                for _, fn in ipairs(o.Clicked) do fn(v) end
            end})
        o.Native = n
        function o:OnChanged(fn) table.insert(self.Changed, fn) end
        function o:OnClick(fn) table.insert(self.Clicked, fn) end
        function o:GetState() return self.Native.Toggled end
        function o:SetValue(v) self.Native:Set(aliases[v] or Enum.KeyCode[v] or v) end
        env.Options[id] = o
        return o
    end
    return group
end
function Bridge:CreateWindow()
    Native.MenuKeybind = tostring(Enum.KeyCode.RightShift)
    local path = Native.Folders.Assets .. "/axis-logo.png"
    if not isfile(path) then writefile(path, game:HttpGet("https://raw.githubusercontent.com/lofaif1234/axisui/main/assets/axis-logo.png")) end
    local window = Native:Window({Name = "", SubName = "", Logo = getcustomasset(path), Wordmark = true})
    local out = {Native = window, Holder = window.Items.MainFrame.Instance}
    function out:AddTab(name)
        local icons = {
            Combat = "rbxassetid://134242818164054",
            Visuals = "rbxassetid://100033680381365",
            Utility = "rbxassetid://112148279212860",
            Settings = "rbxassetid://80758916183665",
        }
        local page = window:Page({Name = name, Icon = (icons[name] or "100050851789190"):gsub("rbxassetid://", "")})
        local p = {Native = page}
        function p:AddLeftGroupbox(title) return wrap(page:Section({Name = label(title), Side = 1})) end
        function p:AddRightGroupbox(title) return wrap(page:Section({Name = label(title), Side = 2})) end
        function p:AddLeftTabbox()
            return {AddTab = function(_, title) return wrap(page:Section({Name = label(title), Side = 1})) end}
        end
        return p
    end
    Bridge.Window = out
    return out
end
function Bridge:Finish(S)
    Native:CreateSettingsPage(self.Window.Native)
    local settings = self.Window.Native.Pages[#self.Window.Native.Pages]
    if settings then
        local session = settings:Section({Name = "Session", Side = 2})
        session:Button({Name = "Disable all features", Callback = S.DisableAll})
    end
    for _, control in pairs(env.Toggles) do control:SetValue(false) end
    if S.Config then S.Config.ThroughWalls = true end
    self.Window.Native:Init()
end
return Bridge
