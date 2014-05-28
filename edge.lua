local path = ({...})[1]:gsub("[%.\\/][Ee]dge$", "") .. "."
local external = path .. "external."
local Class = require(external .. "hump.class")

local Edge = Class {}

function Edge:init(v1, v2)
	self.vertices = {v1, v2}
	self.faces = {}
end

function Edge:addFace(face, prev, next)
	self.faces[face] = {
		prev = prev, -- previous edge
		next = next, -- next edge
	}
end

return Edge
