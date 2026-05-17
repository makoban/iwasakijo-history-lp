import math
import os
import random
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "assets" / "3d"
OUT_DIR.mkdir(parents=True, exist_ok=True)

BLEND_PATH = OUT_DIR / "iwasaki-current-castle.blend"
GLB_PATH = OUT_DIR / "iwasaki-current-castle.glb"
RENDER_PATH = OUT_DIR / "iwasaki-current-castle-render.png"


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()


def material(name, color, roughness=0.72, metallic=0.0):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = color
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    return mat


def cube(name, loc, dims, mat=None, bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dims
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if mat:
        obj.data.materials.append(mat)
    if bevel:
        mod = obj.modifiers.new("softened_edges", "BEVEL")
        mod.width = bevel
        mod.segments = 2
        mod.affect = "EDGES"
        normal = obj.modifiers.new("weighted_normals", "WEIGHTED_NORMAL")
        normal.keep_sharp = True
    return obj


def cylinder(name, loc, radius, depth, mat=None, vertices=24):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc)
    obj = bpy.context.object
    obj.name = name
    if mat:
        obj.data.materials.append(mat)
    return obj


def cone(name, loc, radius1, radius2, depth, mat=None, vertices=24):
    bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=radius1, radius2=radius2, depth=depth, location=loc)
    obj = bpy.context.object
    obj.name = name
    if mat:
        obj.data.materials.append(mat)
    return obj


def hip_roof(name, center, width, depth, height, mat, overhang=0.22, ridge_ratio=0.44):
    x = width / 2 + overhang
    y = depth / 2 + overhang
    ridge_x = x * ridge_ratio
    cx, cy, cz = center
    verts = [
        (cx - x, cy - y, cz),
        (cx + x, cy - y, cz),
        (cx + x, cy + y, cz),
        (cx - x, cy + y, cz),
        (cx - ridge_x, cy, cz + height),
        (cx + ridge_x, cy, cz + height),
    ]
    faces = [
        (0, 1, 5, 4),
        (3, 4, 5, 2),
        (0, 4, 3),
        (1, 2, 5),
    ]
    mesh = bpy.data.meshes.new(f"{name}_mesh")
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat)
    obj.modifiers.new("roof_weighted_normals", "WEIGHTED_NORMAL")

    cube(f"{name}_eave_front", (cx, cy - y - 0.02, cz - 0.03), (width + overhang * 2.15, 0.08, 0.08), mat, 0.01)
    cube(f"{name}_eave_back", (cx, cy + y + 0.02, cz - 0.03), (width + overhang * 2.15, 0.08, 0.08), mat, 0.01)
    cube(f"{name}_ridge", (cx, cy, cz + height + 0.035), (ridge_x * 2 + 0.18, 0.08, 0.08), mat, 0.01)

    for i in range(6):
        tx = cx - width * 0.42 + i * width * 0.168
        cube(f"{name}_tile_hint_{i}", (tx, cy - y - 0.08, cz + 0.02), (0.035, 0.16, 0.08), mat, 0.006)
    return obj


def add_window_bank(prefix, x0, y, z, count, mat_dark, spacing=0.22):
    for i in range(count):
        cube(f"{prefix}_slat_{i}", (x0 + i * spacing, y, z), (0.045, 0.045, 0.44), mat_dark, 0.004)


