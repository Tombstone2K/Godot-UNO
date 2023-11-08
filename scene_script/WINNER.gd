extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Displays "Game Over" along with the name of the winning player
	$Label.text = str("GAME OVER    " ,gamestate.get_winner()," WON!!!!")
	pass # Replace with function body.
