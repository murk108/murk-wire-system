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