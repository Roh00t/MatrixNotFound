"""Shrink the Meshy 3D building models for the web simulator.

Run headless from the repository root:

    /Applications/Blender.app/Contents/MacOS/Blender -b -P tools/prepare_models.py

For each building it imports the original GLB from assets/3d/, reduces the
triangle count with a Decimate (collapse) modifier, downsizes the textures,
and exports a compact GLB to dashboard/models/. The originals (one is 245 MB,
over GitHub's 100 MB limit) stay local and are gitignored.
"""
import os
import bpy

ROOT = os.getcwd()
SOURCE_DIR = os.path.join(ROOT, "assets", "3d")
OUTPUT_DIR = os.path.join(ROOT, "dashboard", "models")

# name -> (source file, target triangle count, max texture size in px)
MODELS = {
    "hive": ("Meshy_AI_The_Hive_Building_3D_1030054134_texture.glb", 60_000, 1024),
    "arc": ("Meshy_AI_NTU_The_Arc_Building_1030055149_image-to-3d-texture.glb", 150_000, 2048),
}


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def triangle_count(objects):
    total = 0
    for obj in objects:
        mesh = obj.data
        mesh.calc_loop_triangles()
        total += len(mesh.loop_triangles)
    return total


def shrink(name, source, target_tris, max_texture):
    reset_scene()
    bpy.ops.import_scene.gltf(filepath=os.path.join(SOURCE_DIR, source))
    meshes = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
    before = triangle_count(meshes)

    ratio = min(1.0, target_tris / max(before, 1))
    if ratio < 1.0:
        for obj in meshes:
            bpy.context.view_layer.objects.active = obj
            modifier = obj.modifiers.new(name="Decimate", type="DECIMATE")
            modifier.decimate_type = "COLLAPSE"
            modifier.ratio = ratio
            bpy.ops.object.modifier_apply(modifier=modifier.name)
    after = triangle_count(meshes)

    for image in bpy.data.images:
        width, height = image.size
        if max(width, height) > max_texture:
            scale = max_texture / max(width, height)
            image.scale(int(width * scale), int(height * scale))

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    target = os.path.join(OUTPUT_DIR, f"{name}.glb")
    bpy.ops.export_scene.gltf(
        filepath=target,
        export_format="GLB",
        export_image_format="JPEG",
        export_image_quality=80,
        export_apply=True,
    )
    size_mb = os.path.getsize(target) / 1e6
    print(f"[prepare_models] {name}: {before:,} -> {after:,} triangles, {size_mb:.1f} MB -> {target}")


for model_name, (file_name, triangles, texture_px) in MODELS.items():
    shrink(model_name, file_name, triangles, texture_px)
