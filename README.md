# Dart D3 Tooltips

## Tooltips for D3 under Dart.

### Author: Rick Berger, Aphorica, Inc ([rickb@aphorica.com](gbergeraph@gmail.com))

A tooltip facility for D3 under Dart.
---

## Features
* Uses SVG nodes (rect, path, text).
* Tip balloon sizes dynamically to text.
* Delay before showing tip (settable).
* Tip duration is settable.
* Offset is settable.  If non-zero, a pointer is generated to
  bottom left of tip rect.  If zero, no pointer and bottom left
  corner of tip is set to entry point.

## To Use:
* <span style="color:red">**Dart D3 Issue:**  The Dart D3 repository is not
  in sync with the _github_ version.  This won't work with the D3 repo
  from dartlang -- you need to download/clone the github version from here:</span>

  > [https://github.com/rwl/d3.dart](https://github.com/rwl/d3.dart)

  <span style="color:red">Change your 'pubspec.yaml' to point to the 
  cloned version.  See the 'd3' entry in the local 'pubspec.yaml' file
  to see how to do this.</span>
* Somewhere, instantiate a D3Tooltip object, passing it the root
  svg canvas and any other settings for the tips themselves.  See the
  constructor documentation for settings.  Best to do it after all
  your other items are created to avoid Z order issues.

* For nodes that you want to respond to tooltips:
  * Add a 'desc' attribute to the node (`.attr['desc'] = 'some text'`)
  * Register the node(s) with the tooltip Facility.

## Implementation notes
* The included demo project shows three circles, entering any circle
  will trigger the tip after a 1 second (default) delay.

* The point of the tip is determined at the point the selection element
  boundary is entered.  If you move fast, that may be the interior of the
  element rather than the edge.

* Currently, the tip is positioned only to the upper right of the
  entry point.

* Currently, the rect and text are positioned explicitly.  This is
  intentional, to allow for future flipping and repositioning at the
  edges without transforms affecting the text.  I'll likely come up with a better
  solution when I look into addressing that (see the 'TODOS' below.)

* Vertical centering of text is kind of a bugaboo in svg, hence the 'dy'
  parameter is exposed in the constructor.  If you set the text size
  in a passed in class and the text isn't centered vertically, fiddle with the
  'dy' parameter until it centers.

## TODOS

* Add fade-in, fade-out anims.

* Sense if the rect is outside the svg boundary on the top or right
  and reposition.

* Maybe add different kind of pointers if vertical or horizontal only
  offset specified?
