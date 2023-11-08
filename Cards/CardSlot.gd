extends MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	# Scale the Card Slot Sprite
	$Sprite.scale *= rect_size/$Sprite.texture.get_size()
	#$Sprite.position = Vector2(476,276)
	
	pass


