tool
extends Spatial

export var width: float = 30
export var height: float = 30
export var nesting_depth: int = 3
export var trigger_gen = false

onready var floor_plane = $FloorPlane
onready var road_path = $RoadPath
onready var csg_polygon = $RoadCSGPolygon

const splittings = 4
const road_size = 0.5
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

func _process(_delta):
	if (trigger_gen):
		trigger_gen = false
		gen_children(self, 0, width, height)

func gen_children(parent_node: Node, depth: int, cw: float, ch: float):
	var child_width = cw / 2
	var child_height = ch / 2
	for n in splittings:
		var new_node = Spatial.new()
		new_node.name = "CityBlock_%d_%d" % [depth, n]
		
		var x_offset = cw / 4
		if invert_x_offsets[n]:
			x_offset = -x_offset
		var z_offset = ch / 4
		if invert_z_offsets[n]:
			z_offset = -z_offset
		new_node.translate(Vector3(x_offset, 0, z_offset))
		parent_node.add_child(new_node)
		
		# Safe node to scene if run as tool script
		if Engine.editor_hint:
			new_node.owner = get_tree().get_edited_scene_root()
		
		if depth == nesting_depth - 1:
			setup_block(new_node, child_width, child_height)
		
		if depth < nesting_depth - 1:
			gen_children(new_node, depth + 1, child_width, child_height)

func setup_block(container_node: Node, cw: float, ch: float):
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(cw, ch)
	
	var floor_mesh_instance = MeshInstance.new()
	floor_mesh_instance.name = "Floor"
	floor_mesh_instance.mesh = plane_mesh
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
	st.generate_normals(true)
	st.generate_tangents()
	
	var road_mesh = st.commit()
	
	var road_instance = MeshInstance.new()
	road_instance.name = "Road"
	road_instance.mesh = road_mesh
	container_node.add_child(road_instance)
	
	# Safe node to scene if run as tool script
	if Engine.editor_hint:
		floor_mesh_instance.owner = get_tree().get_edited_scene_root()
		road_instance.owner = get_tree().get_edited_scene_root()
