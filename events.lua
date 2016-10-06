Bus = {
}

function Bus:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.subscriptions = {}
  return o
end

function Bus:subscribe(topic, handler)
  if not self.subscriptions[topic] then self.subscriptions[topic] = {} end
  table.insert(self.subscriptions[topic], handler)
end

function Bus:fire(topic, event)
  if not self.subscriptions[topic] then return end

  for i, subscription in ipairs(self.subscriptions[topic]) do
    -- This doesn't quite work because the receiver (first param which becomes self)
    -- points to nothing. We'd need to bind, i.e. keep the receiver around as well.
    if subscription(nil,event) then
      return
    end
  end
end
