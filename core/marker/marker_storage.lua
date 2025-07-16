---@type MarkerStorage
local M = {}

---@return boolean
local function clear_marker_id(marker_id)
    local name = storage.marker_to_name[marker_id]

    if not name then
        return false
    end

    local group = storage.markers[name]
    local n = #group

    for i = 1, n do
        if group[i] == marker_id then
            group[i] = group[n]
            group[n] = nil
            break
        end
    end

    storage.marker_to_name[marker_id] = nil
    return true
end

---@return boolean
local function add_marker_id(marker_id, name)
    local group = storage.markers[name] or {}
    storage.markers[name] = group

    group[#group+1] = marker_id
    storage.marker_to_name[marker_id] = name

    return true
end

function M.get_marker_name(marker_id)
    return storage.marker_to_name[marker_id]
end

function M.set_marker_name(marker_id, name)
    clear_marker_id(marker_id)
    add_marker_id(marker_id, name)
    Hooker:trigger_hook(Events.on_marker_set_name, marker_id, name)

    return true
end

function M.get_markers(marker_name)
    return storage.markers[marker_name] or {}
end

function M.get_entities_from_graph(marker_name, graph)
    local markers = storage.markers[marker_name]

    if not markers then
        return {}
    end

    local total = 0
    local entities = {}

    for i = 1, #markers do
        local marker_id = markers[i]
        local entity_ids = graph:get_network(marker_id)

        if entity_ids then
            for j = 1, #entity_ids do
                local ent_id = entity_ids[j]

                total = total + 1
                entities[total] = get_entity(ent_id)
            end
        end
    end

    return entities
end

Hooker:add_hook(Events.on_load, function()
    ---@type table<string, MarkerIds>
    storage.markers = storage.markers or {}

    ---@type table<Id, string>
    storage.marker_to_name = storage.marker_to_name or {}

    ---@type table<Id, LuaRenderObject>
    storage.marker_renders = storage.marker_renders or {}
    return false
end)

Hooker:add_hook(Events.on_died, function(entity)
    local id = entity.unit_number

    if clear_marker_id(id) then
        Hooker:trigger_hook(Events.on_marker_died, id)
    end
end)

return M