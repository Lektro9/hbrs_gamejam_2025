extends TextureRect

@onready var rand := RandomNumberGenerator.new()

func _process(_delta):
	texture.noise.seed = rand.randi()