extends Control

const ListItem = preload("res://src/Interface/gunSlot.tscn")

var listIndex = 0

func addItem( value ):
	var item = ListItem.instance()
	listIndex += 1
	item.get_node("Bullets").text = str(value)
	item.rect_min_size = Vector2(50,50)
	$list.add_child(item)
	
func addAmmo( value ):
	print(value)
	
	
func selectGun( value ):
	print('Selected  ', value)

func _ready() -> void:
	pass
#	addItem(5)
#	for i in range(5):
#		addItem(i)
		
func _process(delta: float) -> void:
	pass


#
#func _on_Arma_body_entered(body: Node) -> void:
#	if body.get_name() == "Player":
#		addItem(15)
#
	
	
	
	