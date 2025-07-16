---@meta

---@alias ConnectionMap table<Id, table<Id, boolean>>
---@alias RenderConnectionMap table<Id, table<Id, LuaRenderObject>>

--- a unique identifier for a network.
--- ex: a seperate square and triangle would have different network ids.
---@alias NetworkId integer

---@alias Network Id[]
---@alias MarkerIds Id[]

---@class WireGraph
---@field wire_name string
---@field wire_color Color
---@field connection_map ConnectionMap
---@field networks table<NetworkId, Network>
---@field network_ids table<Id, NetworkId>
---@field total_networks integer
local WireGraph = {}

---@param wire_name string
---@param color Color
---@return WireGraph
function WireGraph.create(wire_name, color) end

--- refreshes the metatable of the graph
function WireGraph:refresh() end

--- connects a to b
---@param id_a Id aka LuaEntity::unit_number
---@param id_b Id aka LuaEntity::unit_number
---@return boolean success
function WireGraph:connect(id_a, id_b) end

--- disconnects a from b
---@param id_a Id aka LuaEntity::unit_number
---@param id_b Id aka LuaEntity::unit_number
---@return boolean success
function WireGraph:disconnect(id_a, id_b) end

--- removes id from the graph
---@param id Id aka LuaEntity::unit_number
---@return boolean success
function WireGraph:remove(id) end

--- is a connected to b
---@param id_a Id aka LuaEntity::unit_number
---@param id_b Id aka LuaEntity::unit_number
---@return boolean connected
function WireGraph:is_connected(id_a, id_b) end

--- checks if a and b are on the same network
---@param id_a Id aka LuaEntity::unit_number
---@param id_b Id aka LuaEntity::unit_number
---@return boolean same_network
function WireGraph:is_same_network(id_a, id_b) end

--- checks if there if a can reach b through some path
---@param id_a Id aka LuaEntity::unit_number
---@param id_b Id aka LuaEntity::unit_number
---@return boolean can_reach
---@return table<integer, boolean> visited
function WireGraph:can_reach(id_a, id_b) end

--- gets the network that the id belongs to
---@param id Id aka LuaEntity::unit_number
---@return Network network
function WireGraph:get_network(id) end

---@class WireGraphStorage
local WireGraphStorage = {}

--- gets the player's current graph
---@param player LuaPlayer
---@return WireGraph current_graph
function WireGraphStorage.get_player_graph(player) end

---@param wire_name string
---@return WireGraph graph
function WireGraphStorage.get_graph(wire_name) end

--- creates a new wire graph
---@return WireGraph graph
function WireGraphStorage.create_graph(wire_name, wire_color) end

--- sets the players selected graph
---@param player LuaPlayer
---@param wire_name string
function WireGraphStorage.set_player_graph(player, wire_name) end


---@class MarkerStorage
local MarkerStorage = {}

--- gets the name of the marker
---@param marker_id Id aka LuaEntity::unit_number
---@return string name
function MarkerStorage.get_marker_name(marker_id) end

---@param name string
---@return MarkerIds marker_ids
function MarkerStorage.get_markers(name) end

--- gets the entities connected to the markers by a graph.
--- note: its not a live table
---@param name string
---@param graph WireGraph
---@return LuaEntity[] entities
function MarkerStorage.get_entities_from_graph(name, graph) end

---@param marker_id Id aka LuaEntity::unit_number
---@param name string
---@return boolean success
function MarkerStorage.set_marker_name(marker_id, name) end