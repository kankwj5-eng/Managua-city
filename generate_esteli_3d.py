import bpy
import math
import os
import random

def setup_scene():
    # Clear existing objects
    bpy.ops.wm.read_factory_settings(use_empty=True)

    scene = bpy.context.scene
    scene.name = "Esteli_City_Scene"

    # Engine settings
    scene.render.engine = 'CYCLES' if False else 'BLENDER_EEVEE_NEXT' if hasattr(bpy.types, "EeveeSettings") else 'BLENDER_EEVEE'
    if hasattr(scene, "eevee"):
        scene.eevee.use_bloom = True
        scene.eevee.use_gtao = True
        scene.eevee.use_ssr = True

    scene.render.resolution_x = 1920
    scene.render.resolution_y = 1080
    scene.render.resolution_percentage = 100

    # Color Management
    scene.view_settings.view_transform = 'Filmic' if 'Filmic' in [a.name for a in bpy.context.scene.view_settings.bl_rna.properties['view_transform'].enum_items] else 'Standard'
    scene.view_settings.look = 'Medium High Contrast'

def create_pbr_material(name, color=(0.8, 0.8, 0.8, 1.0), roughness=0.5, metallic=0.0, texture_path=None, normal_path=None, rough_path=None, specular=0.5, transmission=0.0, emissive_color=None):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()

    output = nodes.new(type='ShaderNodeOutputMaterial')
    bsdf = nodes.new(type='ShaderNodeBsdfPrincipled')
    links.new(bsdf.outputs['BSDF'], output.inputs['Surface'])

    # Default parameters
    bsdf.inputs['Base Color'].default_value = color
    bsdf.inputs['Roughness'].default_value = roughness
    bsdf.inputs['Metallic'].default_value = metallic
    if 'Specular' in bsdf.inputs:
        bsdf.inputs['Specular'].default_value = specular
    elif 'Specular IOR Level' in bsdf.inputs:
        bsdf.inputs['Specular IOR Level'].default_value = specular

    if transmission > 0:
        if 'Transmission' in bsdf.inputs:
            bsdf.inputs['Transmission'].default_value = transmission
        elif 'Transmission Weight' in bsdf.inputs:
            bsdf.inputs['Transmission Weight'].default_value = transmission
        if hasattr(mat, "blend_method"):
            mat.blend_method = 'BLEND'

    if emissive_color:
        if 'Emission' in bsdf.inputs:
            bsdf.inputs['Emission'].default_value = emissive_color
        elif 'Emission Color' in bsdf.inputs:
            bsdf.inputs['Emission Color'].default_value = emissive_color
            if 'Emission Strength' in bsdf.inputs:
                bsdf.inputs['Emission Strength'].default_value = 1.0

    # Textures setup if provided
    if texture_path and os.path.exists(texture_path):
        tex_node = nodes.new(type='ShaderNodeTexImage')
        tex_node.image = bpy.data.images.load(texture_path)
        links.new(tex_node.outputs['Color'], bsdf.inputs['Base Color'])

    if normal_path and os.path.exists(normal_path):
        norm_tex = nodes.new(type='ShaderNodeTexImage')
        norm_tex.image = bpy.data.images.load(normal_path)
        norm_tex.image.colorspace_settings.name = 'Non-Color'
        norm_map = nodes.new(type='ShaderNodeNormalMap')
        links.new(norm_tex.outputs['Color'], norm_map.inputs['Color'])
        links.new(norm_map.outputs['Normal'], bsdf.inputs['Normal'])

    if rough_path and os.path.exists(rough_path):
        r_tex = nodes.new(type='ShaderNodeTexImage')
        r_tex.image = bpy.data.images.load(rough_path)
        r_tex.image.colorspace_settings.name = 'Non-Color'
        links.new(r_tex.outputs['Color'], bsdf.inputs['Roughness'])

    return mat

def setup_lighting_and_world():
    # Sun light
    sun_data = bpy.data.lights.new(name="SunLight", type='SUN')
    sun_data.energy = 3.5
    sun_data.color = (1.0, 0.95, 0.88)
    sun_obj = bpy.data.objects.new(name="SunLight", object_data=sun_data)
    bpy.context.collection.objects.link(sun_obj)
    sun_obj.rotation_euler = (math.radians(45), math.radians(20), math.radians(130))

    # World / Sky background
    world = bpy.data.worlds.new("Esteli_Sky")
    bpy.context.scene.world = world
    world.use_nodes = True
    wnodes = world.node_tree.nodes
    wlinks = world.node_tree.links
    wnodes.clear()

    w_out = wnodes.new('ShaderNodeOutputWorld')
    w_bg = wnodes.new('ShaderNodeBackground')
    w_bg.inputs['Color'].default_value = (0.45, 0.65, 0.88, 1.0)
    w_bg.inputs['Strength'].default_value = 1.2
    wlinks.new(w_bg.outputs['Background'], w_out.inputs['Surface'])

