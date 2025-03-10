@tool
extends Node3D
 
@export var player_node: Node3D
@export var instance_amount : int = 100  # Number of instances to generate
@export var generate_colliders: bool = false
@export var collider_coverage_dist : float = 50

@export_range(0,50) var instance_min_scale: float = 1
@export var initial_instance_scale_factor: float = 0.1 # the final instance scale factor should always be the inverse of this factor
var final_instance_scale_factor: float = 1/initial_instance_scale_factor
@export_range(0,10) var scale_randomize : float = 0.0  # Amount of randomization for uniform scale
@export_range(0,PI) var instance_Y_rot : float = 0.0  # Amount of randomization for X rotation
@export_range(0,PI) var instance_X_rot : float = 0.0  # Amount of randomization for Y rotation 
@export_range(0,PI) var instance_Z_rot : float = 0.0  # Amount of randomization for Z rotation 
@export var rot_y_randomize : float = 0.0  # Amount of randomization for Y rotation 
@export var rot_x_randomize : float = 0.0  # Amount of randomization for X rotation 
@export var rot_z_randomize : float = 0.0  # Amount of randomization for Z rotation 
@export var instance_mesh : Mesh   # Mesh resource for each instance
@export var instance_material : Material   # material resource for each instance
@export var instance_collision : Shape3D
@onready var instance_rows: int 
@onready var offset: float 
@onready var multi_mesh_instance
@onready var multi_mesh
var h_scale: float = 1
var v_scale: float = 1
@onready var timer 
@onready var collision_parent
@onready var colliders: Array
@onready var colliders_to_spawn: Array
@onready var last_pos: Vector3
@onready var first_update= true
@onready var meshes_growing = false
@onready var growth_vector = Vector3(1,1,1)
@onready var growth_speed = 0.5
@onready var height := instance_mesh.get_aabb().size.y
#@onready var growth_randf_range_start = 1.0
#@onready var growth_randf_range_end = 1.05
@onready var ground_chunk_mesh: = $"../GEO_planeta2"
@onready var internal_ground_mesh: = $"../GEO_planeta2/GEO_planeta"
@onready var planet_collision_node: = $"../GEO_planeta2/GEO_planeta/StaticBody3D"
@onready var collision_shape: = $"../GEO_planeta2/GEO_planeta/StaticBody3D/CollisionShape3D"


func _ready():
	instance_mesh.surface_set_material(0, instance_material)
	print("instancer starting")
	height = instance_mesh.get_aabb().size.y
	# grow meshes here for testing
	#grow_meshes()
	
	#print("ground 1 ", ground_chunk_mesh)
	#print("ground 2  ", internal_ground_mesh)
	#print("ground 3   ", planet_collision_node)
	#print("ground 4    ", collision_shape)
	#print("gravity well: ", $"../GEO_planeta2/GravityWell")
	#print("gravity well bounding shape: ", $"../GEO_planeta2/GravityWell/BoundingShape")
	
	create_multimesh()
	
func create_multimesh():
	# Create a MultiMeshInstance3D and set its MultiMesh
	multi_mesh_instance = MultiMeshInstance3D.new()
	multi_mesh_instance.top_level = true
	multi_mesh = MultiMesh.new()
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	multi_mesh.instance_count = instance_amount
	var material = StandardMaterial3D.new()
	#material.set_path("res://Assets/Trees/mat_arvore.res")
	
	multi_mesh.mesh = instance_mesh
	instance_rows = sqrt(instance_amount) #rounded down to integer
	offset = round(instance_amount/instance_rows) #rounded up/down to nearest integer
	
	#wait for map to load before continuing
	#await heightmap.changed
	#hmap_img = heightmap.get_image()
	#width = hmap_img.get_width()
	#height = hmap_img.get_height()
	print("heightmap loaded")
	# Add the MultiMeshInstance3D as a child of the instancer
	add_child(multi_mesh_instance)
	
	self.global_position = Vector3(player_node.global_position.x,0.0,player_node.global_position.z).snapped(Vector3(1,0,1));
	multi_mesh_instance.multimesh = distribute_meshes()
	print("instancer startup done")
 
func get_random_point_on_sphere(radius : float):
	var phi = randf_range(0, TAU) # Azimuthal angle (around the "equator")
	var theta = acos(randf_range(-1, 1)) # Polar angle (from "pole" to "pole")

	var x = radius * sin(theta) * cos(phi)
	var y = radius * sin(theta) * sin(phi)
	var z = radius * cos(theta)

	return Vector3(x, y, z)
	
func raycast_down_to_surface_point(external_point : Vector3, node: Node3D) -> Vector3:
	var sphere_center = node.global_transform.origin
	var space_state = get_world_3d().direct_space_state
	# print("raycasting from ", external_point, " to ", sphere_center)
	var query = PhysicsRayQueryParameters3D.create(external_point, sphere_center) # Extend ray far enough
	var result = space_state.intersect_ray(query)

	if result:
		if result.collider == node: # check if the collision is with the desired node.
			var collision_point = result.position
			#print("result: ", result.collider)
			#print("Collision Point: ", collision_point)
			# Do something with the collision point, e.g., visualize it.
			# Example: create a marker at the collision point
			return collision_point
		else:
			print("Raycast hit something else: ", result.collider, " expected: ", node)
			return Vector3.ZERO
	else:
		print("No collision")
		return Vector3.ZERO
	
