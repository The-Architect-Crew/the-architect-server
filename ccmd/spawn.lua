local function spawn_chat(name, message)
	minetest.chat_send_player(name, minetest.colorize("grey", "[spawn]").." "..message)
end

local function check_spawn(sname)
	local spawndata = minetest.deserialize(mod_storage:get_string("spawns"))
	if not spawndata then
		return nil
	end
	if spawndata[sname] then
		return spawndata[sname]
	else
		return nil
	end
end

minetest.register_chatcommand("spawn", {
    params = "[<location>]",
    description = "Teleport to the spawn location.",
    privs = {shout=true},
    func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if param == "" or param == nil then
			-- Teleport to spawn
			local sspawn = minetest.settings:get("static_spawnpoint")
			if not sspawn then
				spawn_chat(name, "No valid spawn has been set!")
				return
			end
			player:set_pos(minetest.string_to_pos(sspawn))
			spawn_chat(name, "Teleported to spawn!")
		else
			-- Teleport to alternative spawns
			local spawnpos = check_spawn(param)
			if spawnpos then
				player:set_pos(spawnpos)
				spawn_chat(name, "Teleported to "..param.." spawn!")
			else
				spawn_chat(name, param.. " is not a valid spawn location!")
			end
		end
    end,
})

local spawnnames_table = {}
local function spawnlist_formspec()
	spawnnames_table = {}
	local spawndata = minetest.deserialize(mod_storage:get_string("spawns"))
	local spawnnames = ""
	if spawndata then
		for index, spawnlist in pairs(spawndata) do
			spawnnames = spawnnames..","..index
			table.insert(spawnnames_table, index)
		end
	end
	local formspec = {
		"formspec_version[4]",
		"size[7.75, 7.75]",
		"bgcolor[#00000000;neither]",
		"image[0,0;7.75,7.75;winv_bg.png]",
		"box[0.25,0.25;7.25,6;#00000069]",
		"textlist[0.25,0.25;7.25,6;ccmd_spawnlist;Select a spawn location:,spawn"..spawnnames..";1;true]",
		"button[2.875,6.5;2,1;ccmd_teleport;Travel]",
	}
	return table.concat(formspec, "")
end

minetest.register_chatcommand("spawnlist", {
    description = "Get list of possible spawns.",
    privs = {shout=true},
    func = function(name)
		minetest.show_formspec(name, "ccmd:spawnlist", spawnlist_formspec())
    end,
})

local selected_spawn = {}
minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	selected_spawn[name] = selected_spawn[name] or 1
	if fields.ccmd_spawnlist then
		local event = minetest.explode_textlist_event(fields.ccmd_spawnlist)
		if event.type == "CHG" then
			selected_spawn[name] = event.index
		end
	elseif fields.ccmd_teleport then
		if selected_spawn[name] == 1 then
			spawn_chat(name, "Click and select a spawn location from the list below!")
		elseif selected_spawn[name] == 2 then
			local sspawn = minetest.settings:get("static_spawnpoint")
			if not sspawn then
				spawn_chat(name, "No valid spawn has been set!")
				return
			end
			selected_spawn[name] = 1
			minetest.close_formspec(name, "ccmd:spawnlist")
			player:set_pos(minetest.string_to_pos(sspawn))
			spawn_chat(name, "Teleported to spawn!")
		elseif selected_spawn[name] > 2 then
			local sindex = selected_spawn[name] - 2
			local sname = spawnnames_table[sindex]
			local spawnpos = check_spawn(sname)
			if spawnpos then
				selected_spawn[name] = 1
				minetest.close_formspec(name, "ccmd:spawnlist")
				player:set_pos(spawnpos)
				spawn_chat(name, "Teleported to "..sname.." spawn!")
			else
				selected_spawn[name] = 1
				minetest.show_formspec(name, "ccmd:spawnlist", spawnlist_formspec())
				spawn_chat(name, "Error: Spawn location no longer exists! Refreshing list.")
			end
		end
	end
end)

minetest.register_chatcommand("spawnmod", {
	params = "(add | change | del) <location> | set",
	description = "Modify spawn locations based on your location. Use set to change static spawnpoint",
	privs = {privs=true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		-- ensure valid parameters
		if param == "" or param == nil or not player then
			spawn_chat(name, "Invalid parameters, use '/spawnset add/change/del <location> | /spawnset set'")
			return
		end
		local ppos = player:get_pos()
		-- change static spawnpoint
		if param == "set" then
			minetest.settings:set("static_spawnpoint", ppos.x..", "..ppos.y..", "..ppos.z)
			spawn_chat(name, "Set static spawnpoint to ("..ppos.x..", "..ppos.y..", "..ppos.z..")")
			return
		end
		local cmd, sname = string.match(param, '(%S+) (.*)')
		if sname == "" or not sname or cmd == "" or cmd == nil then
			spawn_chat(name, "Invalid parameters, use '/spawnset add/change/del <location>'")
			return
		end
		local spawndata = minetest.deserialize(mod_storage:get_string("spawns")) or {}
		-- add new spawn
		if cmd == "add" then
			if not spawndata[sname] then
				spawndata[sname] = {x = ppos.x, y = ppos.y, z = ppos.z}
				mod_storage:set_string("spawns", minetest.serialize(spawndata))
				spawn_chat(name, "Added "..sname.." spawn ("..ppos.x..", "..ppos.y..", "..ppos.z..")")
			else
				spawn_chat(name, sname.." is already a defined spawn! Use '/spawnset change' instead.")
			end
		-- change spawn
		elseif cmd == "change" then
			if spawndata[sname] then
				spawndata[sname] = {x = ppos.x, y = ppos.y, z = ppos.z}
				mod_storage:set_string("spawns", minetest.serialize(spawndata))
				spawn_chat(name, "Changed "..sname.." spawn to ("..ppos.x..", "..ppos.y..", "..ppos.z..")")
			else
				spawn_chat(name, sname.." is not a defined spawn! Use '/spawnset add' to define a spawn.")
			end
		-- delete spawn
		elseif cmd == "del" then
			if spawndata[sname] then
				spawndata[sname] = nil
				mod_storage:set_string("spawns", minetest.serialize(spawndata))
				spawn_chat(name, "Removed "..sname.." spawn.")
			else
				spawn_chat(name, sname.." is not a defined spawn!")
			end
		else
			spawn_chat(name, "Invalid modifier '"..cmd.."', use '/spawnset add/change/del <location>'")
		end
    end,
})