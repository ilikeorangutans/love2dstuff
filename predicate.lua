--- Returns predicate that matches the given x and y
function onPosition(pos)
  local predicate = function(input)
    return pos.x == input.x and pos.y == input.y
  end

  return {position=predicate}
end

--- Returns a predicate that matches the given owner
function ownedBy(player)
  local predicate = function(input)
    return input.id == player.id
  end

  return {owner=predicate}
end

--- Returns a predicate that matches everything that's not in a colony
function visible()
  local predicate = function(visible)
    return visible.value
  end
  return {visible=predicate}
end

function inColony()
  local predicate = function(visible)
    return not visible
  end
  return {visible=predicate}
end

function selectable()
  local predicate = function(comp)
    return comp.selectable == true
  end
  return {selectable=predicate}
end
