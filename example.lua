local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/lofaif1234/axisui/main/source/library.lua"), "Axis UI")()
local environment = getgenv()
local previous = environment.NeverloseUIDemo
if previous and previous.Library then
    pcall(function() previous.Library:Unload() end)
end

Library.Folders = {
    Directory = "axisclub-ui",
    Configs = "axisclub-ui/Configs",
    Assets = "axisclub-ui/Assets",
}
Library.MenuKeybind = tostring(Enum.KeyCode.RightShift)
local wordmarkPath = Library.Folders.Assets .. "/axis-logo.png"
if not isfolder(Library.Folders.Directory) then makefolder(Library.Folders.Directory) end
if not isfolder(Library.Folders.Assets) then makefolder(Library.Folders.Assets) end
if not isfile(wordmarkPath) then
    writefile(wordmarkPath, game:HttpGet("https://raw.githubusercontent.com/lofaif1234/axisui/main/assets/axis-logo.png"))
end
local wordmark = getcustomasset(wordmarkPath)
local Window = Library:Window({
    Name = "",
    SubName = "",
    Logo = wordmark,
    Wordmark = true,
})
local events = {}
local status
local function record(name, value)
    local text = if typeof(value) == "Color3" then "#" .. value:ToHex()
        elseif type(value) == "table" then table.concat(value, ", ")
        else tostring(value)
    table.insert(events, 1, name .. ": " .. text)
    if #events > 40 then table.remove(events) end
    if status then status:SetText(events[1]) end
end
local function callback(name)
    return function(value) record(name, value) end
end

Window:Category("Components")
local Controls = Window:Page({Name = "Controls", Icon = "100050851789190"})
local Main = Controls:Section({Name = "Basic controls", Side = 1})
local Toggle = Main:Toggle({Name = "Checkbox", Flag = "DemoToggle", Default = false, Callback = callback("Checkbox")})
local Slider = Main:Slider({Name = "Amount", Flag = "DemoAmount", Min = 0, Max = 100, Default = 50, Decimals = 1, Suffix = "%", Callback = callback("Slider")})
Main:Slider({Name = "Decimal", Flag = "DemoDecimal", Min = 0, Max = 1, Default = 0.5, Decimals = 0.05, Callback = callback("Decimal")})
local Dropdown = Main:Dropdown({Name = "Single choice", Flag = "DemoChoice", Items = {"First", "Second", "Third"}, Default = "First", Callback = callback("Dropdown")})
Main:Dropdown({Name = "Multiple choices", Flag = "DemoMulti", Items = {"Alpha", "Beta", "Gamma"}, Default = {"Alpha"}, Multi = true, Callback = callback("Multiselect")})
Main:Textbox({Name = "Text", Flag = "DemoText", Placeholder = "Type something", Default = "Hello", Finished = true, Callback = callback("Text")})

local Extra = Controls:Section({Name = "Colors and keys", Side = 2})
Extra:Label("Color and opacity"):Colorpicker({Flag = "DemoColor", Default = Color3.fromRGB(65, 155, 255), Alpha = 1, Callback = function(color, alpha) record("Color", color); record("Opacity", alpha) end})
Extra:Keybind({Name = "Test shortcut", Flag = "DemoKey", Default = Enum.KeyCode.K, Mode = "Toggle", Callback = callback("Shortcut")})
local Nested = Extra:Toggle({Name = "Nested options", Flag = "DemoNested", Default = false, Callback = callback("Nested checkbox")})
Nested:Colorpicker({Flag = "DemoNestedColor", Default = Color3.new(1, 1, 1), Callback = callback("Attached color")})
local More = Nested:Settings(UDim2.fromOffset(260, 160))
More:Slider({Name = "Nested amount", Flag = "DemoNestedAmount", Min = 0, Max = 10, Default = 5, Callback = callback("Nested slider")})
More:Dropdown({Name = "Nested choice", Flag = "DemoNestedChoice", Items = {"One", "Two"}, Default = "One", Callback = callback("Nested dropdown")})
Extra:Button({Name = "Test notification", Callback = function()
    record("Button", "clicked")
    Library:Notification({Title = "UI test", Description = "The button callback works.", Duration = 3, Icon = "73789337996373"})
end})
Extra:Button({Name = "Reset demo values", Callback = function()
    Toggle:Set(false); Slider:Set(50); Dropdown:Set("First")
    record("Reset", "complete")
end})

local Lists = Window:Page({Name = "Lists", Icon = "100050851789190"})
local Browser = Lists:Section({Name = "Listbox", Side = 1})
Browser:Listbox({Flag = "DemoList", Items = {"Example one", "Example two", "Example three"}, Multi = false, Callback = callback("List")})
local Tests = Lists:Section({Name = "Test output", Side = 2})
status = Tests:Label("Click any control to test its callback")
Tests:Button({Name = "Run value checks", Callback = function()
    Toggle:Set(true); Slider:Set(75); Dropdown:Set("Second")
    local passed = Toggle:Get() == true and Slider:Get() == 75
    record("Value checks", if passed then "passed" else "failed")
end})
Tests:Button({Name = "Clear events", Callback = function() table.clear(events); status:SetText("Events cleared") end})

Window:Category("Settings")
local KeybindList = Library:KeybindList("Keybinds")
Library:CreateSettingsPage(Window, KeybindList)
Window:Init()
environment.NeverloseUIDemo = {Library = Library, Window = Window, Events = events}
return environment.NeverloseUIDemo
