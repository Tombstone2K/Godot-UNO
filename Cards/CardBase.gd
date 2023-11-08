extends MarginContainer


# Load Card DB
var CardDatabase = preload("res://Assets/Cards/CardsDatabase.gd")
var Cardname = "r_0"
#onready var CardInfo = CardDatabase.DATA[CardDatabase.get(Cardname)]
onready var CardImg = str("res://Assets/Cards/Units/",Cardname,".png")

# Declare variables like the start and target position and rotation of the cards
var startpos = Vector2()
var targetpos = Vector2()
var startrot = 0
var targetrot = 0
var t = 0
var DRAWTIME = 1
var ORGANISETIME = 0.5
onready var Orig_scale = rect_scale

# Enum for the state of the cards
enum{
	InHand
	InPlay
	InMouse
	FocusInHand
	MoveDrawnCardToHand
	ReOrganiseHand
	MoveDrawnCardToDiscard
	MoveCardToSlot
	InSlot
}
var state = InHand
# Called when the node enters the scene tree for the first time.
func _ready():
	# Load card images, border and initiliaze its scale
	var CardSize = rect_size
	$Border.scale *= CardSize/$Border.texture.get_size()
	$Card.texture = load(CardImg)
	$Card.scale *= CardSize/$Card.texture.get_size()
	$CardBack.scale *= CardSize/$CardBack.texture.get_size()
	$Focus.rect_scale *= CardSize/$Focus.rect_size

var setup = true
var startscale = Vector2(0,0)
var Cardpos = Vector2(0,0)

# Amount to zoom in and time in which to transition when one card is in focus
var ZoomInSize = 2
var ZOOMINTIME = 0.2 
var ReorganiseNeighbours = true # Flag to move neighbours a bit when one card is in focus
var NumberCardsHand = 0
onready var Card_Numb = 0
var NeighbourCard
var Move_Neightbour_Card_Check = false

var oldstate = INF 
var CARD_SELECT = true
var INMOUSETIME = 0.1 
var MovingtoInPlay = false
var targetscale = Vector2(0,0)

func _input(event):
	# Function to handle events
	
	# matching the state of the card # Similar to Switch Case Break in JAVA
	match state:
		InHand:
			pass
		FocusInHand:
			# Check if it is my Turn and whether selected card can be legally played
			if $'../../'.isMyTurn:
				if isCardLegal($'../../'.retrieveCardName(Card_Numb)):
					if event.is_action_pressed("leftclick"):
						if CARD_SELECT:
							# Change state of mouse to InMouse
							state = InMouse
							oldstate = state 					
							setup = true
							CARD_SELECT = false
						else:
							pass
					else:
						pass
				else :
					pass
			else:
				pass
		InMouse:
			if $'../../'.isMyTurn:
				if event.is_action_released("leftclick"):
					if CARD_SELECT == false :
						#print(oldstate)
						if oldstate == InMouse:
							#print('checkpoint 003')
							var CardSlots = $'../../CardSlots'
							var CardSlotEmpty = $'../../'.CardSlotEmpty
							for i in range(CardSlots.get_child_count()):
								if CardSlotEmpty[i]:
									var CardSlotPos= CardSlots.get_child(i).rect_position
									var CardSlotSize= CardSlots.get_child(i).rect_size
									var mousepos = get_global_mouse_position()
									if mousepos.x < CardSlotPos.x + CardSlotSize.x \
									&& mousepos.x > CardSlotPos.x \
									&& mousepos.y < CardSlotPos.y + CardSlotSize.y \
									&& mousepos.y > CardSlotPos.y :
										# If Mouse position is within bounds of the discard slot, end up playing the card
										setup = true 
										MovingtoInPlay= true
										# Assign the target Position and Scale
										targetpos = CardSlotPos - $'../../'.CardSize/2
										targetscale = CardSlotSize/rect_size
										state= InPlay
										CARD_SELECT = true
										#$'../../'.isMyTurn = false
										var playingcardinfoo = CardDatabase.DATA[CardDatabase.get($'../../'.retrieveCardName(Card_Numb))]
										if playingcardinfoo[3]:
											# If card played is a Wild Card, enable a color choosing grid to pick the color
											$'../../'.isWild = true
											$'../../'.enable_grid() 
											# Wait for 5 seconds for the players color choice
											yield(get_tree().create_timer(5.0), "timeout")
											pass
											$'../../'.isCardPlayedThisChance = false
											# Allow additional card to be played after wild
										else:
											$'../../'.isCardPlayedThisChance = true
											pass
										
										if $'../../'.isWild:
											$'../../'.isWild = false
											$'../../'.disable_grid() 
											var colours = ['r','g','b','y']
											randomize()
											colours.shuffle()
											$'../../'.colourAfterWild = colours[0]
											# Choose a random color if color picker is timed out
											pass
										else:
											pass
										
										#			 [ 0,          1,     2,     3,     4,        5,      6 ]
										# Unitinfo = [Type   , Colour, Number, Wild, DrawCard, Reverse, Skip]
										if playingcardinfoo[3]:
											# Spawn a new card indicating to other players the color to be played
											$'../../'.spawnNewCard(playingcardinfoo[4])
											#checkUNO()
											$'../../'.nextTurn($'../../'.TurnNumber,false,playingcardinfoo[4],playingcardinfoo[6])
											pass
										else:
											#checkUNO()
											$'../../'.nextTurn($'../../'.TurnNumber,playingcardinfoo[5],playingcardinfoo[4],playingcardinfoo[6])
											pass
										pass#break
									else: 
										pass
							if state!= InPlay :
								setup = true
								targetpos = Cardpos
								state= ReOrganiseHand
								CARD_SELECT = true
								pass
							#state = InPlay
							#print(state)
							else:
								pass
						else:
							setup=true
							state= MoveDrawnCardToDiscard
							pass
						pass
					else:
						pass
				else:
					pass
			else:
				pass
			pass
		InPlay:
			pass
		MoveDrawnCardToHand:
			pass
		ReOrganiseHand:
			pass
		MoveDrawnCardToDiscard:
			pass
		InSlot:
			pass
		MoveCardToSlot:
			pass

