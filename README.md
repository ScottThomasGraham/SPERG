# ☕ SPERG

A tiny macOS menu bar app whose only job is to keep your Mac awake — the same
way a Zoom call stops it from going to sleep. A coffee cup lives in your menu
bar; click it to toggle.

- **Filled cup** ☕ — your Mac is being kept awake (system **and** display).
- **Outline cup** — normal sleep behavior; SPERG is idle.

It starts **active** the moment you launch it, so the Mac stays awake right
away. No Dock icon, no window — just the menu bar.

## How it works

SPERG holds two IOKit power assertions while active:

- `PreventUserIdleSystemSleep` — stops the machine from sleeping.
- `PreventUserIdleDisplaySleep` — keeps the display on/undimmed.

These are the same class of assertions that `caffeinate -di` and video-call
apps use. They're released cleanly when you toggle off or quit.

## Build

Requires the Xcode command line tools (`swiftc`). Then:

```sh
./build.sh
open SPERG.app
```

That compiles `Sources/main.swift` and assembles `SPERG.app`. To keep it
around, drag `SPERG.app` into `/Applications`.

## Usage

- Click the coffee cup → menu with **Keep Awake** (⌘K) toggle and **Quit** (⌘Q).
- Checkmark on "Keep Awake" = currently keeping the Mac awake.

## License

MIT
