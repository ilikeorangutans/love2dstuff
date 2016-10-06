Bus = {
}

function Bus:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.subscriptions = {}
  return o
end

function Bus:subscribe(topic, receiver, handler)
  if not self.subscriptions[topic] then self.subscriptions[topic] = {} end
  table.insert(self.subscriptions[topic], {receiver=receiver,handler=handler})
end

function Bus:fire(topic, event)
  if not self.subscriptions[topic] then return end

  for i, subscription in ipairs(self.subscriptions[topic]) do
    if subscription.handler(subscription.receiver, event) then
      return
    end
  end
end