#onready var topcardname = $'../../'.TopCardName
#onready var TopCardInfo = CardDatabase.DATA[CardDatabase.get(topcardname)]

# Function to check whether the currently focused card can be played legally
func isCardLegal(CardName):
	var playingcardname = CardName#.Cardname
	var playingcardinfo = CardDatabase.DATA[CardDatabase.get(playingcardname)]
	
	# Checking is card is a wild card OR the color/number of card matches that of top card on the discard pile
	if (playingcardinfo[3]):
		return true
	if (playingcardinfo[1]== CardDatabase.DATA[CardDatabase.get($'../../'.TopCardName)][1]):
		return true
	if (playingcardinfo[2]==CardDatabase.DATA[CardDatabase.get($'../../'.TopCardName)][2]):
		return true
	return false

# Details the Translation and/or Rotation of the card based on its state
func _physics_process(delta):
	match state:
		InHand:
			pass
		InPlay:
			if MovingtoInPlay:
				if setup:
					Setup()
				if t <= 1: # Always be a 1
					rect_position = startpos.linear_interpolate(targetpos, t)
					rect_rotation = startrot * (1-t) + 0*t
					rect_scale = startscale * (1-t) + targetscale*t
					t += delta/float(INMOUSETIME)
				else:
					rect_position = targetpos
					rect_rotation = 0
					rect_scale = targetscale
					MovingtoInPlay = false
					$'../../'.ReParentCard(Card_Numb)
		InMouse:
			if t <= 1: # Always be a 1
				rect_position = startpos.linear_interpolate(get_global_mouse_position()- $'../../'.CardSize, t)
				rect_rotation = startrot * (1-t) + targetrot*t
				rect_scale.x = Orig_scale.x * abs(2*t - 1)
				if $CardBack.visible:
					if t >= 0.5:
						$CardBack.visible = false
				t += delta/float(INMOUSETIME)
			else:
				rect_position = get_global_mouse_position()-$'../../'.CardSize
				rect_rotation = 0
		FocusInHand:
			#print('152')
			if setup:
				Setup()
			if t <= 1: # Always be a 1
				rect_position = startpos.linear_interpolate(targetpos, t)
				rect_rotation = startrot * (1-t) + 0*t
				rect_scale = startscale * (1-t) + Orig_scale*2*t
				t += delta/float(ZOOMINTIME)
				if ReorganiseNeighbours:
					ReorganiseNeighbours = false
					NumberCardsHand = $'../../'.NumberCardsHand - 1 # offset for zeroth item
					if Card_Numb - 1 >= 0:
						Move_Neighbour_Card(Card_Numb - 1,true,1) # true is left!
					if Card_Numb - 2 >= 0:
						Move_Neighbour_Card(Card_Numb - 2,true,0.5)
					if Card_Numb + 1 <= NumberCardsHand +1:
						Move_Neighbour_Card(Card_Numb + 1,false,1)
					if Card_Numb + 2 <= NumberCardsHand+1:
						#print('ALERT 001')
						Move_Neighbour_Card(Card_Numb + 2,false,0.5)
					#print(Card_Numb)
				#print('172')
			elif state == InSlot:
				pass
			elif state == MoveCardToSlot:
				pass
			else:
				rect_position = targetpos
				rect_rotation = 0
				rect_scale = Orig_scale*ZoomInSize
				#print('177')
		MoveDrawnCardToHand: # animate from the deck to my hand
			if t <= 1: # Always be a 1
				rect_position = startpos.linear_interpolate(targetpos, t)
				rect_rotation = startrot * (1-t) + targetrot*t
				rect_scale.x = Orig_scale.x * abs(2*t - 1)
				$CardBack.visible = false
				if $CardBack.visible:
					if t >= 0.5:
						$CardBack.visible = false
				t += delta/float(DRAWTIME)
			else:
				rect_position = targetpos
				rect_rotation = targetrot
				state = InHand
				t = 0
		ReOrganiseHand:
			if setup:
				Setup()
			if t <= 1: # Always be a 1
				if Move_Neightbour_Card_Check:
					Move_Neightbour_Card_Check = false
				rect_position = startpos.linear_interpolate(targetpos, t)
				rect_rotation = startrot * (1-t) + targetrot*t
				rect_scale = startscale * (1-t) + Orig_scale*t
				t += delta/float(ORGANISETIME)
				if ReorganiseNeighbours == false:
					ReorganiseNeighbours = true
					if Card_Numb - 1 >= 0:
						Reset_Card(Card_Numb - 1) # true is left!
					if Card_Numb - 2 >= 0:
						Reset_Card(Card_Numb - 2)
					if Card_Numb + 1 <= NumberCardsHand +1 :
						Reset_Card(Card_Numb + 1)
					if Card_Numb + 2 <= NumberCardsHand +1:
						Reset_Card(Card_Numb + 2)
			else:
				rect_position = targetpos
				rect_rotation = targetrot
				rect_scale = Orig_scale
				state = InHand
		MoveDrawnCardToDiscard :
			pass
		MoveCardToSlot :
			#print('222222')
			Cardname = $'../../'.TopCardName
			targetrot=0
			targetpos = $'../../'.global_target_pos
			startrot = 0
			var startpos = Vector2(476,0)#$'../../'.CentreCardOval.x,0)
			if t <= 1: # Always be a 1
				#startpos = Vector2(0,0)
				rect_position = startpos.linear_interpolate(targetpos, t)
				rect_rotation = 0
				#startrot * (1-t) + targetrot*t
				rect_scale.x = Orig_scale.x * abs(2*t - 1)
				if $CardBack.visible:
					if t >= 0.5:
						$CardBack.visible = false

				t += delta/float(DRAWTIME)
				#state = InSlot
			else:
				rect_position = targetpos
				rect_rotation = targetrot
				state = InSlot
				t = 0
			pass
		InSlot:
			pass
	pass

