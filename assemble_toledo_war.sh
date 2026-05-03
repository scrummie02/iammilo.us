#!/bin/bash
set -e

# Toledo War Video Assembly Script v2
# 10 scenes, ~6 seconds each, total ~60 seconds

OUTPUT_DIR="/home/dain/.openclaw/workspace/toledo_war_assets"
mkdir -p "$OUTPUT_DIR"

# Scene images
SCENES=(
  "/home/dain/.openclaw/media/tool-image-generation/toledo_scene1_map---bcff4f9b-06af-438f-a96f-0cb3d3cbc873.jpg"
  "/home/dain/.openclaw/media/tool-image-generation/toledo_scene2_swamp---44c64c1d-1646-4ce0-9843-cc26893d9675.jpg"
  "/home/dain/.openclaw/media/tool-image-generation/toledo_scene3_stakes---3ec383d1-b806-4ace-a046-4ba88e34fd64.jpg"
  "/home/dain/.openclaw/media/tool-image-generation/toledo_scene4_militias---b18e1e56-e160-43c6-8e47-294633fb0f0a.jpg"
  "/home/dain/.openclaw/media/tool-image-generation/toledo_scene5_wintercamp---c8402ba0-808a-46cd-83f4-9a9703b20a10.jpg"
  "/home/dain/.openclaw/media/tool-image-generation/toledo_scene6_violence---8aa03983-eb72-4175-b176-06e2e5466e22.jpg"
  "/home/dain/.openclaw/media/tool-image-generation/toledo_scene7_snowball---16823302-c15c-488f-b4a3-5fa0f9336091.jpg"
  "/home/dain/.openclaw/media/tool-image-generation/toledo_scene8_congress---6d4a7fa1-f73e-43b2-8218-ff9fa056d8d9.jpg"
  "/home/dain/.openclaw/media/tool-image-generation/toledo_scene9_deal---b817e587-98c2-400d-a305-43d9c12e7064.jpg"
  "/home/dain/.openclaw/media/tool-image-generation/toledo_scene10_legacy---6f76ae78-e2d1-439d-9b7b-a6d25d718406.jpg"
)

# Text overlays for each scene
TEXTS=(
  "1835: Ohio vs Michigan"
  "The Toledo Strip: 468 sq miles of swamp"
  "Ohio had power. Michigan wanted statehood."
  "Both governors sent armed militias."
  "Months in the snow, staring each other down."
  "Arrests. Fistfights. One stabbing."
  "The only 'battle'? A snowball fight."
  "Congress had to settle it."
  "Ohio got swamp. Michigan got copper."
  "Michigan arguably won. Follow for more."
)

DURATION=6

# Generate Ken Burns clips with text overlays
for i in $(seq 0 9); do
  idx=$((i+1))
  img="${SCENES[$i]}"
  text="${TEXTS[$i]}"
  
  # Simple Ken Burns - slow zoom in for all scenes
  echo "Processing scene $idx..."
  
  ffmpeg -y -loop 1 -i "$img" -vf "
scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,
zoompan=z='min(pzoom+0.001,1.12)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=${DURATION}*30:s=1080x1920,
drawtext=text='$text':fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:fontsize=48:fontcolor=white:borderw=3:bordercolor=black@0.8:x=(w-text_w)/2:y=h-text_h-80:enable='between(t\\,0\\,${DURATION})'
" -t "$DURATION" -c:v libx264 -pix_fmt yuv420p -crf 18 "$OUTPUT_DIR/scene_${idx}.mp4" 2>&1 | tail -5
done

# Concatenate all scenes
echo "Concatenating scenes..."
for i in $(seq 1 10); do
  echo "file 'scene_${i}.mp4'" >> "$OUTPUT_DIR/concat_list.txt"
done

ffmpeg -y -f concat -safe 0 -i "$OUTPUT_DIR/concat_list.txt" -c copy "$OUTPUT_DIR/temp_video.mp4"

# Add voiceover
echo "Adding voiceover..."
ffmpeg -y -i "$OUTPUT_DIR/temp_video.mp4" -i "/home/dain/.openclaw/media/tool-music-generation/toledo_war_voiceover---1104a2cb-872d-45f4-aa06-d68ee01f25af.mp3" -c:v copy -c:a aac -b:a 192k -shortest "$OUTPUT_DIR/toledo_war_FINAL.mp4"

# Cleanup
rm -f "$OUTPUT_DIR/temp_video.mp4" "$OUTPUT_DIR/concat_list.txt"

# Copy final to workspace
cp "$OUTPUT_DIR/toledo_war_FINAL.mp4" "/home/dain/.openclaw/workspace/toledo_war_FINAL.mp4"

echo "Done! Final video: toledo_war_FINAL.mp4"
DUR=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "/home/dain/.openclaw/workspace/toledo_war_FINAL.mp4")
echo "Duration: ${DUR}s"
