local path = (...):gsub('%.init$', '') .. "."
local external = path .. "external."
local obj_loader = require(external .. "obj_loader")
local cpml = require(external .. "cpml")
local WE = {
	_VERSION = "0.1.0",
	_LICENSE = "Lua Winged Edge is licensed under the MIT Open Source License. See the LICENSE.md file for more information.",
	_DESCRIPTION = "A winged edge implementation that provides relational data between vertices, edges, and faces of a polygon structure.",
}

function WE.new(file)
	local data = obj_loader.load(file)
	local we_object = {}
	
	WE.parse_vertices(data, we_object)
	WE.parse_faces(data, we_object)

	return we_object
end

function WE.parse_vertices(object, data)
	object.vertices = {}

	for _, v in ipairs(data.v) do
		table.insert(object.vertices, WE.new_vertex(cpml.vec3(v.x, v.y, v.z)))
	end
end

function WE.parse_faces(object, data)
	object.edges = {}
	object.faces = {}

	for k, f in ipairs(data.f) do
		local vertices = {}
		local edges = {}
		
		for i=1, #f do
			local found = false
			local v1, v2

			if i == #f then
				v1 = f[i].v
				v2 = f[1].v
			else
				v1 = f[i].v
				v2 = f[i+1].v
			end

			table.insert(vertices, v1)
			local edge = WE.new_edge(v1, v2)

			for k, e in ipairs(object.edges) do
				if (
					e.vertices[1] == edge.vertices[1] and
					e.vertices[2] == edge.vertices[2]
				) or (
					e.vertices[1] == edge.vertices[2] and
					e.vertices[2] == edge.vertices[1]
				) then
					found = true
					table.insert(edges, k)
					break
				end
			end

			if not found then
				table.insert(object.edges, edge)
				table.insert(edges, #object.edges)
			end
		end

		table.insert(object.faces, WE.new_face(vertices, edges))

		for i=1, #edges do
			local prev, next

			if i == 1 then
				prev = edges[#edges]
			else
				prev = edges[i-1]
			end

			if i == #edges then
				next = edges[1]
			else
				next = edges[i+1]
			end

			WE.edge_add_face(object.edges[edges[i]], k, prev, next)
		end
	end

	for i, e in ipairs(object.edges) do
		for _, v in pairs(e.vertices) do
			WE.vertex_add_edge(object.vertices[v], i)
		end
	end
end

function WE.traverse(object, face)
	local adj = {}
	local first = object.faces[face].edges[1]
	local n = 0

	local function next(edge)
		for k, f in pairs(object.edges[edge].faces) do
			if f.face == face then
				n = k
			else
				table.insert(adj, f.face)
			end
		end

		return object.edges[edge].faces[n].next
	end

	local edge = next(first)

	while edge ~= first do
		edge = next(edge)
	end

	return adj
end

function WE.triangulate(object, face)
	local vertices = {}
	for _, v in ipairs(object.faces[face].vertices) do
		table.insert(vertices, v)
	end

	if #vertices < 3 then return {} end

	local triangles = {}
	for i = 2, #vertices-1 do
		table.insert(triangles, { vertices[1], vertices[i], vertices[i+1] })
	end

	return triangles
end

function WE.intersect(ray, triangle)
	return cpml.intersect.ray_triangle(ray, triangle)
end

function WE.new_vertex(position)
	return {
		edges = {},
		position = position,
	}
end

function WE.get_vertex(object, vertex)
	return object.vertices[vertex]
end

function WE.vertex_add_edge(vertex, edge)
	table.insert(vertex.edges, edge)
end

function WE.new_edge(v1, v2)
	return {
		vertices = { v1, v2 },
		faces = {},
	}
end

function WE.get_edge(object, edge)
	return object.edges[edge]
end

function WE.edge_add_face(edge, face, prev, next)
	table.insert(edge.faces, {
		face = face,
		prev = prev, -- previous edge
		next = next, -- next edge
	})
end

function WE.new_face(vertices, edges)
	return {
		vertices = vertices,
		edges = edges,
	}
end

function WE.get_face(object, face)
	return object.faces[face]
end

return WE
