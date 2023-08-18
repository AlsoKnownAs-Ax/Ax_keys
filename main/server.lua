--/////////// vRP bind \\\\\\\\\\\--

local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_keys")

vRPCax = Tunnel.getInterface("vrp_keys","vrp_keys")

vRPSax = {}
Tunnel.bindInterface("vrp_keys",vRPSax)
Proxy.addInterface("vrp_keys",vRPSax)

--===============================================--

local univ_key = Config.UniversalKey.use

local cfg = module("vrp","cfg/garages")
local vehicle_groups = cfg.garage_types

local function CheckVehicleName(veh)
	for i, v in pairs(vehicle_groups) do
		local vehicle = v[veh]
        if vehicle then
			return tostring(vehicle[1])
		end
	end
	return false
end

function vRPSax.Create_key(user_id,plate)
    local item_id = tostring(Config.item.itemid..plate)
    local desc = Config.item.desc..plate

    vRP.defInventoryItem({item_id,Config.item.name,desc,use_key,Config.item.weight})

    vRP.giveInventoryItem({user_id,item_id,1,true})
end

function mysplit (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

use_key = function(itemid)
    local choices = {}

    choices["Foloseste"] = {function(player,choice,mod)
        local key_plate = mysplit(itemid[1], "-")
        vRPCax.getPlate(player,{},function (plate)
            if plate == "nil" then
                return
            elseif tostring(plate) == tostring(key_plate[2]) then
                TriggerClientEvent('ax_keys:change_state',player)
            else
                vRPclient.notify(player,{"Nu detii cheia masinii"})
            end
        end)
    end}
    return choices
end


use_universal_key = function(itemid)
    local choices = {}

    choices["Foloseste"] = {function(player,choice,mod)
        vRPCax.getPlate(player,{},function (plate,universal_plate)
            if universal_plate then
                TriggerClientEvent('ax_keys:change_state',player)
            else
                vRPclient.notify(player,{"Aceasta masina nu foloseste o cheie universala"})
            end
        end)
    end}
    return choices
end

local function GetUserVehicles(user_id)
    if user_id then
        local vehicles = exports[Config.db_export]:executeSync('SELECT vehicle FROM vrp_user_vehicles WHERE user_id = ?',{user_id})
        local veh_names = {}
        local iterator = 0
        for _,v in pairs(vehicles) do
            if not CheckVehicleName(v.vehicle) then
                if Config.OutOfConfigCarAlert then
                    print("Masina: "..v.vehicle.." nu este bagata in garaje ( "..GetCurrentResourceName().." )\n\n")
                end
            else
                iterator = iterator + 1
                veh_names[iterator] = {
                    veh_id = v.vehicle,
                    veh_name = CheckVehicleName(v.vehicle)
                }
            end
        end
        if veh_names then
            return veh_names
        end
    end
end

local ch_admin_givekey = {function(source,choice)
    local user_id = vRP.getUserId{source}
    if user_id then
        
        vRP.prompt({source,"Player ID:","",function(player,target_id) 
            target_id = tonumber(target_id)
            local target_src = vRP.getUserSource{target_id}
            local vehs = GetUserVehicles(target_id)
            local AKeyMenu = {name="Admin Keys Menu",css = {top="75px",header_color="rgba(255, 255,0,0.8)"}}
            for i = 1,#vehs do
                AKeyMenu[vehs[i].veh_name] = {function(player, choice)
                    local plate = exports[Config.db_export]:executeSync('SELECT vehicle_plate FROM vrp_user_vehicles WHERE vehicle = ? AND user_id = ?',{vehs[i].veh_id,user_id})
                    if vRP.getInventoryItemAmount({target_id,Config.item.itemid..plate[1].vehicle_plate}) > 0 then
                        vRPclient.notify(player,{"Acest jucator are deja aceasta cheie"})
                        return
                    end
                    vRPSax.Create_key(target_id,plate[1].vehicle_plate)
                    vRPclient.notify(target_src,{"Adminul "..GetPlayerName(player).. " ti-a oferit o cheie pentru "..vehs[i].veh_name})
                    vRPclient.notify(player,{"I-ai oferit lui "..GetPlayerName(target_src).." o Cheie pentru "..vehs[i].veh_name})
                    vRP.closeMenu({player,AKeyMenu})
                end}
            end
            if univ_key then
                AKeyMenu[Config.UniversalKey.name] = {function (player, choice)
                    local univ_item_id = Config.UniversalKey.id_name
                    if vRP.getInventoryItemAmount({target_id,univ_item_id}) > 0 then
                        vRPclient.notify(target_src,{"Acest jucator are deja o cheie universala"})
                        return
                    end
                    vRP.giveInventoryItem({target_id,univ_item_id,1,false})
                    vRPclient.notify(target_src,{"Adminul "..GetPlayerName(player).. "ti-a oferit o "..Config.UniversalKey.name})
                    vRPclient.notify(player,{"I-ai oferit lui "..GetPlayerName(target_src).." "..Config.UniversalKey.name})
                    vRP.closeMenu({player,AKeyMenu})
                end}
            end
            vRP.closeMenu({player})
            SetTimeout(400, function()
                vRP.openMenu({player, AKeyMenu})
            end)
        end})
    end
end,Config.AdminChoice.choice_desc}

function vRPSax.openLostKeyMenu(source)
    local user_id = vRP.getUserId{source}
    local vehs = GetUserVehicles(user_id)
    if not vehs[1] then
        vRPclient.notify(source,{"Nu detii o masina personala"})
        return
    end

    if vehs then
        local KeyMenu =  {name="Lost Keys Menu",css = {top="75px",header_color="rgba(255, 255,0,0.8)"}}
        for i = 1, #vehs do
            KeyMenu[vehs[i].veh_name] = {function(player, choice)
                if vRP.tryPayment{user_id,Config.lost_keyPrice} then
                    local plate = exports[Config.db_export]:executeSync('SELECT vehicle_plate FROM vrp_user_vehicles WHERE vehicle = ? AND user_id = ?',{vehs[i].veh_id,user_id})
                    if vRP.getInventoryItemAmount({user_id,Config.item.itemid..plate[1].vehicle_plate}) > 0 then
                        vRPclient.notify(player,{"Ai deja cheia de la aceasta masina"})
                        return
                    end
                    vRPSax.Create_key(user_id,plate[1].vehicle_plate)
                    vRPclient.notify(player,{"Ai primit o "..Config.item.name.." pentru "..vehs[i].veh_name})
                    vRP.closeMenu({player,KeyMenu})
                else
                    vRPclient.notify(player, {"Eroare: Nu ai destui bani"})
                    vRP.closeMenu({player,KeyMenu})
                end
            end}
        end
        if univ_key then
            KeyMenu[Config.UniversalKey.name] = {function (player, choice)
                if vRP.tryPayment{user_id,Config.UniversalKey.buy_price} then
                    local univ_item_id = Config.UniversalKey.id_name
                    if vRP.getInventoryItemAmount({user_id,univ_item_id}) > 0 then
                        vRPclient.notify(player,{"Ai deja o cheie universala"})
                        return
                    end
                    vRP.giveInventoryItem({user_id,univ_item_id,1,false})
                    vRPclient.notify(player,{"Ai primit o "..Config.UniversalKey.name})
                    vRP.closeMenu({player,KeyMenu})
                else
                    vRPclient.notify(player, {"Eroare: Nu ai destui bani"})
                    vRP.closeMenu({player,KeyMenu})
                end
            end}
        end
            
        vRP.openMenu({source,KeyMenu})
    end
end

local function ax_defKeys(user_id)
    local keys_codes = exports[Config.db_export]:executeSync('SELECT vehicle_plate FROM vrp_user_vehicles WHERE user_id = ?',{user_id})

    for _,v in pairs(keys_codes) do
        if v.vehicle_plate ~= "" and v.vehicle_plate then
            local desc = Config.item.desc..v.vehicle_plate
            vRP.defInventoryItem({tostring(Config.item.itemid..v.vehicle_plate),Config.item.name,desc,use_key,Config.item.weight})
        end
    end

    if univ_key then
        local Universal_config = Config.UniversalKey
        vRP.defInventoryItem({Universal_config.id_name,Universal_config.name,Universal_config.desc,use_universal_key,Universal_config.weight})
    end
end

local function build_KeysMenu(source)
	local user_id = vRP.getUserId({source})
	if user_id then
		local function keys_enter()
			if user_id then
				vRPSax.openLostKeyMenu(source)
			end
		end
		local function keys_leave()
			vRP.closeMenu({source})
		end
        local x,y,z = table.unpack(Config.LostkeysCoords)
        if Config.blip_settings.use_blip then
            vRPclient.addBlip(source,{x,y,z,Config.blip_settings.blip_id,Config.blip_settings.blip_color,Config.blip_settings.name})
        end
		if Config.marker.use_marker then
            vRPclient.addMarkerNames(source,{x,y,z+0.350, Config.marker.text, Config.marker.fontId, 1.1})
        end
		if Config.markerSign.use then
            r,g,b,a = table.unpack(Config.markerSign.rgba)
            vRPclient.addMarkerSign(source,{Config.markerSign.marker_id,x,y,z-1.45,0.50,0.60,0.60,r,g,b,a,150,1,true,0})
        end

		vRP.setArea({source,"vRP:keys",x,y,z,1,1.5,keys_enter,keys_leave})
	end
end

--// Dev commands

-- RegisterCommand("loadkeys",function (source)
--     local user_id = vRP.getUserId{source}
--     local data = vRP.getUserDataTable({user_id})
--     if data then
--         if data.inventory then
--             for i,v in pairs(data.inventory) do
--                 if string.find(i,"key-") then
--                     local key_plate = mysplit(i, "-")
--                     if not key_plate[2] then
--                         key_plate[2] = ""
--                     end
--                     local desc = Config.item.desc..key_plate[2]
--                     vRP.defInventoryItem({i,Config.item.name,desc,use_key,Config.item.weight})
--                 end
--             end

--             if univ_key then
--                 local Universal_config = Config.UniversalKey
--                 vRP.defInventoryItem({Universal_config.id_name,Universal_config.name,Universal_config.desc,use_universal_key,Universal_config.weight})
--             end
--         end
--     end
--     ax_defKeys(user_id)
--     build_KeysMenu(source)
-- end)

-- RegisterCommand("axkeys", function (source)
--     local user_id = vRP.getUserId{source}
--     if user_id then
--         vRPSax.Create_key(user_id,"")
--     end
-- end)


if Config.AdminChoice.use then
    vRP.registerMenuBuilder({"admin", function(add, data)
        local user_id = vRP.getUserId({data.player})
        if user_id then
          local choices = {}

            if Config.AdminChoice.hasAcces(user_id) then
                choices[Config.AdminChoice.choice_name] = ch_admin_givekey
            end

        add(choices)
        end
    end})
end


AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
    if first_spawn then
        local data = vRP.getUserDataTable({user_id})
        if data then
            if data.inventory then
                for i,_ in pairs(data.inventory) do
                    if string.find(i,"key-") then
                        local key_plate = mysplit(i, "-")
                        local desc = Config.item.desc..key_plate[2]
                        vRP.defInventoryItem({i,Config.item.name,desc,use_key,Config.item.weight})
                    end
                end
            end
        end
        if Config.UseLostKeysZone then
            build_KeysMenu(source)
        end
        ax_defKeys(user_id)
    end
end)