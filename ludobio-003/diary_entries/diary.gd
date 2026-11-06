extends Node

# Called when the node enters the scene tree for the first time.
func make_diary():
	var diary:Array
	var diary_source = DirAccess.open("res://diary_entries/")

	for diary_source_entry in diary_source.get_files():
		if diary_source_entry.ends_with(".txt"):
			var diary_file = FileAccess.open("res://diary_entries/" + diary_source_entry, FileAccess.READ)
			var diary_line:int = 0
			var content:String = ""
			var entry:Array
			while !diary_file.eof_reached():
				if diary_line == 0:
					entry.append(diary_file.get_line())
				elif diary_line == 1:
					entry.append(diary_file.get_line().split(" "))
				else:
					content += diary_file.get_line()
				diary_line += 1
			entry.append(content)
			diary.append(entry)
	return(diary)
