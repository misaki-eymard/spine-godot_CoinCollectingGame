extends Panel

func _ready():
	set_visible(false)

func _on_HelpButton_pressed():
	if is_visible() == true:
		set_visible(false)
	elif is_visible() == false:
		set_visible(true)
