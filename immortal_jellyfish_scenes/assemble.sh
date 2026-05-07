#!/bin/bash
# Immortal Jellyfish Video Assembly

set -e

WORKDIR="/home/dain/.openclaw/workspace/immortal_jellyfish_scenes"
MEDIA_DIR="/home/dain/.openclaw/media/tool-image-generation"
OUTPUT="$WORKDIR/immortal_jellyfish_short.mp4"
VOICEOVER="$WORKDIR/voiceover.mp3"

cd "$WORKDIR"

# Get voiceover duration
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VOICEOVER")
echo "Voiceover duration: ${DURATION}s"

# Calculate scene duration (total / 10)
SCENE_DURATION=$(awk "BEGIN {printf \"%.2f\", $DURATION / 10}")
echo "Scene duration: ${SCENE_DURATION}s per scene"

# Find all jellyfish scene images in order
IMAGES=($(ls -v "$MEDIA_DIR"/jellyfish_scene*_*.jpg 2>/dev/null | head -10))

if [ ${#IMAGES[@]} -lt 10 ]; then
    echo "ERROR: Found ${#IMAGES[@]} images, need 10"
    exit 1
fi

echo "Found ${#IMAGES[@]} scene images"

# Create individual scene videos with Ken Burns
echo "Creating scene videos with Ken Burns..."
for i in {0..9}; do
    scene_num=$((i + 1))
    echo "  Scene $scene_num..."
    
    ffmpeg -y -loop 1 -i "${IMAGES[$i]}" \
        -vf "zoompan=z='min(zoom+0.0015, 1.1)':d=1:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920" \
        -t "$SCENE_DURATION" \
        -c:v libx264 -preset fast -crf 23 \
        -pix_fmt yuv420p \
        "$WORKDIR/scene${scene_num}.mp4" 2>/dev/null
done

# Create concat list
echo "Creating concat list..."
rm -f "$WORKDIR/concat_list.txt"
for i in {1..10}; do
    echo "file '$WORKDIR/scene${i}.mp4'" >> "$WORKDIR/concat_list.txt"
done

# Concatenate scenes
echo "Concatenating scenes..."
ffmpeg -y -f concat -safe 0 -i "$WORKDIR/concat_list.txt" \
    -c:v libx264 -preset fast -crf 23 \
    -pix_fmt yuv420p \
    "$WORKDIR/video_no_audio.mp4" 2>/dev/null

# Add voiceover
echo "Adding voiceover..."
ffmpeg -y -i "$WORKDIR/video_no_audio.mp4" -i "$VOICEOVER" \
    -c:v copy -c:a aac -b:a 128k \
    -shortest \
    "$OUTPUT" 2>/dev/null

# Cleanup
echo "Cleaning up..."
rm -f "$WORKDIR/scene"*.mp4 "$WORKDIR/video_no_audio.mp4" "$WORKDIR/concat_list.txt"

echo ""
echo "✅ Immortal Jellyfish video complete!"
echo "Output: $OUTPUT"
ls -lh "$OUTPUT"

# Show duration
FINAL_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTPUT")
echo "Duration: ${FINAL_DURATION}s"
