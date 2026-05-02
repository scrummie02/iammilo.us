#!/bin/bash
# Emu War Short v3 - Armchair Historian Style with Ken Burns Effects
# Simple approach: pre-crop images to vertical, then zoompan

set -e

WORKSPACE="/home/dain/.openclaw/workspace"
MEDIA_DIR="/home/dain/.openclaw/media/tool-image-generation"
VIDEO_DIR="/tmp/emu_war_v3"
mkdir -p "$VIDEO_DIR"

echo "=== Emu War Short v3 - Cinematic Assembly ==="
echo "Started at $(date)"

# Scene timings (total: 60s)
SCENE1_DUR=4.0
SCENE2_DUR=5.0
SCENE3_DUR=5.2
SCENE4_DUR=5.1
SCENE5_DUR=2.7
SCENE6_DUR=6.8
SCENE7_DUR=8.7
SCENE8_DUR=6.1
SCENE9_DUR=5.6
SCENE10_DUR=4.8
SCENE11_DUR=6.0

# Pre-process images to 1620x2880 (1.5x for zoom room)
echo "Step 0: Pre-processing images to vertical format..."

convert "$MEDIA_DIR/emu_scene1_opening---b274697c-e78d-42b2-9653-481dd897a84c.jpg" -resize 1620x2880^ -gravity center -crop 1620x2880+0+0 +repage "$VIDEO_DIR/s1.png"
convert "$MEDIA_DIR/emu_scene2_settlers---f4c6d94f-e472-4702-9e52-63c78069270c.jpg" -resize 1620x2880^ -gravity center -crop 1620x2880+0+0 +repage "$VIDEO_DIR/s2.png"
convert "$MEDIA_DIR/emu_scene3_emustorm---c5eeda81-103c-4203-aee8-a968c1f172af.jpg" -resize 1620x2880^ -gravity center -crop 1620x2880+0+0 +repage "$VIDEO_DIR/s3.png"
convert "$MEDIA_DIR/emu_scene4_devastation---6eb02ba2-0ae4-4754-95b8-e8e186dad4d0.jpg" -resize 1620x2880^ -gravity center -crop 1620x2880+0+0 +repage "$VIDEO_DIR/s4.png"
convert "$MEDIA_DIR/emu_scene5_military---14377bfa-6920-454b-beb0-c4d4eac5f092.jpg" -resize 1620x2880^ -gravity center -crop 1620x2880+0+0 +repage "$VIDEO_DIR/s5.png"
convert "$MEDIA_DIR/emu_scene6_battle---fcb9fbdb-211e-4e8a-ab93-69b725096e27.jpg" -resize 1620x2880^ -gravity center -crop 1620x2880+0+0 +repage "$VIDEO_DIR/s6.png"
convert "$MEDIA_DIR/emu_scene7_chase---acb56edc-d8ef-4c90-9899-37235ef56189.jpg" -resize 1620x2880^ -gravity center -crop 1620x2880+0+0 +repage "$VIDEO_DIR/s7.png"
convert "$MEDIA_DIR/emu_scene8_defeat---951a4b28-654d-4341-8ae1-3f3720a7a0f5.jpg" -resize 1620x2880^ -gravity center -crop 1620x2880+0+0 +repage "$VIDEO_DIR/s8.png"
convert "$MEDIA_DIR/emu_scene9_memorial---4d51506b-748c-42c0-b9fe-40e8b649c784.jpg" -resize 1620x2880^ -gravity center -crop 1620x2880+0+0 +repage "$VIDEO_DIR/s9.png"
convert "$MEDIA_DIR/emu_scene10_coatarms---6e4c6b06-ea0f-4221-a0cf-25622520b1ee.jpg" -resize 1620x2880^ -gravity center -crop 1620x2880+0+0 +repage "$VIDEO_DIR/s10.png"
convert "$MEDIA_DIR/emu_scene11_teach---ed5ee441-f45d-4bcb-9ddc-0118813c2e59.jpg" -resize 1620x2880^ -gravity center -crop 1620x2880+0+0 +repage "$VIDEO_DIR/s11.png"

echo "Step 1: Processing with Ken Burns effects..."

# Scene 1: Opening - slow zoom out
ffmpeg -loop 1 -i "$VIDEO_DIR/s1.png" \
  -vf "zoompan=z='if(eq(on,1),1.5,max(1,zoom-0.0015))':d=120:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)+100':s=1080x1920,format=yuv420p" \
  -t $SCENE1_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene1.mp4" -y 2>&1 | tail -2

# Scene 2: Settlers - pan right
ffmpeg -loop 1 -i "$VIDEO_DIR/s2.png" \
  -vf "zoompan=z='1.4':d=150:x='if(eq(on,1),0,min(iw-iw/1.4,iw/2-(iw/zoom/2)))':y='ih/2-(ih/zoom/2)':s=1080x1920,format=yuv420p" \
  -t $SCENE2_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene2.mp4" -y 2>&1 | tail -2

# Scene 3: Emu storm - zoom in
ffmpeg -loop 1 -i "$VIDEO_DIR/s3.png" \
  -vf "zoompan=z='min(zoom+0.001,1.5)':d=156:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920,format=yuv420p" \
  -t $SCENE3_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene3.mp4" -y 2>&1 | tail -2

