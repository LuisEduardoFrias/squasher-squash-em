class_name Resources extends ItemDrop

enum Type_resource { ROCK1, ROCK2, ROCK3, WOOD, METAL, HELMET, ARMOR, SWORD, BLADES }

var type_resource: Type_resource = Type_resource.WOOD


func _ready() -> void:
	$AnimatedSprite2D.play(Type_resource.keys()[type_resource].to_lower())
	value = value_cost * type_resource
	super()


func index_to_type(index: int) -> void:
	type_resource = Type_resource[Type_resource.keys()[index]]
