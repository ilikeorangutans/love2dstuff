function overBox(x, y, box)
  return over(x, y, box.x, box.y, box.x + box.w, box.y + box.h)
end

function over(x, y, tlx, tly, brx, bry)
  return tlx < x and x < brx and tly < y and y < bry
end

local module = {}
module.overBox = overBox
return module
