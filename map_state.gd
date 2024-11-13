extends Node

func read_file_to_int_array(file_path: String) -> Array:
	var int_array = []
	
	# Open the file in read mode
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Failed to open file: " + file_path)
		get_tree().quit()
	
	# Read each line and convert it to an array of integers
	while not file.eof_reached():
		var line = file.get_line()
		
		# Skip empty lines
		if line == "":
			continue

		# Split the line by spaces and convert each element to an integer
		var row = []
		for item in line.split(" "):
			row.append(int(item))

		# Add the row (as an Array of integers) to the main array
		int_array.append(row)
	
	file.close()
	return int_array

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