# Function to move neighbouring cards when one card is in focus
func Move_Neighbour_Card(Card_Numb,Left,Spreadfactor):
	NeighbourCard = $'../'.get_child(Card_Numb)

	if Left:
		NeighbourCard.targetpos = NeighbourCard.Cardpos - Spreadfactor*Vector2(65,0)
	else:
		NeighbourCard.targetpos = NeighbourCard.Cardpos + Spreadfactor*Vector2(65,0)
	NeighbourCard.setup = true
	NeighbourCard.state = ReOrganiseHand
	NeighbourCard.Move_Neightbour_Card_Check = true
	pass

# Reset card positions after the focused card is no longer in focus
func Reset_Card(Card_Numb):
	if NeighbourCard.Move_Neightbour_Card_Check == false:
		NeighbourCard = $'../'.get_child(Card_Numb)
		if NeighbourCard.state != FocusInHand:
			NeighbourCard.state = ReOrganiseHand
			NeighbourCard.targetpos = NeighbourCard.Cardpos
			NeighbourCard.setup = true
	pass

func Setup():
	startpos = rect_position
	startrot = rect_rotation
	startscale = rect_scale
	t = 0
	setup = false
	pass

func _on_Focus_mouse_entered():
	match state:
		MoveCardToSlot, InSlot:
			pass
		InHand, ReOrganiseHand:
			setup = true
			targetpos = Cardpos
			targetpos.y = get_viewport().size.y - $'../../'.CardSize.y*ZoomInSize
			state = FocusInHand
	pass


func _on_Focus_mouse_exited():
	match state:
		FocusInHand:
			setup = true
			targetpos = Cardpos
			state = ReOrganiseHand
	pass
