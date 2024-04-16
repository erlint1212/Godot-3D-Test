extends CharacterBody3D

signal typing_finished

const ACTIVATION_DISANCE := 5.0
const LINEAR_DIALOGUE = [
	"Hello, first line. Pause the more AAAAAA",
	"THis stuff is stuff",
	"Ok, this is the end",
	"loop"
]

@export var playerPath : NodePath

@onready var player = get_node(playerPath)
@onready var player_dialogue_node = get_node(str(playerPath) + "/DialogueSystem")
@onready var dialogue_box = get_node(str(playerPath) + "/HUD/DialogueBox")
@onready var dialogue_text = get_node(str(playerPath) + "/HUD/DialogueBox/RichTextLabel")
@onready var Skeleton = $Armature/Skeleton3D
@export var resource : NPC_core_stats_resource = load("res://NPC/resources/NPC_res/human_scuffed_self_portrait_resource.tres")
@onready var dialogue_sfx : AudioStreamWAV = preload("res://Sounds/Dialogue_text_sfx.wav")
@onready var dialogueAudioPlayer : AudioStreamPlayer3D = $Talking_Sound

#NPC stats
var Health : int = resource.Health

var distance : float
var active : bool = false

# Text stuff
var page : int = 0
var page_length : int = LINEAR_DIALOGUE.size()
var is_typing : bool = false
const PAUSE_TIMES = {
	" ": 0.04,
	".": 0.10,
	",": 0.07,
	"!": 0.10
}
const VOWLS : Array[String] = ["a", "e", "i", "o", "u", "y"]

func read_line(current_sentence : String, speech_sfx : AudioStream) -> void:
	dialogue_text.text = ""
	for character in current_sentence:
		if is_typing:
			dialogue_text.text += character
			dialogueAudioPlayer.stream = dialogue_sfx
			
			if character not in [" ", ".", ",", "!"]:
				dialogueAudioPlayer.pitch_scale = 2.0
				dialogueAudioPlayer.volume_db = 0.0
				
				if character == character.to_lower():
					if character in VOWLS:
						dialogueAudioPlayer.pitch_scale += 0.2
				else:
					character = character.to_lower()
					dialogueAudioPlayer.volume_db += 5.0
					if character in VOWLS:
						dialogueAudioPlayer.pitch_scale += 0.2
					
				dialogueAudioPlayer.play()
				await dialogueAudioPlayer.finished
				dialogueAudioPlayer.pitch_scale = 2.0
				dialogueAudioPlayer.volume_db = 0.0
			elif character in [" ", ".", ",", "!"]:
				await get_tree().create_timer(PAUSE_TIMES[character]).timeout
			else:
				push_error("Letter not recognized")
	emit_signal("typing_finished")
		
enum {DEAD, ALIVE}

var state = ALIVE
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match [Health <= 0, state == ALIVE]:
		[true, _]:
			state = DEAD
			Skeleton.physical_bones_start_simulation()
			if dialogue_text.material.get_shader_parameter("fade") == 0.9:
				player_dialogue_node.fade_out(0.9, 0.0)
		
		[false, true]:
			distance = (global_position - player.global_position).length()
			
			if distance > ACTIVATION_DISANCE:
				if !active:
					active = true
					if !dialogue_text.material.get_shader_parameter("fade") == 0.0:
						player_dialogue_node.fade_out(0.9, 0.0)
			else:
				if active:
					active = false
					#player_dialogue_node.fade_out(0.9, 0.9)

func talking():
	if state == ALIVE:
		if not is_typing:
			is_typing = true
			if page < page_length:
				#dialogue_text.text = LINEAR_DIALOGUE[page]
				read_line(LINEAR_DIALOGUE[page], dialogue_sfx)
			else:
				#dialogue_text.text = LINEAR_DIALOGUE[page]
				read_line(LINEAR_DIALOGUE[page], dialogue_sfx)
			await typing_finished
			if page < page_length - 1:
					page += 1
			is_typing = false
		elif is_typing:
			dialogue_text.text = LINEAR_DIALOGUE[page]
			emit_signal("typing_finished")

func Hit_Successful(Body, Damage, collison_point):
	if state == ALIVE:
		if Body != null:
			Body.name = "Projectile_Mesh"
			Body.reparent($"..")
		Health -= Damage
		print("Hit", Damage," ", Health, " ", state)
