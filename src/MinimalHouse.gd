tool
extends Spatial

export var mesh_material: Material

func setup():
	var mesh_instance = $RootNode/Cube
	mesh_instance.set_surface_material(0, mesh_material)
	mesh_instance.use_in_baked_light = true

