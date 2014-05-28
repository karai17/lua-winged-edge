local path = ({...})[1]:gsub("[%.\\/][Ff]ace$", "") .. "."
local external = path .. "external."
local Class = require(external .. "hump.class")

local Face = Class {}

function Face:init(vertices, edges)
	self.vertices = vertices
	self.edges = edges
end

return Face
