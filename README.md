# PULSE — neon survival arcade

One file, no build step, no dependencies. Open `pulse.html` and play.

**Play online:** https://rukhmanis632-hash.github.io/pulse/pulse.html

## Play it in VS Code

1. Save `pulse.html` into a folder and open that folder in VS Code (`File → Open Folder`).
2. Install the **Live Server** extension (Ritwick Dey) if you want a local server, then right-click
   `pulse.html` → **Open with Live Server**.
   Or skip the extension: just double-click `pulse.html` — it runs straight from the file system.
3. Click **Start**, then move with the mouse (or WASD / arrow keys).

## Controls

| Input | Action |
| --- | --- |
| Mouse / touch drag | Steer the ship |
| `W A S D` / arrow keys | Fly with keys |
| `Space` | Fire the shockwave (needs a full charge) |
| `P` / `Esc` | Pause |
| `R` | Restart |

## How to score

- Collect mint orbs — each one adds a third of the shockwave charge and points.
- Graze an asteroid without touching it for a **NEAR MISS** and a combo step (up to x9).
- Fire the shockwave to vaporise everything near you: 120 points per asteroid, multiplied by combo.
- Combo decays after ~2.6 seconds without a graze or kill. Your best score is saved in `localStorage`.

## Repo

`pulse.html` is the whole game — HTML, CSS and JavaScript in one file.
