extends Node

# Called when the node enters the scene tree for the first time.
func load_diary():
	#$HTTPRequest.request_completed.connect(open_diary)
	var url = "https://api.github.com/repos/emm-aube/Ludobio_003/commits?sha=diary"
	$HTTPRequest.request(url)

	var response = await $HTTPRequest.request_completed
	return open_diary(response[0],response[1], response[2], response[3]) 
	
func open_diary(result, response_code, headers, body):
	var diary:Array
	if response_code != 200:
		print("github not accessed", response_code)
		return
	var commits = JSON.parse_string(body.get_string_from_utf8())
	for commit_entry in commits:
		if commit_entry["commit"]["author"]["name"] == "Diary Bot":
			#print(commit_entry["commit"]["message"])


	
	#var diary_source = DirAccess.open("res://diary_entries/")

	#for diary_source_entry in diary_source.get_files():
		#if diary_source_entry.ends_with(".txt"):
			#var diary_file = FileAccess.open("res://diary_entries/" + diary_source_entry, FileAccess.READ)
			#var entry_file:String = commit_entry["commit"]["message"]
			#print(diary_file)
			#var diary_line:int = 0
			var entry:Array
			var entry_array_origin = str(commit_entry["commit"]["message"]).split("|")
			if len(entry_array_origin) > 1:
				entry.append(commit_entry["commit"]["author"]["date"])
				
				#print (entry_array_origin)
				var tags = entry_array_origin[1]
				#print(tag_entry)
				entry.append(tags.split(", "))
				var content = entry_array_origin[0]
				entry.append(content)
				#entry.append(entry_array_origin[1])
				#print (entry[1])
				#var content = " "
				
				#while !diary_file.eof_reached():
				#	if diary_line == 0:
				#		entry.append(diary_file.get_line())
				#	elif diary_line == 1:
				#		entry.append(diary_file.get_line().split(" "))
				#	else:
				#		content += diary_file.get_line()
				#	diary_line += 1
				#entry.append(content)
				#print(entry)
				diary.append(entry)
	print(diary)
	return(diary)