def build_cathedral(materials, pos=(-35, 0, 0)):
    # Catedral Nuestra Señora del Rosario de Estelí
    # Main group
    cathedral_collection = bpy.data.collections.new("Catedral_Esteli")
    bpy.context.scene.collection.children.link(cathedral_collection)

    x0, y0, z0 = pos

    # 1. Base / Podium / Steps
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x0, y0, z0 + 0.6))
    podium = bpy.context.active_object
    podium.name = "Cathedral_Podium"
    podium.scale = (32, 22, 1.2)
    podium.data.materials.append(materials['concrete'])
    cathedral_collection.objects.link(podium)
    bpy.context.collection.objects.unlink(podium)

    # Front Steps
    for step in range(5):
        bpy.ops.mesh.primitive_cube_add(size=1, location=(x0 + 16 + step*0.4, y0, z0 + 0.5 - step*0.1))
        st = bpy.context.active_object
        st.scale = (0.5, 12, 0.2)
        st.data.materials.append(materials['concrete'])
        cathedral_collection.objects.link(st)
        bpy.context.collection.objects.unlink(st)

    # 2. Main Nave Body
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x0 - 2, y0, z0 + 7))
    nave = bpy.context.active_object
    nave.name = "Cathedral_Nave"
    nave.scale = (24, 18, 12)
    nave.data.materials.append(materials['stucco'])
    cathedral_collection.objects.link(nave)
    bpy.context.collection.objects.unlink(nave)

    # Roof Gables / Moldings
    bpy.ops.mesh.primitive_cylinder_add(radius=1, depth=24, location=(x0 - 2, y0, z0 + 13), rotation=(0, math.radians(90), 0))
    roof_gable = bpy.context.active_object
    roof_gable.scale = (1, 9, 1)
    roof_gable.data.materials.append(materials['rooftiles'])
    cathedral_collection.objects.link(roof_gable)
    bpy.context.collection.objects.unlink(roof_gable)

    # 3. Main Entrance Facade (Neoclassical Portico)
    facade_x = x0 + 10
    # Central arch portal frame
    bpy.ops.mesh.primitive_cube_add(size=1, location=(facade_x + 0.2, y0, z0 + 8))
    facade_wall = bpy.context.active_object
    facade_wall.scale = (0.8, 18.4, 14)
    facade_wall.data.materials.append(materials['stucco'])
    cathedral_collection.objects.link(facade_wall)
    bpy.context.collection.objects.unlink(facade_wall)

    # Main Entrance Arched Doorway
    bpy.ops.mesh.primitive_cube_add(size=1, location=(facade_x + 0.5, y0, z0 + 3.5))
    door_frame = bpy.context.active_object
    door_frame.scale = (0.6, 4.5, 6)
    door_frame.data.materials.append(materials['wood'])
    cathedral_collection.objects.link(door_frame)
    bpy.context.collection.objects.unlink(door_frame)

    # Front Columns (4 Neoclassical Columns)
    col_offsets = [-7.5, -3.5, 3.5, 7.5]
    for col_y in col_offsets:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.55, depth=10, location=(facade_x + 1.2, y0 + col_y, z0 + 6.2))
        col = bpy.context.active_object
        col.name = f"Facade_Column_{col_y}"
        col.data.materials.append(materials['stucco'])
        cathedral_collection.objects.link(col)
        bpy.context.collection.objects.unlink(col)
        # Base & Capital
        for cz in [1.4, 11.0]:
            bpy.ops.mesh.primitive_cube_add(size=1, location=(facade_x + 1.2, y0 + col_y, z0 + cz))
            cap = bpy.context.active_object
            cap.scale = (1.4, 1.4, 0.5)
            cap.data.materials.append(materials['stucco'])
            cathedral_collection.objects.link(cap)
            bpy.context.collection.objects.unlink(cap)

    # Triangular Pediment above Entrance
    bpy.ops.mesh.primitive_cylinder_add(vertices=3, radius=9.5, depth=1.2, location=(facade_x + 1.0, y0, z0 + 13), rotation=(0, math.radians(90), 0))
    pediment = bpy.context.active_object
    pediment.rotation_euler = (math.radians(90), 0, math.radians(90))
    pediment.scale = (1, 0.4, 1)
    pediment.data.materials.append(materials['stucco'])
    cathedral_collection.objects.link(pediment)
    bpy.context.collection.objects.unlink(pediment)

    # Decorative Niche & Statue
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1.2, location=(facade_x + 1.1, y0, z0 + 10))
    niche = bpy.context.active_object
    niche.scale = (0.3, 1.0, 1.6)
    niche.data.materials.append(materials['gold'])
    cathedral_collection.objects.link(niche)
    bpy.context.collection.objects.unlink(niche)

    # 4. Twin Bell Towers (Torres Campanario Norte y Sur)
    tower_ys = [-9.2, 9.2]
    for ty in tower_ys:
        # Base Tower Body
        bpy.ops.mesh.primitive_cube_add(size=1, location=(facade_x - 1, y0 + ty, z0 + 10))
        tower = bpy.context.active_object
        tower.scale = (5.8, 5.8, 18)
        tower.data.materials.append(materials['stucco'])
        cathedral_collection.objects.link(tower)
        bpy.context.collection.objects.unlink(tower)

        # Upper Bell Stage (Belfry with Arched Openings)
        bpy.ops.mesh.primitive_cube_add(size=1, location=(facade_x - 1, y0 + ty, z0 + 21))
        belfry = bpy.context.active_object
        belfry.scale = (5.0, 5.0, 5.0)
        belfry.data.materials.append(materials['stucco'])
        cathedral_collection.objects.link(belfry)
        bpy.context.collection.objects.unlink(belfry)

        # Bell Inside
        bpy.ops.mesh.primitive_cone_add(radius1=0.8, radius2=0.3, depth=1.2, location=(facade_x - 1, y0 + ty, z0 + 20.5))
        bell = bpy.context.active_object
        bell.data.materials.append(materials['metal_dark'])
        cathedral_collection.objects.link(bell)
        bpy.context.collection.objects.unlink(bell)

        # Tower Cornice Molding
        bpy.ops.mesh.primitive_cube_add(size=1, location=(facade_x - 1, y0 + ty, z0 + 23.8))
        tc = bpy.context.active_object
        tc.scale = (5.6, 5.6, 0.6)
        tc.data.materials.append(materials['concrete'])
        cathedral_collection.objects.link(tc)
        bpy.context.collection.objects.unlink(tc)

        # Pyramidal Tower Roof / Spire
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=3.2, depth=6.0, location=(facade_x - 1, y0 + ty, z0 + 26.8))
        spire = bpy.context.active_object
        spire.rotation_euler = (0, 0, math.radians(45))
        spire.data.materials.append(materials['rooftiles'])
        cathedral_collection.objects.link(spire)
        bpy.context.collection.objects.unlink(spire)

        # Gold Cross on Top
        bpy.ops.mesh.primitive_cube_add(size=1, location=(facade_x - 1, y0 + ty, z0 + 30.5))
        c1 = bpy.context.active_object
        c1.scale = (0.2, 0.2, 1.6)
        c1.data.materials.append(materials['gold'])
        cathedral_collection.objects.link(c1)
        bpy.context.collection.objects.unlink(c1)

        bpy.ops.mesh.primitive_cube_add(size=1, location=(facade_x - 1, y0 + ty, z0 + 30.8))
        c2 = bpy.context.active_object
        c2.scale = (0.2, 1.0, 0.2)
        c2.data.materials.append(materials['gold'])
        cathedral_collection.objects.link(c2)
        bpy.context.collection.objects.unlink(c2)

    # 5. Central Dome (Cúpula Mayor)
    dome_x = x0 - 10
    # Drum
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=5.0, depth=4.0, location=(dome_x, y0, z0 + 15))
    drum = bpy.context.active_object
    drum.data.materials.append(materials['stucco'])
    cathedral_collection.objects.link(drum)
    bpy.context.collection.objects.unlink(drum)

    # Dome Roof
    bpy.ops.mesh.primitive_uv_sphere_add(radius=5.0, location=(dome_x, y0, z0 + 17))
    dome = bpy.context.active_object
    dome.scale = (1, 1, 0.7)
    dome.data.materials.append(materials['rooftiles'])
    cathedral_collection.objects.link(dome)
    bpy.context.collection.objects.unlink(dome)

    # Lantern & Cupola Cross
    bpy.ops.mesh.primitive_cylinder_add(radius=1.2, depth=2.0, location=(dome_x, y0, z0 + 21))
    lant = bpy.context.active_object
    lant.data.materials.append(materials['stucco'])
    cathedral_collection.objects.link(lant)
    bpy.context.collection.objects.unlink(lant)

    bpy.ops.mesh.primitive_cube_add(size=1, location=(dome_x, y0, z0 + 22.8))
    cx1 = bpy.context.active_object
    cx1.scale = (0.2, 0.2, 1.4)
    cx1.data.materials.append(materials['gold'])
    cathedral_collection.objects.link(cx1)
    bpy.context.collection.objects.unlink(cx1)

