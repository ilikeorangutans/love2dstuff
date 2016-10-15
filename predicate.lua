--- Returns predicate that matches the given x and y
function onPosition(x, y)
  return function(input)
    return x == input.x and y == input.y
  end
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
    return visible
  end
  return {visible=predicate}
end

function inColony()
  local predicate = function(visible)
    return not visible
  end
  return {visible=predicate}
end
