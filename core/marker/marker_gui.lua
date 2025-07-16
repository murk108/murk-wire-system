---@param frame LuaGuiElement
local function create_marker_renamer(frame)
    local marker_flow = frame.add{type=  "flow", direction ="horizontal", name = "marker_flow"}
    marker_flow.add{type = "textfield", name = "marker_name"}
    marker_flow.add{type = "button", name = "market_set_name", caption = "Set Marker Name"}
end

---@param player LuaPlayer
---@param gui LuaGuiElement
---@param entity LuaEntity
local function create_marker_gui(player, gui, entity)
    if gui.marker_gui then
        gui.marker_gui.destroy()
    end

    local tags = {entity_id = entity.unit_number}
    local frame = gui.add{type = "frame", name = "marker_gui", caption = "Marker Renamer", direction = "vertical", tags = tags}

    create_marker_renamer(frame)
end

Hooker:add_hook(GameEvents.on_gui_opened, function (event)
    local entity = event.entity

    if entity and entity.unit_number then
        local player = game.get_player(event.player_index)
        create_marker_gui(player, player.gui.screen, entity)
    end
end)

---@param event EventData.on_gui_closed
Hooker:add_hook(GameEvents.on_gui_closed, function (event)
    local entity = event.entity

    if entity and entity.unit_number then
        local player = game.get_player(event.player_index)
        local gui = player.gui.screen.marker_gui

        if gui then
            gui.destroy()
        end
    end
end)

Hooker:add_hook("on_gui_market_set_name", function (player, element)
    local marker_gui = element.parent.parent
    local marker_flow = element.parent

    local id = tonumber(marker_gui.tags.entity_id)
    local new_name = tostring(marker_flow.marker_name.text)

    Markers.set_marker_name(id, new_name)
end)