#!/usr/bin/env python3
"""Create Dancing Plague video with Ken Burns effect"""

import os
import subprocess
import glob

WORKSPACE = "/home/dain/.openclaw/workspace"
MEDIA_DIR = "/home/dain/.openclaw/media/tool-image-generation"
OUTPUT = f"{WORKSPACE}/dancing_plague_FINAL.mp4"

# Scene durations (seconds)
DURATIONS = [5.5, 5.5, 5.5, 5.5, 5.5, 5.5, 5.5, 5.5, 5.5, 10.5]

# Scene texts
SCENE_TEXTS = [
    "July 1518, Strasbourg, France",
    "Within a month, 400 people",
    "Some danced until they died",
    "The cure? MORE dancing",
    "They built a stage. Hired musicians.",
    "Doctors vs. The Church",
    "September 1518. Dozens dead.",
    "No one knows why it stopped.",
    "Mass psychogenic illness?",
    "A town danced itself to death."
]

# Image files
IMAGES = [
    f"{MEDIA_DIR}/dancing_plague_scene1---f0d9628d-8946-45cb-b790-0f64e245191d.jpg",
    f"{MEDIA_DIR}/dancing_plague_scene2---8b6cae92-0f6c-4e9a-87d6-b97e593ecc27.jpg",
    f"{MEDIA_DIR}/dancing_plague_scene3---4a11e79e-0f60-4e83-b65a-90f35f8704b5.jpg",
    f"{MEDIA_DIR}/dancing_plague_scene4---c111838f-7b5c-4189-b17c-1c361e455068.jpg",
    f"{MEDIA_DIR}/dancing_plague_scene5---520dda0f-b729-467d-b314-5d92eaa1b8d2.jpg",
    f"{MEDIA_DIR}/dancing_plague_scene6---ae48c05b-bd95-441e-9a71-d56acc5a6d1a.jpg",
    f"{MEDIA_DIR}/dancing_plague_scene7---92a1e18f-9598-4a7e-baa3-780c1bab9781.jpg",
    f"{MEDIA_DIR}/dancing_plague_scene8---c56b97db-67bc-4dd3-9f84-6192523f3314.jpg",
    f"{MEDIA_DIR}/dancing_plague_scene9---cc0a2458-095c-4a5d-916c-7c0609ed5878.jpg",
    f"{MEDIA_DIR}/dancing_plague_scene10---f8306d57-e7fb-4f80-ad13-dfcdc399f79f.jpg",
]

def create_scene_clip(image_path, duration, output_path, zoom_start=1.0, zoom_end=1.15):
    """Create a video clip from image with zoom effect"""
    frames = int(duration * 30)  # 30 fps
    
    cmd = [
        "ffmpeg", "-y",
        "-loop", "1",
        "-i", image_path,
        "-vf", f"fps=30,scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920:(in_w-1080)/2:(in_h-1920)/2,zoompan=z='if(eq(on,0),{zoom_start},min(zoom+{(zoom_end-zoom_start)/frames},{zoom_end}))':d={frames}:s=1080x1920:fps=30",
        "-c:v", "libx264",
        "-preset", "fast",
        "-t", str(duration),
        "-pix_fmt", "yuv420p",
        "-an",
        output_path
    ]
    
    subprocess.run(cmd, check=True)
    print(f"  Created: {output_path}")

def main():
    os.chdir(WORKSPACE)
    
    print("Creating Dancing Plague video...")
    print(f"Output: {OUTPUT}")
    print()
    
    # Create scene clips
    scene_files = []
    for i, (img, dur, text) in enumerate(zip(IMAGES, DURATIONS, SCENE_TEXTS), 1):
        print(f"Scene {i}: {dur}s - {text}")
        scene_file = f"dp_scene_{i:02d}.mp4"
        scene_files.append(scene_file)
        
        # Alternate zoom direction for variety
        if i % 2 == 0:
            create_scene_clip(img, dur, scene_file, zoom_start=1.15, zoom_end=1.0)
        else:
            create_scene_clip(img, dur, scene_file, zoom_start=1.0, zoom_end=1.15)
    
    # Create concat file
    concat_file = "dp_concat.txt"
    with open(concat_file, "w") as f:
        for scene in scene_files:
            f.write(f"file '{scene}'\n")
    
    # Concatenate scenes
    print("\nConcatenating scenes...")
    temp_video = "dp_temp_video.mp4"
    subprocess.run([
        "ffmpeg", "-y",
        "-f", "concat",
        "-safe", "0",
        "-i", concat_file,
        "-c", "copy",
        temp_video
    ], check=True)
    
    # Add voiceover
    voiceover = f"{WORKSPACE}/dancing_plague_voiceover_sped.mp3"
    if not os.path.exists(voiceover):
        voiceover = f"{WORKSPACE}/dancing_plague_voiceover.mp3"
    
    print(f"Adding voiceover: {voiceover}")
    subprocess.run([
        "ffmpeg", "-y",
        "-i", temp_video,
        "-i", voiceover,
        "-c:v", "copy",
        "-c:a", "aac",
        "-shortest",
        OUTPUT
    ], check=True)
    
    # Cleanup
    for f in scene_files + [concat_file, temp_video]:
        if os.path.exists(f):
            os.remove(f)
    
    # Get video info
    result = subprocess.run([
        "ffprobe", "-v", "error",
        "-show_entries", "format=duration,size,bit_rate",
        "-of", "default=noprint_wrappers=1",
        OUTPUT
    ], capture_output=True, text=True)
    
    print(f"\n✓ Done! Video saved to: {OUTPUT}")
    print(result.stdout)
    
    # Show file size
    size_mb = os.path.getsize(OUTPUT) / (1024 * 1024)
    print(f"File size: {size_mb:.1f} MB")

if __name__ == "__main__":
    main()
