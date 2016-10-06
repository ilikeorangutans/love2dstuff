Bus = {
}

--- Pub/sub event bus.
function Bus:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.subscriptions = {}
  return o
end

--- Adds a new subscriber for the given topic.
-- @param topic the topic we want to be notified about
-- @param receiver the thing passed as the first parameter to the handler
-- @param handler the actual handler function
function Bus:subscribe(topic, receiver, handler)
  if not self.subscriptions[topic] then self.subscriptions[topic] = {} end
  table.insert(self.subscriptions[topic], {receiver=receiver,handler=handler})
end

--- Fires an event on the given topic.
function Bus:fire(topic, event)
  if not self.subscriptions[topic] then return end

  for i, subscription in ipairs(self.subscriptions[topic]) do
    if subscription.handler(subscription.receiver, event) then
      return
    end
  end
end
