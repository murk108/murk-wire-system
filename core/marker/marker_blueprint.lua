Hooker:add_hook(Events.on_setup_blueprint, function (player, bp_entities, stack, mappings)
    for i = 1, #bp_entities do
        local bp_entity = bp_entities[i]
        local entity_number = bp_entity.entity_number

        local entity = mappings[entity_number]

        local unit_number = entity.unit_number
        local marker_name = Markers.get_marker_name(unit_number)

        if marker_name then
            stack.set_blueprint_entity_tag(entity_number, "marker_name", marker_name)
        end
    end
end)

Hooker:add_hook(Events.on_spawned, function (entity, tags)
    if tags and tags.marker_name then
        Markers.set_marker_name(entity.unit_number, tags.marker_name)
    end
end)