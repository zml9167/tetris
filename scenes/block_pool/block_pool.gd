extends Node2D

class_name BlockPool

@export var block_scene: PackedScene

var blocks: Array[Node2D]
var idle_nodes: Array[Node2D]


func initialize(size: int):
	blocks.resize(size)
	blocks.fill(null)


func acquire_node() -> Node2D:
	var node
	if idle_nodes.is_empty():
		node = block_scene.instantiate()
		add_child(node)
	else:
		node = idle_nodes.pop_back()
		node.show()
	return node


func release_node(index: int) -> bool:
	if index < 0 or index >= blocks.size():
		return false
	var node = blocks[index]
	idle_nodes.append(node)
	node.hide()
	blocks[index] = null
	return true


func register_node(index: int , node: Node2D) -> bool:
	if index < 0 or index >= blocks.size():
		return false
	blocks[index] = node
	return true
