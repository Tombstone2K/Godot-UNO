extends Node2D

# Init card Size
const CardSize = Vector2(125,175)

# Load resources
const CardBase = preload("res://Cards/CardBase.tscn")
const PlayerHand = preload("res://Cards/Player_Hand.gd")
const CardSlot = preload("res://Cards/CardSlot.tscn")
onready var DeckSize = PlayerHand.CardList.size()

# Init Card paramters for holding in the players "hands", arranged on a virtual ellipse
var CardOffset = Vector2()
onready var CentreCardOval = get_viewport().size * Vector2(0.50, 1.3)
onready var Hor_rad = get_viewport().size.x*0.73
onready var Ver_rad = get_viewport().size.y*0.4
var angle = 0
var Card_Numb = 0
var NumberCardsHand = -1
var CardSpread = 0.085
var OvalAngleVector = Vector2()

# Init bool flags
var isCardPlayedThisChance = false
var winner_name =''
var UNOcheckk = false
var UNOflag = false
var cardsDrawnThisChance = 0
var colourAfterWild = ''
onready var AntiClock = false
var TurnNumber = 0
onready var isMyTurn = false
var Turn = ''
var PlayerOrder =[]
var global_target_pos = Vector2(426,136) - CardSize/2
onready var TopCardName = ''

onready var isWild = false

# Enum for cards state
enum{
	InHand
	InPlay
	InMouse
	FocusInHand
	MoveDrawnCardToHand
	ReOrganiseHand
	MoveDrawnCardToDiscard
	MoveCardToSlot
}

var CardSlotEmpty = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var NewSlot = CardSlot.instance()
	NewSlot.rect_position = Vector2(426,136)
	NewSlot.rect_size *= CardSize/NewSlot.rect_size
	$CardSlots.add_child(NewSlot)
	CardSlotEmpty.append(true)
	$Background/LABEL0.text = 'QWERTY'
	if gamestate.isHost:
		firstcard()
		isMyTurn = true
		
		# Randomize the order of the player's turns
		var AllPlayers = gamestate.get_player_list()
		AllPlayers.append(gamestate.get_player_name())
		randomize()
		AllPlayers.shuffle()
		PlayerOrder.clear()
		for number in range(0,AllPlayers.size()):
			PlayerOrder.append(AllPlayers[number])
		for number in range(0,AllPlayers.size()):
			if AllPlayers[number]==gamestate.get_player_name() :
				TurnNumber = number

		rpc("sync_get_player_list", AllPlayers, TurnNumber)
		set_label_names()
		enable_light(TurnNumber)
		pass
	else:
		#set_label_names()
		pass
	#
	$GridContainer/Button.rect_min_size.x = 75
	$GridContainer/Button2.rect_min_size.x = 75
	$GridContainer/Button3.rect_min_size.x = 75
	$GridContainer/Button4.rect_min_size.x = 75
	$GridContainer/Button.rect_min_size.y = 75
	$GridContainer/Button2.rect_min_size.y = 75
	$GridContainer/Button3.rect_min_size.y = 75
	$GridContainer/Button4.rect_min_size.y = 75
	pass

