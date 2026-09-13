extends Node

## Global day/night, weather, season — survives scene changes.
## Outdoor DayNightWeather pulls/pushes this; interiors stay dry but state persists.

signal state_changed(time_grade: int, weather: int, season: int)

enum TimeGrade { DAY, NIGHT }
enum WeatherKind { CLEAR, RAIN, SNOW, FOG }
enum Season { SPRING, SUMMER, AUTUMN, WINTER }

var time_grade: TimeGrade = TimeGrade.DAY
var weather: WeatherKind = WeatherKind.CLEAR
var season: Season = Season.SPRING
## When lamp sticky-night forced day restore; mirrors DayNightWeather flag across loads.
var lamp_forced_night: bool = false


func is_night() -> bool:
	return time_grade == TimeGrade.NIGHT


func is_precipitating() -> bool:
	return weather == WeatherKind.RAIN or weather == WeatherKind.SNOW


func is_bad_weather() -> bool:
	return weather != WeatherKind.CLEAR


func set_time_grade(grade: TimeGrade, from_lamp: bool = false) -> void:
	time_grade = grade
	if grade == TimeGrade.DAY:
		lamp_forced_night = false
	elif from_lamp:
		lamp_forced_night = true
	_emit()


func toggle_night() -> void:
	set_time_grade(TimeGrade.DAY if time_grade == TimeGrade.NIGHT else TimeGrade.NIGHT)


func set_weather(kind: WeatherKind) -> void:
	weather = kind
	_emit()


func cycle_weather() -> void:
	match weather:
		WeatherKind.CLEAR:
			weather = WeatherKind.RAIN
		WeatherKind.RAIN:
			weather = WeatherKind.SNOW
		WeatherKind.SNOW:
			weather = WeatherKind.FOG
		_:
			weather = WeatherKind.CLEAR
	_emit()


func set_season(s: Season) -> void:
	season = s
	_emit()


func cycle_season() -> void:
	season = ((int(season) + 1) % 4) as Season
	_emit()


func snapshot() -> Dictionary:
	return {
		"time_grade": int(time_grade),
		"weather": int(weather),
		"season": int(season),
		"night": is_night(),
		"lamp_forced_night": lamp_forced_night,
	}


func _emit() -> void:
	state_changed.emit(int(time_grade), int(weather), int(season))
