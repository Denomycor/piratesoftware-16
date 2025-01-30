class_name MainMenu extends CanvasLayer

@onready var tab_container := $TabContainer
@onready var options_menu: OptionsMenu = $TabContainer/OptionsMenu


func _ready() -> void:
	options_menu.back_button.pressed.connect(func(): tab_container.current_tab = 0)
	%options.pressed.connect(func(): 
		tab_container.current_tab = 1
		$click.play()
	)
	%credits.pressed.connect(func(): 
		tab_container.current_tab = 2
		$click.play()
	)
	%back2.pressed.connect(func(): 
		tab_container.current_tab = 0
		$click.play()
	)