def build_parque_central(materials, pos=(10, 0, 0)):
    park_collection = bpy.data.collections.new("Parque_Central_Esteli")
    bpy.context.scene.collection.children.link(park_collection)

    x0, y0, z0 = pos
    p_width, p_length = 50, 60

    # 1. Main Plaza Base Ground
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x0, y0, z0 - 0.1))
    ground = bpy.context.active_object
    ground.name = "Park_Ground"
    ground.scale = (p_width, p_length, 0.2)
    ground.data.materials.append(materials['park_pavers'])
    park_collection.objects.link(ground)
    bpy.context.collection.objects.unlink(ground)

    # 2. Central Kiosk / Gazebo (Kiosco Central del Parque)
    k_x, k_y = x0, y0
    # Octagonal Base
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=5.5, depth=0.8, location=(k_x, k_y, z0 + 0.4))
    k_base = bpy.context.active_object
    k_base.data.materials.append(materials['concrete'])
    park_collection.objects.link(k_base)
    bpy.context.collection.objects.unlink(k_base)

    # Steps
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=6.5, depth=0.4, location=(k_x, k_y, z0 + 0.2))
    k_step = bpy.context.active_object
    k_step.data.materials.append(materials['concrete'])
    park_collection.objects.link(k_step)
    bpy.context.collection.objects.unlink(k_step)

    # 8 Iron Pillars & Railings
    for i in range(8):
        angle = i * (math.pi / 4)
        px = k_x + 4.8 * math.cos(angle)
        py = k_y + 4.8 * math.sin(angle)
        bpy.ops.mesh.primitive_cylinder_add(radius=0.12, depth=3.2, location=(px, py, z0 + 2.4))
        pillar = bpy.context.active_object
        pillar.data.materials.append(materials['metal_dark'])
        park_collection.objects.link(pillar)
        bpy.context.collection.objects.unlink(pillar)

    # Conical Octagonal Roof
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=5.8, depth=2.8, location=(k_x, k_y, z0 + 5.2))
    k_roof = bpy.context.active_object
    k_roof.data.materials.append(materials['rooftiles'])
    park_collection.objects.link(k_roof)
    bpy.context.collection.objects.unlink(k_roof)

    # Finial / Ornament Spire
    bpy.ops.mesh.primitive_cone_add(radius1=0.3, radius2=0.02, depth=1.5, location=(k_x, k_y, z0 + 7.2))
    spire = bpy.context.active_object
    spire.data.materials.append(materials['gold'])
    park_collection.objects.link(spire)
    bpy.context.collection.objects.unlink(spire)

    # 3. Central Fountain (Fuente Ornamental)
    f_x, f_y = x0 + 14, y0
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=4.0, depth=0.6, location=(f_x, f_y, z0 + 0.3))
    f_basin = bpy.context.active_object
    f_basin.data.materials.append(materials['concrete'])
    park_collection.objects.link(f_basin)
    bpy.context.collection.objects.unlink(f_basin)

    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=3.5, depth=0.2, location=(f_x, f_y, z0 + 0.45))
    f_water = bpy.context.active_object
    f_water.data.materials.append(materials['glass'])
    park_collection.objects.link(f_water)
    bpy.context.collection.objects.unlink(f_water)

    # Central Tier Column
    bpy.ops.mesh.primitive_cylinder_add(radius=0.6, depth=2.0, location=(f_x, f_y, z0 + 1.2))
    f_col = bpy.context.active_object
    f_col.data.materials.append(materials['concrete'])
    park_collection.objects.link(f_col)
    bpy.context.collection.objects.unlink(f_col)

    bpy.ops.mesh.primitive_cylinder_add(radius=1.8, depth=0.3, location=(f_x, f_y, z0 + 2.0))
    f_tier = bpy.context.active_object
    f_tier.data.materials.append(materials['concrete'])
    park_collection.objects.link(f_tier)
    bpy.context.collection.objects.unlink(f_tier)

    # 4. Garden Planters, Palm Trees, and Benches
    # Gardens
    garden_coords = [
        (x0 - 12, y0 + 15), (x0 + 12, y0 + 15),
        (x0 - 12, y0 - 15), (x0 + 12, y0 - 15)
    ]
    for gx, gy in garden_coords:
        # Curb
        bpy.ops.mesh.primitive_cube_add(size=1, location=(gx, gy, z0 + 0.2))
        g_curb = bpy.context.active_object
        g_curb.scale = (12, 10, 0.4)
        g_curb.data.materials.append(materials['concrete'])
        park_collection.objects.link(g_curb)
        bpy.context.collection.objects.unlink(g_curb)

        # Grass inner
        bpy.ops.mesh.primitive_cube_add(size=1, location=(gx, gy, z0 + 0.25))
        grass = bpy.context.active_object
        grass.scale = (11.2, 9.2, 0.4)
        grass.data.materials.append(materials['foliage'])
        park_collection.objects.link(grass)
        bpy.context.collection.objects.unlink(grass)

        # Palm Tree in center of garden
        build_palm_tree(park_collection, materials, (gx, gy, z0 + 0.4))

    # Wrought-Iron Park Benches along walkways
    bench_coords = [
        (x0 - 5, y0 + 8, 0), (x0 + 5, y0 + 8, math.pi),
        (x0 - 5, y0 - 8, 0), (x0 + 5, y0 - 8, math.pi),
        (x0 + 14, y0 + 6, math.pi/2), (x0 + 14, y0 - 6, -math.pi/2)
    ]
    for bx, by, brot in bench_coords:
        build_park_bench(park_collection, materials, (bx, by, z0 + 0.1), brot)

    # Double Globe Park Lights
    light_coords = [
        (x0 - 18, y0 + 20), (x0 + 18, y0 + 20),
        (x0 - 18, y0 - 20), (x0 + 18, y0 - 20),
        (x0, y0 + 22), (x0, y0 - 22)
    ]
    for lx, ly in light_coords:
        build_park_light(park_collection, materials, (lx, ly, z0 + 0.1))

