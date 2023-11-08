extends TextureButton


# Declare member variables here. Examples:
var counter = 0
var initialNumberCards = 7


var Decksize = INF

# Called when the node enters the scene tree for the first time.
func _ready():
	rect_scale *= $'../../'.CardSize/rect_size



func _gui_input(event):
	if Input.is_action_just_released("leftclick"):
		if counter == 0 :
			# Initial drawing of 7 cards at the start of the game
			counter += 1
			for number in range (0,initialNumberCards):
				if $'../../'.PlayerHand.CardList.size() > 0:
					$'../../'.drawcard()
					yield(get_tree().create_timer(0.1), "timeout")
			if $'../../'.PlayerHand.CardList.size() == 0:
					disabled = true
		elif ($'../../'.isMyTurn && $'../../'.cardsDrawnThisChance == 0):
			# Draw a card from deck on your chance
			if $'../../'.PlayerHand.CardList.size() > 0:
				$'../../'.drawcard()
				$'../../'.cardsDrawnThisChance +=1
			if $'../../'.PlayerHand.CardList.size() == 0:
					disabled = true
			pass


func disable_deck():
	if $'../../'.PlayerHand.CardList.size() == 0:
			disabled = true
