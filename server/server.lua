local _doorCache = {}
local _CreateThread, _RegisterServerEvent = CreateThread, RegisterServerEvent

ESX = ESX
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) 

isAllowed = function(id)
    local xPlayer = ESX.GetPlayerFromId(id)
    local group = xPlayer.getGroup()
    for k, v in pairs(Config['admingroups']) do
        if group == v then
            return true
        end
    end
    return false
end

_CreateThread(function()
    local doors = LoadResourceFile(GetCurrentResourceName(), "doors.json")
    if doors == "" then
        SaveResourceFile(GetCurrentResourceName(), "doors.json", "[]", -1)
    end
end)

ESX['RegisterServerCallback']('guille_doorlock:cb:getDoors', function(source,cb) 
    local doors = LoadResourceFile(GetCurrentResourceName(), "doors.json")
    doors = json['decode'](doors)
    cb(doors, _doorCache)
end)

_RegisterServerEvent("guille_doorlock:server:addDoor", function(_doorCoords, _doorModel, _heading, type, _textCoords, dist, jobs, pin, item)
    local _src = source
    if isAllowed(_src) then
        local usePin = false
        local useitem = false
        local doors = LoadResourceFile(GetCurrentResourceName(), "doors.json")
        if pin ~= "" then
            usePin = true
        end
        if item ~= "" then
            useitem = true
        end
        doors = json.decode(doors)
        local tableToIns = {
            doorCoords = _doorCoords,
            _doorModel = _doorModel,
            _heading = _heading,
            _type = type,
            _textCoords = _textCoords,
            dist = dist,
            jobs = jobs,
            usePin = usePin,
            pin = pin,
            useitem = useitem,
            item = item
        }
        table['insert'](doors, tableToIns)
        SaveResourceFile(GetCurrentResourceName(), "doors.json", json['encode'](doors, { indent = true }), -1)
        TriggerClientEvent("guille_doorlock:client:refreshDoors", -1, tableToIns)
    end
end)

_RegisterServerEvent("guille_doorlock:server:addDoubleDoor", function(_doorsDobule, type, _textCoords, dist, jobs, pin)
    local _src = source
    if isAllowed(_src) then
        local doors = LoadResourceFile(GetCurrentResourceName(), "doors.json")
        doors = json.decode(doors)
        local usePin = false
        if pin ~= "" then
            usePin = true
        end
        local tableToIns = {
            _doorsDouble = _doorsDobule,
            _type = type,
            _textCoords = _textCoords,
            dist = dist,
            jobs = jobs,
            usePin = usePin,
            pin = pin,
        }
        table['insert'](doors, tableToIns)
        SaveResourceFile(GetCurrentResourceName(), "doors.json", json['encode'](doors, { indent = true }), -1)
        TriggerClientEvent("guille_doorlock:client:refreshDoors", -1, tableToIns)
    end
end)

_RegisterServerEvent("guille_doorlock:server:updateDoor", function(id, type)
    _doorCache[id] = type
    TriggerClientEvent("guille_doorlock:client:updateDoorState", -1, id, type)
end)

_RegisterServerEvent("guille_doorlock:server:syncRemove", function(id)
    local _src = source
    if isAllowed(_src) then
        local doors = LoadResourceFile(GetCurrentResourceName(), "doors.json")
        doors = json.decode(doors)
        table['remove'](doors, id)
        SaveResourceFile(GetCurrentResourceName(), "doors.json", json['encode'](doors, { indent = true }), -1)
        TriggerClientEvent("guille_doorlock:client:removeGlobDoor", -1, id)
    end
end)

RegisterCommand("createdoor", function(source, args)  
    local _src = source
    if isAllowed(_src) then
        TriggerClientEvent("guille_doorlock:client:setUpDoor", _src)
    end 
end, false)

RegisterCommand("deletedoor", function(source, args)  
    local _src = source
    if isAllowed(_src) then
        TriggerClientEvent("guille_doorlock:client:deleteDoor", _src)
    end 
end, false)

ESX.RegisterServerCallback('guille_doorlock:cb:hasObj', function(source,cb, item) 
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local itemPly = xPlayer.getInventoryItem(item)
    if itemPly and itemPly.count > 0 then
        return cb(true)
    else 
        return cb(false)
    end
end)