func set_label_names():
	# Set Label Names for the player. Prepend "(Y)" to the players name to indicate your username
	
	for number in range (0,PlayerOrder.size()):
		#$Background/LABEL
		pass
	$Background/LABEL0.visible = true
	if PlayerOrder[0] == gamestate.get_player_name() :
		$Background/LABEL0.text = str("(Y)",PlayerOrder[0])
	else:
		$Background/LABEL0.text = str(PlayerOrder[0])
	$Background/N0.visible = true
	$Background/NUMER0.visible = true
	if PlayerOrder.size()>=2:
		$Background/LABEL1.visible = true
		if PlayerOrder[1] == gamestate.get_player_name() :
			$Background/LABEL1.text = str("(Y)",PlayerOrder[1])
		else:
			$Background/LABEL1.text = str(PlayerOrder[1])
		$Background/N1.visible = true
		$Background/NUMER1.visible = true
		pass
	if PlayerOrder.size()>=3:
		$Background/LABEL2.visible = true
		if PlayerOrder[2] == gamestate.get_player_name() :
			$Background/LABEL2.text = str("(Y)",PlayerOrder[2])
		else:
			$Background/LABEL2.text = str(PlayerOrder[2])
		$Background/N2.visible = true
		$Background/NUMER2.visible = true
		pass
	if PlayerOrder.size()>=4:
		$Background/LABEL3.visible = true
		if PlayerOrder[3] == gamestate.get_player_name() :
			$Background/LABEL3.text = str("(Y)",PlayerOrder[3])
		else:
			$Background/LABEL3.text = str(PlayerOrder[3])
		$Background/N3.visible = true
		$Background/NUMER3.visible = true
		pass
	if PlayerOrder.size()>=5:
		$Background/LABEL4.visible = true
		if PlayerOrder[4] == gamestate.get_player_name() :
			$Background/LABEL4.text = str("(Y)",PlayerOrder[4])
		else:
			$Background/LABEL4.text = str(PlayerOrder[4])
		$Background/N4.visible = true
		$Background/NUMER4.visible = true
		pass
	if PlayerOrder.size()>=6:
		$Background/LABEL5.visible = true
		if PlayerOrder[5] == gamestate.get_player_name() :
			$Background/LABEL5.text = str("(Y)",PlayerOrder[5])
		else:
			$Background/LABEL5.text = str(PlayerOrder[5])
		$Background/N5.visible = true
		$Background/NUMER5.visible = true
		pass
		pass
	else:
		pass
	pass

var CardDatabase = preload("res://Assets/Cards/CardsDatabase.gd")

func firstcard():
	# Randomly choose the first card to go the discard pile to start play
		var new_cardd = CardBase.instance()
		#CardSelected = randi() % DeckSize
		randomize()
		var CardSelected = int(rand_range(0,DeckSize))
		#print(CardSelected)
		new_cardd.Cardname = PlayerHand.CardList[CardSelected]
		var playingcardinfoo = CardDatabase.DATA[CardDatabase.get(new_cardd.Cardname)]
		
		# Ensure the first Card is not a Wild Card
		if playingcardinfoo[3]:
			CardSelected = int(rand_range(0,DeckSize))
			new_cardd.Cardname = PlayerHand.CardList[CardSelected]
			playingcardinfoo = CardDatabase.DATA[CardDatabase.get(new_cardd.Cardname)]
			if playingcardinfoo[3]:
				CardSelected = int(rand_range(0,DeckSize))
				new_cardd.Cardname = PlayerHand.CardList[CardSelected]
				playingcardinfoo = CardDatabase.DATA[CardDatabase.get(new_cardd.Cardname)]
				if playingcardinfoo[3]:
					CardSelected = int(rand_range(0,DeckSize))
					new_cardd.Cardname = PlayerHand.CardList[CardSelected]
					playingcardinfoo = CardDatabase.DATA[CardDatabase.get(new_cardd.Cardname)]
					pass
				else:
					pass
				pass
			else:
				pass
			pass
		else:
			pass
		TopCardName = PlayerHand.CardList[CardSelected]
		new_cardd.rect_position = get_global_mouse_position() 
		#OvalAngleVector = Vector2(Hor_rad * cos(angle), - Ver_rad * sin(angle))
		new_cardd.startpos = Vector2(CentreCardOval.x,0)
		new_cardd.targetpos = global_target_pos
		new_cardd.Cardpos = new_cardd.targetpos
		new_cardd.startrot = 0
		new_cardd.targetrot = 0
		new_cardd.rect_scale *= CardSize/new_cardd.rect_size
		$CardsInPlay.add_child(new_cardd)
		new_cardd.state = MoveCardToSlot
		DeckSize -=1
		PlayerHand.CardList.erase(PlayerHand.CardList[CardSelected])
		
		# Signal whether Top Card changed
		sync_func(CardSelected,true,TopCardName)
		rpc("sync_top_card",new_cardd.Cardname)
		pass

