extends TextureRect

@onready var rand := RandomNumberGenerator.new()

var time_passed := 0.0
func _process(delta):
	time_passed += delta
	if time_passed > 0.2:
		time_passed = 0
		texture.noise.seed = rand.randi()
