import bpy, bmesh, math, json, os
from mathutils import Matrix, Vector
specs = json.load(open(os.path.join(os.path.dirname(__file__), "kit-specs.json"), encoding="utf-8"))
output_dir = os.path.dirname(os.path.abspath(__file__))
os.makedirs(output_dir, exist_ok=True)
scene = bpy.data.scenes.new("ProjectMS_ToyCity_v04")
bpy.context.window.scene = scene
scale = 0.18
conversion = Matrix(((1,0,0),(0,0,-1),(0,1,0)))
placements = {"StarterHouse":(-5,-3,0), "Office":(2,-3,0), "TechLab":(-6,4,0), "AFKLab":(0,4,0), "CraftingMachine":(5,4,0)}
materials = {}
created = []

def linear(c):
    return c / 12.92 if c <= 0.04045 else ((c+0.055)/1.055)**2.4

def material(rgb):
    key = tuple(round(v,3) for v in rgb)
    if key in materials:
        return materials[key]
    mat = bpy.data.materials.new("ToyCity_"+"_".join(str(round(v*255)) for v in key))
    mat.use_nodes = True
    shader = next(node for node in mat.node_tree.nodes if node.type == "BSDF_PRINCIPLED")
    shader.inputs["Base Color"].default_value = tuple(linear(v) for v in key)+(1,)
    shader.inputs["Roughness"].default_value = 0.42
    mat.diffuse_color = tuple(key)+(1,)
    materials[key] = mat
    return mat

def mesh_for(piece):
    sx,sy,sz = piece["size"]
    mesh = bpy.data.meshes.new(piece["name"])
    shape = piece["shape"]
    if shape == "Ball":
        bm=bmesh.new()
        bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.5)
        for vert in bm.verts:
            old=vert.co.copy()
            vert.co=Vector((old.x*sx,-old.z*sz,old.y*sy))*scale
        bm.to_mesh(mesh)
        bm.free()
    elif shape == "Cylinder":
        verts=[]
        for x in [-0.5,0.5]:
            for i in range(16):
                angle=i*math.tau/16
                verts.append((x*sx*scale,-math.sin(angle)*sz*0.5*scale,math.cos(angle)*sy*0.5*scale))
        faces=[tuple(reversed(range(16))),tuple(range(16,32))]
        faces.extend((i,(i+1)%16,(i+1)%16+16,i+16) for i in range(16))
        mesh.from_pydata(verts,[],faces)
    else:
        verts=[(x*sx*scale,-z*sz*scale,y*sy*scale) for x,y,z in [(-.5,-.5,-.5),(.5,-.5,-.5),(.5,.5,-.5),(-.5,.5,-.5),(-.5,-.5,.5),(.5,-.5,.5),(.5,.5,.5),(-.5,.5,.5)]]
        faces=[(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]
        mesh.from_pydata(verts,[],faces)
    mesh.update()
    return mesh

for spec in specs:
    collection=bpy.data.collections.new("Kit_"+spec["name"])
    scene.collection.children.link(collection)
    placement=Vector(placements[spec["name"]])
    for piece in spec["parts"]:
        cf=piece["cf"]
        rotation=Matrix((cf[3:6],cf[6:9],cf[9:12]))
        obj=bpy.data.objects.new(spec["name"]+"_"+piece["name"],mesh_for(piece))
        collection.objects.link(obj)
        obj.location=conversion@Vector(cf[:3])*scale+placement
        obj.rotation_mode='QUATERNION'
        obj.rotation_quaternion=(conversion@rotation@conversion.transposed()).to_quaternion()
        obj.data.materials.append(material(piece["color"]))
        bevel=obj.modifiers.new("Soft toy edges","BEVEL")
        bevel.width=min(0.045,min(piece["size"])*scale*0.14)
        bevel.segments=2
        bevel.affect='EDGES'
        created.append(obj)

ground_mesh=bpy.data.meshes.new("StageGround")
ground_mesh.from_pydata([(-16,-12,-.05),(16,-12,-.05),(16,14,-.05),(-16,14,-.05)],[],[(0,1,2,3)])
ground=bpy.data.objects.new("StageGround",ground_mesh)
scene.collection.objects.link(ground)
ground.data.materials.append(material((0.79,0.85,0.94)))
world=bpy.data.worlds.new("ToyCityDaylight")
world.use_nodes=True
background=next(n for n in world.node_tree.nodes if n.type=="BACKGROUND")
background.inputs[0].default_value=(0.7,0.82,1,1)
background.inputs[1].default_value=0.65
scene.world=world
for name,location,power,size in [("SoftKey",(1,8,14),1800,10),("SoftFill",(-8,4,9),1000,8)]:
    data=bpy.data.lights.new(name,'AREA')
    data.energy=power
    data.shape='DISK'
    data.size=size
    obj=bpy.data.objects.new(name,data)
    scene.collection.objects.link(obj)
    obj.location=location
    obj.rotation_euler=(Vector((0,0,2))-obj.location).to_track_quat('-Z','Y').to_euler()
camera_data=bpy.data.cameras.new("ToyCityKitCamera")
camera=bpy.data.objects.new("ToyCityKitCamera",camera_data)
scene.collection.objects.link(camera)
camera.location=(17,23,19)
camera.rotation_euler=(Vector((0,0,2.2))-camera.location).to_track_quat('-Z','Y').to_euler()
camera_data.type='ORTHO'
camera_data.ortho_scale=22
scene.camera=camera
scene.render.resolution_x=1280
scene.render.resolution_y=850
scene.render.resolution_percentage=100
scene.render.image_settings.file_format=next(i.identifier for i in scene.render.image_settings.bl_rna.properties["file_format"].enum_items if i.identifier=="PNG")
scene.render.filepath=os.path.join(output_dir,"toy-city-v04-kit.png")
for obj in bpy.context.selected_objects:
    obj.select_set(False)
for obj in created:
    obj.select_set(True)
bpy.context.view_layer.objects.active=created[0]
blend_path=os.path.join(output_dir,"toy-city-v04-kit.blend")
bpy.ops.wm.save_as_mainfile(filepath=blend_path)
# GLB was confirmed in Blender5.2's runtime enum error; dynamic enum_items is empty there.
bpy.ops.export_scene.gltf(filepath=os.path.join(output_dir,"toy-city-v04-kit.glb"),export_format="GLB",use_selection=True,use_active_scene=True)
bpy.ops.render.render(write_still=True)
print(json.dumps({"scene":scene.name,"assets":len(specs),"meshObjects":len(created),"blend":blend_path,"preview":scene.render.filepath}))
