tool
extends Spatial

export var width: float = 30
export var height: float = 30
export var nesting_depth: int = 3
export var trigger_gen = false

onready var floor_plane = $FloorPlane
onready var road_path = $RoadPath
onready var csg_polygon = $RoadCSGPolygon

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if (trigger_gen):
		trigger_gen = false
		gen_children()


func setup_grid():
	var floor_mesh: PlaneMesh = floor_plane.mesh
	floor_mesh.size = Vector2(width, height)
	floor_plane.visible = true
	floor_plane.owner = get_tree().get_edited_scene_root()
	
	var offset_x = width / 2
	var offset_z = height / 2
	road_path.curve.clear_points()
	road_path.curve.add_point(offset_x, offset_x)
	road_path.curve.add_point(-offset_x, offset_x)
	road_path.curve.add_point(-offset_x, -offset_x)
	road_path.owner = get_tree().get_edited_scene_root()
	
	csg_polygon.path_node = road_path.get_path()
	csg_polygon.visible = true
	csg_polygon.owner = get_tree().get_edited_scene_root()
	
func gen_children():
	var city_grid_scene = load("res://src/CityGridNode.tscn")
	
	var scene_1 = city_grid_scene.duplicate(true)
	scene_1.resource_local_to_scene = true
	
	var scene_2 = city_grid_scene.duplicate(true)
	scene_2.resource_local_to_scene = true
	
	var scene_3 = city_grid_scene.duplicate(true)
	scene_3.resource_local_to_scene = true
	
	var scene_4 = city_grid_scene.duplicate(true)
	scene_4.resource_local_to_scene = true
	
	var offsetX = width / 4
	var offsetZ = height / 4
		
	var grid_node_1 = scene_1.instance()
	grid_node_1.width = width / 2
	grid_node_1.height = height / 2
	if (nesting_depth > 0):
		grid_node_1.nesting_depth = nesting_depth - 1
		grid_node_1.trigger_gen = true
	grid_node_1.translate(Vector3(offsetX, 0, offsetZ))
	add_child(grid_node_1)
	grid_node_1.owner = get_tree().get_edited_scene_root()
	if (nesting_depth <= 0):
		grid_node_1.setup_grid()

	var grid_node_2 = scene_2.instance()
	grid_node_2.width = width / 2
	grid_node_2.height = height / 2
	if (nesting_depth > 0):
		grid_node_2.nesting_depth = nesting_depth - 1
		grid_node_2.trigger_gen = true
	grid_node_2.translate(Vector3(-offsetX, 0, offsetZ))
	add_child(grid_node_2)
	grid_node_2.owner = get_tree().get_edited_scene_root()
	if (nesting_depth <= 0):
		grid_node_2.setup_grid()
	
	var grid_node_3 = scene_3.instance()
	grid_node_3.width = width / 2
	grid_node_3.height = height / 2
	if (nesting_depth > 0):
		grid_node_3.nesting_depth = nesting_depth - 1
		grid_node_3.trigger_gen = true
	grid_node_3.translate(Vector3(offsetX, 0, -offsetZ))
	add_child(grid_node_3)
	grid_node_3.owner = get_tree().get_edited_scene_root()
	if (nesting_depth <= 0):
		grid_node_3.setup_grid()
	
	var grid_node_4 = scene_4.instance()
	grid_node_4.width = width / 2
	grid_node_4.height = height / 2
	if (nesting_depth > 0):
		grid_node_4.nesting_depth = nesting_depth - 1
		grid_node_4.trigger_gen = true
	grid_node_4.translate(Vector3(-offsetX, 0, -offsetZ))
	add_child(grid_node_4)
	grid_node_4.owner = get_tree().get_edited_scene_root()
	if (nesting_depth <= 0):
		grid_node_4.setup_grid()
