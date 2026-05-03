#!/usr/bin/env python3
"""
Toledo War Video Assembly - Python-based text overlay + FFmpeg Ken Burns
"""
import subprocess
import os
from PIL import Image, ImageDraw, ImageFont

OUTPUT_DIR = "/home/dain/.openclaw/workspace/toledo_war_assets"
os.makedirs(OUTPUT_DIR, exist_ok=True)

SCENES = [
    "/home/dain/.openclaw/media/tool-image-generation/toledo_scene1_map---bcff4f9b-06af-438f-a96f-0cb3d3cbc873.jpg",
    "/home/dain/.openclaw/media/tool-image-generation/toledo_scene2_swamp---44c64c1d-1646-4ce0-9843-cc26893d9675.jpg",
    "/home/dain/.openclaw/media/tool-image-generation/toledo_scene3_stakes---3ec383d1-b806-4ace-a046-4ba88e34fd64.jpg",
    "/home/dain/.openclaw/media/tool-image-generation/toledo_scene4_militias---b18e1e56-e160-43c6-8e47-294633fb0f0a.jpg",
    "/home/dain/.openclaw/media/tool-image-generation/toledo_scene5_wintercamp---c8402ba0-808a-46cd-83f4-9a9703b20a10.jpg",
    "/home/dain/.openclaw/media/tool-image-generation/toledo_scene6_violence---8aa03983-eb72-4175-b176-06e2e5466e22.jpg",
    "/home/dain/.openclaw/media/tool-image-generation/toledo_scene7_snowball---16823302-c15c-488f-b4a3-5fa0f9336091.jpg",
    "/home/dain/.openclaw/media/tool-image-generation/toledo_scene8_congress---6d4a7fa1-f73e-43b2-8218-ff9fa056d8d9.jpg",
    "/home/dain/.openclaw/media/tool-image-generation/toledo_scene9_deal---b817e587-98c2-400d-a305-43d9c12e7064.jpg",
    "/home/dain/.openclaw/media/tool-image-generation/toledo_scene10_legacy---6f76ae78-e2d1-439d-9b7b-a6d25d718406.jpg",
]

TEXTS = [
    "1835: Ohio vs Michigan",
    "The Toledo Strip: 468 sq miles of swamp",
    "Ohio had power. Michigan wanted statehood.",
    "Both governors sent armed militias.",
    "Months in the snow, staring each other down.",
    "Arrests. Fistfights. One stabbing.",
    "The only 'battle'? A snowball fight.",
    "Congress had to settle it.",
    "Ohio got swamp. Michigan got copper.",
    "Michigan arguably won. Follow for more.",
]

DURATION = 6

def add_text_overlay(image_path, text, output_path):
    """Add text overlay to image, save as 1080x1920"""
    img = Image.open(image_path)
    
    # Resize to 1080x1920 maintaining aspect ratio, then crop/pad
    target_w, target_h = 1080, 1920
    img_ratio = img.width / img.height
    target_ratio = target_w / target_h
    
    if img_ratio > target_ratio:
        # Image is wider, scale to target height
        new_h = target_h
        new_w = int(img.width * (target_h / img.height))
        img = img.resize((new_w, new_h), Image.LANCZOS)
        # Center crop horizontally
        left = (img.width - target_w) // 2
        img = img.crop((left, 0, left + target_w, target_h))
    else:
        # Image is taller, scale to target width
        new_w = target_w
        new_h = int(img.height * (target_w / img.width))
        img = img.resize((new_w, new_h), Image.LANCZOS)
        # Center crop vertically
        top = (img.height - target_h) // 2
        img = img.crop((0, top, target_w, top + target_h))
    
    # Add text overlay
    draw = ImageDraw.Draw(img)
    
    # Try to load font
    font_paths = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/freefont/FreeSansBold.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
    ]
    
    font = None
    for fp in font_paths:
        if os.path.exists(fp):
            try:
                font = ImageFont.truetype(fp, 48)
                break
            except:
                pass
    
    if font is None:
        font = ImageFont.load_default()
    
    # Calculate text size for centering
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    
    x = (target_w - text_w) // 2
    y = target_h - text_h - 100
    
    # Draw black outline/shadow
    for dx in [-3, -2, -1, 1, 2, 3]:
        for dy in [-3, -2, -1, 1, 2, 3]:
            draw.text((x + dx, y + dy), text, font=font, fill=(0, 0, 0, 180))
    
    # Draw white text
    draw.text((x, y), text, font=font, fill=(255, 255, 255, 255))
    
    img.save(output_path, quality=95)
    return output_path

def create_ken_burns_clip(image_path, output_path, duration=6):
    """Create a Ken Burns zoom-in effect clip"""
    # Start zoomed out at 1.0, end at 1.12
    # Duration in frames at 30fps
    frames = duration * 30
    
    cmd = [
        "ffmpeg", "-y", "-loop", "1", "-i", image_path,
        "-vf", f"zoompan=z='min(pzoom+0.001,1.12)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d={frames}:s=1080x1920:fps=30",
        "-t", str(duration),
        "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "18",
        output_path
    ]
    
    subprocess.run(cmd, check=True, capture_output=True)

def main():
    print("Step 1: Adding text overlays to images...")
    texted_images = []
    for i, (img_path, text) in enumerate(zip(SCENES, TEXTS)):
        idx = i + 1
        out_path = os.path.join(OUTPUT_DIR, f"texted_scene_{idx}.jpg")
        add_text_overlay(img_path, text, out_path)
        texted_images.append(out_path)
        print(f"  Scene {idx} done")
    
    print("\nStep 2: Creating Ken Burns clips...")
    clips = []
    for i, img_path in enumerate(texted_images):
        idx = i + 1
        out_path = os.path.join(OUTPUT_DIR, f"scene_{idx}.mp4")
        create_ken_burns_clip(img_path, out_path, DURATION)
        clips.append(out_path)
        print(f"  Scene {idx} done")
    
    print("\nStep 3: Concatenating clips...")
    concat_file = os.path.join(OUTPUT_DIR, "concat_list.txt")
    with open(concat_file, "w") as f:
        for clip in clips:
            f.write(f"file '{clip}'\n")
    
    temp_video = os.path.join(OUTPUT_DIR, "temp_video.mp4")
    subprocess.run([
        "ffmpeg", "-y", "-f", "concat", "-safe", "0",
        "-i", concat_file, "-c", "copy", temp_video
    ], check=True, capture_output=True)
    
    print("\nStep 4: Adding voiceover...")
    final_video = "/home/dain/.openclaw/workspace/toledo_war_FINAL.mp4"
    voiceover = "/home/dain/.openclaw/media/tool-music-generation/toledo_war_voiceover---1104a2cb-872d-45f4-aa06-d68ee01f25af.mp3"
    
    subprocess.run([
        "ffmpeg", "-y", "-i", temp_video, "-i", voiceover,
        "-c:v", "copy", "-c:a", "aac", "-b:a", "192k",
        "-shortest", final_video
    ], check=True, capture_output=True)
    
    # Get duration
    result = subprocess.run([
        "ffprobe", "-v", "error",
        "-show_entries", "format=duration",
        "-of", "default=noprint_wrappers=1:nokey=1",
        final_video
    ], capture_output=True, text=True, check=True)
    duration = result.stdout.strip()
    
    print(f"\nDone! Final video: {final_video}")
    print(f"Duration: {duration}s")
    print(f"File size: {os.path.getsize(final_video) / (1024*1024):.1f} MB")

if __name__ == "__main__":
    main()
