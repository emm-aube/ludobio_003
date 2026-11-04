extends Resource
class_name Anchor

enum anchor_enum{
	Mum, 
	Adam, 
	Migraine, 
	Pill, 
	Family, 
	Dog
}

@export var anchors:anchor_enum
@export_range (0.0, 0.1) var strength: float