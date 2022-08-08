local function motd_chat(name, message)
	minetest.chat_send_player(name, minetest.colorize("grey", "[MOTD]").." "..message)
end

minetest.register_chatcommand("motd", {
	params = "[<new_message>] | [del]",
	description = "Message of the day.",
	func = function(name, param)
		local check_privs = minetest.check_player_privs(name, {ban=true})
		if param == "" or not check_privs then
			local motd = mod_storage:get_string("motd")
			if motd and motd ~= "" then
				motd_chat(name, motd)
			else
				motd_chat(name, "No message of the day has been set!")
			end
		elseif param ~= "" and check_privs then
			if param == "del" then
				mod_storage:set_string("motd", "")
				motd_chat(name, "Message of the day deleted!")
			else
				mod_storage:set_string("motd", param)
				motd_chat(name, "Message of the day has been set to: "..param)
			end
		end
	end,
})

minetest.register_on_joinplayer(function(player)
	local motd = mod_storage:get_string("motd")
	local name = player:get_player_name()
	if motd and motd ~= "" then
		motd_chat(name, motd)
	end
end)