local game = GetService("TweenService").Parent
local LimeEnv = loadlib("LimeEnv")
if LimeEnv.env["libhookersafemode"] == nil then
    LimeEnv.env["libhookersafemode"] = false
end
if LimeEnv.env["libhookerhooks"] == nil then LimeEnv.env["libhookerhooks"] = {} end
local libhookerhooks = LimeEnv.env["libhookerhooks"]

local hooktemplate = {
    ["name"] = "hookcustomname",
    ["lib"] = "lib", -- if nil its a userapp
    ["funcname"] = nil,
    ["code"] = "code"
}

function checkfunctionhook(lib)
    for i, v in pairs(libhookerhooks) do if v.lib == lib then return true end end
    return false
end

function checkapphook(funcname)
    for i, v in pairs(libhookerhooks) do
        if v.lib == nil and v.funcname == funcname then return true end
    end
    return false
end

function checkmultifunction(name)
    for i, v in pairs(libhookerhooks) do
        if v.name == name then return true end
    end
    return false
end

function hooklibinternal(lib, funcname, ...)
    if LimeEnv.env["libhookersafemode"] then return "safemode" end
    if lib then -- its a lib
        print("debug3")
        for i, v in pairs(libhookerhooks) do
            if v.lib == lib and v.funcname == funcname then v.code(...) end
        end
    else
        local decodedargs = {...}
        print("debug1")
        print(decodedargs[1])
        print(funcname)
        if decodedargs[1] == funcname then
            -- found it!
            print("debug2")
            for i, v in pairs(libhookerhooks) do
                if v.lib == nil and v.funcname == funcname then
                    v.code(...)
                end
            end
        end
    end
end

function hooklib(lib, funcname, hook, name, userapp)
    if lib == nil then
        if checkmultifunction(name) then return "already exists" end
        local laf = loadlib("LimeAppFramework")
        local oldfunc = laf['StartUserProcess']
        if checkapphook(funcname) == false then
            print("first time")
            laf['StartUserProcess'] = function(...)
                hooklibinternal(nil, funcname, ...)
                return oldfunc(...)
            end
        end
        local templateclone = table.clone(hooktemplate)
        templateclone.name = name
        templateclone.lib = nil
        templateclone.funcname = funcname
        templateclone.code = hook
        table.insert(libhookerhooks, templateclone)
        return "yay!"
    else
        if checkmultifunction(name) then return "already exists" end
        local oldfunc = lib[funcname]
        if checkfunctionhook(lib) == false then
            print("first time")
            lib[funcname] = function(...)
                hooklibinternal(lib, funcname, ...)
                return oldfunc(...)
            end
        end
        local templateclone = table.clone(hooktemplate)
        templateclone.name = name
        templateclone.lib = lib
        templateclone.funcname = funcname
        templateclone.code = hook
        table.insert(libhookerhooks, templateclone)
        return "yay!"
    end
end

local app = createapp("LibHookerConfig")
local safemodetoggle = new("TextButton", app)
safemodetoggle.Size = UDim2.fromScale(1, 1)
safemodetoggle.TextScaled = true
safemodetoggle.BackgroundTransparency = 1
safemodetoggle.TextColor3 = Color3.fromRGB(255, 255, 255)
safemodetoggle.MouseButton1Click:Connect(function()
    LimeEnv.env["libhookersafemode"] = not LimeEnv.env["libhookersafemode"]
    if LimeEnv.env["libhookersafemode"] then
        safemodetoggle.Text = "Safe Mode (Disables Tweaks): ON"
    else
        safemodetoggle.Text = "Safe Mode (Disables Tweaks): OFF"
    end
end)
if LimeEnv.env["libhookersafemode"] then
    safemodetoggle.Text = "Safe Mode (Disables Tweaks): ON"
else
    safemodetoggle.Text = "Safe Mode (Disables Tweaks): OFF"
end

LimeEnv.env['HookLib'] = hooklib




function hookeg() print("lolz u just got hooked fool") end
print(hooklib(loadlib("LimeEnv"), "Print", hookeg, "Example Hook"))
print(hooklib(nil, "testapp", hookeg, "Example App Hook"))
loadlib("LimeEnv").Print("hello.")
