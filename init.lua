--[[
------------------------------------------------------------------------------
Lua Winged Edge is licensed under the MIT Open Source License.
(http://www.opensource.org/licenses/mit-license.html)
------------------------------------------------------------------------------

Copyright (c) 2014 Landon Manning - LManning17@gmail.com - LandonManning.com
                   Colby Klein - excessive.io

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local path = ... .. "."
local external = path .. "external."
local WE = {}

WE.version = "0.0.3"

local Vertex = require(path .. "vertex")
local Edge = require(path .. "edge")
local Face = require(path .. "face")
local obj_loader = require(external .. "obj_loader")
local Vec3 = require(external .. "hump.vector3d")

function WE.new(file)
	local object = obj_loader.load(file)
	local we_object = {}
	
	we_object.vertices = WE.parseVertices(object)
	we_object.edges, we_object.faces = WE.parseFaces(object, we_object.vertices)

	return we_object
end

function WE.parseVertices(object)
	local vertices = {}

	for _, v in ipairs(object.v) do
		table.insert(vertices, Vertex(Vec3(v.x, v.y, v.z)))
	end

	return vertices
end

function WE.parseFaces(object, we_vertices)
	local faces = {}
	local we_edges = {}

	for _, f in ipairs(object.f) do
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
			local edge = Edge(we_vertices[v1], we_vertices[v2])

			for k, e in ipairs(we_edges) do
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
				table.insert(we_edges, edge)
				table.insert(edges, #we_edges)
			end
		end

		local face = Face(vertices, edges)
		table.insert(faces, face)

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

			we_edges[edges[i]]:addFace(face, prev, next)
		end
	end

	for _, e in ipairs(we_edges) do
		for _, v in pairs(e.vertices) do
			v:addEdge(e)
		end
	end

	return we_edges, faces
end

function WE.traverse(face)
	local adj = {}
	local first = face.edges[1]

	local function next(edge)
		for f in pairs(edge.faces) do
			if f ~= face then table.insert(adj, f) end
		end

		return edge.faces[face].next
	end

	local edge = next(first)

	while edge ~= first do
		edge = next(edge)
	end

	return adj
end

function WE.triangulate(face)
	local vertices = {}
	for _, v in ipairs(face.vertices) do
		table.insert(vertices, v)
	end

	if #vertices < 3 then return {} end

	local triangles = {}
	for i = 2, #vertices-1 do
		table.insert(triangles, { vertices[1], vertices[i], vertices[i+1] })
	end

	return triangles
end

function WE.intersect(p, d, triangle)
	assert(#triangle == 3)

	local h, s, q = Vec3(), Vec3(), Vec3()
	local a, f, u, v

	local e1 = triangle[2] - triangle[1]
	local e2 = triangle[3] - triangle[1]

	h = d:clone():cross(e2)

	a = (e1*h) -- dot product

	if a > -0.00001 and a < 0.00001 then
		return false
	end

	f = 1/a
	s = p - triangle[1]
	u = f * (s*h)

	if u < 0 or u > 1 then
		return false
	end

	q = s:clone():cross(e1)
	v = f * (d*q)

	if v < 0 or u + v > 1 then
		return false
	end

	-- at this stage we can compute t to find out where
	-- the intersection point is on the line
	t = f * (e2*q)

	if t > 0.00001 then
		return true -- we've got a hit!
	else
		return false -- the line intersects, but it's behind the point
	end
end

return WE