func drawcard():
	# Draw a card to the player's hand.
	# Can be triggered by user click or UNO violation
	if PlayerHand.CardList.size()>0:
		# Realculate the new position of the cards in the players hands
		# as placed on the virtual ellipse after inclusion of newly drawn card
		angle = PI/2 + CardSpread*(float(NumberCardsHand)/2 - NumberCardsHand)
		var new_card = CardBase.instance()
		randomize()
		var CardSelected = int(rand_range(0,PlayerHand.CardList.size()))
		new_card.Cardname = PlayerHand.CardList[CardSelected]
		new_card.rect_position = get_global_mouse_position() 
		OvalAngleVector = Vector2(Hor_rad * cos(angle), - Ver_rad * sin(angle))
		new_card.startpos = $Deck.position - CardSize/2
		new_card.targetpos = CentreCardOval  - CardSize # + OvalAngleVector
		new_card.Cardpos = new_card.targetpos
		new_card.startrot = 0
		new_card.targetrot = (90 - rad2deg(angle))/6
		new_card.rect_scale *= CardSize/new_card.rect_size
		new_card.state = MoveDrawnCardToHand
		new_card.Card_Numb = NumberCardsHand
		Card_Numb = 0
		$Cards.add_child(new_card)
		PlayerHand.CardList.erase(PlayerHand.CardList[CardSelected])
		#print(PlayerHand.CardList)
		angle += 0.25
		DeckSize -= 1
		NumberCardsHand += 1
	#	Card_Numb += 1
		sync_func(CardSelected,false,'')
		OrganiseHand()
	else:
		$'../../'.disable_deck()
	return DeckSize

# Enable and Disable the 2x2 grid of colors for Color Picker
func enable_grid():
	$GridContainer.visible = true
	pass

func disable_grid():
	$GridContainer.visible = false
	pass

# Disable all turn indicators in the start
func disable_all_lights():
	$Background/LIGHT0.visible = false
	$Background/LIGHT1.visible = false
	$Background/LIGHT2.visible = false
	$Background/LIGHT3.visible = false
	$Background/LIGHT4.visible = false
	$Background/LIGHT5.visible = false
	pass

# Enable the indicator next to player's name to indicate whose turn it is
func enable_light(TemppTurnNumber):
	TemppTurnNumber = int(fposmod(TemppTurnNumber,PlayerOrder.size()))

	match int(TemppTurnNumber):
			0:
				$Background/LIGHT0.visible = true
				pass
			1:
				$Background/LIGHT1.visible = true
				pass
			2:
				$Background/LIGHT2.visible = true
				pass
			3:
				$Background/LIGHT3.visible = true
				pass
			4:
				$Background/LIGHT4.visible = true
				pass
			5:
				$Background/LIGHT5.visible = true
				pass
	pass

# Syncronize the player list
remote func sync_get_player_list(AllPlayersArray, TempTurnNumber):
	PlayerOrder.clear()
	for number in range(0,AllPlayersArray.size()):
		PlayerOrder.append(AllPlayersArray[number])
	TurnNumber = TempTurnNumber
	set_label_names()
	disable_all_lights()
	enable_light(TurnNumber)
	pass

func retrieveCardName(Temp_Card_Numb):
	var tempcardname  = $Cards.get_child(Temp_Card_Numb).Cardname
	return tempcardname
	pass

remote func sync_player_list(PlayerOrders):
	PlayerOrder.clear()
	for number in range(0,PlayerOrders.size()):
		PlayerOrder.append(PlayerOrders[number])
	pass
	
# Trigger the next turn accounting for the direction of play
func nextTurn(TurnNumberr, bReverse, nDrawCard, bSkip):
	isMyTurn = false
	cardsDrawnThisChance = 0
	
	# Reverse direction of play if a "Reverse Card" was played in this chance
	if bReverse:
		if AntiClock ==false:
			AntiClock = true
			$Background/ARROWR.visible = false
			$Background/ARROWL.visible = true
			pass
		elif AntiClock == true:
			AntiClock = false
			$Background/ARROWL.visible = false
			$Background/ARROWR.visible = true			
			pass
		else:
			pass
	else:
		pass
	if AntiClock == false :
		TurnNumber = TurnNumberr +1
		pass
	else:
		TurnNumber = TurnNumberr -1
		pass
	TurnNumber = int(fposmod(TurnNumber,PlayerOrder.size()))#TurnNumber % PlayerOrder.size()
	#	print(TurnNumber)
	
	# Sync the number of cards in the players hand
	if isCardPlayedThisChance:
		set_number_cards(TurnNumberr,($Cards.get_child_count()-1))
		if ($Cards.get_child_count()-1) !=1:
			disable_uno(TurnNumberr)
			rpc("sync_uno",TurnNumberr, false)
		pass
	else:
		set_number_cards(TurnNumberr,$Cards.get_child_count())
		if $Cards.get_child_count() !=1:
			disable_uno(TurnNumberr)
			rpc("sync_uno",TurnNumberr, false)
		pass
	isCardPlayedThisChance =false
	# Initiate the next turn using Remote Procedure Call
	rpc("initiate_next_turn",TurnNumber, AntiClock, nDrawCard, bSkip)
	pass

