#!/bin/bash
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00

set -euo pipefail

# Submit from a SLURM login node, or run the job body inside an allocation.
if [ -z "${SLURM_JOB_ID:-}" ]; then
    INPUT_FILE="${1:-}"
    if [ -z "$INPUT_FILE" ]; then
        echo "Usage: $0 <input_audio_file> [target_language]" >&2
        exit 1
    fi

    TARGET_LANG="${2:-es}"
    SONG_FILE=$(basename -- "$INPUT_FILE")
    SONG_NAME="${SONG_FILE%.*}"

    LOG_FILE="songs/output/${SONG_NAME}.out"
    AUDIO_OUT="songs/output/${SONG_NAME}_${TARGET_LANG}.wav"
    mkdir -p songs/output

    echo "Submitting job for: $SONG_NAME"
    echo "Log file will be:   $LOG_FILE"
    sbatch -o "$LOG_FILE" --job-name="${SONG_NAME}" "$0" "$INPUT_FILE" "$TARGET_LANG" "$AUDIO_OUT"

    exit 0
fi

# If we are here, we are on a compute node.
echo "Job started on $(hostname) at $(date)"

# Adjust these module names for your cluster.
module load python/3.11
module load ffmpeg

# Activate environment
VENV_DIR=".venv"
source "$VENV_DIR/bin/activate"

# Assign arguments
INPUT_AUDIO="$1"
TGT_LANG="${2:-es}"
OUT_FILE="${3:-translated_song.wav}"

# Debugging Output
echo "----------------------------------------"
echo "Processing: $INPUT_AUDIO"
echo "Source: en | Target: $TGT_LANG"
echo "Output: $OUT_FILE"
echo "----------------------------------------"

# Run
python main.py "$INPUT_AUDIO" --src en --tgt "$TGT_LANG" --out "$OUT_FILE"

echo "Job completed at $(date)"
