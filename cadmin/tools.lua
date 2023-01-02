minetest.register_tool("cadmin:pick", {
	description = "Admin Pickaxe",
	inventory_image = "cadmin_pick.png",
	--groups = {not_in_creative_inventory = 1},
	tool_capabilities = {
        full_punch_interval = 0.1,
        max_drop_level = 3,
        groupcaps = {
            unbreakable = {times = {[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 5},
            fleshy = {times = {[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 5},
            choppy = {times = {[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 5},
            bendy = {times = {[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 5},
            cracky = {times = {[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 5},
            crumbly = {times = {[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 5},
            snappy = {times = {[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 5},
        },
        damage_groups = {fleshy = 1000},
    },
	on_drop = function(itemstack, dropper, pos)
		return
	end,
})
