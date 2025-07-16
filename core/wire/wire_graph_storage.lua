---@type WireGraphStorage
local M = {}
local wire_graph = require("core.wire.wire_graph")

local function create_default_graphs()
    local create_graph = M.create_graph
    create_graph("white", {1, 1, 1})
    create_graph("red",   {1, 0, 0})
    create_graph("green", {0, 1, 0})
    create_graph("blue",  {0, 0, 1})
end

local function refresh_graph_metatables()
    for _, graph in pairs(storage.wire_graphs) do
        wire_graph.refresh(graph)
    end
end

function M.create_graph(wire_name, wire_color)
    local graph = storage.wire_graphs[wire_name]

    if not graph then
        graph = wire_graph.create(wire_name, wire_color)

        storage.wire_graphs[wire_name] = graph
        storage.render_connection_maps[wire_name] = {}
    end

    return graph
end

function M.get_player_graph(player)
    return storage.selected_graph[player.index] or storage.wire_graphs.red
end

function M.get_graph(wire_name)
    return storage.wire_graphs[wire_name]
end

function M.set_player_graph(player, wire_name)
    storage.selected_graph[player.index] = storage.wire_graphs[wire_name]
end

Hooker:add_hook(Events.on_load, function()
    ---@type table<string, WireGraph>
    storage.wire_graphs = storage.wire_graphs or {}

    ---@type table<integer, WireGraph>
    storage.selected_graph = storage.selected_graph or {}

    ---@type table<string, RenderConnectionMap>
    storage.render_connection_maps = storage.render_connection_maps or {}

    ---@type table<integer, LuaRenderObject>
    storage.pre_build_wire = storage.pre_build_wire or {}

    ---@type table<integer, table<Id, Id>>
    storage.bp_wire_groups = storage.bp_wire_groups or {}

    ---@type table<integer, integer>
    storage.bp_wire_total = storage.bp_wire_total or {}

    create_default_graphs()
    refresh_graph_metatables()

    return false
end)

Hooker:add_hook(Events.on_died, function(entity)
    local id = entity.unit_number

    if not id then
        return
    end

    for _, graph in pairs(storage.wire_graphs) do
        graph:remove(id)
    end
end)

return M