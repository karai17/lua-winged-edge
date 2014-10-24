# Lua Winged Edge

Lua Winged Edge piggy backs off of my [**Wavefront Object Loader**][OBJ] library (among others) to create a comprehensive Winged Edge data structure. For further reading, please check the [**Documentation**][DOX].


## Quick Example

```lua
local we = require "winged-edge"

local object = we.new("some_object.obj")

for face in ipairs(obj.faces) do
	local adjacent = we.traverse(face, object)

	for _, adj_face in ipairs(adjacent) do
		print(face, adj_face)
	end
end
```


## License

This code is licensed under the [**MIT Open Source License**][MIT]. Check out the LICENSE file for more information.

[OBJ]: https://github.com/karai17/Lua-obj-loader
[DOX]: http://karai17.github.io/Lua-Winged-Edge/
[MIT]: http://www.opensource.org/licenses/mit-license.html
