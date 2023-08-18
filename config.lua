Config = {}

--// Lincese and Client Name //--
Config.clientName = "AX"
Config.license = "localhost"

--// Keys Config //--

Config.OutOfConfigCarAlert = true        --// This will print in console any car that`s not included in the vehicles.lua
Config.LostkeysCoords = vec3(-29.971008300781,-1105.0959472656,26.422334671021)

Config.db_export = 'oxmysql'
Config.lost_keyPrice = 500
Config.Use_npcs = false                 --// true => Wvery npc`s car will ve locked (will consume resmon)
Config.UseLostKeysZone = true           --// Use a zone where you can recover the lost keys
Config.LeaveTheEngineRunning = true     --// Leave the engine running after leaving the vehicle
Config.UniversalKey = {                 --// A key that will start any car that has these Number Plate Texts
    use = true,
    id_name = "key-universal",
    name = "Cheie Universala",
    desc = "O Cheie Universala",
    weight = 0.1,
    buy_price = 300,

    universal_plates = {
        "",
        "SPAWNVEH",
        "--AX-",
    }
}

Config.AdminChoice = {
    use = true,
    choice_name = "Admin Give Key",
    choice_desc = "Creeaza O Cheie unui Jucator",
    hasAcces = function (user_id)
        if vRP.isAdmin{user_id} then    --// Set your Admin Access
            return true
        else
            return false
        end
    end
}

Config.Instantly = false
Config.DisableAutoStart = true

Config.DisableStartAfter = {
    Entering = true,
    PressingKey = true
}

Config.item = {
    itemid = "key-",
    name = "Cheie",
    desc = "Cheie: ",
    weight = 0.1
}

Config.blip_settings = {
    use_blip = true,
    blip_id = 60,
    blip_color = 38,
    name = "Lost Keys"
}

Config.marker = {
    use_marker = true,
    text = "~o~Keys Menu",
    fontId = 1,

}

Config.markerSign = {
    use = true,
    marker_id = 36,
    rgba = vec4(255, 165, 0, 255),
}
