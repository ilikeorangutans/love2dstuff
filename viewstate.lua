-- Simple stack of views
ViewStack = {}
function ViewStack:current()
  return self[#(self)]
end

function ViewStack:push(view)
  self:checkView(view)
  view.viewstack = self
  view:resize(self.w, self.h)
  table.insert(self, view)
end

function ViewStack:checkView(view)
  assert(view.resize, "view does not implement resize")
  assert(view.update, "view does not implement update")
  assert(view.draw, "view does not implement draw")
end

function ViewStack:pop()
  if #(self) <= 1 then
    print("CANNOT POP VIEW STATE, NOT ENOUGH LEFT!")
    return
  end
  table.remove(self)
end

function ViewStack:resize(w, h)
  self.w = w
  self.h = h
  print("ViewStack:resize()", w, h)
  if #(self) > 0 then
    self:current():resize(w, h)
  end
end
