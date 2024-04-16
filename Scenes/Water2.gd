@tool

extends MeshInstance3D

var material : ShaderMaterial
var noise : Image

var noise_scale : float
var wave_speed : float
var height_scale : float

# Sync time between shader GPU and code CPU
var time : float
var temprature = 6.3
var density = 1024

# Called when the node enters the scene tree for the first time.
func _ready():
	material = mesh.surface_get_material(0)
	noise = material.get_shader_parameter("wave").noise.get_seamless_image(512,512)
	noise_scale = material.get_shader_parameter("noise_scale")
	wave_speed = material.get_shader_parameter("wave_speed")
	height_scale = material.get_shader_parameter("height_scale")
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	material.set_shader_parameter("wave_time",time)

func get_height(world_pos : Vector3) -> float:
	var uv_x = wrapf(world_pos.x / noise_scale + time * wave_speed, 0, 1)
	var uv_y = wrapf(world_pos.z / noise_scale + time * wave_speed, 0, 1)
	
	var piexel_pos = Vector2(uv_x * noise.get_width(), uv_y * noise.get_height())
	return global_position.y + noise.get_pixelv(piexel_pos).r * height_scale
	