# Scene 4: Devastation - pan left
ffmpeg -loop 1 -i "$VIDEO_DIR/s4.png" \
  -vf "zoompan=z='1.35':d=153:x='if(eq(on,1),iw-iw/1.35,max(0,iw/2-(iw/zoom/2)-100))':y='ih/2-(ih/zoom/2)':s=1080x1920,format=yuv420p" \
  -t $SCENE4_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene4.mp4" -y 2>&1 | tail -2

# Scene 5: Military - slow zoom in
ffmpeg -loop 1 -i "$VIDEO_DIR/s5.png" \
  -vf "zoompan=z='min(zoom+0.0015,1.6)':d=81:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920,format=yuv420p" \
  -t $SCENE5_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene5.mp4" -y 2>&1 | tail -2

# Scene 6: Battle - zoom out
ffmpeg -loop 1 -i "$VIDEO_DIR/s6.png" \
  -vf "zoompan=z='if(eq(on,1),1.7,max(1,zoom-0.001))':d=204:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920,format=yuv420p" \
  -t $SCENE6_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene6.mp4" -y 2>&1 | tail -2

# Scene 7: Chase - pan right
ffmpeg -loop 1 -i "$VIDEO_DIR/s7.png" \
  -vf "zoompan=z='1.4':d=261:x='if(eq(on,1),0,min(iw-iw/1.4,iw/2-(iw/zoom/2)+100))':y='ih/2-(ih/zoom/2)':s=1080x1920,format=yuv420p" \
  -t $SCENE7_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene7.mp4" -y 2>&1 | tail -2

# Scene 8: Defeat - slow zoom in
ffmpeg -loop 1 -i "$VIDEO_DIR/s8.png" \
  -vf "zoompan=z='min(zoom+0.0013,1.55)':d=183:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)-50':s=1080x1920,format=yuv420p" \
  -t $SCENE8_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene8.mp4" -y 2>&1 | tail -2

# Scene 9: Memorial - pan across
ffmpeg -loop 1 -i "$VIDEO_DIR/s9.png" \
  -vf "zoompan=z='1.3':d=168:x='if(eq(on,1),iw/2-(iw/zoom/2),iw/2-(iw/zoom/2)+sin(on/30)*150)':y='ih/2-(ih/zoom/2)':s=1080x1920,format=yuv420p" \
  -t $SCENE9_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene9.mp4" -y 2>&1 | tail -2

# Scene 10: Coat of arms - slow zoom out
ffmpeg -loop 1 -i "$VIDEO_DIR/s10.png" \
  -vf "zoompan=z='if(eq(on,1),1.6,max(1.15,zoom-0.0013))':d=144:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920,format=yuv420p" \
  -t $SCENE10_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene10.mp4" -y 2>&1 | tail -2

# Scene 11: Classroom - gentle pan with fade to black
ffmpeg -loop 1 -i "$VIDEO_DIR/s11.png" \
  -vf "zoompan=z='1.2':d=180:x='iw/2-(iw/zoom/2)+sin(on/40)*75':y='ih/2-(ih/zoom/2)':s=1080x1920,fade=t=out:st=5.5:d=0.5,format=yuv420p" \
  -t $SCENE11_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene11.mp4" -y 2>&1 | tail -2

echo "Step 2: Creating concat list..."
cat > "$VIDEO_DIR/list.txt" << EOF
file '$VIDEO_DIR/scene1.mp4'
duration $SCENE1_DUR
file '$VIDEO_DIR/scene2.mp4'
duration $SCENE2_DUR
file '$VIDEO_DIR/scene3.mp4'
duration $SCENE3_DUR
file '$VIDEO_DIR/scene4.mp4'
duration $SCENE4_DUR
file '$VIDEO_DIR/scene5.mp4'
duration $SCENE5_DUR
file '$VIDEO_DIR/scene6.mp4'
duration $SCENE6_DUR
file '$VIDEO_DIR/scene7.mp4'
duration $SCENE7_DUR
file '$VIDEO_DIR/scene8.mp4'
duration $SCENE8_DUR
file '$VIDEO_DIR/scene9.mp4'
duration $SCENE9_DUR
file '$VIDEO_DIR/scene10.mp4'
duration $SCENE10_DUR
file '$VIDEO_DIR/scene11.mp4'
duration $SCENE11_DUR
EOF

echo "Step 3: Concatenating scenes..."
ffmpeg -f concat -safe 0 -i "$VIDEO_DIR/list.txt" \
  -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/video_no_audio.mp4" -y 2>&1 | tail -5

echo "Step 4: Adding voiceover..."
ffmpeg -i "$VIDEO_DIR/video_no_audio.mp4" -i "$WORKSPACE/emu_voiceover_sped.mp3" \
  -c:v copy -c:a aac -b:a 192k -shortest \
  "$WORKSPACE/emu_war_shorts_v3.mp4" -y 2>&1 | tail -5

echo "=== Done! ==="
echo "Final video: $WORKSPACE/emu_war_shorts_v3.mp4"
ls -lh "$WORKSPACE/emu_war_shorts_v3.mp4"
ffprobe -i "$WORKSPACE/emu_war_shorts_v3.mp4" 2>&1 | grep -E "Duration|Stream|Video|Audio"
