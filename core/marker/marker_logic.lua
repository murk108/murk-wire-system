Hooker:add_hook(Events.on_marker_set_name, function (id, name)
    local render_obj = storage.marker_renders[id]

    if render_obj then
        render_obj.text = name
        return
    end

    local entity = get_entity(id)
    storage.marker_renders[id] = rendering.draw_text{text = name, color = {1,1,1}, target = entity, surface = entity.surface}
end)

Hooker:add_hook(Events.on_marker_died, function (id)
    storage.marker_renders[id].destroy()
    storage.marker_renders[id] = nil
end)