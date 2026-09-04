@tool
extends "res://addons/popochiu/engine/interfaces/i_audio.gd"
## Audio autoload — Popochiu 2.1.1. The editor fills in cue markers.
# cues ----
var ambience_study: AudioCueMusic = load("res://assets/audio/ambience_study.tres")
var pickup_chime: AudioCueSound = load("res://assets/audio/pickup_chime.tres")
var ui_click: AudioCueSound = load("res://assets/audio/ui_click.tres")
# ---- cues