# Sync the number of cards in each players hands
remote func sync_no_cards(Tnumber, numberofcards):
	Tnumber = int(fposmod(Tnumber,PlayerOrder.size())) #Tnumber % PlayerOrder.size()
	match Tnumber:
		0:
			$Background/NUMER0.text = str("%02d" % numberofcards)#.pad_zeros(2)
			pass
		1:
			$Background/NUMER1.text =  str("%02d" % numberofcards)
			pass
		2:
			$Background/NUMER2.text =  str("%02d" % numberofcards)
			pass
		3:
			$Background/NUMER3.text =  str("%02d" % numberofcards)
			pass
		4:
			$Background/NUMER4.text =  str("%02d" % numberofcards)
			pass
		5:
			$Background/NUMER5.text =  str("%02d" % numberofcards)
			pass
	pass


func set_number_cards(Tnumber, numberofcards):
	Tnumber = int(fposmod(Tnumber,PlayerOrder.size()))#Tnumber % PlayerOrder.size()
	rpc("sync_no_cards",Tnumber, numberofcards)
	match Tnumber:
		0:
			$Background/NUMER0.text = str("%02d" % numberofcards)#.pad_zeros(2)
			pass
		1:
			$Background/NUMER1.text =  str("%02d" % numberofcards)
			pass
		2:
			$Background/NUMER2.text =  str("%02d" % numberofcards)
			pass
		3:
			$Background/NUMER3.text =  str("%02d" % numberofcards)
			pass
		4:
			$Background/NUMER4.text =  str("%02d" % numberofcards)
			pass
		5:
			$Background/NUMER5.text =  str("%02d" % numberofcards)
			pass
	pass

# Receiver function of the RPC call to initate next turn
remote func initiate_next_turn(TurnNumberrr, TempAntiClock, TempDrawCard, TempSkip):

	TurnNumber = int(fposmod(TurnNumberrr,PlayerOrder.size()))
	AntiClock = TempAntiClock
	if AntiClock ==false:
		#AntiClock = true
		$Background/ARROWR.visible = true
		$Background/ARROWL.visible = false
		pass
	elif AntiClock == true:
		#AntiClock = false
		$Background/ARROWL.visible = true
		$Background/ARROWR.visible = false
		pass
	else:
		pass
		
	# Check if it is "My Turn"
	if PlayerOrder[TurnNumber] == gamestate.get_player_name():

		isMyTurn = true
		isCardPlayedThisChance = false

		disable_all_lights()
		enable_light(TurnNumber)
		rpc("sync_all_lights",TurnNumber)
		if $Cards.get_child_count() !=1:
			disable_uno(TurnNumber)
			rpc("sync_uno",TurnNumber, false)
			UNOflag = false
		cardsDrawnThisChance = 0

		if (TopCardName=='d_r'||TopCardName=='d_y'||TopCardName=='d_g'||TopCardName=='d_b'||TopCardName=='w_r'||TopCardName=='w_y'||TopCardName=='w_g'||TopCardName=='w_b'):
			$GridContainer.visible=false
			pass
		else:
			pass
		if TempDrawCard !=0 :
			for number in range(0,TempDrawCard):
				drawcard()
				yield(get_tree().create_timer(0.3), "timeout")
			pass
		else:
			pass
		# If Player has been skipped, initate next turn
		if TempSkip:
			isMyTurn = false
			nextTurn(TurnNumber, false,0,false)
		else:
			pass
		pass
	else:
		pass
	pass