def build_palm_tree(collection, materials, pos):
    x, y, z = pos
    # Trunk with curved segments
    trunk_h = 7.0
    segments = 8
    curr_z = z
    curr_x, curr_y = x, y
    for s in range(segments):
        rad = 0.35 - (s * 0.02)
        dz = trunk_h / segments
        nx = curr_x + random.uniform(-0.05, 0.05)
        ny = curr_y + random.uniform(-0.05, 0.05)
        nz = curr_z + dz/2
        bpy.ops.mesh.primitive_cylinder_add(radius=rad, depth=dz+0.05, location=(nx, ny, nz))
        seg = bpy.context.active_object
        seg.data.materials.append(materials['wood'])
        collection.objects.link(seg)
        bpy.context.collection.objects.unlink(seg)
        curr_x, curr_y, curr_z = nx, ny, curr_z + dz

    # Palm Fronds
    top_pos = (curr_x, curr_y, curr_z)
    frond_count = 12
    for f in range(frond_count):
        angle = f * (2 * math.pi / frond_count)
        tilt = math.radians(35 + random.uniform(-5, 10))
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.6, depth=3.5, location=(top_pos[0] + math.cos(angle)*1.2, top_pos[1] + math.sin(angle)*1.2, top_pos[2] - 0.2))
        frond = bpy.context.active_object
        frond.rotation_euler = (tilt * math.sin(angle), tilt * math.cos(angle), angle)
        frond.scale = (0.15, 1.0, 0.8)
        frond.data.materials.append(materials['foliage'])
        collection.objects.link(frond)
        bpy.context.collection.objects.unlink(frond)

def build_park_bench(collection, materials, pos, rot_z=0):
    x, y, z = pos
    # Bench seat & backrest
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, z + 0.45))
    bench = bpy.context.active_object
    bench.scale = (1.8, 0.5, 0.08)
    bench.rotation_euler = (0, 0, rot_z)
    bench.data.materials.append(materials['wood'])
    collection.objects.link(bench)
    bpy.context.collection.objects.unlink(bench)

    # Legs
    for dx in [-0.7, 0.7]:
        bpy.ops.mesh.primitive_cube_add(size=1, location=(x + dx*math.cos(rot_z), y + dx*math.sin(rot_z), z + 0.22))
        leg = bpy.context.active_object
        leg.scale = (0.08, 0.45, 0.44)
        leg.rotation_euler = (0, 0, rot_z)
        leg.data.materials.append(materials['metal_dark'])
        collection.objects.link(leg)
        bpy.context.collection.objects.unlink(leg)

