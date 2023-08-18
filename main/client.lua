--/////////// vRP bind \\\\\\\\\\\--

vRPCax = {}
Tunnel.bindInterface("vrp_keys",vRPCax)
Proxy.addInterface("vrp_keys",vRPCax)
vRP = Proxy.getInterface("vRP")
vRPSax = Tunnel.getInterface("vrp_keys","vrp_keys")

--===============================================--

function vRPCax.getPlate()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn( ped, false )
    local licenseplate = GetVehicleNumberPlateText(vehicle)

	local universal_plate = false

	if Config.UniversalKey.use then
		for _,v in pairs(Config.UniversalKey.universal_plates) do
			local _licenseplate = string.gsub(licenseplate," ","")

			if v == tostring(_licenseplate) then
				universal_plate = true
				break
			end
		end
	end

    return tostring(licenseplate),universal_plate
end

local engineRunning = false
local isInVehicle = false
local currentVehicle = nil


--	[[ Code snippet from Github , if i will have the necessary time to improve it, i will ]]
if Config.Use_npcs  then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
	
			local playerPed = PlayerPedId()
			local isInAnyVehicle = IsPedInAnyVehicle(playerPed, true)
	
			if not isInVehicle and isInAnyVehicle then
				local vehicleEntering = GetVehiclePedIsEntering(playerPed)
	
				isInVehicle = true
				currentVehicle = vehicleEntering ~= 0 and vehicleEntering or GetVehiclePedIsIn(playerPed)
				engineRunning = GetIsVehicleEngineRunning(currentVehicle)
	
				if Config.DisableStartAfter.Entering then
					SetVehicleEngineOn(currentVehicle, engineRunning, Config.Instantly, Config.DisableAutoStart)
				end
			elseif isInVehicle and not isInAnyVehicle then
				isInVehicle = false
	
				SetVehicleEngineOn(currentVehicle, engineRunning, Config.Instantly, Config.DisableAutoStart)
			end
	
			if Config.DisableStartAfter.PressingKey and isInVehicle and not engineRunning then
				DisableControlAction(0, 71, true) -- INPUT_VEH_ACCELERATE
				DisableControlAction(0, 72, true) -- INPUT_VEH_BRAKE
			end
		end
	end)
end

local vehicle = nil

RegisterNetEvent("ax_keys:change_state", function(state,nveh)
	local playerPed = PlayerPedId()
	vehicle = GetVehiclePedIsIn(playerPed)
	if nveh then
		vehicle = nveh
	end

	if vehicle then
		inVeh = true
	end

	local engine = true
	
	if state == nil then
		engine = GetIsVehicleEngineRunning(vehicle)
		SetVehicleEngineOn(vehicle, not engine, Config.Instantly, Config.DisableAutoStart)
	else
		SetVehicleEngineOn(vehicle, state, Config.Instantly, Config.DisableAutoStart)
	end


	if state or not engine then
		if Config.LeaveTheEngineRunning then
			local loop = true
			Citizen.CreateThread(function()
				local done = false
				while loop do
					Wait(500)
					local inveh = IsPedInAnyVehicle(playerPed, true)
					local check = GetIsVehicleEngineRunning(vehicle)

					if not inveh and not done then
						SetVehicleEngineOn(vehicle, not check, true, true)
						done = true
					end

					if not check and done then
						loop = false
						vehicle = nil
					end

				end
			end)
		end
	else
		engine = not engine
	end
end)

AddEventHandler('gameEventTriggered', function (name, args)
	if name == "CEventNetworkPlayerEnteredVehicle" then
		local engine = GetIsVehicleEngineRunning(args[2])
		SetVehicleEngineOn(args[2], engine, Config.Instantly, Config.DisableAutoStart)
		Citizen.CreateThread(function ()
			local ped = PlayerPedId()
			while IsPedInAnyVehicle(ped, true) and not vehicle do
				Wait(500)
				if vehicle then
					break
				end
				local inveh = IsPedInAnyVehicle(ped, true)

				if not inveh then
					SetVehicleEngineOn(args[2],engine, true, true)
				end

			end
		end)
	end
end)