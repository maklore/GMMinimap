<h1 align="center">GMMinimap</h1>
<h3 align="center">Generate a minimap of set objects and colour(s) of the current room.<h3>

> Disclaimer: Only draws whats inside room borders.

### Basic setup example
> Change to desired values.
- Create an object.
  
- Add to room start event:
  ```gml
  GMMinimap.generate(objPlayer, c_red, [objWall, objDoor], [c_gray, c_orange]);
  ```
- Add to draw GUI event
  ```gml
  GMMinimap.draw(0, 0, 200, 200);
  ```
- Add to cleanup event
  ```gml
  GMMinimap.cleanup();
  ```
- Add object to room
- Enjoy!
