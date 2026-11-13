extends Node

# Called when the node enters the scene tree for the first time.
func load_diary():
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
			var entry:Array
			#var entry_array_origin = str(commit_entry["commit"]["message"]).split("|")
			#if len(entry_array_origin) > 1:
			var date = str(commit_entry["commit"]["author"]["date"])
			date = date.replace("-", "")
			date = date.replace(":", "")
			#date[1] = date[1].get_slice("Z", 0)
			entry.append(date)
			#var tags = entry_array_origin[1]
			#entry.append(tags.split(", "))
			var content = str(commit_entry["commit"]["message"])
			entry.append(content)
			diary.append(entry)
			print(diary.find(entry))
			print(entry)
	#print(diary)
	diary.sort_custom(func(a, b): return a[0] < b[0])
	print(diary)
	return(diary)
