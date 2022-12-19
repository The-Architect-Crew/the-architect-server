minetest.register_chatcommand("speed", {
	params = "[<speed>]",
    privs = {ban = true},
	description = "Set player speed.",
	func = function(name, param)
        if not tonumber(param) then
            minetest.chat_send_player(name, minetest.colorize("grey", "[speed]").." Speed must be a number!")
        else
            local speed = tonumber(param)
            if speed <= 0 then
                speed = 1
            elseif speed > 100 then
                speed = 100
            end
            minetest.chat_send_player(name, minetest.colorize("grey", "[speed]").." Player speed set to "..speed..".")
		    minetest.get_player_by_name(name):set_physics_override({speed=speed})
        end
	end,
})