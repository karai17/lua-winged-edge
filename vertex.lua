local path = ({...})[1]:gsub("[%.\\/][Vv]ertex$", "") .. "."
local external = path .. "external."
local Class = require(external .. "hump.class")

local Vertex = Class {}

function Vertex:init(pos)
	self.edges = {}
	self.position = pos
end

function Vertex:addEdge(edge)
	table.insert(self.edges, edge)
end

return Vertex