def build_park_light(collection, materials, pos):
    x, y, z = pos
    # Cast iron post
    bpy.ops.mesh.primitive_cylinder_add(radius=0.12, depth=3.8, location=(x, y, z + 1.9))
    post = bpy.context.active_object
    post.data.materials.append(materials['metal_dark'])
    collection.objects.link(post)
    bpy.context.collection.objects.unlink(post)

    # Lantern Globes
    for dx in [-0.4, 0.4]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.25, location=(x + dx, y, z + 3.8))
        globe = bpy.context.active_object
        globe.data.materials.append(materials['glass'])
        collection.objects.link(globe)
        bpy.context.collection.objects.unlink(globe)

def build_street_and_infrastructure(materials):
    street_collection = bpy.data.collections.new("Calle_Real_Street")
    bpy.context.scene.collection.children.link(street_collection)

    # 1. Main Asphalt Road (Calle Real / Avenida Central)
    # North-South main avenue alongside cathedral & park
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-10, 0, -0.05))
    road = bpy.context.active_object
    road.name = "Calle_Real_Asphalt"
    road.scale = (12, 120, 0.1)
    road.data.materials.append(materials['asphalt'])
    street_collection.objects.link(road)
    bpy.context.collection.objects.unlink(road)

    # East-West Cross Street
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, -32, -0.04))
    cross_road = bpy.context.active_object
    cross_road.name = "Cross_Street_Asphalt"
    cross_road.scale = (100, 12, 0.1)
    cross_road.data.materials.append(materials['asphalt'])
    street_collection.objects.link(cross_road)
    bpy.context.collection.objects.unlink(cross_road)

    # 2. Sidewalks & Raised Curbs
    # Sidewalk west of Calle Real
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-17, 0, 0.1))
    sw_west = bpy.context.active_object
    sw_west.scale = (2, 120, 0.2)
    sw_west.data.materials.append(materials['concrete'])
    street_collection.objects.link(sw_west)
    bpy.context.collection.objects.unlink(sw_west)

    # Sidewalk east of Calle Real (between street and park/cathedral)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-3.2, 0, 0.1))
    sw_east = bpy.context.active_object
    sw_east.scale = (1.6, 120, 0.2)
    sw_east.data.materials.append(materials['concrete'])
    street_collection.objects.link(sw_east)
    bpy.context.collection.objects.unlink(sw_east)

    # Pedestrian Crosswalk Stripes (Zebra Crossing)
    for i in range(8):
        bpy.ops.mesh.primitive_cube_add(size=1, location=(-10, -28 + i*0.8, 0.02))
        stripe = bpy.context.active_object
        stripe.scale = (10, 0.4, 0.02)
        stripe.data.materials.append(materials['stucco'])
        street_collection.objects.link(stripe)
        bpy.context.collection.objects.unlink(stripe)

    # 3. Utility Poles & Power Lines (Postes de Tendido Eléctrico)
    pole_positions = [(-17.5, -45), (-17.5, -15), (-17.5, 15), (-17.5, 45)]
    for px, py in pole_positions:
        # Wooden pole
        bpy.ops.mesh.primitive_cylinder_add(radius=0.18, depth=8.0, location=(px, py, 4.0))
        pole = bpy.context.active_object
        pole.data.materials.append(materials['wood'])
        street_collection.objects.link(pole)
        bpy.context.collection.objects.unlink(pole)

        # Crossarm
        bpy.ops.mesh.primitive_cube_add(size=1, location=(px, py, 7.5))
        arm = bpy.context.active_object
        arm.scale = (0.1, 1.8, 0.12)
        arm.data.materials.append(materials['wood'])
        street_collection.objects.link(arm)
        bpy.context.collection.objects.unlink(arm)

        # Transformer cylinder
        bpy.ops.mesh.primitive_cylinder_add(radius=0.3, depth=0.8, location=(px + 0.3, py, 6.8))
        trans = bpy.context.active_object
        trans.data.materials.append(materials['metal_dark'])
        street_collection.objects.link(trans)
        bpy.context.collection.objects.unlink(trans)

    # Street Signs ("ALTO / STOP" and "Calle Real")
    build_street_sign(street_collection, materials, (-16.5, -26, 0.1))

def build_street_sign(collection, materials, pos):
    x, y, z = pos
    # Pole
    bpy.ops.mesh.primitive_cylinder_add(radius=0.05, depth=2.8, location=(x, y, z + 1.4))
    post = bpy.context.active_object
    post.data.materials.append(materials['metal_dark'])
    collection.objects.link(post)
    bpy.context.collection.objects.unlink(post)

    # Octagonal STOP (ALTO) sign
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.4, depth=0.04, location=(x, y, z + 2.5), rotation=(0, math.radians(90), 0))
    sign = bpy.context.active_object
    sign.data.materials.append(materials['red_paint'])
    collection.objects.link(sign)
    bpy.context.collection.objects.unlink(sign)

