local function get_blueprint_graph(unit_number, connections, reverse_map)
    local blueprint_connections = {}
    local total = 0

    for unit_number_2 in pairs(connections) do
        if reverse_map[unit_number_2] then
            if unit_number > unit_number_2 then -- one directional counting
                total = total + 1
            end

            blueprint_connections[unit_number_2] = true
        end
    end

    if not next(blueprint_connections) then
        return nil
    end

    return blueprint_connections, total
end

local function setup_entity(unit_number, reverse_map)
    local blueprint_graphs = {}
    local total = 0

    for wire_name, graph in pairs(storage.wire_graphs) do
        local connections = graph.connection_map[unit_number]

        if connections then
            local blueprint_graph, local_total = get_blueprint_graph(unit_number, connections, reverse_map)

            if blueprint_graph then
                blueprint_graphs[wire_name] = blueprint_graph
                total = total + local_total
            end
        end
    end

    if not next(blueprint_graphs) then
        return nil
    end

    return blueprint_graphs, total
end

Hooker:add_hook(Events.on_setup_blueprint, function (player, bp_entities, stack, mappings)
    local total_connections = 0
    local reverse_map = {}
    local has_blueprint_graph = {}

    for entity_number, entity in pairs(mappings) do
        reverse_map[entity.unit_number] = entity_number
    end

    for i = 1, #bp_entities do
        local bp_entity = bp_entities[i]
        local entity_number = bp_entity.entity_number

        local entity = mappings[entity_number]
        local unit_number = entity.unit_number

        local blueprint_graphs, local_total = setup_entity(unit_number, reverse_map)

        if blueprint_graphs then
            stack.set_blueprint_entity_tag(entity_number, "old_unit_number", unit_number)
            stack.set_blueprint_entity_tag(entity_number, "blueprint_graphs", blueprint_graphs)
            total_connections = total_connections + local_total

            has_blueprint_graph[entity_number] = true
        end
    end

    if total_connections > 0 then
        for i = 1, #bp_entities do
            local bp_entity = bp_entities[i]
            local entity_number = bp_entity.entity_number

            if has_blueprint_graph[entity_number] then
                stack.set_blueprint_entity_tag(entity_number, "total_connections", total_connections)
            end
        end
    end
end)

------------- spawning

 ---@param id integer
 ---@param old_id integer
 ---@param blueprint_graphs table<string, table<string, boolean>>
 ---@param total_connections any
 ---@param group_id any
local function handle_on_spawned(id, old_id, blueprint_graphs, total_connections, group_id)
    old_id = tostring(old_id) -- neccessary because blueprint_graphs is in strings.

    local get_graph = Wires.get_graph

    local total = storage.bp_wire_total[group_id] or total_connections
    local group = storage.bp_wire_groups[group_id] or {}

    group[old_id] = id

    for wire_name, connections in pairs(blueprint_graphs) do
        local graph = get_graph(wire_name)

        for old_id_2 in pairs(connections) do
            local id_2 = group[old_id_2]

            if id_2 then
                if graph:connect(id, id_2) then
                    total = total - 1
                end
            end
        end
    end

    if total <= 0 then
        storage.bp_wire_groups[group_id] = nil
        storage.bp_wire_total[group_id] = nil
    else
        storage.bp_wire_groups[group_id] = group
        storage.bp_wire_total[group_id] = total
    end
end

Hooker:add_hook(Events.on_spawned, function (entity, tags)
    if not tags or not tags.blueprint_graphs then
        return
    end

    local id = entity.unit_number
    local old_id = tags.old_unit_number
    local blueprint_graphs = tags.blueprint_graphs
    local total_connections = tags.total_connections
    local group_id = get_group_id(id)

    handle_on_spawned(id, old_id, blueprint_graphs, total_connections, group_id)
end)