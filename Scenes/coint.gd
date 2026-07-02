class_name Coin extends ItemDrop

enum Type_coin { COIN_5, COIN_10, COIN_15, COIN_20, COIN_25 }

var type_coin: Type_coin = Type_coin.COIN_5


func _ready() -> void:
	$AnimatedSprite2D.play(Type_coin.keys()[type_coin].to_lower())
	value = value_cost * type_coin
	super()


func index_to_type(index: int) -> void:
	type_coin = Type_coin[Type_coin.keys()[index]]
