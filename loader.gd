extends Control

func _ready():
	var dir = Directory.new()
	var path = ""
	if OS.has_feature("editor"):
		path = "res://mods"
	else:
		path = OS.get_executable_path().get_base_dir().plus_file("mods")
	if dir.open(path) == OK:
		print("Found mods folder, loading mods...")
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".pck"):
				var mod_name = file_name.split(".")[0]
				printraw("Loading " + mod_name + "...")
				var success = ProjectSettings.load_resource_pack("res://mods/" + file_name)
				if success:
					var entrypoint_path = "res://"+mod_name+".gd"
					if ResourceLoader.exists(entrypoint_path):
						var node = Node.new()
						node.name = mod_name
						node.set_script(load(entrypoint_path))
						get_tree().root.call_deferred("add_child", node)
					print("Done.")
				else:
					print("Failed!")
			file_name = dir.get_next()
		print("Done loading mods")
	else:
		print("No mods folder found")
	var _tree = get_tree().change_scene("res://scenes/mainmenu.tscn")
