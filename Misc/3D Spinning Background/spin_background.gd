extends Node3D

## 0->prism[br]1->ring[br]2->outer ring[br]3->ancillary ring[br]4->camera
@export var speeds:Array[float]
@export var central_prism:MeshInstance3D
@export var ring:MeshInstance3D
@export var camera_pivot:Node3D
@export var outer_ring:MeshInstance3D
@export var ancillary_ring_1:MeshInstance3D
@export var ancillary_ring_2:MeshInstance3D
@export var ancillary_ring_3:MeshInstance3D
@export var ancillary_ring_4:MeshInstance3D
@export var ancillary_ring_5:MeshInstance3D
@export var ancillary_ring_6:MeshInstance3D
@export var ancillary_ring_7:MeshInstance3D
func _process(delta):
	central_prism.rotation_degrees +=  Vector3.ONE * delta * speeds[0]
	ring.rotation_degrees += Vector3.ONE * delta * speeds[1]
	outer_ring.rotation_degrees += Vector3.ONE * delta * speeds[2]
	ancillary_ring_1.rotation_degrees += Vector3.ONE * delta * speeds[3]
	ancillary_ring_2.rotation_degrees += Vector3.ONE * delta * speeds[3]
	ancillary_ring_3.rotation_degrees += Vector3.ONE * delta * speeds[3]
	ancillary_ring_4.rotation_degrees += Vector3.ONE * delta * speeds[3]
	ancillary_ring_5.rotation_degrees += Vector3.ONE * delta * speeds[3]
	ancillary_ring_6.rotation_degrees += Vector3.ONE * delta * speeds[3]
	ancillary_ring_7.rotation_degrees += Vector3.ONE * delta * speeds[3]
	camera_pivot.rotation_degrees += Vector3.ONE * delta * speeds[4]