def build_city_buildings(materials):
    bldg_collection = bpy.data.collections.new("Edificios_Esteli")
    bpy.context.scene.collection.children.link(bldg_collection)

    # 1. Commercial Strip facing Calle Real (West side of the main street)
    # Building 1: "Tabacos de Estelí / Puros Artesanales" Cigar Shop
    b1_x, b1_y = -26, -10
    bpy.ops.mesh.primitive_cube_add(size=1, location=(b1_x, b1_y, 4.0))
    b1 = bpy.context.active_object
    b1.name = "Store_CigarShop_Esteli"
    b1.scale = (14, 16, 8.0)
    b1.data.materials.append(materials['stucco'])
    bldg_collection.objects.link(b1)
    bpy.context.collection.objects.unlink(b1)

    # Clay Roof
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=11.5, depth=3.0, location=(b1_x, b1_y, 9.5), rotation=(0, 0, math.radians(45)))
    r1 = bpy.context.active_object
    r1.scale = (1.0, 1.1, 1.0)
    r1.data.materials.append(materials['rooftiles'])
    bldg_collection.objects.link(r1)
    bpy.context.collection.objects.unlink(r1)

    # Storefront Sign Board
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-18.9, b1_y, 4.8))
    sign_obj = bpy.context.active_object
    sign_obj.name = "Cigar_Store_Sign"
    sign_obj.scale = (0.1, 10.0, 1.8)
    sign_obj.data.materials.append(materials['cigar_sign'])
    bldg_collection.objects.link(sign_obj)
    bpy.context.collection.objects.unlink(sign_obj)

    # Glass Display Windows & Wood Doors
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-18.9, b1_y - 4, 2.0))
    door = bpy.context.active_object
    door.scale = (0.15, 2.2, 3.5)
    door.data.materials.append(materials['wood'])
    bldg_collection.objects.link(door)
    bpy.context.collection.objects.unlink(door)

    for win_y in [b1_y + 2, b1_y + 5]:
        bpy.ops.mesh.primitive_cube_add(size=1, location=(-18.9, win_y, 2.2))
        win = bpy.context.active_object
        win.scale = (0.15, 2.5, 2.4)
        win.data.materials.append(materials['glass'])
        bldg_collection.objects.link(win)
        bpy.context.collection.objects.unlink(win)

    # Building 2: Colonial Home / Hotel (Terracotta & Ochre Facade)
    b2_x, b2_y = -26, 12
    bpy.ops.mesh.primitive_cube_add(size=1, location=(b2_x, b2_y, 4.5))
    b2 = bpy.context.active_object
    b2.name = "Colonial_Building_Esteli"
    b2.scale = (14, 20, 9.0)
    b2.data.materials.append(materials['red_paint'])
    bldg_collection.objects.link(b2)
    bpy.context.collection.objects.unlink(b2)

    # Balcony with wrought iron railing
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-18.5, b2_y, 5.2))
    balc = bpy.context.active_object
    balc.scale = (1.5, 12.0, 0.2)
    balc.data.materials.append(materials['concrete'])
    bldg_collection.objects.link(balc)
    bpy.context.collection.objects.unlink(balc)

    bpy.ops.mesh.primitive_cube_add(size=1, location=(-17.8, b2_y, 5.7))
    rail = bpy.context.active_object
    rail.scale = (0.1, 12.0, 0.8)
    rail.data.materials.append(materials['metal_dark'])
    bldg_collection.objects.link(rail)
    bpy.context.collection.objects.unlink(rail)

    # Building 3: Modern Commercial Bank / Pharmacy (Blue paint)
    b3_x, b3_y = -26, 30
    bpy.ops.mesh.primitive_cube_add(size=1, location=(b3_x, b3_y, 5.0))
    b3 = bpy.context.active_object
    b3.scale = (14, 14, 10.0)
    b3.data.materials.append(materials['blue_paint'])
    bldg_collection.objects.link(b3)
    bpy.context.collection.objects.unlink(b3)

    # Buildings on South Side of Cross Street
    s_bldgs = [
        (-35, -45, 16, 14, materials['stucco']),
        (-15, -45, 18, 14, materials['red_paint']),
        (10, -45, 24, 14, materials['blue_paint']),
        (35, -45, 20, 14, materials['stucco'])
    ]
    for sbx, sby, w, d, mat in s_bldgs:
        bpy.ops.mesh.primitive_cube_add(size=1, location=(sbx, sby, 4.0))
        sb = bpy.context.active_object
        sb.scale = (w, d, 8.0)
        sb.data.materials.append(mat)
        bldg_collection.objects.link(sb)
        bpy.context.collection.objects.unlink(sb)

        # Tile Roof
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=max(w, d)*0.7, depth=2.5, location=(sbx, sby, 9.2), rotation=(0, 0, math.radians(45)))
        sr = bpy.context.active_object
        sr.data.materials.append(materials['rooftiles'])
        bldg_collection.objects.link(sr)
        bpy.context.collection.objects.unlink(sr)

