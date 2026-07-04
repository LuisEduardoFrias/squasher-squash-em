extends Node

var game_level: int = 1
var player_level: int = 1
var player_ph = 0
var player_max_exp: float = 500.0
var player_exp: float = 0.0:
	set(val):
		player_exp = val
		if player_exp >= player_max_exp:
			player_exp = 0.0
			player_level += 1
			player_ph += 1
var player_max_live: float = 500.0
var player_live: float = 500.0
var coins: float = 0
var resource: float = 0


var skills = [
	{
		"img": Rect2(168.0, 261.0, 36.0, 38.0),
		"name": "fist of fire",
		"ph": 2,
		"lv_required": 1,
		"coin": 80,
		"resource": 100,
		"lv": 1,
		"timer": 50
	},
	{
		"img": Rect2(132.0, 261.0, 36.0, 38.0),
		"name": "lightning storm",
		"ph": 3,
		"lv_required": 2,
		"coin": 95,
		"resource": 125,
		"lv": 1,
		"timer": 25
	},
	{
		"img": Rect2(132.0, 299.0, 36.0, 38.0),
		"name": "cloud of toxic gas",
		"ph": 2,
		"lv_required": 1,
		"coin": 60,
		"resource": 90,
		"lv": 1,
		"timer": 8
	}
]


var store = [
	{
		"item_id": 565,
		"img": Rect2(132.0, 337.0, 36.0, 38.0),
		"name": "Muro de Troncos",
		"lv": 0,
		"item": "res://Scenes/item_trunk_wall.tscn",
		"coins_pay": 50,
		"resource_pay": 15,
		"lv_required": 2,
		"ph_required": 0,
		"coins_required": 50,
		"resource_required": 15
	},
	{
		"item_id": 574,
		"img": Rect2(132.0, 375.0, 36.0, 38.0),
		"name": "Barrera de Espinas",
		"lv": 0,
		"item": "res://Scenes/item_spine_barrier.tscn",
		"coins_pay": 75,
		"resource_pay": 10,
		"lv_required": 2,
		"ph_required": 1,
		"coins_required": 75,
		"resource_required": 10
	},
	{
		"item_id": 348,
		"img": Rect2(132.0, 414.0, 36.0, 38.0),
		"name": "Defensa Escarpa", # Troncos en 45°
		"lv": 0,
		"item": "res://Scenes/item_escarpment_defense.tscn",
		"coins_pay": 90,
		"resource_pay": 20,
		"lv_required": 3,
		"ph_required": 1,
		"coins_required": 90,
		"resource_required": 20
	},
	{
		"item_id": 963,
		"img": Rect2(132.0, 451.0, 36.0, 38.0),
		"name": "Foso con Púas",
		"lv": 0,
		"item": "res://Scenes/item_barbed_wire_pit.tscn",
		"coins_pay": 120,
		"resource_pay": 25,
		"lv_required": 3,
		"coins_required": 75,
		"ph_required": 2,
		"resource_required": 25
	},
	{
		"item_id": 431,
		"img": Rect2(168.0, 337.0, 36.0, 38.0),
		"name": "Campo de Abrojos", # Púas triangulares
		"lv": 0,
		"item": "res://Scenes/item_burrfield.tscn",
		"coins_pay": 150,
		"resource_pay": 15,
		"lv_required": 3,
		"ph_required": 2,
		"coins_required": 150,
		"resource_required": 15
	},
	{
		"item_id": 688,
		"img": Rect2(168.0, 375.0, 36.0, 38.0),
		"name": "Lecho de Brea",
		"lv": 0,
		"item": "res://Scenes/item_tar_bed.tscn",
		"coins_pay": 100,
		"resource_pay": 30,
		"lv_required": 3,
		"ph_required": 3,
		"coins_required": 100,
		"resource_required": 30
	},
	{
		"item_id": 446,
		"img": Rect2(168.0, 413.0, 36.0, 38.0),
		"name": "Puesto de Guardia", # Torre pequeña con personaje
		"lv": 0,
		"item": "res://Scenes/item_guard_post.tscn",
		"coins_pay": 200,
		"resource_pay": 40,
		"lv_required": 4,
		"ph_required": 3,
		"coins_required": 200,
		"resource_required": 40
	},
	{
		"item_id": 992,
		"img": Rect2(168.0, 451.0, 36.0, 38.0),
		"name": "Torre de Vigilancia", # Torre alta
		"lv": 0,
		"item": "res://Scenes/item_watchtower.tscn",
		"coins_pay": 350,
		"resource_pay": 60,
		"lv_required": 4,
		"ph_required": 4,
		"coins_required": 350,
		"resource_required": 60
	}
]