def add_balcony(prefix, cx, cy, z, width, depth, mat_wood):
    cube(f"{prefix}_deck_front", (cx, cy - depth / 2, z), (width, 0.08, 0.12), mat_wood, 0.01)
    cube(f"{prefix}_deck_back", (cx, cy + depth / 2, z), (width, 0.08, 0.12), mat_wood, 0.01)
    cube(f"{prefix}_deck_left", (cx - width / 2, cy, z), (0.08, depth, 0.12), mat_wood, 0.01)
    cube(f"{prefix}_deck_right", (cx + width / 2, cy, z), (0.08, depth, 0.12), mat_wood, 0.01)
    for i in range(8):
        x = cx - width / 2 + 0.18 + i * (width - 0.36) / 7
        cube(f"{prefix}_front_post_{i}", (x, cy - depth / 2 - 0.02, z + 0.22), (0.035, 0.035, 0.42), mat_wood, 0.004)
        cube(f"{prefix}_back_post_{i}", (x, cy + depth / 2 + 0.02, z + 0.22), (0.035, 0.035, 0.42), mat_wood, 0.004)
    for i in range(5):
        y = cy - depth / 2 + 0.18 + i * (depth - 0.36) / 4
        cube(f"{prefix}_left_post_{i}", (cx - width / 2 - 0.02, y, z + 0.22), (0.035, 0.035, 0.42), mat_wood, 0.004)
        cube(f"{prefix}_right_post_{i}", (cx + width / 2 + 0.02, y, z + 0.22), (0.035, 0.035, 0.42), mat_wood, 0.004)


def add_stone_face(prefix, y, x_min, x_max, z_min, z_max, stone_mats):
    random.seed(1584)
    row = 0
    z = z_min
    while z < z_max:
        h = random.uniform(0.16, 0.28)
        x = x_min
        col = 0
        while x < x_max:
            w = random.uniform(0.28, 0.52)
            cx = min(x + w / 2, x_max - 0.02)
            cube(
                f"{prefix}_stone_{row}_{col}",
                (cx, y, z + h / 2),
                (min(w, x_max - x), 0.045, h * 0.92),
                random.choice(stone_mats),
                0.018,
            )
            x += w + random.uniform(0.018, 0.045)
            col += 1
        z += h + random.uniform(0.02, 0.045)
        row += 1


def add_tree(prefix, x, y, z, trunk_mat, leaf_mat, scale=1.0):
    trunk = cylinder(f"{prefix}_trunk", (x, y, z + 0.22 * scale), 0.045 * scale, 0.44 * scale, trunk_mat, 12)
    trunk.rotation_euler[0] = random.uniform(-0.08, 0.08)
    for i, (ox, oy, oz, r) in enumerate([
        (0, 0, 0.62, 0.34),
        (-0.16, 0.06, 0.48, 0.24),
        (0.18, -0.08, 0.50, 0.25),
    ]):
        cone(f"{prefix}_foliage_{i}", (x + ox * scale, y + oy * scale, z + oz * scale), r * scale, 0.03 * scale, 0.5 * scale, leaf_mat, 18)


def look_at(obj, target):
    direction = Vector(target) - obj.location
    obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


clear_scene()

mat_plaster = material("warm white plaster", (0.82, 0.78, 0.68, 1.0), 0.82)
mat_roof = material("dark tiled roof", (0.07, 0.08, 0.09, 1.0), 0.6)
mat_roof_edge = material("weathered roof edge", (0.22, 0.22, 0.22, 1.0), 0.62)
mat_stone = material("stone wall light", (0.58, 0.54, 0.46, 1.0), 0.86)
mat_stone2 = material("stone wall warm", (0.70, 0.62, 0.48, 1.0), 0.86)
mat_stone3 = material("stone wall dark", (0.40, 0.39, 0.35, 1.0), 0.86)
mat_wood = material("dark timber", (0.16, 0.10, 0.07, 1.0), 0.76)
mat_blackwood = material("black balcony lattice", (0.05, 0.04, 0.035, 1.0), 0.7)
mat_ground = material("park earth and grass", (0.30, 0.34, 0.22, 1.0), 0.9)
mat_path = material("stone stairs", (0.42, 0.40, 0.36, 1.0), 0.84)
mat_leaf = material("pine green", (0.08, 0.22, 0.13, 1.0), 0.85)
mat_gold = material("roof ornament gold", (0.95, 0.66, 0.22, 1.0), 0.45, 0.25)
mat_shadow = material("window shadow", (0.12, 0.11, 0.10, 1.0), 0.72)

