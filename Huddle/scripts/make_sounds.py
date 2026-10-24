#!/usr/bin/env python3
"""Makes Huddle's sound effects as small WAV files in Huddle/Resources/Sounds. No audio libraries needed.
Synth helpers copied from Sudoku Harian's make_sounds.py.

Run from Huddle/: python3 scripts/make_sounds.py
"""
import math
import os
import random
import struct
import wave

RATE = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "Huddle", "Resources", "Sounds")
random.seed(7)  # same files every run


def silence(seconds):
    return [0.0] * int(RATE * seconds)


def mix(base, sound, at):
    start = int(at * RATE)
    if len(base) < start + len(sound):
        base.extend([0.0] * (start + len(sound) - len(base)))
    for i, x in enumerate(sound):
        base[start + i] += x
    return base


def clack(pitch=2600, length=0.05, volume=0.8):
    n = int(RATE * length)
    out, low = [], 0.0
    for i in range(n):
        t = i / RATE
        env = math.exp(-t * 90)
        noise = random.uniform(-1, 1)
        low += 0.35 * (noise - low)
        body = math.sin(2 * math.pi * pitch * t) * 0.6 + math.sin(2 * math.pi * pitch * 1.5 * t) * 0.3
        out.append(volume * env * (0.55 * low + 0.45 * body))
    return out


def bell(freq, length=0.6, volume=0.5):
    n = int(RATE * length)
    out = []
    for i in range(n):
        t = i / RATE
        env = math.exp(-t * 5) * min(1, t * 400)
        x = math.sin(2 * math.pi * freq * t) + 0.4 * math.sin(2 * math.pi * freq * 2 * t) + 0.15 * math.sin(2 * math.pi * freq * 3.01 * t)
        out.append(volume * env * x / 1.55)
    return out


def boom(length=0.9):
    """Low noise thump with a falling rumble."""
    n = int(RATE * length)
    out, low = [], 0.0
    for i in range(n):
        t = i / RATE
        env = math.exp(-t * 5) * min(1, t * 300)
        low += 0.06 * (random.uniform(-1, 1) - low)
        thump = math.sin(2 * math.pi * (90 - 50 * t) * t)
        out.append(env * (0.8 * low * 6 + 0.6 * thump))
    return out


def buzz(freq, length=0.25, volume=0.5):
    n = int(RATE * length)
    return [volume * math.exp(-i / RATE * 8) * (1 if math.sin(2 * math.pi * freq * i / RATE) > 0 else -1) * 0.5 for i in range(n)]


def save(name, samples, level=0.9):
    peak = max(1e-9, max(abs(x) for x in samples))
    scale = level / peak
    with wave.open(os.path.join(OUT, name + ".wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(x * scale * 32767)) for x in samples))


def main():
    os.makedirs(OUT, exist_ok=True)
    start = silence(0.1)  # round start: rising G-C-E
    for i, f in enumerate([392.0, 523.25, 659.25]):
        mix(start, bell(f, 0.5, 0.4), i * 0.08)
    save("start", start)

    save("tick", mix(silence(0.06), clack(2200, 0.04, 0.5), 0), level=0.6)

    reveal = silence(0.1)  # a soft "ta-da" shimmer
    mix(reveal, bell(783.99, 0.6, 0.35), 0)
    mix(reveal, bell(1174.66, 0.8, 0.35), 0.06)
    save("reveal", reveal)

    win = silence(0.1)
    for i, f in enumerate([523.25, 659.25, 783.99, 1046.5]):  # C E G C
        mix(win, bell(f, 1.0, 0.45), i * 0.11)
    save("win", win)

    correct = silence(0.05)
    mix(correct, bell(987.77, 0.3, 0.3), 0)
    mix(correct, bell(1318.51, 0.4, 0.3), 0.06)
    save("correct", correct)

    wrong = silence(0.05)
    mix(wrong, buzz(180, 0.18), 0)
    mix(wrong, buzz(150, 0.22), 0.12)
    save("wrong", wrong, level=0.5)

    save("boom", boom())


if __name__ == "__main__":
    main()
