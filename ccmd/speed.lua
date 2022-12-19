minetest.register_chatcommand("speed", {
	params = "[<speed>]",
    privs = {ban = true},
	description = "Set player speed.",
	func = function(name, param)
        if not tonumber(param) then
            minetest.chat_send_player(name, minetest.colorize("grey", "[speed]").." Speed must be a number!")
        else
		    minetest.get_player_by_name(name):set_physics_override({speed=param})
        end
	end,
})