# Sync functions below ->
func sync_func(cardSelected,newTopCardBool,newTopCardVal):

	rpc("sync_players",cardSelected,newTopCardBool,newTopCardVal)
	pass

remote func sync_all_lights(tttnumber):
	disable_all_lights()
	tttnumber = int(fposmod(tttnumber,PlayerOrder.size()))
	enable_light(tttnumber)
	pass

remote func sync_players(player_data,newTopCardBool, newTopCardVal):

	if newTopCardBool:
		TopCardName = newTopCardVal
		pass
	else:
		pass
	PlayerHand.CardList.erase(PlayerHand.CardList[player_data])
	DeckSize -= 1

	pass

func ReParentCard(CardNo):
	# Change Parent of Card
	NumberCardsHand -= 1
	Card_Numb = 0
	var Card = $Cards.get_child(CardNo)
	var oldcount = $Cards.get_child_count()

	TopCardName = $Cards.get_child(CardNo).Cardname
	sync_card_slot(TopCardName)
	$Cards.remove_child(Card)
	$CardsInPlay.add_child(Card)
	
	if ($Cards.get_child_count() == 1):
		# If only one card remains, check whether player declares UNO
		checkUNO(oldcount)
		pass
	else:
		pass
	if $Cards.get_child_count() ==0:
		# Announce winner if zero cards in hand
		gamestate.set_winner()
		pass
	else:
		pass

	OrganiseHand()
	pass

# Check whether player declares UNO by clicking on the flash icon within stipulated time
func checkUNO(oldcount):
	if oldcount ==2:
		if $Cards.get_child_count() ==1:
			# Wait for 5 seconds for player to declare UNO
			yield(get_tree().create_timer(5.0), "timeout")
			if UNOflag :
				pass
			else:
				if $Cards.get_child_count()==1:
					# Trigger penalty for failing to declare UNO
					UNO_violation()
					pass
				else:
					pass
				pass
		else:
			pass
	else:
		pass
	pass

# Spawn New Top Card after new color has been picked
# to indicate to all players which color is to be played
func spawnNewCard(NumberOfCards):
	if NumberOfCards == 0 :
		if (colourAfterWild == 'r'):
			TopCardName = 'w_r'
			pass
		elif (colourAfterWild == 'y'):
			TopCardName = 'w_y'
			pass
		elif (colourAfterWild == 'g'):
			TopCardName = 'w_g'
			pass
		elif (colourAfterWild == 'b'):
			TopCardName = 'w_b'
			pass
		pass
	elif NumberOfCards == 4 :
		if (colourAfterWild == 'r'):
			TopCardName = 'd_r'
			pass
		elif (colourAfterWild == 'y'):
			TopCardName = 'd_y'
			pass
		elif (colourAfterWild == 'g'):
			TopCardName = 'd_g'
			pass
		elif (colourAfterWild == 'b'):
			TopCardName = 'd_b'
			pass
		pass
	else:
		pass
	sync_card_slot(TopCardName)
	new_top_card_animation()
	pass

# RPC function to Sync New Top Cards
func sync_card_slot(CardPlayedName):
	TopCardName = CardPlayedName
	rpc("sync_top_card",CardPlayedName)
	pass

# Receiver function to Sync New Top Card
remote func sync_top_card(NewTopCardName):
	TopCardName = NewTopCardName
	new_top_card_animation()
	pass

# Animation (Translation, Rotation) for New Top Card
func new_top_card_animation():
	var new_cardd = CardBase.instance()
	new_cardd.Cardname = TopCardName
	new_cardd.rect_position = get_global_mouse_position() 
	#OvalAngleVector = Vector2(Hor_rad * cos(angle), - Ver_rad * sin(angle))
	new_cardd.startpos = Vector2(CentreCardOval.x,0)
	new_cardd.targetpos = global_target_pos
	new_cardd.Cardpos = new_cardd.targetpos
	new_cardd.startrot = 0
	new_cardd.targetrot = 0
	new_cardd.rect_scale *= CardSize/new_cardd.rect_size
	$CardsInPlay.add_child(new_cardd)
	new_cardd.state = MoveCardToSlot
	pass

