#!/bin/bash
# Planet Nine - Simple Video Assembly
# YouTube Short format: 1080x1920, 30fps

set -e

IMG_THUMB="/home/dain/.openclaw/media/tool-image-generation/planet-nine-thumb---241a1826-df10-48fb-aefd-403f7ea7fb7d.jpg"
IMG_ORBITS="/home/dain/.openclaw/media/tool-image-generation/planet-nine-orbits---8bf2c8c4-7908-49a1-a536-81d31d6e680c.jpg"
IMG_BLACKHOLE="/home/dain/.openclaw/media/tool-image-generation/planet-nine-blackhole---1170ecc1-e252-4f92-97f3-da4fba59d465.jpg"
IMG_WIDE="/home/dain/.openclaw/media/tool-image-generation/planet-nine-wide---edbe24b1-a401-482b-b626-ebed5dcadaf0.jpg"
AUDIO="/home/dain/.openclaw/workspace/youtube-shorts/planet-nine/voiceover.mp3"
OUTPUT="/home/dain/.openclaw/workspace/youtube-shorts/planet-nine/planet-nine-short.mp4"
WORK_DIR="/home/dain/.openclaw/workspace/youtube-shorts/planet-nine"

# Get audio duration
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$AUDIO")
echo "Audio duration: $DURATION seconds"

# Create working directory for frames
mkdir -p "$WORK_DIR/frames"

# Scale all images to 1080x1920 first
for img in "$IMG_THUMB" "$IMG_ORBITS" "$IMG_WIDE" "$IMG_BLACKHOLE"; do
    name=$(basename "$img" .jpg)
    convert "$img" -resize 1080x1920^ -gravity center -extent 1080x1920 "$WORK_DIR/${name}_1080x1920.jpg" 2>/dev/null || \
    ffmpeg -y -i "$img" -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black" -frames:v 1 "$WORK_DIR/${name}_1080x1920.jpg" 2>/dev/null
    echo "Scaled: $name"
done

# Get audio duration in a simpler way
DURATION_INT=$(python3 -c "import math; print(math.ceil($DURATION))")
if [ -z "$DURATION_INT" ] || [ "$DURATION_INT" -lt 1 ]; then
    DURATION_INT=55
fi
echo "Using duration: $DURATION_INT seconds"

# Create a simple approach: concatenate images with crossfade
# Calculate segment times
# 0:00-0:05  → IMG_THUMB (hook)
# 0:05-0:18  → IMG_ORBITS (evidence)
# 0:18-0:32  → IMG_WIDE (Planet Nine)
# 0:32-0:42  → IMG_BLACKHOLE (black hole theory)
# 0:42-END   → IMG_THUMB (CTA/wrap)

T1=5    # thumb
T2=13   # orbits
T3=14   # wide
T4=10   # blackhole
T5=$(python3 -c "import math; print(max($DURATION_INT - 42, 10))")

echo "Segments: $T1, $T2, $T3, $T4, $T5"

# Create video segments with slight zoom effect
ffmpeg -y -loop 1 -i "$WORK_DIR/planet-nine-thumb---241a1826-df10-48fb-aefd-403f7ea7fb7d_1080x1920.jpg" -vf "zoompan=z='min(zoom+0.0015,1.08)':d=$(($T1*30)):s=1080x1920:fps=30" -t $T1 -c:v libx264 -pix_fmt yuv420p -an "$WORK_DIR/seg1.mp4"
ffmpeg -y -loop 1 -i "$WORK_DIR/planet-nine-orbits---8bf2c8c4-7908-49a1-a536-81d31d6e680c_1080x1920.jpg" -vf "zoompan=z='min(zoom+0.0015,1.08)':d=$(($T2*30)):s=1080x1920:fps=30" -t $T2 -c:v libx264 -pix_fmt yuv420p -an "$WORK_DIR/seg2.mp4"
ffmpeg -y -loop 1 -i "$WORK_DIR/planet-nine-wide---edbe24b1-a401-482b-b626-ebed5dcadaf0_1080x1920.jpg" -vf "zoompan=z='min(zoom+0.0015,1.08)':d=$(($T3*30)):s=1080x1920:fps=30" -t $T3 -c:v libx264 -pix_fmt yuv420p -an "$WORK_DIR/seg3.mp4"
ffmpeg -y -loop 1 -i "$WORK_DIR/planet-nine-blackhole---1170ecc1-e252-4f92-97f3-da4fba59d465_1080x1920.jpg" -vf "zoompan=z='min(zoom+0.0015,1.08)':d=$(($T4*30)):s=1080x1920:fps=30" -t $T4 -c:v libx264 -pix_fmt yuv420p -an "$WORK_DIR/seg4.mp4"
ffmpeg -y -loop 1 -i "$WORK_DIR/planet-nine-thumb---241a1826-df10-48fb-aefd-403f7ea7fb7d_1080x1920.jpg" -vf "zoompan=z='min(zoom+0.0015,1.08)':d=$(($T5*30)):s=1080x1920:fps=30" -t $T5 -c:v libx264 -pix_fmt yuv420p -an "$WORK_DIR/seg5.mp4"

# Concatenate all segments
echo "file 'seg1.mp4'" > "$WORK_DIR/concat.txt"
echo "file 'seg2.mp4'" >> "$WORK_DIR/concat.txt"
echo "file 'seg3.mp4'" >> "$WORK_DIR/concat.txt"
echo "file 'seg4.mp4'" >> "$WORK_DIR/concat.txt"
echo "file 'seg5.mp4'" >> "$WORK_DIR/concat.txt"

ffmpeg -y -f concat -safe 0 -i "$WORK_DIR/concat.txt" -i "$AUDIO" -c:v copy -c:a aac -b:a 128k -shortest "$OUTPUT"

# Cleanup
rm -f "$WORK_DIR/"seg*.mp4 "$WORK_DIR/concat.txt"

echo "✓ Video assembled: $OUTPUT"
ls -lh "$OUTPUT"
