extends Node

# Called when the node enters the scene tree for the first time.
func load_diary():
	$HTTPRequest.request_completed.connect(open_diary)
	var url = "https://api.github.com/repos/emm-aube/Ludobio_003/commits?sha=diary"
	$HTTPRequest.request(url)
	
func open_diary(result, response_code, headers, body):
	if response_code != 200:
		print("github not accessed", response_code)
		return
	var commits = JSON.parse_string(body.get_string_from_utf8())
	for entry in commits:
		if entry["commit"]["author"]["name"] == "Diary Bot":
			print(entry["commit"]["message"])


func obsolete():
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
