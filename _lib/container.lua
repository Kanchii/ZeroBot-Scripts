function Get_Container(container_name)
    local containers = Player.getContainers()
    if containers == nil then
        return
    end

    for i, index in pairs(containers) do
        local container = Container.new(index)
        local containerName = container:getName()
        if containerName ~= nil and containerName:lower() == container_name then
            return container
        end
    end

    return nil
end