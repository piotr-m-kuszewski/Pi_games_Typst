# pi-games for Typst

Typst libraries for drawing strategic and extensive form games.

## Libraries

### `pi-games.typ` — Umbrella bundle

Imports all three libraries (`pi-game-palette.typ`, `pi-game-normal.typ`, `pi-game-trees.typ`) into a single namespace, so one `#import "pi-games.typ": *` exposes the full normal-form and extensive-form API plus the shared palette.

---

### `pi-game-normal.typ` — Normal form games

Draws strategic (normal) form payoff matrices using [CeTZ](https://github.com/cetz-package/cetz). Supports 2-player and 3-player games. It covers the same kind of normal-form games as the [`game-theoryst`](https://typst.app/universe/package/game-theoryst/) Typst package by Connor T. Wiegand — players, strategy lists, a payoff matrix and per-player best-response underlines — but exposes a different, CeTZ-based API (positional `p1, p2, s1, s2, payoffs` with out-of-band `p1-best`/`p2-best`/`nash` coordinate lists, rather than `game-theoryst`'s table cells with inline `hul()`/`vul()` markers).

**Public API:**

| Function | Description |
|---|---|
| `game-normal-form(p1, p2, s1, s2, payoffs, ...)` | N×M payoff matrix for two players with colored payoffs, best-response underlines, and Nash equilibrium cell highlights |
| `game-three-player-normal-form(p1, p2, p3, s1, s2, s3, payoffs, ...)` | Three-player game rendered as a collection of N×M matrices, one per Player 3 strategy, arranged in rows |

Both functions accept optional `p1-best`, `p2-best`, `nash` arrays for annotating best responses and equilibria. Cell dimensions auto-grow to fit content.

**Global style variables** (override after import): `game-pal`, `game-nash-color`, `game-fg`, `game-cell-width`, `game-cell-height`, `game-games-per-row`.

---

### `pi-game-trees.typ` — Extensive form game trees

Draws extensive form (sequential) game trees inside a `cetz.canvas` environment. The visual style replicates the [`xgames`](https://carlabernard.ch/beni/downloads/xgames.pdf) LaTeX package by Benjamin Bernard — per-player coloured node labels, action labels and payoff vectors — reimplemented natively in Typst/CeTZ.

**Public API:**

| Function | Description |
|---|---|
| `game-node(pos, player, label, ...)` | Decision node for a player (filled, open, or dot style) |
| `game-nature(pos, label, ...)` | Nature / chance node (grey) |
| `game-terminal(pos, payoffs, ...)` | Terminal node with coloured payoff vector |
| `game-branch(from, to, action, ...)` | Branch (edge) with an optional action label; label can be centred on the line or offset to either side |
| `game-prob(from, to, action, ...)` | Convenience wrapper around `game-branch` for Nature branch probability labels |
| `game-infoset(...pts, player, style, ...)` | Information set connecting two or more nodes; `"dashed"` (default) or `"bracket"` style, with optional curvature |
| `game-subgame(apex, depth, width, ...)` | Proper-subgame triangle marker (dotted outline, light fill) |
| `game-highlight(from, to, color, ...)` | Bold coloured overlay on an existing branch to mark an equilibrium path |
| `game-payoffs(payoffs, parens)` | Inline coloured payoff vector for body text |
| `game-player(player, label)` | Typeset text in a player's colour (bold) |
| `game-player-default(player)` | Typeset "Player N" in player N's colour (bold) |

**Global style variables** (override after import): `game-pal`, `game-nature-color`, `game-fg`, `game-highlight-color`, `game-infoset-color`, `game-subgame-stroke/fill/label`, and geometry constants `game-node-radius`, `game-gap`, `game-act`, `game-apos`, `game-tick`, stroke widths `game-sw-*`, font sizes `game-fs*`.

---

### `pi-game-palette.typ` — Shared colour palette

Single source of truth for all colours used by both libraries. Imported automatically by `pi-game-normal.typ` and `pi-game-trees.typ`. Can be imported standalone to access colours in document text.

Defines: `game-player-colors` (5-entry array), `game-nature-color`, `game-fg`, `game-nash-color`, `game-highlight-color`, `game-infoset-color`, `game-subgame-stroke`, `game-subgame-fill`, `game-subgame-label`.

---

### `pi-games-fletcher.typ` — Arrow presets for Fletcher diagrams

Small helper with three named style presets for use with the [`fletcher`](https://github.com/Jollywatt/typst-fletcher) package:

- `pi-thick-red-arrow` / `pi-thick-blue-arrow` — bold coloured arrows for highlighting equilibrium paths
- `pi-label-inside` — label placement shorthand (`label-fill: true, label-anchor: "center"`)

This file is independent of `pi-game-normal.typ` and `pi-game-trees.typ` and is only needed when using `fletcher` for game trees.

---

## Example and documentation files

| File | Description |
|---|---|
| `pi-games-normal-example.typ` | Usage examples for `pi-games.typ`: Prisoner's Dilemma, Battle of the Sexes, three-player games, best responses, and Nash equilibrium highlights |
| `pi-games-normal-example.pdf` | Compiled output of the above |
| `pi-games-manual.typ` | Consolidated manual and API reference for the whole bundle — normal-form games and extensive-form trees, built with [tidy](https://github.com/Mc-Zen/tidy) |
| `pi-games-manual.pdf` | Compiled manual |
| `pi-games-trees-example.typ` | Usage examples for `pi-game-trees.typ`: perfect-information trees, information sets, Nature nodes, equilibrium highlights, subgame markers |
| `pi-games-trees-example.pdf` | Compiled output of the above |

## Alternative: extensive form games with `fletcher`

[`extensive-form-games-with-fletcher.typ`](extensive-form-games-with-fletcher.typ) (compiled: [`extensive-form-games-with-fletcher.pdf`](extensive-form-games-with-fletcher.pdf)) is a standalone note that shows how to draw extensive form game trees using the `fletcher` package directly, without `pi-game-trees.typ`.

This approach treats nodes and branches as standard Fletcher `node`/`edge` elements, which makes it easy to integrate game trees into documents that already use `fletcher` for other diagrams. The document covers basic trees, information sets via dashed edges, Nature nodes, signalling games (beer–quiche), and equilibrium-path decoration using `pi-games-fletcher.typ` presets. It serves as a reference for when the full `pi-game-trees` machinery is not needed or when `fletcher`'s grid-based layout is more convenient.

## Dependencies

| Package | Version | Used by |
|---|---|---|
| `@preview/cetz` | 0.5.2 | `pi-game-normal.typ`, `pi-game-trees.typ` |
| `@preview/fletcher` | 0.5.8 | `extensive-form-games-with-fletcher.typ` |
| `@preview/tidy` | 0.4.3 | manual files |
| `@preview/codly` | 1.3.0 | manual and example files |
| `@preview/codly-languages` | 0.1.10 | manual and example files |

## Acknowledgements

- Normal-form games cover the same ground as the [`game-theoryst`](https://typst.app/universe/package/game-theoryst/) Typst package by Connor T. Wiegand, though `pi-games` uses its own CeTZ-based API rather than `game-theoryst`'s syntax.
- Extensive-form trees replicate the look of the [`xgames`](https://carlabernard.ch/beni/downloads/xgames.pdf) LaTeX package by Benjamin Bernard. The visual design — per-player colours for node labels, actions and payoffs — is his; `pi-game-trees.typ` reimplements it in Typst/CeTZ. All credit for the original design goes to him.
