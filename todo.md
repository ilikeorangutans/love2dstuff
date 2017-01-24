# In Progress

[ ] Action system will simulate any entity that has an action;
    [ ] action system should listen to events/methods about which one to simulate
[ ] properly think through how the action system deals with actions that are done

# Notes

Properly set lua path:
`eval $(luarocks path --bin)`

# Ideas

[ ] have a map view return a function predicate to check if it's visible
[ ] when subscribing to events provide filter methods so the bus will prefilter

# To Do

[ ] selections: should unselect if selected unit goes invisible
  [ ] what does that mean, go invisible? Entities have a state when on board, and when in colony.
  [ ] when entering a colony they become not controllable.
[ ] visibility: only active visibility where units currently are
[ ] check for selected entitiy before issuing commands
[ ] colony should produce stuff
[ ] colony screen
[ ] pathfinding
[ ] colonist added to colony should get a job assigned
[ ] create function on map to get surroundings?
[ ] use sprite batch to draw tiles
[ ] Android bug: for some reason tile IDs are not passed on to the map rendering function

# Done

[x] visibility system had incorrect owner check
[x] vision system incorrectly updates for wrong players
[x] Basic Move system
[x] Map needs methods that return range of tiles, iterators to iterate
[x] build colonies: should use all action points, settler gets "consumed" and added to colony
[x] completed commands should be removed from queue
[x] marker for worked fields
[x] terrain types
[x] introduce colonies
[x] have commands calculate the proper number of required action points
[x] viewport should support a focus on event/method
[x] instead of subscribing Game, Viewport, etc directly to input events, there should be something in between that also checks what can be done at the current state of the game.
