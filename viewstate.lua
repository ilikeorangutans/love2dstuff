-- Simple stack of views
ViewStack = {}
function ViewStack:current()
  return self[#(self)]
end

function ViewStack:push(view)
  table.insert(self, view)
end

function ViewStack:pop()
  if #(self) <= 1 then
    print("CANNOT POP VIEW STATE, NOT ENOUGH LEFT!")
    return
  end
  table.remove(self)
end

