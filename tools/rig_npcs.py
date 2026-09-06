import bpy
import os
import sys
import math
from mathutils import Vector

src = sys.argv[-2]
out = sys.argv[-1]

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=src)
meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
for obj in meshes:
    obj.select_set(False)

# Humanoid armature in the model's approximate 1m source space.
bpy.ops.object.armature_add(enter_editmode=True, location=(0, 0, 0))
arm = bpy.context.object
arm.name = 'HumanoidRig'
arm.data.name = 'HumanoidRig'
edit = arm.data.edit_bones
root = edit[0]
root.name = 'root'
root.head = (0, 0, 0)
root.tail = (0, 0, 0.08)

def bone(name, head, tail, parent=None, use_connect=False):
    b = edit.new(name)
    b.head = head
    b.tail = tail
    if parent:
        b.parent = edit.get(parent)
        b.use_connect = use_connect
    return b

bone('pelvis', (0,0,0.08), (0,0,0.22), 'root')
bone('spine', (0,0,0.22), (0,0,0.48), 'pelvis', True)
bone('spine.001', (0,0,0.48), (0,0,0.68), 'spine', True)
bone('neck', (0,0,0.68), (0,0,0.78), 'spine.001', True)
bone('head', (0,0,0.78), (0,0,0.98), 'neck', True)
# legs
for side, x in [('L', -0.13), ('R', 0.13)]:
    bone('thigh.'+side, (x,0,0.10), (x,0,0.48), 'pelvis')
    bone('shin.'+side, (x,0,0.48), (x,0,0.08), 'thigh.'+side, True)
    bone('foot.'+side, (x,0,0.08), (x,0.12,0.02), 'shin.'+side, True)
# arms
for side, x in [('L', -0.16), ('R', 0.16)]:
    bone('upper_arm.'+side, (x,0,0.62), (x*1.75,0,0.53), 'spine.001')
    bone('forearm.'+side, (x*1.75,0,0.53), (x*2.15,0,0.42), 'upper_arm.'+side, True)
    bone('hand.'+side, (x*2.15,0,0.42), (x*2.25,0,0.38), 'forearm.'+side, True)

bpy.ops.object.mode_set(mode='POSE')
arm.pose.bones['head'].rotation_mode = 'XYZ'
bpy.ops.object.mode_set(mode='OBJECT')

# Normalize object origin and use automatic skinning; fallback to empty groups if Blender cannot solve weights.
bpy.ops.object.select_all(action='DESELECT')
arm.select_set(True)
bpy.context.view_layer.objects.active = arm
for obj in meshes:
    obj.select_set(True)
bpy.context.view_layer.objects.active = arm
try:
    bpy.ops.object.parent_set(type='ARMATURE_AUTO')
except Exception:
    bpy.ops.object.parent_set(type='ARMATURE_ENVELOPE')

# Add simple animation clips usable by Godot's AnimationPlayer import.
for name, frames in [('Idle', 40), ('Walk', 30), ('Run', 18), ('Fight', 24)]:
    action = bpy.data.actions.new(name)
    arm.animation_data_create()
    arm.animation_data.action = action
    action.use_fake_user = True
    arm.keyframe_insert(data_path='rotation_euler', frame=1)
    action.frame_range = (1, frames)

bpy.ops.wm.save_as_mainfile(filepath=os.path.splitext(out)[0] + '.blend')
bpy.ops.object.select_all(action='SELECT')
bpy.context.view_layer.objects.active = arm
bpy.ops.export_scene.gltf(filepath=out, export_format='GLB', export_animations=True, export_skins=True, export_apply=False)
print('RIGGED', out, 'bones=', len(arm.data.bones))
