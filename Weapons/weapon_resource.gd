extends Resource

class_name Weapons_Resource

@export var Weapon_Name : String
@export var Activate_Anim : String
@export var Shoot_Anim : String
@export var Reload_Anim : String
@export var Deactivate_Anim : String
@export var Out_Of_Ammo_Anim : String

@export var Current_Ammo : int
@export var Reserve_Ammo : int
@export var Magazine : int
@export var Max_Ammo : int

@export var Auto_Fire : bool
@export var Weapon_Range : int
@export var Damage : int
@export_flags("HitScan", "Projectile", "Melee") var Type
@export var Projectile_to_Load: PackedScene
@export var Projectile_Velocity : int

@export var Weapon_hurtbox : NodePath

@export var Shooting_Sound : AudioStreamWAV
@export var Chargeing_Sound : AudioStreamWAV
@export var Hit_Sound : AudioStreamWAV
@export var Draw_sound : AudioStreamWAV




