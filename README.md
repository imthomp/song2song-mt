# song2songMT

An experimental audio translation pipeline that turns the vocal content of a song into translated speech mixed over the original instrumental.

The project combines pretrained models for source separation, speech recognition, machine translation, and text-to-speech. It is a prototype: generated vocals are spoken rather than sung, and their timing and melody are not aligned to the original performance.

## How it works

1. Demucs separates vocals from accompaniment.
2. Whisper large-v3 transcribes the vocal track.
3. M2M100 translates the transcript.
4. XTTS v2 synthesizes speech in the target language.
5. FFmpeg mixes the generated speech with the instrumental.

## Requirements

- Python 3.10 or newer
- [uv](https://docs.astral.sh/uv/) (recommended) or pip
- FFmpeg installed and available on `PATH`
- A supported PyTorch environment; a CUDA-capable GPU is recommended for model inference
- Internet access on first run to download pretrained model weights

The models are large and inference can take several minutes. Disk, memory, and GPU requirements depend on the selected environment and input audio.

## Install

```bash
git clone https://github.com/imthomp/song2songMT.git
cd song2songMT
uv sync
```

If you use pip instead of uv:

```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

## Run

Translate English vocals to Spanish and save the mix as a WAV file:

```bash
uv run python main.py path/to/input.mp3 --src en --tgt es --out output/translated.wav
```

Arguments:

| Argument | Default | Description |
| --- | --- | --- |
| `audio` | Required | Input audio path |
| `--src` | `en` | Source language code supported by M2M100 |
| `--tgt` | `es` | Target language code supported by M2M100 and XTTS v2 |
| `--out` | `translated_song.wav` | Output audio path; the extension determines the container/codec FFmpeg selects |

The first run downloads model weights. To download/cache the models before processing audio, run:

```bash
uv run python download_models.py
```

## SLURM

`run_song.sh` is an optional SLURM submission wrapper. It requests a single GPU and submits an English-to-Spanish job by default:

```bash
bash run_song.sh path/to/input.mp3 [target_language]
```

The script expects a prepared `.venv` in the project directory and a SLURM environment with Python and FFmpeg available. Adjust the resource requests and module-loading lines to match your cluster.

## Limitations

- This pipeline synthesizes spoken text; it does not translate or recreate singing.
- The synthesized voice is not aligned to the original singer, lyrics, rhythm, or melody.
- Automatic transcription and translation can be inaccurate, especially with music, backing vocals, or overlapping instruments.
- Mixing is a simple audio blend and does not include timing alignment, mastering, or loudness control.
- Model support, quality, runtime, and hardware requirements vary by language and environment.

## Models and third-party terms

This repository contains pipeline code, not model weights. The code downloads third-party models at runtime. Review and follow the terms for each model and dependency before use or redistribution; model licenses and availability may differ from this repository's license.

## License

The project code is released under the MIT License. See [LICENSE](LICENSE). This license does not grant rights to input recordings, model weights, or generated content.
