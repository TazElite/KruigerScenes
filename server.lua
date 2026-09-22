local scenes, nextId, cooldowns = {}, 1, {}
local resource = GetCurrentResourceName()

local function can(src, perm)
    return perm == nil or perm == '' or IsPlayerAceAllowed(src, perm)
end

local function sanitize(s)
    s = tostring(s or ''):gsub('[\r\n\t]', ' '):gsub('<', ''):gsub('>', '')
    s = s:gsub('%s+', ' '):match('^%s*(.-)%s*$') or ''
    return s:sub(1, Config.MaxTextLength)
end

local function publicScene(s)
    return {
        id=s.id, text=s.text, preset=s.preset, x=s.x, y=s.y, z=s.z,
        distance=s.distance, mode=s.mode, createdAt=s.createdAt, expiresAt=s.expiresAt,
        permanent=s.permanent
    }
end

local function save()
    local keep = {}
    for _,s in pairs(scenes) do
        if s.permanent then keep[#keep+1]=s end
    end
    SaveResourceFile(resource, Config.PersistentFile, json.encode({nextId=nextId, scenes=keep}), -1)
end

local function broadcast()
    local out={}
    for _,s in pairs(scenes) do out[#out+1]=publicScene(s) end
    TriggerClientEvent('kruiger:scenes:sync', -1, out)
end

CreateThread(function()
    local raw=LoadResourceFile(resource, Config.PersistentFile)
    if raw and raw ~= '' then
        local ok,data=pcall(json.decode,raw)
        if ok and type(data)=='table' then
            nextId=tonumber(data.nextId) or 1
            for _,s in ipairs(data.scenes or {}) do scenes[s.id]=s end
        end
    end
    Wait(1000); broadcast()
    while true do
        Wait(30000)
        local now=os.time()
        local changed=false
        for id,s in pairs(scenes) do
            if not s.permanent and s.expiresAt and s.expiresAt <= now then scenes[id]=nil; changed=true end
        end
        if changed then broadcast() end
    end
end)

RegisterNetEvent('kruiger:scenes:request', function() broadcast() end)

RegisterNetEvent('kruiger:scenes:create', function(data)
    local src=source
    if not Config.AllowEveryoneToCreate and not can(src,Config.Permissions.Create) then return end
    local now=os.time()
    if cooldowns[src] and now-cooldowns[src] < Config.CreateCooldownSeconds then return end
    local count=0
    for _,s in pairs(scenes) do if s.owner==src then count=count+1 end end
    if count >= Config.MaxScenesPerPlayer and not can(src,Config.Permissions.Manage) then return end
    local text=sanitize(data.text)
    if text=='' then return end
    local permanent=data.permanent==true
    if permanent and not can(src,Config.Permissions.Permanent) then permanent=false end
    local minutes=math.max(1, math.min(1440, tonumber(data.minutes) or Config.DefaultDurationMinutes))
    local dist=math.max(2.0, math.min(Config.MaxViewDistance, tonumber(data.distance) or Config.DefaultViewDistance))
    local mode=(data.mode=='text' or data.mode=='both') and data.mode or 'inspect'
    local id=nextId; nextId=nextId+1
    scenes[id]={
        id=id, owner=src, ownerName=GetPlayerName(src) or ('Player '..src),
        text=text, preset=sanitize(data.preset), x=tonumber(data.x),y=tonumber(data.y),z=tonumber(data.z),
        distance=dist, mode=mode, permanent=permanent, createdAt=now,
        expiresAt=permanent and nil or (now + minutes*60)
    }
    cooldowns[src]=now
    if permanent then save() end
    broadcast()
end)

RegisterNetEvent('kruiger:scenes:delete', function(id)
    local src=source; id=tonumber(id); local s=id and scenes[id]
    if not s then return end
    if s.owner ~= src and not can(src,Config.Permissions.Manage) then return end
    local was=s.permanent; scenes[id]=nil
    if was then save() end
    broadcast()
end)

RegisterNetEvent('kruiger:scenes:updateText', function(id,text)
    local src=source; id=tonumber(id); local s=id and scenes[id]
    if not s or (s.owner ~= src and not can(src,Config.Permissions.Manage)) then return end
    text=sanitize(text); if text=='' then return end
    s.text=text; if s.permanent then save() end; broadcast()
end)

AddEventHandler('playerDropped', function()
    cooldowns[source]=nil
end)
