#!/bin/bash
# Toledo War Video Assembly v2 - Single ffmpeg command

set -e

WORKDIR="/home/dain/.openclaw/workspace/toledo_war_scenes"
MEDIA_DIR="/home/dain/.openclaw/media/tool-image-generation"
OUTPUT="$WORKDIR/toledo_war_short.mp4"
VOICEOVER="$WORKDIR/voiceover.mp3"

cd "$WORKDIR"

# Get voiceover duration
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VOICEOVER")
echo "Voiceover duration: ${DURATION}s"

# Calculate scene duration (total / 10)
SCENE_DURATION=$(awk "BEGIN {printf \"%.2f\", $DURATION / 10}")
echo "Scene duration: ${SCENE_DURATION}s per scene"

# Find all Toledo scene images in order
IMAGES=($(ls -v "$MEDIA_DIR"/toledo_scene*_*.jpg 2>/dev/null | head -10))

if [ ${#IMAGES[@]} -lt 10 ]; then
    echo "ERROR: Found ${#IMAGES[@]} images, need 10"
    exit 1
fi

echo "Found ${#IMAGES[@]} scene images"

# Build ffmpeg filter complex for 10 scenes with Ken Burns
FILTER=""
INPUTS=""

for i in {0..9}; do
    INPUTS="$INPUTS -i ${IMAGES[$i]}"
    if [ $i -gt 0 ]; then
        FILTER="$FILTER;"
    fi
    # Ken Burns: slow zoom in
    FILTER="$FILTER[$i:v]zoompan=z='min(zoom+0.0015, 1.1)':d=1:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920:duration=$SCENE_DURATION:fps=30[v$i]"
done

# Concatenate all video streams
for i in {0..9}; do
    if [ $i -eq 0 ]; then
        CONCAT="[v0]"
    else
        CONCAT="$CONCAT[v$i]"
    fi
done
CONCAT="$CONCAT concat=n=10:v=1:a=0[outv]"

echo "Creating video with Ken Burns effects..."

# Run ffmpeg
ffmpeg -y $INPUTS \
    -i "$VOICEOVER" \
    -filter_complex "$FILTER;$CONCAT" \
    -map "[outv]" -map 10:a \
    -c:v libx264 -preset fast -crf 23 \
    -c:a aac -b:a 128k \
    -shortest \
    -pix_fmt yuv420p \
    "$OUTPUT" 2>&1 | tail -20

echo ""
echo "✅ Toledo War video complete!"
echo "Output: $OUTPUT"
ls -lh "$OUTPUT"

# Show duration
FINAL_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$OUTPUT")
echo "Duration: ${FINAL_DURATION}s"
