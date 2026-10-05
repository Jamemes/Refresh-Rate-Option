Hooks:Add("LocalizationManagerPostInit", "Refresh_Rate_Option.loc", function(...)		
	LocalizationManager:add_localized_strings({
		menu_refresh_rate_option = "Refresh Rate"
	})

	if Idstring("russian"):key() == SystemInfo:language():key() then
		LocalizationManager:add_localized_strings({
			menu_refresh_rate_option = "Частота обновления"
		})
	end
end)

Hooks:Add("MenuManagerBuildCustomMenus", "Refresh_Rate_Option.add_option", function(menu_manager, nodes)
	local node = nodes.video
	if node then
		local pos = 1
		for id, item in pairs(node._items) do
			if item:name() == "resolution" then
				pos = id + 1
			end
		end

		local params = {
			callback = "choice_refresh_rate",
			name = "menu_refresh_rate_option",
			text_id = "menu_refresh_rate_option",
		}

		local data_node = {
			type = "MenuItemMultiChoice"
		}

		local refresh_rates = {}
		for _, mode in pairs(RenderSettings.modes) do
			if not refresh_rates[mode.z] then
				refresh_rates[mode.z] = true
				table.insert(data_node, {
					_meta = "option",
					text_id = tostring(mode.z),
					localize = false,
					value = tonumber(mode.z)
				})
			end
		end

		table.sort(data_node, function(a, b) return a.value > b.value end)

		local change_slot_btn = node:create_item(data_node, params)
		change_slot_btn.dirty_callback = callback(node, node, "item_dirty")
		if node.callback_handler then
			change_slot_btn:set_callback_handler(node.callback_handler)
		end

		change_slot_btn:set_value(RenderSettings.resolution.z)

		table.insert(node._items, pos, change_slot_btn)
	end
end)

function MenuCallbackHandler:choice_refresh_rate(item)
	local resolution = RenderSettings.resolution
	managers.viewport:set_resolution(Vector3(resolution.x, resolution.y, item:value()))
end