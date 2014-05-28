Lua Winged Edge
==
Lua Winged Edge piggy backs off of my [**Wavefront Object Loader**][OBJ] library (among others) to create a comprehensive Winged Edge data structure.

Quick Example
--
```lua
local we = require "libwe"

local we_object = we.new("some_object.obj")

for k, face in ipairs(obj.faces) do
	local adjacent = WE.traverse(face, we_object.faces, we_object.edges)

	for _, f in ipairs(adjacent) do
		print(k, f)
	end
end
```

License
--
This code is licensed under the [**MIT Open Source License**][MIT]. Check out the LICENSE file for more information.

[OBJ]: https://github.com/karai17/Lua-obj-loader
[MIT]: http://www.opensource.org/licenses/mit-license.html
