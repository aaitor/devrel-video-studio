#!/usr/bin/env python3
# ponytail: local synth music bed — license-clean placeholder, no model/auth needed.
# Swap for a produced track via /media-use `resolve --type bgm` (HeyGen catalog) or --local-only (MusicGen),
# through the same <audio> seam. Upbeat-calm tech bed: I-V-vi-IV pad + arp + soft kick/hats.
import numpy as np, wave, sys

SR = 44100
DUR = float(sys.argv[2]) if len(sys.argv) > 2 else 25.7   # gen-bgm.py <out.wav> [duration_s]
N = int(SR * DUR)
t = np.arange(N) / SR
BPM = 100.0
beat = 60.0 / BPM          # 0.6s
bar = 4 * beat             # 2.4s
rng = np.random.default_rng(7)  # deterministic

def hz(m): return 440.0 * 2 ** ((m - 69) / 12)

# I–V–vi–IV in C: chord = (bass midi, [voicing midis], [arp midis])
CHORDS = [
    (48, [64, 67, 72], [60, 64, 67, 72]),  # C
    (43, [62, 67, 71], [62, 67, 71, 74]),  # G
    (45, [64, 69, 72], [57, 60, 64, 69]),  # Am
    (41, [65, 69, 72], [65, 69, 72, 77]),  # F
]

pad = np.zeros(N); bass = np.zeros(N); arp = np.zeros(N); kick = np.zeros(N); hat = np.zeros(N)

def place(buf, start, sig):
    i0 = int(start * SR); i1 = min(N, i0 + len(sig))
    if i0 < N: buf[i0:i1] += sig[: i1 - i0]

nbars = int(np.ceil(DUR / bar))
for b in range(nbars):
    bass_m, voicing, arp_m = CHORDS[b % 4]
    tb = b * bar
    # pad: soft detuned triad, whole bar, slow attack/release
    ln = int(bar * SR); tt = np.arange(ln) / SR
    e = np.ones(ln); a = int(0.3 * SR); r = int(0.5 * SR)
    e[:a] = np.linspace(0, 1, a) ** 2
    e[-r:] *= np.linspace(1, 0, r)
    chord = np.zeros(ln)
    for m in voicing:
        f = hz(m)
        chord += np.sin(2*np.pi*f*tt) + 0.5*np.sin(2*np.pi*f*1.005*tt) + 0.18*np.sin(2*np.pi*2*f*tt)
    place(pad, tb, chord/len(voicing) * e * 0.5)
    # bass: root, one per beat, short decay
    for bt in range(4):
        ln2 = int(beat * SR); tt2 = np.arange(ln2)/SR
        f = hz(bass_m)
        sig = (np.sin(2*np.pi*f*tt2) + 0.25*np.sin(2*np.pi*2*f*tt2)) * np.exp(-tt2/0.42) * 0.5
        place(bass, tb + bt*beat, sig)
    # arp: 1/8 notes cycling arp tones (start after the intro)
    if tb >= 1.2:
        for e8 in range(8):
            m = arp_m[e8 % len(arp_m)] + (12 if e8 >= 4 else 0)
            ln3 = int(0.5*beat*SR); tt3 = np.arange(ln3)/SR
            f = hz(m)
            sig = (np.sin(2*np.pi*f*tt3) + 0.3*np.sin(2*np.pi*2*f*tt3)) * np.exp(-tt3/0.14) * 0.22
            place(arp, tb + e8*0.5*beat, sig)

# drums: only in the body (3.0 .. 23.0s)
b0, b1 = 3.0, 23.0
tk = b0
while tk < b1:
    ln = int(0.16*SR); tt2 = np.arange(ln)/SR
    fsw = 120*np.exp(-tt2/0.03) + 48
    sig = np.sin(2*np.pi*np.cumsum(fsw)/SR) * np.exp(-tt2/0.11) * 0.9
    place(kick, tk, sig); tk += beat
th = b0 + beat/2
while th < b1:
    ln = int(0.05*SR)
    noise = rng.standard_normal(ln) * np.exp(-np.arange(ln)/SR/0.02) * 0.10
    place(hat, th, noise); th += beat

# high-pass the hats a touch (1st-order diff) so they sit above the pad
hat = np.concatenate([[0], np.diff(hat)])

# sidechain: duck pad+bass under each kick for gentle pump
kick_env = np.abs(kick)
if kick_env.max() > 0:
    from numpy import convolve
    smooth = convolve(kick_env, np.ones(int(0.12*SR))/int(0.12*SR), mode='same')
    duck = 1 - 0.35 * (smooth / (smooth.max() + 1e-9))
    pad *= duck; bass *= duck

mix = pad*0.9 + bass*1.0 + arp*0.9 + kick*1.0 + hat*0.8

# structure gains: gentle intro, full body, resolve
g = np.ones(N)
g[t < 3.0] = 0.6
fi = int(0.4*SR); g[:fi] *= np.linspace(0, 1, fi)          # fade in
fo = int(2.2*SR); g[-fo:] *= np.linspace(1, 0, fo) ** 1.5  # fade out
mix *= g

# soft limit + normalize to -3 dBFS
mix = np.tanh(mix * 1.1)
mix *= 10**(-3/20) / (np.abs(mix).max() + 1e-9)

# stereo: tiny Haas widening on arp/pad side
L = mix.copy(); R = mix.copy()
d = int(0.008*SR)
R[d:] += 0.12 * arp[:-d] * g[:-d]
L[d:] += 0.12 * pad[:-d] * g[:-d] * 0.5
st = np.stack([L, R], axis=1)
st *= 10**(-3/20) / (np.abs(st).max() + 1e-9)

pcm = (st * 32767).astype('<i2')
with wave.open(sys.argv[1] if len(sys.argv) > 1 else 'bgm.wav', 'wb') as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes(pcm.tobytes())
print(f"wrote {DUR}s stereo bed, peak {np.abs(st).max():.3f}")
