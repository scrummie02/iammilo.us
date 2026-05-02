#!/bin/bash
# Video assembly script for Emu War Short
# Run this after images are generated

set -e

WORKSPACE="/home/dain/.openclaw/workspace"
VIDEO_DIR="/tmp/emu_video_final"
mkdir -p "$VIDEO_DIR"

echo "=== Emu War Short Video Assembly ==="
echo "Started at $(date)"

# Scene durations (must total 60 seconds)
SCENE1_DUR=12   # Hook: Soldier vs Emu
SCENE2_DUR=13   # Setup: The Chase  
SCENE3_DUR=25   # Conflict/Twist: Scoreboard (with text overlay)
SCENE4_DUR=10   # Aftermath: Coat of Arms

echo "Step 1: Processing images to 1080x1920..."

# Scene 1: Soldier vs Emu (zoom in)
ffmpeg -loop 1 -i "$WORKSPACE/emu_img1_final.png" \
  -vf "scale=1080:1920:flags=lanczos,format=yuv420p,zoompan=z='min(zoom+0.001,1.3)':d=360:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'" \
  -t $SCENE1_DUR -c:v h264_qsv -b:v 5M -r 30 "$VIDEO_DIR/scene1.mp4" -y 2>&1 | tail -3

# Scene 2: Emu Chase (pan right)
ffmpeg -loop 1 -i "$WORKSPACE/emu_img2_final.png" \
  -vf "scale=1080:1920:flags=lanczos,format=yuv420p,zoompan=z='min(zoom+0.002,1.5)':d=390:x='iw/2-(iw/zoom/2)+200':y='ih/2-(ih/zoom/2)'" \
  -t $SCENE2_DUR -c:v h264_qsv -b:v 5M -r 30 "$VIDEO_DIR/scene2.mp4" -y 2>&1 | tail -3

# Scene 3: Scoreboard - WITH TEXT OVERLAY
# Base image without text
ffmpeg -loop 1 -i "$WORKSPACE/emu_img3_final.png" \
  -vf "scale=1080:1920:flags=lanczos,format=yuv420p" \
  -t $SCENE3_DUR -c:v h264_qsv -b:v 5M -r 30 "$VIDEO_DIR/scene3_base.mp4" -y 2>&1 | tail -3

# Add text overlays to Scene 3
ffmpeg -i "$VIDEO_DIR/scene3_base.mp4" \
  -vf "drawtext=text='THE GREAT EMU WAR':fontsize=80:fontcolor=white:x=(w-text_w)/2:y=150:box=1:boxcolor=black@0.6:boxborderw=10:fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf,\
       drawtext=text='EMUS':fontsize=100:fontcolor=#90EE90:x=150:y=800:box=1:boxcolor=black@0.6:boxborderw=10:fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf,\
       drawtext=text='WINNERS':fontsize=80:fontcolor=#90EE90:x=150:y=930:box=1:boxcolor=black@0.6:boxborderw=10:fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf,\
       drawtext=text='HUMANS':fontsize=100:fontcolor=#FF6B6B:x=w-text_w-150:y=800:box=1:boxcolor=black@0.6:boxborderw=10:fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf,\
       drawtext=text='LOST':fontsize=80:fontcolor=#FF6B6B:x=w-text_w-150:y=930:box=1:boxcolor=black@0.6:boxborderw=10:fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" \
  -c:v h264_qsv -b:v 5M -r 30 "$VIDEO_DIR/scene3.mp4" -y 2>&1 | tail -3

# Scene 4: Coat of Arms (slow zoom out)
ffmpeg -loop 1 -i "$WORKSPACE/emu_img4_final.png" \
  -vf "scale=1080:1920:flags=lanczos,format=yuv420p,zoompan=z='if(eq(on,1),1.3,zoom-0.001)':d=300:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'" \
  -t $SCENE4_DUR -c:v h264_qsv -b:v 5M -r 30 "$VIDEO_DIR/scene4.mp4" -y 2>&1 | tail -3

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
EOF

echo "Step 3: Concatenating scenes..."
ffmpeg -f concat -safe 0 -i "$VIDEO_DIR/list.txt" \
  -c:v h264_qsv -b:v 5M -r 30 "$VIDEO_DIR/video_no_audio.mp4" -y 2>&1 | tail -5

echo "Step 4: Adding voiceover..."
ffmpeg -i "$VIDEO_DIR/video_no_audio.mp4" -i "$WORKSPACE/emu_voiceover_sped.mp3" \
  -c:v copy -c:a aac -b:a 128k -shortest "$WORKSPACE/emu_war_final.mp4" -y 2>&1 | tail -5

echo "=== Done! ==="
echo "Final video: $WORKSPACE/emu_war_final.mp4"
ls -lh "$WORKSPACE/emu_war_final.mp4"
ffprobe -i "$WORKSPACE/emu_war_final.mp4" 2>&1 | grep -E "Duration|Stream|Video|Audio"