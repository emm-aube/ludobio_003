@tool
extends RichTextLabel

var souvenirs: Dictionary = {}
var selected_souvenir: String = ""

func _ready():
	load_souvenirs()
	notify_property_list_changed()
	update_text()

func load_souvenirs():
	souvenirs.clear()

	var data = JSON.parse_string(
		FileAccess.get_file_as_string("res://text/pool.json")
	)

	if data is Dictionary:
		for entry in data.get("souvenirs", []):
			souvenirs[entry["SOUVENIR"]] = entry["ASCII"]

func _get_property_list() -> Array[Dictionary]:
	return [{
		"name": "souvenir",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(souvenirs.keys()),
		"usage": PROPERTY_USAGE_DEFAULT
	}]

func _set(property: StringName, value: Variant) -> bool:
	if property == "souvenir":
		selected_souvenir = value
		update_text()
		return true
	return false

func _get(property: StringName) -> Variant:
	if property == "souvenir":
		return selected_souvenir
	return null

func update_text():
	text = souvenirs.get(selected_souvenir, "")