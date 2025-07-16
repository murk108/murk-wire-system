---@param frame LuaGuiElement
local function create_wire_label(frame)
    frame.add{type = "label", name = "wire_label"}
end

---@param frame LuaGuiElement
local function create_wire_dropdown(frame)
    local items = {}

    for wire_name in pairs(storage.wire_graphs) do
        items[#items + 1] = wire_name
    end

    frame.add{type = "drop-down", name = "wire_dropdown", items = items}
end

---@param label LuaGuiElement
local function set_player_wire_caption(label, player)
    local wire_name = Wires.get_player_graph(player).wire_name
    label.caption = "Selected wire: " .. wire_name
end

---@param player LuaPlayer
---@param gui LuaGuiElement
local function create_wire_gui(player, gui)
    local frame = gui.add{type = "frame", name = "wire_gui", direction = "vertical", caption = "Wire Selector"}

    create_wire_label(frame)
    create_wire_dropdown(frame)

    set_player_wire_caption(frame.wire_label, player)
end

Hooker:add_hook(Events.on_create_main_gui, create_wire_gui)

Hooker:add_hook("on_gui_wire_dropdown", function (player, element, event)
    if event.name == GameEvents.on_gui_selection_state_changed then
        local wire_name = tostring(element.items[element.selected_index])
        Wires.set_player_graph(player, wire_name)
        set_player_wire_caption(element.parent.wire_label, player)
    end
end)