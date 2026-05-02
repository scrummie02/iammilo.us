#!/bin/bash
# Emu War Short v4 - Final with fixed audio ending
set -e

WORKSPACE="/home/dain/.openclaw/workspace"
VIDEO_DIR="/tmp/emu_war_v3"  # Reuse processed scenes

echo "=== Emu War Short v4 - Final Assembly ==="

# Same scene timings as v3
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

echo "Step 1: Reusing pre-processed scenes from v3..."

# Rebuild concat list
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

echo "Step 2: Concatenating scenes..."
ffmpeg -f concat -safe 0 -i "$VIDEO_DIR/list.txt" \
  -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/video_no_audio.mp4" -y 2>&1 | tail -3

echo "Step 3: Adding fixed voiceover..."
ffmpeg -i "$VIDEO_DIR/video_no_audio.mp4" -i "/tmp/emu_voiceover_v2.mp3" \
  -c:v copy -c:a aac -b:a 192k -shortest \
  "$WORKSPACE/emu_war_shorts_v4.mp4" -y 2>&1 | tail -5

echo "=== Done! ==="
ls -lh "$WORKSPACE/emu_war_shorts_v4.mp4"
ffprobe -i "$WORKSPACE/emu_war_shorts_v4.mp4" 2>&1 | grep -E "Duration|Stream|Video|Audio"