# Hill and retaining walls.
cube("soft hill platform", (0, -0.25, 0.08), (9.0, 6.2, 0.16), mat_ground, 0.08)
cube("upper earth mound", (0.2, -0.1, 0.55), (7.7, 4.4, 0.9), mat_ground, 0.06)
cube("front stone retaining mass", (0.2, -2.48, 0.92), (7.6, 0.42, 1.42), mat_stone, 0.03)
cube("left lower stone wall", (-2.9, -3.15, 0.42), (3.6, 0.28, 0.72), mat_stone3, 0.025)
add_stone_face("front_wall", -2.72, -3.55, 3.85, 0.26, 1.62, [mat_stone, mat_stone2, mat_stone3])
add_stone_face("lower_left_wall", -3.32, -4.55, -1.25, 0.10, 0.76, [mat_stone, mat_stone2, mat_stone3])

# Main entrance stairs.
for i in range(18):
    y = -4.02 + i * 0.115
    z = 0.18 + i * 0.065
    cube(f"front_stair_{i}", (-0.5, y, z), (1.12, 0.12, 0.045), mat_path, 0.006)
cube("left_stair_wall", (-1.16, -3.0, 0.78), (0.10, 2.2, 1.05), mat_stone3, 0.018)
cube("right_stair_wall", (0.16, -3.0, 0.78), (0.10, 2.2, 1.05), mat_stone3, 0.018)

# Long current castle structure.
cube("main stone base", (-0.25, -0.35, 1.62), (6.8, 2.22, 1.15), mat_stone2, 0.03)
add_stone_face("main_base_front", -1.49, -3.55, 3.05, 1.06, 2.12, [mat_stone, mat_stone2, mat_stone3])
cube("main plaster wall", (-0.35, -0.35, 2.58), (6.55, 1.94, 0.92), mat_plaster, 0.02)
cube("entrance shadow", (-0.48, -1.34, 1.45), (0.86, 0.08, 0.76), mat_shadow, 0.01)
cube("entrance lintel", (-0.48, -1.40, 1.88), (1.05, 0.12, 0.12), mat_wood, 0.01)
hip_roof("main_long_roof", (-0.35, -0.35, 3.12), 6.9, 2.22, 0.72, mat_roof, 0.28)

for start_x, count in [(-2.9, 5), (-1.0, 5), (1.0, 4)]:
    add_window_bank(f"main_window_{start_x}", start_x, -1.34, 2.66, count, mat_shadow, 0.18)

for i in range(13):
    cube(f"main_under_eave_bracket_{i}", (-3.35 + i * 0.5, -1.46, 2.98), (0.11, 0.34, 0.10), mat_roof_edge, 0.008)

# Left wing, visible in the current photo.
cube("left_wing_plaster", (-2.55, 0.65, 2.45), (2.35, 1.55, 0.82), mat_plaster, 0.02)
hip_roof("left_wing_roof", (-2.55, 0.65, 2.95), 2.62, 1.86, 0.56, mat_roof, 0.24)
add_window_bank("left_wing_window", -3.18, -0.15, 2.48, 5, mat_shadow, 0.17)

# Tower stack and modern observation balcony.
cube("tower_lower_wall", (1.85, -0.13, 3.32), (2.55, 1.75, 1.02), mat_plaster, 0.02)
hip_roof("tower_lower_roof", (1.85, -0.13, 3.88), 2.95, 2.08, 0.64, mat_roof, 0.24)
add_window_bank("tower_lower_window", 1.42, -1.05, 3.32, 4, mat_shadow, 0.16)

cube("tower_middle_wall", (1.85, -0.13, 4.34), (1.95, 1.36, 0.82), mat_plaster, 0.018)
hip_roof("tower_middle_roof", (1.85, -0.13, 4.82), 2.35, 1.68, 0.54, mat_roof, 0.22)
add_window_bank("tower_mid_window", 1.52, -0.88, 4.32, 3, mat_shadow, 0.15)

cube("observation_core", (1.85, -0.13, 5.15), (1.62, 1.08, 0.64), mat_plaster, 0.014)
add_balcony("observation_deck", 1.85, -0.13, 5.08, 2.55, 1.84, mat_blackwood)
hip_roof("observation_roof", (1.85, -0.13, 5.58), 2.25, 1.58, 0.66, mat_roof, 0.26)

