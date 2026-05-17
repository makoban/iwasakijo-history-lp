#!/usr/bin/env python3
from __future__ import annotations

import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets/seedance/tsuchi-no-shiro-v3/narration/google-ai-studio-one-take/one-take-fast.wav"
OUT_DIR = ROOT / "assets/seedance/tsuchi-no-shiro-v3/narration/google-ai-studio-one-take/segments"

# Cut points from the single Google AI Studio take. Each range preserves the
# original voice character and keeps only the brief natural pause around a block.
CUTS = [
    ("01", 0.20, 1.55),
    ("02", 2.62, 6.25),
    ("03", 7.45, 12.50),
    ("04", 13.80, 17.15),
    ("05", 18.50, 22.55),
    ("06", 23.70, 29.65),
    ("07", 30.95, 35.25),
    ("08", 36.50, 40.30),
    ("09", 41.45, 46.85),
    ("10", 48.00, 52.35),
]


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    with wave.open(str(SOURCE), "rb") as source:
        params = source.getparams()
        rate = source.getframerate()
        sample_width = source.getsampwidth()
        channels = source.getnchannels()
        source_frames = source.getnframes()
        data = source.readframes(source_frames)

    bytes_per_frame = sample_width * channels
    fade_frames = int(round(rate * 0.025))

    for name, start, end in CUTS:
        start_frame = max(0, int(round(start * rate)))
        end_frame = min(source_frames, int(round(end * rate)))
        chunk = bytearray(data[start_frame * bytes_per_frame : end_frame * bytes_per_frame])
        sample_count = len(chunk) // sample_width
        if sample_width == 2 and sample_count > fade_frames * channels * 2:
            for frame in range(fade_frames):
                fade_in = frame / fade_frames
                fade_out = (fade_frames - frame) / fade_frames
                for channel in range(channels):
                    left_index = (frame * channels + channel) * sample_width
                    right_index = ((sample_count // channels - fade_frames + frame) * channels + channel) * sample_width
                    left = int.from_bytes(chunk[left_index:left_index + 2], "little", signed=True)
                    right = int.from_bytes(chunk[right_index:right_index + 2], "little", signed=True)
                    chunk[left_index:left_index + 2] = int(left * fade_in).to_bytes(2, "little", signed=True)
                    chunk[right_index:right_index + 2] = int(right * fade_out).to_bytes(2, "little", signed=True)
        out = OUT_DIR / f"{name}.wav"
        with wave.open(str(out), "wb") as target:
            target.setparams(params)
            target.writeframes(chunk)
        print(f"{name}: {end - start:.2f}s -> {out}")


if __name__ == "__main__":
    main()