def build_vehicles(materials):
    veh_collection = bpy.data.collections.new("Vehiculos_Esteli")
    bpy.context.scene.collection.children.link(veh_collection)

    # 1. Toyota Hilux Style Pickup Truck (Iconic Nicaraguan Pickup in Estelí)
    # Parked on Calle Real at (-13, -8, 0)
    vx, vy, vz = -13.2, -8, 0.1

    # Chassis / Body
    bpy.ops.mesh.primitive_cube_add(size=1, location=(vx, vy, vz + 0.8))
    body = bpy.context.active_object
    body.name = "Pickup_Body"
    body.scale = (2.1, 4.8, 1.2)
    body.data.materials.append(materials['car_white'])
    veh_collection.objects.link(body)
    bpy.context.collection.objects.unlink(body)

    # Cab / Windshield
    bpy.ops.mesh.primitive_cube_add(size=1, location=(vx, vy - 0.4, vz + 1.6))
    cab = bpy.context.active_object
    cab.scale = (2.0, 2.4, 1.0)
    cab.data.materials.append(materials['car_white'])
    veh_collection.objects.link(cab)
    bpy.context.collection.objects.unlink(cab)

    # Glass Windshield & Windows
    bpy.ops.mesh.primitive_cube_add(size=1, location=(vx, vy - 0.4, vz + 1.65))
    glass = bpy.context.active_object
    glass.scale = (2.02, 2.2, 0.9)
    glass.data.materials.append(materials['glass'])
    veh_collection.objects.link(glass)
    bpy.context.collection.objects.unlink(glass)

    # Truck Bed Recess
    bpy.ops.mesh.primitive_cube_add(size=1, location=(vx, vy + 1.4, vz + 1.2))
    bed = bpy.context.active_object
    bed.scale = (1.8, 1.8, 0.6)
    bed.data.materials.append(materials['metal_dark'])
    veh_collection.objects.link(bed)
    bpy.context.collection.objects.unlink(bed)

    # Wheels (4 Rubber tires with metal rims)
    wheel_offsets = [(-1.1, -1.4), (1.1, -1.4), (-1.1, 1.4), (1.1, 1.4)]
    for wx, wy in wheel_offsets:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.42, depth=0.35, location=(vx + wx, vy + wy, vz + 0.42), rotation=(0, math.radians(90), 0))
        wheel = bpy.context.active_object
        wheel.data.materials.append(materials['metal_dark'])
        veh_collection.objects.link(wheel)
        bpy.context.collection.objects.unlink(wheel)

    # Headlights
    for hx in [-0.7, 0.7]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, location=(vx + hx, vy - 2.42, vz + 0.8))
        hl = bpy.context.active_object
        hl.data.materials.append(materials['glass'])
        veh_collection.objects.link(hl)
        bpy.context.collection.objects.unlink(hl)

    # 2. Sedan Car parked further down street
    sx, sy, sz = -13.2, 18, 0.1
    bpy.ops.mesh.primitive_cube_add(size=1, location=(sx, sy, sz + 0.7))
    car = bpy.context.active_object
    car.name = "Sedan_Car"
    car.scale = (2.0, 4.4, 0.9)
    car.data.materials.append(materials['car_red'])
    veh_collection.objects.link(car)
    bpy.context.collection.objects.unlink(car)

    bpy.ops.mesh.primitive_cube_add(size=1, location=(sx, sy, sz + 1.3))
    roof = bpy.context.active_object
    roof.scale = (1.8, 2.2, 0.7)
    roof.data.materials.append(materials['glass'])
    veh_collection.objects.link(roof)
    bpy.context.collection.objects.unlink(roof)

    for wx, wy in wheel_offsets:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.38, depth=0.32, location=(sx + wx, sy + wy, sz + 0.38), rotation=(0, math.radians(90), 0))
        sw = bpy.context.active_object
        sw.data.materials.append(materials['metal_dark'])
        veh_collection.objects.link(sw)
        bpy.context.collection.objects.unlink(sw)

def build_valley_mountains(materials):
    landscape_collection = bpy.data.collections.new("Montanas_Tisey_Esteli")
    bpy.context.scene.collection.children.link(landscape_collection)

    # Surrounding Green Mountains (Tisey / Miraflor mountain range)
    mtn_positions = [
        (-120, 0, 35, 90, 160),
        (-90, 80, 42, 80, 140),
        (-100, -80, 38, 85, 150),
        (0, 120, 45, 160, 90),
        (0, -120, 40, 160, 85),
        (110, 0, 30, 80, 150)
    ]
    for mx, my, mz, sx, sy in mtn_positions:
        bpy.ops.mesh.primitive_cone_add(vertices=12, radius1=sx, depth=mz*2, location=(mx, my, mz - 5))
        mtn = bpy.context.active_object
        mtn.name = "Mountain_Tisey"
        mtn.scale = (1.0, sy/sx, 1.0)
        mtn.data.materials.append(materials['foliage'])
        landscape_collection.objects.link(mtn)
        bpy.context.collection.objects.unlink(mtn)

def setup_cameras_and_render_views(output_dir):
    os.makedirs(output_dir, exist_ok=True)

    cameras_config = [
        {
            "name": "Cam_Cathedral_Hero",
            "loc": (-3.0, -38.0, 4.5),
            "rot": (math.radians(80), 0, math.radians(-38)),
            "filename": "1_Cathedral_Hero_View.png",
            "description": "Catedral Nuestra Señora del Rosario & Plaza"
        },
        {
            "name": "Cam_Park_View",
            "loc": (32.0, -22.0, 8.0),
            "rot": (math.radians(72), 0, math.radians(52)),
            "filename": "2_Parque_Central_Kiosco_View.png",
            "description": "Parque Central Domingo Gadea & Kiosco Central"
        },
        {
            "name": "Cam_Street_Level",
            "loc": (-12.0, -28.0, 2.2),
            "rot": (math.radians(88), 0, math.radians(0)),
            "filename": "3_Calle_Real_Street_View.png",
            "description": "Calle Real, Puros de Esteli Shop & Pickup Truck"
        },
        {
            "name": "Cam_Aerial_Overview",
            "loc": (25.0, -65.0, 55.0),
            "rot": (math.radians(52), 0, math.radians(22)),
            "filename": "4_Esteli_City_Aerial_Overview.png",
            "description": "Panoramic Aerial View of Esteli City & Tisey Mountains"
        }
    ]

    scene = bpy.context.scene

    for config in cameras_config:
        cam_data = bpy.data.cameras.new(config['name'])
        cam_data.lens = 35 # 35mm lens
        cam_obj = bpy.data.objects.new(config['name'], cam_data)
        bpy.context.collection.objects.link(cam_obj)
        cam_obj.location = config['loc']
        cam_obj.rotation_euler = config['rot']

        scene.camera = cam_obj
        filepath = os.path.join(output_dir, config['filename'])
        scene.render.filepath = filepath
        print(f"Rendering {config['name']} -> {filepath}")
        bpy.ops.render.render(write_still=True)

