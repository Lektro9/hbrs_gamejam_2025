extends CanvasLayer
@onready var version_label: Label = $VersionLabel

func _ready() -> void:
	version_label.text = "Version: " + get_git_version()
	
func get_git_version() -> String:
	var version_path = "res://version.txt"
	if FileAccess.file_exists(version_path):
		var f = FileAccess.open(version_path, FileAccess.READ)
		var version = f.get_as_text().strip_edges()
		f.close()
		return version
	return "local-dev"
