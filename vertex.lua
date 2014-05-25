local path = ({...})[1]:gsub("[%.\\/][Vv]ertex$", "") .. "."
local external = path .. "external."
local Class = require(external .. "hump.class")
local Vec3 = require(external .. "hump.vector3d")

local Vertex = Class {}

function Vertex:init(x, y, z)
	self.edges = {} -- list of edges connected to this vertex
	self.position = Vec3(x, y, z)
end

function Vertex:addEdge(edge)
	table.insert(self.edges, edge)
end

return Vertex