for x in [1.45, 2.25]:
    cone(f"gold_roof_ornament_{x}", (x, -0.13, 6.12), 0.07, 0.0, 0.24, mat_gold, 16)

# Side building on the right edge.
cube("right_side_wall", (3.25, -0.1, 2.72), (1.35, 1.62, 0.78), mat_plaster, 0.02)
hip_roof("right_side_roof", (3.25, -0.1, 3.22), 1.7, 1.92, 0.48, mat_roof, 0.22)
cube("right_balcony_mass", (2.65, -1.02, 2.15), (1.1, 0.12, 0.52), mat_blackwood, 0.01)

# Foreground sign stone and planting to anchor the model to the current site.
cube("iwasaki_sign_stone", (3.75, -3.35, 0.96), (0.42, 0.16, 1.62), mat_stone3, 0.035)
cube("sign_face_light", (3.75, -3.44, 1.02), (0.34, 0.035, 1.38), mat_stone, 0.015)

random.seed(2026)
for idx, (x, y, s) in enumerate([
    (-3.65, -3.15, 1.0),
    (-2.25, -3.35, 0.85),
    (-3.85, -1.25, 0.95),
    (3.65, -1.7, 0.8),
    (4.1, 0.6, 1.15),
]):
    add_tree(f"site_pine_{idx}", x, y, 0.18, mat_wood, mat_leaf, s)

for i in range(20):
    x = random.uniform(-4.2, 4.2)
    y = random.uniform(-3.4, 2.5)
    if -1.1 < x < 0.3 and -4.0 < y < -2.0:
        continue
    cone(f"low_shrub_{i}", (x, y, 0.25), random.uniform(0.13, 0.28), 0.02, random.uniform(0.18, 0.32), mat_leaf, 14)

# Camera and lighting.
bpy.ops.object.light_add(type="SUN", location=(0, -4, 8))
sun = bpy.context.object
sun.name = "late morning sun"
sun.data.energy = 3.2
sun.rotation_euler = (math.radians(42), math.radians(0), math.radians(34))

bpy.ops.object.light_add(type="AREA", location=(-3.5, -4.5, 6.0))
area = bpy.context.object
area.name = "soft sky fill"
area.data.energy = 840
area.data.size = 5.5

bpy.ops.object.camera_add(location=(7.6, -8.8, 5.35))
camera = bpy.context.object
look_at(camera, (0.05, -0.55, 2.72))
camera.data.lens = 32
camera.data.type = "ORTHO"
camera.data.ortho_scale = 11.2
bpy.context.scene.camera = camera

world = bpy.context.scene.world or bpy.data.worlds.new("World")
bpy.context.scene.world = world
world.color = (0.78, 0.84, 0.92)

scene = bpy.context.scene
try:
    scene.render.engine = "BLENDER_EEVEE_NEXT"
except TypeError:
    scene.render.engine = "BLENDER_EEVEE"
scene.eevee.taa_render_samples = 64
scene.render.resolution_x = 1600
scene.render.resolution_y = 900
scene.view_settings.view_transform = "Standard"
scene.view_settings.look = "Medium High Contrast"
scene.view_settings.exposure = 0
scene.view_settings.gamma = 1

# Keep the web model centered and reasonably sized.
bpy.ops.object.select_all(action="DESELECT")
for obj in bpy.context.scene.objects:
    if obj.type in {"MESH", "CURVE"}:
        obj.select_set(True)
bpy.ops.object.origin_set(type="ORIGIN_GEOMETRY", center="BOUNDS")

bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_PATH))
bpy.ops.export_scene.gltf(
    filepath=str(GLB_PATH),
    export_format="GLB",
    export_materials="EXPORT",
    export_apply=True,
)
scene.render.filepath = str(RENDER_PATH)
bpy.ops.render.render(write_still=True)

print(f"wrote {BLEND_PATH}")
print(f"wrote {GLB_PATH}")
print(f"wrote {RENDER_PATH}")
