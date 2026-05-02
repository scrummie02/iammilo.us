#!/bin/bash
# Emu War Short v2 - Armchair Historian Style with Ken Burns Effects
# 11 scenes with dramatic zooms and pans

set -e

WORKSPACE="/home/dain/.openclaw/workspace"
MEDIA_DIR="/home/dain/.openclaw/media/tool-image-generation"
VIDEO_DIR="/tmp/emu_war_v2"
mkdir -p "$VIDEO_DIR"

echo "=== Emu War Short v2 - Cinematic Assembly ==="
echo "Started at $(date)"

# Scene timings based on transcript (total: 60s)
# 0:00-4.0  "In 1932 Australia lost a war to flightless birds"
# 4:0-9:0   "After WWI, 5,000 soldier settlers..."
# 9:0-14.2  "Poor soil... 20,000 emus showed up"
# 14.2-19.3 "The emus destroyed fences..."
# 19.3-22.0 "So Australia did the logical thing..."
# 22.0-28.8 "Three soldiers... Day three, jammed gun"
# 28.8-37.5 "Emus scattered at 55 mph..."
# 37.5-43.6 "Commanding officer admitted..."
# 43.6-49.2 "45 days later... The emus won"
# 49.2-54.0 "Today emus appear..."
# 54.0-60.0 "Because when you lose... Follow for more"

SCENE1_DUR=4.0    # Opening: slow zoom out from emu silhouette
SCENE2_DUR=5.0    # Settlers: pan right across settlement
SCENE3_DUR=5.2    # Emu storm: zoom in on approaching horde
SCENE4_DUR=5.1    # Devastation: pan left across broken fences
SCENE5_DUR=2.7    # Military: slow zoom in on soldiers
SCENE6_DUR=6.8    # Battle: zoom out from chaos
SCENE7_DUR=8.7    # Chase: pan right following emu
SCENE8_DUR=6.1    # Defeat: slow zoom in on officer
SCENE9_DUR=5.6    # Memorial: pan across monument
SCENE10_DUR=4.8   # Coat of arms: slow zoom out
SCENE11_DUR=6.0   # Classroom: gentle pan, fade to black

echo "Step 1: Processing images with Ken Burns effects..."

# Scene 1: Opening - slow zoom out from emus (0:00-4.0)
ffmpeg -loop 1 -i "$MEDIA_DIR/emu_scene1_opening---b274697c-e78d-42b2-9653-481dd897a84c.jpg" \
  -vf "scale=1080:1920:flags=lanczos,format=yuv420p,
       zoompan=z='if(eq(on,1),1.5,max(1,zoom-0.0015))':
              d=120:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)+50'" \
  -t $SCENE1_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene1.mp4" -y 2>&1 | tail -3

# Scene 2: Settlers - pan right across settlement (4:0-9:0)
ffmpeg -loop 1 -i "$MEDIA_DIR/emu_scene2_settlers---f4c6d94f-e472-4702-9e52-63c78069270c.jpg" \
  -vf "scale=1080:1920:flags=lanczos,format=yuv420p,
       zoompan=z='1.3':d=150:
              x='if(eq(on,1),0,iw/2-(iw/zoom/2))':
              y='ih/2-(ih/zoom/2)'" \
  -t $SCENE2_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene2.mp4" -y 2>&1 | tail -3

# Scene 3: Emu storm - zoom in on horde (9:0-14.2)
ffmpeg -loop 1 -i "$MEDIA_DIR/emu_scene3_emustorm---c5eeda81-103c-4203-aee8-a968c1f172af.jpg" \
  -vf "scale=1080:1920:flags=lanczos,format=yuv420p,
       zoompan=z='min(zoom+0.001,1.4)':d=156:
              x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'" \
  -t $SCENE3_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene3.mp4" -y 2>&1 | tail -3

# Scene 4: Devastation - pan left across broken fences (14.2-19.3)
ffmpeg -loop 1 -i "$MEDIA_DIR/emu_scene4_devastation---6eb02ba2-0ae4-4754-95b8-e8e186dad4d0.jpg" \
  -vf "scale=1080:1920:flags=lanczos,format=yuv420p,
       zoompan=z='1.25':d=153:
              x='if(eq(on,1),iw-(iw/zoom),max(0,iw/2-(iw/zoom/2)-50))':
              y='ih/2-(ih/zoom/2)'" \
  -t $SCENE4_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene4.mp4" -y 2>&1 | tail -3

