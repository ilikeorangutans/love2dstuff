--- Returns predicate that matches the given x and y
function onPosition(x, y)
  return function(input)
    return x == input.x and y == input.y
  end
end

--- Returns a predicate that matches the given owner
function ownedBy(player)
  return function(input)
    return input.id == player.id
  end
end
