# Love2D UI Toolkit

# Features

- Box model based layouting system
- Meant to be used with love 2d

# Concepts

Basis for this framework is the box model as follows:
- Basic building block is a box.
- Box has dimensions that define the desired position and size
- Margin for top, right, bottom and left can be set. Margin defines the distance between the outer limits of the border and its parent element.
- Alignment which defines how the widgets are placed inside of their box. This allows for both horizontal and vertical alignment or filling.

Layout process:
- First the bounds of a widget have to be set. The bounds define the overall area that the parent has reserved for a widget. Bounds can be retrieved via `widget.bounds`.
- Once the bounds have been set, the margins will be subtracted from it, resulting in the margin area. This area is the same or smaller. It can be retrieved via `widget.marginArea`.
- Within the margin area the alignment is applied. Depending on the settings, a new area called widget area is created. It is either the same or smaller than the margin area. Within this area the widget is supposed to draw itself.

# Usage

- Require the root module `ui = require('widgets')`, that module has all exported types.
- Create root UI, e.g. `myUI = ui.VerticalContainer:new()`
- Configure root UI, set margin, alignment, etc.
- Set up event handlers: love.resize(), love.mousemoved, etc
- First call the layout and then draw method on the root ui

# Structure


