tool
extends Spatial

export var width: float = 600
export var height: float = 600
export var trigger_gen = false
export var trigger_cleanup = false

export var road_material: Material
export var floor_material: Material
export var building_material: Material

var gi_probe_node: Node

var minimal_house_scene
var minimal_skyscraper_scene

const splittings = 4
const road_size = 0.125
const invert_x_offsets = {
	0: false,
	1: true,
	2: false,
	3: true
}
const invert_z_offsets = {
	0: false,
	1: false,
	2: true,
	3: true
}

func _ready():
	if !Engine.editor_hint:
		trigger_gen = true

func _process(_delta):
	if (trigger_gen):
		trigger_gen = false
		minimal_house_scene = load("res://prefabs/MinimalHouse.tscn")
		minimal_skyscraper_scene = load("res://prefabs/MinimalSkyscraper.tscn")
		gen_children(self, 0, width, height)
		
	if trigger_cleanup:
		trigger_cleanup = false
		for node in get_children():
			node.queue_free()

func gen_children(parent_node: Node, depth: int, cw: float, ch: float):
	var w_divider = rand_range(1.6, 2.3)
	var child_width_1 = cw / w_divider
	var child_width_2 = cw - child_width_1
	var h_divider = w_divider
	var child_height_1 = ch / h_divider
	var child_height_2 = ch - child_height_1
	var dimensions = {
		0: [child_width_1, child_height_1],
		1: [child_width_2, child_height_1],
		2: [child_width_1, child_height_2],
		3: [child_width_2, child_height_2], 
	}
	
	for n in splittings:
		var new_node = Spatial.new()
		new_node.name = "CityBlock_%d_%d" % [depth, n]
		
		var child_dimension = dimensions[n]
		var opposite
		if n == 0:
			opposite = dimensions[3]
		elif n == 3:
			opposite = dimensions[0]
		elif n == 1:
			opposite = dimensions[2]
		else:
			opposite = dimensions[1]
		
		var x_offset = opposite[0] / 2
		if invert_x_offsets[n]:
			x_offset = -x_offset
		var z_offset = opposite[1] / 2
		if invert_z_offsets[n]:
			z_offset = -z_offset
		new_node.translate(Vector3(x_offset, 0, z_offset))
		parent_node.add_child(new_node)
		
		if child_dimension[0] < 14 or child_dimension[1] < 14:
			setup_block(new_node, child_dimension[0], child_dimension[1])
		else:
			gen_children(new_node, depth + 1, child_dimension[0], child_dimension[1])

func setup_block(container_node: Node, cw: float, ch: float):
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(cw, ch)
	
	var floor_mesh_instance = MeshInstance.new()
	floor_mesh_instance.name = "Floor"
	floor_mesh_instance.mesh = plane_mesh
	floor_mesh_instance.set_surface_material(0, floor_material)
	container_node.add_child(floor_mesh_instance)
	
	# Road generation
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	st.add_vertex(Vector3(-cw/2 + road_size, 0.01, -ch/2 + road_size))	#1
	st.add_vertex(Vector3(-cw/2, 0.01, -ch/2))							#2
	st.add_vertex(Vector3(cw/2 - road_size, 0.01, -ch/2 + road_size))	#3
	st.add_vertex(Vector3(cw/2, 0.01, -ch/2))							#4
	st.add_vertex(Vector3(cw/2 - road_size, 0.01, ch/2 - road_size))	#5
	st.add_vertex(Vector3(cw/2, 0.01, ch/2))							#6
	st.add_vertex(Vector3(-cw/2 + road_size, 0.01, ch/2 - road_size))	#7
	st.add_vertex(Vector3(-cw/2, 0.01, ch/2))							#8
	st.add_vertex(Vector3(-cw/2 + road_size, 0.01, -ch/2 + road_size))	#9
	st.add_vertex(Vector3(-cw/2, 0.01, -ch/2))							#10
	
	var road_mesh = st.commit()
	
	var road_instance = MeshInstance.new()
	road_instance.name = "Road"
	road_instance.mesh = road_mesh
	road_instance.set_surface_material(0, road_material)
	road_instance.use_in_baked_light = true
	container_node.add_child(road_instance)
	
	var building_depth_and_width = 2.5	
	
	var x_count = floor(cw / 3)
	var z_count = floor(ch / 3)
	
	var building_offset_x = (cw - road_size*2) / x_count
	var building_offset_z = (ch - road_size*2) / z_count
	
	var build_space_x = building_depth_and_width + (x_count - 1) * building_offset_x
	var build_space_z = building_depth_and_width + (z_count - 1) * building_offset_z

	var current_x_translate = (-cw / 2) + ((cw - build_space_x) / 2) + (building_depth_and_width / 2)
	for x in x_count:
		var current_z_translate = (-ch / 2) + ((ch - build_space_z) / 2) + (building_depth_and_width / 2)
		
		for z in z_count:
			var building_mesh_instance: Spatial
			if randf() > 0.8:
				building_mesh_instance = minimal_skyscraper_scene.instance()
			else:
				building_mesh_instance = minimal_house_scene.instance()
				
			building_mesh_instance.translate(Vector3(current_x_translate, 0, current_z_translate))
			building_mesh_instance.rotation = Vector3(0, round(randf() * 3) * PI, 0)
			building_mesh_instance.mesh_material = building_material
			container_node.add_child(building_mesh_instance)
			building_mesh_instance.setup()
			
			current_z_translate += building_offset_z
		
		current_x_translate += building_offset_x
