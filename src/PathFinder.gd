extends Node

class_name PathFinder

var grid_map: GridMap = null
var navigation_id = -1
var astar: AStar = null

var navigation_points = []
var indexes = {}

func _init(grid_map, navigation_id):
	self.grid_map = grid_map
	self.navigation_id = navigation_id
	self.astar = AStar.new()
	
	for cell in grid_map.get_used_cells():
		var id = grid_map.get_cell_item(cell.x, cell.y, cell.z)
		
		if id == navigation_id:
			var point = Vector3(cell.x, cell.y, cell.z)
			navigation_points.append(point)
			var index = indexes.size()
			indexes[point] = index
			astar.add_point(index, point)
	
	for point in navigation_points:
		var index = get_point_index(point)
	
		if index < 0:
			continue
	
		var relative_points = PoolVector3Array([
			Vector3(point.x + 1, point.y, point.z),
			Vector3(point.x - 1, point.y, point.z),
			Vector3(point.x, point.y, point.z + 1),
			Vector3(point.x, point.y, point.z - 1)
		])
		
		for relative_point in relative_points:
			var relative_index = get_point_index(relative_point)
			
			if relative_index < 0:
				continue
			
			if astar.has_point(relative_index):
				astar.connect_points(index, relative_index)

func find_path(source, target):
	var grid_source = grid_map.world_to_map(source)
	var grid_target = grid_map.world_to_map(target)
	var index_source = get_point_index(grid_source)
	var index_target = get_point_index(grid_target)
	
	if (index_source == -1 || index_target == -1):
		return []
	
	var astar_path = astar.get_point_path(index_source, index_target)
	var world_path = []
	
	for point in astar_path:
		world_path.append(grid_map.map_to_world(point.x, point.y, point.z))
	
	return world_path

func get_point_index(vector):
	if indexes.has(vector):
		return indexes[vector]
	return -1
