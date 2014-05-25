local path = ({...})[1]:gsub("[%.\\/][Ff]ace$", "") .. "."
local external = path .. "external."
local Class = require(external .. "hump.class")

local Face = Class {}

function Face:init(edges)
	self.edges = edges
end

return Face
