---@type WireGraph
local M = {}
M.__index = M

function M.create(wire_name, wire_color)
    local wire_graph = {
        wire_name = wire_name,
        wire_color = wire_color,
        connection_map = {},

        network_ids = {},
        networks = {},
        total_networks = 0
    }

    return setmetatable(wire_graph, M)
end

function M.refresh(wire_graph)
    setmetatable(wire_graph, M)
end

function M:is_connected(id_a, id_b)
    local connections_a = self.connection_map[id_a]

    if connections_a then
        return connections_a[id_b] ~= nil
    end

    return false
end

---@param self WireGraph
---@param id_a Id
---@param id_b Id
local function assign_network(self, id_a, id_b)
    local network_ids = self.network_ids
    local networks = self.networks

    local network_id_a = network_ids[id_a]
    local network_id_b = network_ids[id_b]

    if not network_id_a and not network_id_b then -- create network
        local new_network_id = self.total_networks + 1
        network_ids[id_a] = new_network_id
        network_ids[id_b] = new_network_id

        networks[new_network_id] = {id_a, id_b}
        self.total_networks = new_network_id
        return
    end

    if network_id_a == network_id_b then
        return
    end

    if network_id_a and network_id_b then -- merge network
        local network_a = networks[network_id_a]
        local network_b = networks[network_id_b]

        local size_a = #network_a
        local size_b = #network_b

        if size_a > size_b then -- swap
            network_id_a, network_id_b = network_id_b, network_id_a
            network_a, network_b = network_b, network_a
            size_a, size_b = size_b, size_a
        end

        for i = 1, size_a do
            local id = network_a[i]

            network_b[size_b + i] = id
            network_ids[id] = network_id_b
        end

        networks[network_id_a] = nil
        return
    end

    local network_id = network_id_a or network_id_b -- network to add onto
    local id = (not network_id_a and id_a) or id_b -- find which network doesnt have a network_id
    local network = networks[network_id]

    network[#network+1] = id
    network_ids[id] = network_id
end

function M:connect(id_a, id_b)
    local connection_map = self.connection_map

    if not self:is_connected(id_a, id_b) then
        local connections_a = connection_map[id_a] or {}
        local connections_b = connection_map[id_b] or {}

        -- bi directional
        connections_a[id_b] = true
        connections_b[id_a] = true

        connection_map[id_a] = connections_a
        connection_map[id_b] = connections_b

        assign_network(self, id_a, id_b)
        Hooker:trigger_hook(Events.on_wire_connect, self, id_a, id_b)

        return true
    end

    return false
end

function M:can_reach(id_a, id_b)
    local connection_map = self.connection_map

    local queue = { id_a }
    local visited = { [id_a] = true }
    local i = 1
    local n = 1

    while i <= n do
        local id = queue[i]

        if id == id_b then
            return true
        end

        local connections = connection_map[id]

        if connections then
            for id_2 in pairs(connections) do
                if not visited[id_2] then
                    n = n + 1
                    queue[n] = id_2
                    visited[id_2] = true
                end
            end
        end

        i = i + 1
    end

    return false, visited
end

local function split_network(self, network_id, should_split)
    local networks = self.networks
    local network_ids = self.network_ids

    local network = networks[network_id]
    local size = #network

    local new_network = {}
    local new_network_id = self.total_networks + 1

    local net_index = 1
    local new_net_index = 1

    for i = 1, size do
        local id = network[i]

        if should_split[id] then
            new_network[new_net_index] = id
            new_net_index = new_net_index + 1

            network_ids[id] = new_network_id
        else
            network[net_index] = id
            net_index = net_index + 1
        end
    end

    for i = net_index, size do
        network[i] = nil
    end

    self.networks[new_network_id] = new_network
    self.total_networks = new_network_id
end

function M:disconnect(id_a, id_b)
    local connection_map = self.connection_map

    if self:is_connected(id_a, id_b) then
        local connections_a = connection_map[id_a] or {}
        local connections_b = connection_map[id_b] or {}

        -- bi directional
        connections_a[id_b] = nil
        connections_b[id_a] = nil

        local can_reach, should_split = self:can_reach(id_a, id_b)

        if not can_reach then
            local network_id = self.network_ids[id_a]
            split_network(self, network_id, should_split)
        end

        Hooker:trigger_hook(Events.on_wire_disconnect, self, id_a, id_b)
        return true
    end

    return false
end

function M:remove(id)
    local connection_map = self.connection_map
    local connections = connection_map[id]

    if connections then
        local disconnect = M.disconnect

        for id_2 in pairs(connections) do
            disconnect(self, id, id_2)
        end

        local networks = self.networks
        local network_ids = self.network_ids
        local network_id = network_ids[id]

        networks[network_id] = nil
        network_ids[id] = nil
        connection_map[id] = nil

        return true
    end

    return false
end

function M:is_same_network(id_a, id_b)
    local network_ids = self.network_ids
    local network_id_a = network_ids[id_a]
    local network_id_b = network_ids[id_b]
    return network_id_a and network_id_b and network_id_a == network_id_b
end

function M:get_network(id)
    return self.networks[self.network_ids[id]]
end

return M