func align_mesh_y_to_vector(t: Transform3D, target_vector: Vector3):
	# 1. Handle zero-length target vector:
	if target_vector.length_squared() == 0:
		print("Warning: Target vector is zero length. Cannot align.")
		return

	var n1norm = t.basis.y.normalized()
	var n2norm = target_vector.normalized()
	var cosa = n1norm.dot(n2norm)
	var alpha = acos(cosa)
	var axis = n1norm.cross(n2norm)
	axis = axis.normalized()

	return t.rotated_local(axis, alpha)
	

 
func distribute_meshes():
	print("distribute meshes called")
	randomize()
	var planet = ground_chunk_mesh
	var outer_radius = 5 * planet.scale.x
	for i in range(instance_amount):
		var outer_point = get_random_point_on_sphere(outer_radius)
		
		var surface_point = raycast_down_to_surface_point(outer_point, planet_collision_node)
		if surface_point == Vector3.ZERO:
			print("Raycasting error... aborting this instance")
			continue

		#print("spawning stuff at surface point, ", surface_point)

		var normal_vector = surface_point.normalized()
		# account for half the size of assets before placing on surface (trees were stuffed inside the planet, for some reason)
		# surface_point = surface_point + (initial_instance_scale_factor * instance_mesh.get_aabb().size/2 * normal_vector)
		
		var rot = Vector3(0,0,0)

		rot.x += instance_X_rot + (randf() * PI * rot_x_randomize / 180)
		rot.y += instance_Y_rot + (randf() * PI * rot_y_randomize / 180)
		rot.z += instance_Z_rot + (randf() * PI * rot_z_randomize / 180)
		
		#print("spawning stuff with rotation ",rot)
		var t
		t = Transform3D()
		t.origin = surface_point
		# print("original transform: ", t)
		
		
		t = align_mesh_y_to_vector(t, normal_vector)
		# print("aligned transform: ", t)
		
		t = t.rotated(normal_vector,rot.x)
		t = t.rotated(normal_vector,rot.y)
		t = t.rotated(normal_vector,rot.z)
		
		t = t.scaled_local(Vector3(
			initial_instance_scale_factor,
			initial_instance_scale_factor,
			initial_instance_scale_factor
		))
		
		
		
		# Set the instance data
		multi_mesh.set_instance_transform(i, t)
 
		#Collisions
		if generate_colliders:
			if first_update:
				if i == instance_amount-1:
					first_update = false
					generate_subset()
			else:   
				if !colliders[i] == null:
					colliders[i].global_transform = t
 
	last_pos = global_position
	return multi_mesh
 
func random(x,z):
	var r = fposmod(sin(Vector2(x,z).dot(Vector2(12.9898,78.233)) * 43758.5453123),1.0)
	return r
	
func spawn_colliders():
	collision_parent = StaticBody3D.new()
	add_child(collision_parent)
	collision_parent.set_as_top_level(true)
	var c_shape = instance_collision
	
	for i in range(instance_amount):
		if colliders_to_spawn.has(i):
			var collider = CollisionShape3D.new()
			collision_parent.add_child(collider)
			collider.set_shape(instance_collision)
			colliders.append(collider)
		else:
			colliders.append(null)      
	
func generate_subset():
	for i in range(instance_amount):
		var t = multi_mesh.get_instance_transform(i)
		if t.origin.distance_squared_to(player_node.global_position) < pow(collider_coverage_dist,2):
			colliders_to_spawn.append(i)        
		if i==instance_amount-1:
			spawn_colliders()
 
func grow_meshes():
	print("start growing meshes ", instance_mesh.resource_name)
	meshes_growing = true

func _process(delta: float) -> void:
	if meshes_growing:
		growth_vector = Vector3(1,1,1) + Vector3(1,1,1) * growth_speed * delta
		grow_meshes_by(growth_vector)

func grow_meshes_by(scale_factor: Vector3):
	var t :Transform3D
	var normal_vector :Vector3
	var growth_upward :Vector3
	var new_height :float
	for i in range(instance_amount):
		t = multi_mesh.get_instance_transform(i)
		# keep the tree rooted in ground, as its pivot point is in the center
		# new_height = height * scale_factor.y
		# normal_vector = t.origin.normalized()
		# growth_upward = normal_vector * (new_height - height)/2
		# t.origin = t.origin + growth_upward
		# height = new_height
		multi_mesh.set_instance_transform(i, t.scaled_local(scale_factor))
	# print("current size ", t.basis.get_scale())
	# the last tree scale is the trigger to stop growth
	if t.basis.get_scale().x >= 1.0:
		print("stop growing meshes ", instance_mesh.resource_name)
		meshes_growing = false
