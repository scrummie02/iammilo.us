#!/bin/bash
# Dancing Plague Video Assembly - Simplified approach

set -e

WORKSPACE="/home/dain/.openclaw/workspace"
MEDIA_DIR="/home/dain/.openclaw/media/tool-image-generation"
OUTPUT="$WORKSPACE/dancing_plague_FINAL.mp4"

cd "$WORKSPACE"

# Scene durations
declare -a DURS=(5.5 5.5 5.5 5.5 5.5 5.5 5.5 5.5 5.5 10.5)

declare -a IMAGES=(
    "$MEDIA_DIR/dancing_plague_scene1---f0d9628d-8946-45cb-b790-0f64e245191d.jpg"
    "$MEDIA_DIR/dancing_plague_scene2---8b6cae92-0f6c-4e9a-87d6-b97e593ecc27.jpg"
    "$MEDIA_DIR/dancing_plague_scene3---4a11e79e-0f60-4e83-b65a-90f35f8704b5.jpg"
    "$MEDIA_DIR/dancing_plague_scene4---c111838f-7b5c-4189-b17c-1c361e455068.jpg"
    "$MEDIA_DIR/dancing_plague_scene5---520dda0f-b729-467d-b314-5d92eaa1b8d2.jpg"
    "$MEDIA_DIR/dancing_plague_scene6---ae48c05b-bd95-441e-9a71-d56acc5a6d1a.jpg"
    "$MEDIA_DIR/dancing_plague_scene7---92a1e18f-9598-4a7e-baa3-780c1bab9781.jpg"
    "$MEDIA_DIR/dancing_plague_scene8---c56b97db-67bc-4dd3-9f84-6192523f3314.jpg"
    "$MEDIA_DIR/dancing_plague_scene9---cc0a2458-095c-4a5d-916c-7c0609ed5878.jpg"
    "$MEDIA_DIR/dancing_plague_scene10---f8306d57-e7fb-4f80-ad13-dfcdc399f79f.jpg"
)

echo "Generating scene clips..."

for i in $(seq 0 9); do
    idx=$((i+1))
    dur=${DURS[$i]}
    img="${IMAGES[$i]}"
    
    echo "Scene $idx: ${dur}s..."
    
    # Simple zoom effect using scale + crop
    ffmpeg -y -loop 1 -i "$img" -vf "
        fps=30,
        scale=1080:1920:force_original_aspect_ratio=increase,
        crop=1080:1920:(in_w-1080)/2:(in_h-1920)/2,
        zoompan=z='min(zoom+0.002,1.15)':d=$((dur*30)):s=1080x1920:fps=30
    " -c:v libx264 -preset fast -t "$dur" -pix_fmt yuv420p -an "dp_scene_${idx}.mp4"
done

# Concatenate
echo "Concatenating..."
for i in $(seq 1 10); do
    echo "file 'dp_scene_${i}.mp4'"
done > dp_scenes.txt

ffmpeg -y -f concat -safe 0 -i dp_scenes.txt -c copy dp_temp.mp4

# Add audio
VOICEOVER="$WORKSPACE/dancing_plague_voiceover_sped.mp3"
if [ -f "$VOICEOVER" ]; then
    echo "Adding Josh voiceover..."
    ffmpeg -y -i dp_temp.mp4 -i "$VOICEOVER" -c:v copy -c:a aac -shortest "$OUTPUT"
else
    echo "Voiceover not found, using voiceover without _sped..."
    VOICEOVER="$WORKSPACE/dancing_plague_voiceover.mp3"
    ffmpeg -y -i dp_temp.mp4 -i "$VOICEOVER" -c:v copy -c:a aac -shortest "$OUTPUT"
fi

# Cleanup
rm -f dp_scene_*.mp4 dp_scenes.txt dp_temp.mp4

echo "✓ Done: $OUTPUT"
ls -lh "$OUTPUT"
