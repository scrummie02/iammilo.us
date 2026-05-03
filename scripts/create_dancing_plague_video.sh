#!/bin/bash
# Dancing Plague Video Assembly Script
# 10 scenes with Ken Burns effects and text overlays

set -e

WORKSPACE="/home/dain/.openclaw/workspace"
MEDIA_DIR="/home/dain/.openclaw/media/tool-image-generation"
OUTPUT="$WORKSPACE/dancing_plague_short.mp4"

cd "$WORKSPACE"

# Scene durations (matching voiceover timing)
# Total: ~60 seconds
SCENE_DURATIONS=(5.5 5.5 5.5 5.5 5.5 5.5 5.5 5.5 5.5 10.5)
SCENE_TEXTS=(
    "July 1518, Strasbourg, France"
    "Within a month, 400 people"
    "Some danced until they died"
    "The cure? MORE dancing"
    "They built a stage. Hired musicians."
    "Doctors vs. The Church"
    "September 1518. Dozens dead."
    "No one knows why it stopped."
    "Mass psychogenic illness?"
    "A town danced itself to death."
)

# Image files
IMAGES=(
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

echo "Generating Ken Burns video clips..."

# Generate individual scene clips with Ken Burns effect
for i in $(seq 0 9); do
    idx=$((i+1))
    dur=${SCENE_DURATIONS[$i]}
    img="${IMAGES[$i]}"
    text="${SCENE_TEXTS[$i]}"
    
    echo "Processing scene $idx (duration: ${dur}s)..."
    
    # Ken Burns: zoom in slightly with pan
    # Scale to 1080x1920 (9:16) vertical format
    ffmpeg -y -loop 1 -i "$img" -vf "
        zoompan=z='min(zoom+0.003,1.3)':d=$(echo "$dur * 30" | bc | cut -d. -f1):s=1080x1920:fps=30,
        scale=1080:1920:force_original_aspect_ratio=decrease,
        pad=1080:1920:(ow-iw)/2:(oh-ih)/2,
        drawtext=text='$text':fontcolor=white:fontsize=48:fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:
            x=(w-text_w)/2:y=h-text_h-100:box=1:boxcolor=black@0.6:boxborderw=10,
        fade=t=out:st=$(echo "$dur - 0.5" | bc):d=0.5
    " -c:v libx264 -t "$dur" -pix_fmt yuv420p -an "scene_${idx}.mp4"
done

# Concatenate all scenes
echo "Creating concatenation file..."
for i in $(seq 1 10); do
    echo "file 'scene_${i}.mp4'" >> scenes.txt
done

echo "Concatenating scenes..."
ffmpeg -y -f concat -safe 0 -i scenes.txt -c copy temp_video.mp4

# Add Josh's voiceover (sped version)
echo "Adding voiceover..."
ffmpeg -y -i temp_video.mp4 -i "$WORKSPACE/dancing_plague_voiceover_sped.mp3" -c:v copy -c:a aac -shortest "$OUTPUT"

# Cleanup
rm -f scene_*.mp4 scenes.txt temp_video.mp4

echo "Done! Video saved to: $OUTPUT"
echo "Duration: $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTPUT") seconds"
