local scenes={}
local placing=false
local draft=nil

local function notify(msg)
    BeginTextCommandThefeedPost('STRING'); AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false,false)
end

local function draw3D(x,y,z,text)
    local ok,sx,sy=World3dToScreen2d(x,y,z)
    if not ok then return end
    SetTextScale(0.32,0.32); SetTextFont(4); SetTextCentre(true); SetTextOutline()
    SetTextEntry('STRING'); AddTextComponentString(text); DrawText(sx,sy)
end

local function raycast()
    local ped=PlayerPedId()
    local from=GetGameplayCamCoord()
    local rot=GetGameplayCamRot(2)
    local rz=math.rad(rot.z); local rx=math.rad(rot.x); local c=math.abs(math.cos(rx))
    local dir=vector3(-math.sin(rz)*c, math.cos(rz)*c, math.sin(rx))
    local to=from + dir*20.0
    local ray=StartShapeTestRay(from.x,from.y,from.z,to.x,to.y,to.z,-1,ped,0)
    local _,hit,endPos=GetShapeTestResult(ray)
    return hit==1,endPos
end

RegisterNetEvent('kruiger:scenes:sync',function(data) scenes=data or {} end)
CreateThread(function() Wait(1500); TriggerServerEvent('kruiger:scenes:request') end)

RegisterCommand(Config.Commands.Create,function()
    SetNuiFocus(true,true)
    SendNUIMessage({action='create', presets=Config.Presets, durations=Config.Durations,
        defaultDistance=Config.DefaultViewDistance, maxDistance=Config.MaxViewDistance})
end,false)

RegisterCommand(Config.Commands.Manage,function()
    SetNuiFocus(true,true); SendNUIMessage({action='manage', scenes=scenes})
end,false)

RegisterNUICallback('close',function(_,cb) SetNuiFocus(false,false); cb('ok') end)
RegisterNUICallback('startPlacement',function(data,cb)
    draft=data; placing=true; SetNuiFocus(false,false); cb('ok')
    notify('Aim where the scene should be placed. Press ~g~E~s~ to place or ~r~BACKSPACE~s~ to cancel.')
end)
RegisterNUICallback('delete',function(data,cb) TriggerServerEvent('kruiger:scenes:delete',data.id); cb('ok') end)
RegisterNUICallback('edit',function(data,cb) TriggerServerEvent('kruiger:scenes:updateText',data.id,data.text); cb('ok') end)

CreateThread(function()
    while true do
        if placing then
            Wait(0)
            local hit,pos=raycast()
            if hit then
                DrawMarker(28,pos.x,pos.y,pos.z+0.05,0,0,0,0,0,0,0.18,0.18,0.18,30,160,255,180,false,false,2,false,nil,nil,false)
                draw3D(pos.x,pos.y,pos.z+0.25,'[E] Place Scene')
                if IsControlJustPressed(0,38) then
                    draft.x,draft.y,draft.z=pos.x,pos.y,pos.z
                    TriggerServerEvent('kruiger:scenes:create',draft)
                    placing=false; draft=nil; notify('Scene placed.')
                end
            end
            if IsControlJustPressed(0,177) then placing=false; draft=nil; notify('Placement cancelled.') end
        else Wait(250) end
    end
end)

CreateThread(function()
    while true do
        local wait=750
        local p=GetEntityCoords(PlayerPedId())
        for _,s in ipairs(scenes) do
            local pos=vector3(s.x,s.y,s.z)
            local d=#(p-pos)
            if d <= (s.distance or Config.DefaultViewDistance) then
                wait=0
                if s.mode=='text' or s.mode=='both' then
                    draw3D(s.x,s.y,s.z+0.25,('[SCENE] %s'):format(s.text))
                end
                if (s.mode=='inspect' or s.mode=='both') and d <= Config.InteractDistance then
                    draw3D(s.x,s.y,s.z+0.15,'[E] Inspect Scene')
                    if IsControlJustPressed(0,38) then
                        SetNuiFocus(true,true); SendNUIMessage({action='inspect',scene=s})
                    end
                end
            end
        end
        Wait(wait)
    end
end)
