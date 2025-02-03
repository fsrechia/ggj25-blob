@tool
extends Node3D
 
@export var player_node: Node3D
@export var instance_amount : int = 100  # Number of instances to generate
@export var generate_colliders: bool = false
@export var collider_coverage_dist : float = 50
@export var ground_chunk_mesh: NodePath
@export var pos_randomize : float = 0  # Amount of randomization for x and z positions
@export_range(0,50) var instance_min_scale: float = 1
@export var instance_height: float = 1
@export var instance_width: float = 1
@export var instance_spacing: int = 10
@export var terrain_height: float = 1
@export_range(0,10) var scale_randomize : float = 0.0  # Amount of randomization for uniform scale
@export_range(0,PI) var instance_Y_rot : float = 0.0  # Amount of randomization for X rotation
@export_range(0,PI) var instance_X_rot : float = 0.0  # Amount of randomization for Y rotation 
@export_range(0,PI) var instance_Z_rot : float = 0.0  # Amount of randomization for Z rotation 
@export var rot_y_randomize : float = 0.0  # Amount of randomization for Y rotation 
@export var rot_x_randomize : float = 0.0  # Amount of randomization for X rotation 
@export var rot_z_randomize : float = 0.0  # Amount of randomization for Z rotation 
@export var instance_mesh : Mesh   # Mesh resource for each instance
@export var instance_collision : Shape3D
@export var update_frequency: float = 0.01
@onready var instance_rows: int 
@onready var offset: float 
@onready var rand_x : float
@onready var rand_z : float
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
 
func _ready():
	print("instancer starting")
	create_multimesh()
	
func create_multimesh():
	#grab horizontal scale on the terrain mesh so match the scale of the heightmap in case your terrain is resized
	h_scale = get_node(ground_chunk_mesh).scale.x # could be x or z, doesn not matter as they should be the same
	v_scale = get_node(ground_chunk_mesh).scale.y
	print("scale: h ", h_scale, " v ", v_scale)
	# Create a MultiMeshInstance3D and set its MultiMesh
	multi_mesh_instance = MultiMeshInstance3D.new()
	multi_mesh_instance.top_level = true
	multi_mesh = MultiMesh.new()
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	multi_mesh.instance_count = instance_amount
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
	
	#Add timer for updates
	timer = Timer.new()
	$"..".add_child(timer)
	timer.timeout.connect(_update)
	timer.wait_time = update_frequency 
	_update()
	print("instancer startup done")
 
func _update():
	#on each update, move the center to player
	print("updating")
	self.global_position = Vector3(player_node.global_position.x,0.0,player_node.global_position.z).snapped(Vector3(1,0,1));
	multi_mesh_instance.multimesh = distribute_meshes()
	timer.wait_time = update_frequency
	timer.start()

func get_random_point_on_sphere(radius : float):
	var phi = randf_range(0, TAU) # Azimuthal angle (around the "equator")
	var theta = acos(randf_range(-1, 1)) # Polar angle (from "pole" to "pole")

	var x = radius * sin(theta) * cos(phi)
	var y = radius * sin(theta) * sin(phi)
	var z = radius * cos(theta)

	return Vector3(x, y, z)
	
func raycast_down_to_surface_point(external_point : Vector3, node: Node3D) -> Vector3:
	print("raycasting to node: ", node)
	var sphere_center = node.global_transform.origin
	var space_state = get_world_3d().direct_space_state
	print("raycasting from ", external_point, " to ", sphere_center)
	var query = PhysicsRayQueryParameters3D.create(external_point, sphere_center) # Extend ray far enough
	var result = space_state.intersect_ray(query)
	# 5. Check for Collision and Get Point
	if result:
		#if result.collider == node: # check if the collision is with the desired sphere.
			var collision_point = result.position
			print("result: ", result)
			print("Collision Point: ", collision_point)
			# Do something with the collision point, e.g., visualize it.
			# Example: create a marker at the collision point
			return collision_point
		#else:
			#print("Raycast hit something else")
			#print("result: ", result)
			#return Vector3.ZERO
	else:
		print("No collision")
		return Vector3.ZERO
	
func align_mesh_y_to_vector(t: Transform3D, target_vector: Vector3):
	# 1. Handle zero-length target vector:
	if target_vector.length_squared() == 0:
		print("Warning: Target vector is zero length. Cannot align.")
		return

	# 2. Calculate the rotation needed:
	#var current_y = t.basis.y.normalized()  # Current Y axis of the mesh
	#var rotation_quat = current_y.get_rotation_to(target_vector.normalized())
	#var axis = current_y.cross(target_vector).normalized()  # Find the rotation axis
	#var angle = acos(current_y.dot(target_vector))        # Find the rotation angle
	#var rotation_quat = Quaternion(axis, angle) # Create the quaternion

	var n1norm = t.basis.y.normalized()
	var n2norm = target_vector.normalized()
	var cosa = n1norm.dot(n2norm)
	var alpha = acos(cosa)
	var axis = n1norm.cross(n2norm)
	axis = axis.normalized()

	t = t.rotated(axis, alpha)

	# 3. Apply the rotation to the mesh instance:
	# There are a couple of ways to do this, depending on your desired behavior:

	# A. Replace the entire rotation:
	# This is the simplest approach and will completely reorient the mesh.
	# t.basis = Basis(rotation_quat) * t.basis.scaled(t.basis.get_scale())
	# This approach ensures that any scaling is preserved.
	return
	

 
func distribute_meshes():
	print("distribute meshes called")
	randomize()
	var planet = get_node(ground_chunk_mesh)
	var outer_radius = 2 * planet.scale.x
	for i in range(instance_amount):
		var outer_point = get_random_point_on_sphere(outer_radius)
		
		var surface_point = raycast_down_to_surface_point(outer_point, planet)
		if surface_point == Vector3.ZERO:
			print("Raycasting error... aborting this instance")
			continue

		print("spawning stuff at surface point, ", surface_point)

		var normal_vector = surface_point.normalized()
		
		var ori = surface_point
		var rot = Vector3(0,0,0)
		rot.x += instance_X_rot + (random(ori.x,ori.z) * rot_x_randomize)
		rot.y += instance_Y_rot + (random(ori.x,ori.z) * rot_y_randomize)
		rot.z += instance_Z_rot + (random(ori.x,ori.z) * rot_z_randomize)
		print("spawning stuff with rotation ",rot)
		var t
		t = Transform3D()
		t.origin = ori
		align_mesh_y_to_vector(t, normal_vector)
		
		t = t.rotated_local(t.basis.x.normalized(),rot.x)
		t = t.rotated_local(t.basis.y.normalized(),rot.y)
		t = t.rotated_local(t.basis.z.normalized(),rot.z)
 
		
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
 