# Organize cards on the virtual Ellipse
func OrganiseHand():
	for Card in $Cards.get_children(): # reorganise hand
		angle = PI/2 + CardSpread*(float(NumberCardsHand)/2 - Card_Numb)
		OvalAngleVector = Vector2(Hor_rad * cos(angle), - Ver_rad * sin(angle))		
		Card.targetpos = CentreCardOval  - CardSize + OvalAngleVector
		Card.Cardpos = Card.targetpos # card default pos
		Card.startrot = Card.rect_rotation
		Card.targetrot = (90 - rad2deg(angle))/6
		Card.Card_Numb = Card_Numb
		Card_Numb += 1

		if Card.state == InHand:
			Card.setup = true
			Card.state = ReOrganiseHand
			Card.startpos = Card.rect_position
		elif Card.state == MoveDrawnCardToHand:
			Card.startpos = $Deck.position - CardSize/2
	pass

# Handle player picking Red Color in color picker after wild card
func _on_Button_pressed():
	$GridContainer.visible = false
	colourAfterWild = 'r'
	isWild =false
	pass # Replace with function body.

# Handle player picking Blue Color in color picker after wild card
func _on_Button2_pressed():
	$GridContainer.visible = false
	colourAfterWild = 'b'
	isWild =false
	pass # Replace with function body.

# Handle player picking Yellow Color in color picker after wild card
func _on_Button3_pressed():
	$GridContainer.visible = false
	isWild =false
	colourAfterWild = 'y'
	pass # Replace with function body.

# Handle player picking Green Color in color picker after wild card
func _on_Button4_pressed():
	$GridContainer.visible = false
	colourAfterWild = 'g'
	isWild =false
	pass # Replace with function body.

# Handle the pass button being pressed
func _on_PASS_pressed():
	# Only pass when one card has already been drawn from the deck
	if cardsDrawnThisChance ==1 :
		if (isMyTurn):
			if UNOcheckk == false:
				isMyTurn = false
				nextTurn(TurnNumber, false,0,false)
				pass
			else:
				pass
			pass
		else:
			pass
		pass
	else:
			pass
	pass # Replace with function body.


func isUNO():
	return $Cards.get_child_count()
	pass

# Penalty for UNO violation
func UNO_violation():
	drawcard()
	drawcard()
	pass

# Sync Flash Sign to indicate the player declaring UNO
func set_uno_symbol():
	for number in range(0,PlayerOrder.size()):
		if PlayerOrder[number]==gamestate.get_player_name():
			#disable_uno(number)
			enable_uno(number)
			rpc("sync_uno", number,true)
			pass
		else:
			pass
	pass

# Sync Flash Sign to indicate the player declaring UNO
remote func sync_uno(number,flag):
	if flag == true:
		enable_uno(number)
		pass
	else:
		pass
	if flag == false:
		disable_uno(number)
		pass
	else:
		pass
	pass

# Disable UNO Flash Sign next to players name
func disable_uno(number):
	number = int(fposmod(number,PlayerOrder.size()))#number % PlayerOrder.size()
	match number:
		0:
			$Background/UNO0.visible = false
			pass
		1:
			$Background/UNO1.visible = false
			pass
		2:
			$Background/UNO2.visible = false
			pass
		3:
			$Background/UNO3.visible = false
			pass
		4:
			$Background/UNO4.visible = false
			pass
		5:
			$Background/UNO5.visible = false
			pass
	pass

# Enable UNO flash sign next to players name
func enable_uno(number):
	number  = int(fposmod(number,PlayerOrder.size()))
	match number:
		0:
			$Background/UNO0.visible = true
			pass
		1:
			$Background/UNO1.visible = true
			pass
		2:
			$Background/UNO2.visible = true
			pass
		3:
			$Background/UNO3.visible = true
			pass
		4:
			$Background/UNO4.visible = true
			pass
		5:
			$Background/UNO5.visible = true
			pass
	pass

# Handle the UNO button being pressed
func _on_UNO_pressed():
	UNOflag = true
	if ($Cards.get_child_count()==1):
		set_uno_symbol()
		pass

	pass # Replace with function body.
