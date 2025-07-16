---@type table<integer, LuaEntity>
local previous_entities = {}

---@param entity LuaEntity?
local function is_valid(entity)
    return entity and entity.unit_number
end

---@param graph WireGraph
---@return LuaRenderObject
local function draw_connection(graph, a, b)
    local ent_a = get_entity(a)
    local ent_b = get_entity(b)

    local obj = rendering.draw_line{
        from = ent_a.position,
        to = ent_b.position,
        surface = ent_a.surface,
        color = graph.wire_color,
        width = 1
    }

    return obj
end

local function create_empty_line(surface)
    return rendering.draw_line{from = {0,0}, to = {0,0}, color = {0,0,0}, width = 1, surface = surface}
end

-------- custom-wire tool

InputHooker:add_hook("SHIFT + mouse-button-1", function(player)
    local previous = previous_entities[player.index]
    local current = player.selected

    if is_valid(previous) and is_valid(current) then
        local a = previous.unit_number
        local b = current.unit_number

        local graph = Wires.get_player_graph(player)
        local connected = graph:is_connected(a, b)

        if not connected then
            graph:connect(a, b)
        else
            graph:disconnect(a, b)
        end
    end

    previous_entities[player.index] = current
end)

InputHooker:add_hook("SHIFT + mouse-button-2", function(player)
    previous_entities[player.index] = nil
end)

----------------- rendering

Hooker:add_hook(Events.on_wire_connect, function(graph, a, b)
    local render_connection_map = storage.render_connection_maps[graph.wire_name]
    local render_obj = draw_connection(graph, a, b)

    local connections_a = render_connection_map[a] or {}
    local connections_b = render_connection_map[b] or {}

    connections_a[b] = render_obj
    connections_b[a] = render_obj

    render_connection_map[a] = connections_a
    render_connection_map[b] = connections_b
end)

Hooker:add_hook(Events.on_wire_disconnect, function(graph, a, b)
    local render_connection_map = storage.render_connection_maps[graph.wire_name]

    render_connection_map[a][b].destroy()

    render_connection_map[a][b] = nil
    render_connection_map[b][a] = nil
end)

Scheduler:schedule(1, function()
    local pre_build_wire = storage.pre_build_wire

    for _, player in pairs(game.players) do
        local index = player.index
        local previous = previous_entities[index]
        local current = player.selected

        local render_obj = pre_build_wire[index]

        if is_valid(previous) and is_valid(current) then
            render_obj = render_obj or create_empty_line(player.surface)
            pre_build_wire[index] = render_obj

            render_obj.from = previous.position
            render_obj.to = current.position
            render_obj.color = Wires.get_player_graph(player).wire_color
            render_obj.visible = true

        elseif render_obj and render_obj.visible then
            render_obj.visible = false
        end
    end

    return 8
end)