def main():
    print("=== Starting 3D Estelí City Builder in Blender ===")
    setup_scene()
    setup_lighting_and_world()

    tex_dir = os.path.abspath("esteli_project/Textures")

    # Materials Dictionary
    materials = {
        'concrete': create_pbr_material('Mat_Concrete', texture_path=os.path.join(tex_dir, 'concrete_albedo.png'), normal_path=os.path.join(tex_dir, 'concrete_normal.png'), rough_path=os.path.join(tex_dir, 'concrete_roughness.png')),
        'asphalt': create_pbr_material('Mat_Asphalt', texture_path=os.path.join(tex_dir, 'asphalt_albedo.png'), rough_path=os.path.join(tex_dir, 'asphalt_roughness.png')),
        'stucco': create_pbr_material('Mat_Cathedral_Stucco', texture_path=os.path.join(tex_dir, 'cathedral_stucco.png'), roughness=0.6),
        'rooftiles': create_pbr_material('Mat_RoofTiles', texture_path=os.path.join(tex_dir, 'rooftile_albedo.png'), roughness=0.7),
        'wood': create_pbr_material('Mat_Wood', texture_path=os.path.join(tex_dir, 'wood_albedo.png'), roughness=0.55),
        'park_pavers': create_pbr_material('Mat_Park_Pavers', texture_path=os.path.join(tex_dir, 'park_pavers.png'), roughness=0.65),
        'cigar_sign': create_pbr_material('Mat_Cigar_Sign', texture_path=os.path.join(tex_dir, 'cigar_sign.png'), roughness=0.3, emissive_color=(0.1, 0.08, 0.05, 1.0)),
        'glass': create_pbr_material('Mat_Glass', color=(0.85, 0.95, 1.0, 0.5), roughness=0.08, specular=0.9, transmission=0.85),
        'gold': create_pbr_material('Mat_Gold', color=(0.92, 0.76, 0.2, 1.0), roughness=0.2, metallic=0.95),
        'metal_dark': create_pbr_material('Mat_Metal_Dark', color=(0.12, 0.12, 0.15, 1.0), roughness=0.35, metallic=0.85),
        'red_paint': create_pbr_material('Mat_Red_Paint', color=(0.75, 0.12, 0.1, 1.0), roughness=0.35),
        'blue_paint': create_pbr_material('Mat_Blue_Paint', color=(0.12, 0.3, 0.7, 1.0), roughness=0.35),
        'foliage': create_pbr_material('Mat_Foliage', color=(0.08, 0.38, 0.08, 1.0), roughness=0.6),
        'car_white': create_pbr_material('Mat_Car_White', color=(0.92, 0.92, 0.94, 1.0), roughness=0.15, metallic=0.6),
        'car_red': create_pbr_material('Mat_Car_Red', color=(0.8, 0.05, 0.05, 1.0), roughness=0.15, metallic=0.7)
    }

    print("Building Catedral Nuestra Señora del Rosario...")
    build_cathedral(materials, pos=(-35, 0, 0))

    print("Building Parque Central Domingo Gadea...")
    build_parque_central(materials, pos=(10, 0, 0))

    print("Building Calle Real & Infrastructure...")
    build_street_and_infrastructure(materials)

    print("Building City Storefronts & Colonial Buildings...")
    build_city_buildings(materials)

    print("Building Vehicles...")
    build_vehicles(materials)

    print("Building Estelí Valley & Tisey Mountains...")
    build_valley_mountains(materials)

    # Save Blender file
    blend_path = os.path.abspath("esteli_project/Blender/esteli_city.blend")
    os.makedirs(os.path.dirname(blend_path), exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=blend_path)
    print(f"Saved .blend file to {blend_path}")

    # Export OBJ
    obj_path = os.path.abspath("esteli_project/OBJ/esteli_city.obj")
    os.makedirs(os.path.dirname(obj_path), exist_ok=True)
    if hasattr(bpy.ops.wm, "obj_export"):
        bpy.ops.wm.obj_export(filepath=obj_path)
    else:
        bpy.ops.export_scene.obj(filepath=obj_path)
    print(f"Exported OBJ to {obj_path}")

    # Export FBX
    fbx_path = os.path.abspath("esteli_project/FBX/esteli_city.fbx")
    os.makedirs(os.path.dirname(fbx_path), exist_ok=True)
    if hasattr(bpy.ops.export_scene, "fbx"):
        bpy.ops.export_scene.fbx(filepath=fbx_path)
    print(f"Exported FBX to {fbx_path}")

    # Render evidence screenshots outside the ZIP
    screenshots_dir = os.path.abspath("screenshots")
    print("Rendering high-resolution evidence screenshots...")
    setup_cameras_and_render_views(screenshots_dir)

    print("=== Estelí City 3D Model Generation Complete! ===")

if __name__ == "__main__":
    main()
