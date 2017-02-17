function overBox(x, y, box)
  return over(x, y, box.x, box.y, box.x + box.w, box.y + box.h)
end

function over(x, y, tlx, tly, brx, bry)
  return tlx < x and x < brx and tly < y and y < bry
end

function box2string(box)
  return ("%dx%d at %d/%d"):format(box.w, box.h, box.x, box.y)
end

function box(x, y, w, h)
  return {x=x, y=y, w=w, h=h}
end

function distributeSizes(available, sizes)
  if not sizes or #(sizes) == 0 then assert(false, "no input sizes given") end

  local result = {}
  local remaining = available
  local required = 0
  local fillers = {}

  for i, s in pairs(sizes) do
    remaining = remaining - s
    required = required + s
    result[i] = s

    if s == 0 then
      table.insert(fillers, i)
    end
  end

  if remaining < 0 then
    local ratio = available / required
    for i in pairs(result) do
      result[i] = result[i] * ratio
    end
  end

  if #(fillers) > 0 and remaining > 0 then
    local fillerWidth = remaining / #(fillers)
    for _, i in pairs(fillers) do
      result[i] = fillerWidth
    end
  end

  return result
end

local module = {}
module.overBox = overBox
module.box2string = box2string
module.distributeSizes = distributeSizes
module.box = box
return module
