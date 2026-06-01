@tool
extends MeshInstance3D

@export_range(64, 16384, 8) var SIZE: float = 256.0:
	set(new_size):
		SIZE = new_size
		update_mesh()

@export_range(4, 256, 4) var resolution: int = 32:
	set(new_res):
		resolution = new_res
		update_mesh()

@export var noise: FastNoiseLite:
	set(new_noise):
		noise = new_noise
		update_mesh()
		if noise:
				noise.changed.connect(update_mesh)

@export_range(4.0, 128.0, 4.0) var height: float = 64.0:
	set(new_height):
		height = new_height
		material_override.set_shader_parameter("height", height * 2)
		update_mesh()

func get_height(x: float, y: float) -> float:
	return noise.get_noise_2d(x, y) * height

func get_normal(x: float, y: float) -> Vector3:
	var epsilon: float = SIZE / resolution
	var normal: Vector3 = Vector3(
		(get_height(x + epsilon, y) - get_height(x - epsilon, y)) / (2.0 * epsilon),
		1.0,
		(get_height(x, y + epsilon) - get_height(x, y - epsilon)) / (2.0 * epsilon),
	)
	return normal.normalized()

func update_mesh() -> void:
	var plane: PlaneMesh = PlaneMesh.new()
	plane.subdivide_depth = resolution
	plane.subdivide_width = resolution
	
	plane.size = Vector2(SIZE, SIZE)
	
	var plane_arrays: Array = plane.get_mesh_arrays()
	var vertex_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_VERTEX]
	var normal_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_NORMAL]
	var tangent_array: PackedFloat32Array = plane_arrays[ArrayMesh.ARRAY_TANGENT]
	
	for i: int in vertex_array.size():
		var vertex: = vertex_array[i]
		
		var normal: Vector3 = Vector3.UP
		var tangent: Vector3 = Vector3.RIGHT
		
		if noise:
			vertex.y = get_height(vertex.x, vertex.z)
			normal = get_normal(vertex.x, vertex.z)
			tangent = normal.cross(Vector3.UP)
		vertex_array[i] = vertex
		normal_array[i] = normal
		
		tangent_array[4 * i] = tangent.x
		tangent_array[4 * i + 1] = tangent.y
		tangent_array[4 * i + 2] = tangent.z
		
	var array_mesh: ArrayMesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_arrays)
	mesh = array_mesh
