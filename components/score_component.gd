extends Node

class_name ScoreComponent

@export var game_stats: GameStats

@export var score: int

const SAVE_PATH = "user://highscore.json"

func _ready():
	load_high_score()

func adjust_score():
	game_stats.score += score
	if game_stats.score > game_stats.highscore:
		game_stats.highscore = game_stats.score
		save_high_score()  # Save only if there's a new high score

func save_high_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"highscore": game_stats.highscore}))
		file.close()

func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			if data and typeof(data) == TYPE_DICTIONARY:
				game_stats.highscore = data.get("highscore", 0)
			file.close()