# Scene 5: Military - slow zoom in (19.3-22.0)
ffmpeg -loop 1 -i "$MEDIA_DIR/emu_scene5_military---14377bfa-6920-454b-beb0-c4d4eac5f092.jpg" \
  -vf "scale=1080:1920:flags=lanczos,format=yuv420p,
       zoompan=z='min(zoom+0.0015,1.5)':d=81:
              x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'" \
  -t $SCENE5_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene5.mp4" -y 2>&1 | tail -3

# Scene 6: Battle - zoom out from chaos (22.0-28.8)
ffmpeg -loop 1 -i "$MEDIA_DIR/emu_scene6_battle---fcb9fbdb-211e-4e8a-ab93-69b725096e27.jpg" \
  -vf "scale=1080:1920:flags=lanczos,format=yuv420p,
       zoompan=z='if(eq(on,1),1.6,max(1,zoom-0.001))':d=204:
              x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'" \
  -t $SCENE6_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene6.mp4" -y 2>&1 | tail -3

# Scene 7: Chase - pan right following emu (28.8-37.5)
ffmpeg -loop 1 -i "$MEDIA_DIR/emu_scene7_chase---acb56edc-d8ef-4c90-9899-37235ef56189.jpg" \
  -vf "scale=1080:1920:flags=lanczos,format=yuv420p,
       zoompan=z='1.3':d=261:
              x='if(eq(on,1),0,min(iw-(iw/zoom),iw/2-(iw/zoom/2)+50))':
              y='ih/2-(ih/zoom/2)'" \
  -t $SCENE7_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene7.mp4" -y 2>&1 | tail -3

# Scene 8: Defeat - slow zoom in on officer (37.5-43.6)
ffmpeg -loop 1 -i "$MEDIA_DIR/emu_scene8_defeat---951a4b28-654d-4341-8ae1-3f3720a7a0f5.jpg" \
  -vf "scale=1080:1920:flags=lanczos,format=yuv420p,
       zoompan=z='min(zoom+0.0013,1.5)':d=183:
              x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)-30'" \
  -t $SCENE8_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene8.mp4" -y 2>&1 | tail -3

# Scene 9: Memorial - pan across monument (43.6-49.2)
ffmpeg -loop 1 -i "$MEDIA_DIR/emu_scene9_memorial---4d51506b-748c-42c0-b9fe-40e8b649c784.jpg" \
  -vf "scale=1080:1920:flags=lanczos,format=yuv420p,
       zoompan=z='1.2':d=168:
              x='if(eq(on,1),iw/2-(iw/zoom/2),iw/2-(iw/zoom/2)+sin(on/30)*100)':
              y='ih/2-(ih/zoom/2)'" \
  -t $SCENE9_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene9.mp4" -y 2>&1 | tail -3

# Scene 10: Coat of arms - slow zoom out (49.2-54.0)
ffmpeg -loop 1 -i "$MEDIA_DIR/emu_scene10_coatarms---6e4c6b06-ea0f-4221-a0cf-25622520b1ee.jpg" \
  -vf "scale=1080:1920:flags=lanczos,format=yuv420p,
       zoompan=z='if(eq(on,1),1.5,max(1.1,zoom-0.0013))':d=144:
              x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'" \
  -t $SCENE10_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene10.mp4" -y 2>&1 | tail -3

# Scene 11: Classroom - gentle pan with fade to black (54.0-60.0)
ffmpeg -loop 1 -i "$MEDIA_DIR/emu_scene11_teach---ed5ee441-f45d-4bcb-9ddc-0118813c2e59.jpg" \
  -vf "scale=1080:1920:flags=lanczos,format=yuv420p,
       zoompan=z='1.15':d=180:
              x='iw/2-(iw/zoom/2)+sin(on/40)*50':
              y='ih/2-(ih/zoom/2)',
       fade=t=out:st=5.5:d=0.5" \
  -t $SCENE11_DUR -c:v libx264 -preset medium -crf 18 -r 30 -pix_fmt yuv420p \
  "$VIDEO_DIR/scene11.mp4" -y 2>&1 | tail -3

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
  "$WORKSPACE/emu_war_shorts_v2.mp4" -y 2>&1 | tail -5

echo "=== Done! ==="
echo "Final video: $WORKSPACE/emu_war_shorts_v2.mp4"
ls -lh "$WORKSPACE/emu_war_shorts_v2.mp4"
ffprobe -i "$WORKSPACE/emu_war_shorts_v2.mp4" 2>&1 | grep -E "Duration|Stream|Video|Audio"
