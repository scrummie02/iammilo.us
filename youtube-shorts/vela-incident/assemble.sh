#!/bin/bash
# Vela Incident Video Assembly
# YouTube Short format: 1080x1920, 30fps

set -e

WORKDIR="/home/dain/.openclaw/workspace/youtube-shorts/vela-incident"
SCENES_DIR="$WORKDIR/scenes"
OUTPUT="$WORKDIR/vela-incident-short.mp4"
VOICEOVER="$WORKDIR/voiceover-v2.mp3"

cd "$WORKDIR"

# Generate voiceover using ElevenLabs (Josh voice)
# Note: This requires API key - see TOOLS.md for credentials

echo "Step 1: Generate voiceover..."
echo "Voiceover text saved to: $WORKDIR/voiceover.txt"
echo "Use ElevenLabs web UI or API with Josh voice to generate voiceover.mp3"
echo ""
echo "Voice: Josh (hpp4J3VqNfWAUOO0d1Us)"
echo "Settings: Stability 0.5, Clarity + Similarity 0.75"
echo ""

# Check if voiceover exists
if [ ! -f "$VOICEOVER" ]; then
    echo "ERROR: voiceover.mp3 not found!"
    echo "Please generate voiceover first."
    exit 1
fi

# Get voiceover duration
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VOICEOVER")
echo "Voiceover duration: ${DURATION}s"

# Scene images (in order)
SCENES=(
    "vela-satellite---acabe9dd-b5ce-48c2-9242-960a81e81495.jpg"
    "south-atlantic---96bb03c1-39fa-477c-97ca-9b4fe831be9a.jpg"
    "double-flash---d2a9cd26-05a2-41b2-951e-de222d327f16.jpg"
    "carter-diary---d44553b0-5753-48f4-8160-991acc9080b7.jpg"
    "radioactive-sheep---be39340f-6c9e-49fe-b20a-8e9485ab71f8.jpg"
    "secret-alliance---a9244e7d-01ae-4293-963c-aa3ef264c276.jpg"
    "ocean-explosion---c7b1a112-a399-490b-86b3-4963defefcaa.jpg"
    "classified-document---e9d84507-f511-442d-86c6-2782d0ad409f.jpg"
)

NUM_SCENES=${#SCENES[@]}

# Calculate scene duration
SCENE_DURATION=$(awk "BEGIN {print $DURATION / $NUM_SCENES}")
echo "Scene duration: ${SCENE_DURATION}s each ($NUM_SCENES scenes)"

# Create working directory for temp files
mkdir -p "$WORKDIR/temp"

# Create video segments with Ken Burns effect
create_scene() {
    local scene_num=$1
    local input_file="$SCENES_DIR/$2"
    local output_file="$WORKDIR/temp/scene${scene_num}.mp4"
    
    echo "Creating scene $scene_num..."
    
    # Ken Burns: slow zoom in (scale from 1.0 to 1.08)
    ffmpeg -y -loop 1 -i "$input_file" \
        -vf "zoompan=z='min(zoom+0.0015,1.08)':d=1:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920,format=yuv420p" \
        -t "$SCENE_DURATION" \
        -c:v libx264 -preset fast -crf 23 \
        -pix_fmt yuv420p \
        -r 30 \
        "$output_file" 2>/dev/null
}

# Create all scene videos
for i in "${!SCENES[@]}"; do
    scene_num=$((i + 1))
    create_scene $scene_num "${SCENES[$i]}"
done

# Create concat list
rm -f "$WORKDIR/temp/concat_list.txt"
for i in $(seq 1 $NUM_SCENES); do
    echo "file '$WORKDIR/temp/scene${i}.mp4'" >> "$WORKDIR/temp/concat_list.txt"
done

# Concatenate scenes
echo "Concatenating scenes..."
ffmpeg -y -f concat -safe 0 -i "$WORKDIR/temp/concat_list.txt" \
    -c:v libx264 -preset fast -crf 23 \
    -pix_fmt yuv420p \
    "$WORKDIR/temp/video_no_audio.mp4" 2>/dev/null

# Add voiceover
echo "Adding voiceover..."
ffmpeg -y -i "$WORKDIR/temp/video_no_audio.mp4" -i "$VOICEOVER" \
    -c:v copy -c:a aac -b:a 128k \
    -shortest \
    "$OUTPUT" 2>/dev/null

# Cleanup intermediate files
rm -rf "$WORKDIR/temp"

echo ""
echo "Vela Incident video complete!"
echo "Output: $OUTPUT"
ls -lh "$OUTPUT"
