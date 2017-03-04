function posAt(x, y)
  return {x=x,y=y}
end

function entityCapabilities(comps)
  local result = {}

  for comp, v in pairs(comps) do
    if v.capabilities then
      local x = v:capabilities()
      for _, y in pairs(x) do
        table.insert(result, y)
      end
    end
  end

  return result
end

--- Returns true if the entity has the specified capability.
function entityCanDo(comps, capability)
  local caps = entityCapabilities(comps)
  for k, v in ipairs(caps) do
    if v == capability then return true end
  end
  return false
end
