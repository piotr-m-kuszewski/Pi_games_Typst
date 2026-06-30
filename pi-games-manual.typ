#import "@preview/tidy:0.4.3"
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
#import "@preview/cetz:0.5.2" as cetz
#import "@preview/pi-games:0.1.0": *

#show: codly-init.with()
#codly(languages: codly-languages)

#set page(
  paper: "a4",
  margin: (top: 25mm, bottom: 25mm, left: 25mm, right: 25mm),
)
#set text(lang: "en", font: "New Computer Modern", size: 12pt)
#show math.equation: set text(font: "New Computer Modern Math")
#show math.equation: it => {
  show ",": math.class("normal", ",")
  show regex(",\\s"): math.class("punctuation", ",")
  it
}

// Bold table headers
#show table.cell.where(y: 0): set text(weight: "bold")

// Academic-style table borders
#let frame(stroke) = (x, y) => (
    left: 0pt,
    right: 0pt,
    top: if y == 0 { stroke + 0.5pt } else if y == 1 { stroke } else { 0pt },
    bottom: stroke + 0.5pt,
  )

#set table(
    fill: (_, y) => if calc.odd(y) { gray.lighten(80%) },
    stroke: frame(black),
  )

#set par(first-line-indent: 0pt, justify: true)
#set page(numbering: "1")
#set heading(numbering: "1.1")
#set document(
  title: [pi-games: Normal-Form and Extensive-Form Games\ in Typst],
  author: "Piotr Kuszewski",
)

// Visual divider between the two halves of the manual.
#let part-divider(title) = {
  pagebreak(weak: true)
  align(center, block(inset: (y: 1em), {
    text(size: 18pt, weight: "bold")[#title]
  }))
  line(length: 100%, stroke: 0.6pt)
  v(0.8em)
}

#align(center)[
  #v(1em)
  #text(weight: "bold", size: 20pt)[$pi$-games\ Normal-Form and Extensive-Form Games\ in Typst]
  #v(0.5em)
  Piotr Kuszewski #h(2em) June 2026
  #v(1em)
]

= Introduction

The `pi-games` bundle provides Typst tools for typesetting both representations of a game used in game-theory courses and research:

/ Normal-form (strategic-form) games: payoff matrices, drawn by `pi-game-normal.typ`.
/ Extensive-form games: sequential game trees, drawn by `pi-game-trees.typ`.

Both libraries share a single colour palette (`pi-game-palette.typ`) so that player colours are consistent across the two representations. The umbrella module `pi-games.typ` re-exports everything, so a single import exposes the full API:

```typst
#import "@preview/cetz:0.5.2" as cetz
#import "pi-games.typ": *
```

Extensive-form trees are drawn inside a `cetz.canvas` block, so `cetz` is imported explicitly as well. The manual first covers normal-form games, then extensive-form trees, and a combined API reference appears at the end.

== Normal-Form Functions

/ `game-normal-form`: draws a two-player N×M payoff matrix. Each cell displays both players' payoffs separated by a comma, coloured by player.
/ `game-three-player-normal-form`: draws a three-player game as a collection of N×M matrices — one per strategy of Player 3 — laid out in rows.

Both functions measure content at layout time and automatically size each cell to fit its widest payoff expression or strategy label, so the typesetter never needs to specify column widths by hand.

== Extensive-Form Functions

The `pi-game-trees` library covers the full vocabulary of extensive-form games:
- `game-node`: a decision node for a named player, drawn as a filled or outlined circle in that player's colour.
- `game-nature`: a Nature / chance node, drawn in neutral grey.
- `game-terminal`: a terminal (leaf) node with a coloured payoff vector.
- `game-branch`: a directed edge with an optional action label, placed either on the branch line or to its east or west side.
- `game-prob`: convenience wrapper around `game-branch` that renders the label in Nature's grey — intended for probability annotations.
- `game-infoset`: an information set connecting two or more decision nodes, drawn either as a dashed line or as a rounded bracket ribbon.
- `game-subgame`: a proper-subgame triangle marker (Osborne–Rubinstein style).
- `game-highlight`: a bold coloured overlay for marking equilibrium paths.
- `game-payoffs`, `game-player`, `game-player-default`: inline text helpers for body text and captions.

Every tree is drawn inside a `cetz.canvas` block:

```typst
#figure(
  cetz.canvas({
    import cetz.draw: *
    // game-… calls go here
  }),
  caption: [My game tree],
)
```

Player colours are shown below. They can be overridden by redefining `game-pal` after import (see @sec-config).

#box(inset: (y: 4pt), [
  #for i in range(1, 6) {
    h(4pt)
    box(fill: game-pal.at(i - 1).lighten(75%), inset: 4pt, radius: 2pt)[
      #text(fill: game-pal.at(i - 1), weight: "bold", [Player #i])
    ]
    h(4pt)
  }
  #h(4pt)
  #box(fill: game-nature-color.lighten(75%), inset: 4pt, radius: 2pt)[
    #text(fill: game-nature-color, weight: "bold", [Nature])
  ]
])

== Coordinate System

CeTZ uses a standard mathematical coordinate system: the $x$-axis points right and the $y$-axis points _up_. Extensive-form game trees conventionally grow _downward_, so the root node is placed at $y = 0$ and each successive level has a more negative $y$-coordinate. A typical vertical tree uses level spacing $Delta y approx -2$ cm and sibling spacing $Delta x approx 1.5$–$3$ cm per level.

The order of calls within a `cetz.canvas` block determines the drawing order (painter's algorithm). Draw branches and information sets _before_ the nodes so that node circles appear on top of the line endpoints. Place `game-highlight` calls between the branches and the nodes for the same reason.


#part-divider[Normal-Form Games]

= `game-normal-form`

== Payoff Array Structure

The `payoffs` argument is a 2-dimensional array. Element `payoffs.at(r).at(c)` holds a 2-element array `(v1, v2)` where `v1` is Player 1's payoff and `v2` is Player 2's payoff when Player 1 plays row $r$ and Player 2 plays column $c$. Both values are ordinary Typst content and may contain arbitrary markup or mathematics.

```typst
payoffs: (
  // row 0
  ( (v1_00, v2_00),  (v1_01, v2_01) ),
  // row 1
  ( (v1_10, v2_10),  (v1_11, v2_11) ),
)
```

== Auto-Sizing

Cell width is determined automatically at render time as the maximum of three quantities:

+ *`cell-width`*: the user-supplied lower bound (defaults to `game-cell-width`, initially `5em`).
+ *Strategy-label width*: the rendered width of the widest Player 2 strategy label plus `2em` of horizontal padding. This ensures each column is never narrower than its header.
+ *Payoff width*: the rendered width of the widest payoff pair `v1, v2` — including best-response underlines where active — plus `2em` of padding.

The measurement happens inside a `context` block, so it uses the exact font metrics of every piece of content, including mathematical formulas of arbitrary complexity. The *left margin* (Player 1 strategy labels and rotated player name) is auto-sized to the widest Player 1 label; the *top margin* (Player 2 strategy labels and player name) is auto-sized to the tallest Player 2 label. *Cell height* is fixed at `cell-height` (defaults to `game-cell-height`, initially `2em`) and is not auto-sized, since all payoff content is placed on a single line.

== Best Responses and Nash Equilibria

- *`p1-best` / `p2-best`*: arrays of `(row, col)` tuples. In each listed cell the respective player's payoff is underlined with a 1 pt stroke in their colour (`game-pal.at(0)` and `game-pal.at(1)`).
- *`nash`*: array of `(row, col)` tuples. A coloured rectangle in `game-nash-color` is drawn just inside the cell border.

Both underlines and Nash rectangles are taken into account when auto-sizing, so highlighting never causes payoffs to overflow their cells.

== Examples

=== Prisoner's Dilemma

The Prisoner's Dilemma is the textbook example of a dominant-strategy equilibrium. Defection strictly dominates Cooperation for both players, so $(D,D)$ is the unique Nash equilibrium even though $(C,C)$ Pareto-dominates it.

```typst
#game-normal-form(
  [Prisoner 1], [Prisoner 2],
  ([C], [D]),
  ([C], [D]),
  (
    (([$3$], [$3$]), ([$0$], [$5$])),
    (([$5$], [$0$]), ([$1$], [$1$])),
  ),
  p1-best: ((1, 0), (1, 1)),
  p2-best: ((0, 1), (1, 1)),
  nash: ((1, 1),),
)
```

#align(center, game-normal-form(
  [Prisoner 1], [Prisoner 2],
  ([C], [D]),
  ([C], [D]),
  (
    (([$3$], [$3$]), ([$0$], [$5$])),
    (([$5$], [$0$]), ([$1$], [$1$])),
  ),
  p1-best: ((1, 0), (1, 1)),
  p2-best: ((0, 1), (1, 1)),
  nash: ((1, 1),),
))

=== Battle of Sexes

In the Battle of Sexes the players want to coordinate but disagree on which outcome to coordinate on. There are two pure-strategy Nash equilibria — both choose Opera, or both choose Football — and a mixed-strategy equilibrium in between.

```typst
#game-normal-form(
  [She], [He],
  ([Opera], [Football]),
  ([Opera], [Football]),
  (
    (([$2$], [$1$]), ([$0$], [$0$])),
    (([$0$], [$0$]), ([$1$], [$2$])),
  ),
  p1-best: ((0, 0), (1, 1)),
  p2-best: ((0, 0), (1, 1)),
  nash: ((0, 0), (1, 1)),
)
```

#align(center, game-normal-form(
  [She], [He],
  ([Opera], [Football]),
  ([Opera], [Football]),
  (
    (([$2$], [$1$]), ([$0$], [$0$])),
    (([$0$], [$0$]), ([$1$], [$2$])),
  ),
  p1-best: ((0, 0), (1, 1)),
  p2-best: ((0, 0), (1, 1)),
  nash: ((0, 0), (1, 1)),
))

=== Mixed-Strategy Equilibrium: Matching Pennies

Strategy labels are arbitrary Typst content, so mixed-strategy equilibrium probabilities can be embedded directly in the label. Matching Pennies has no pure-strategy Nash equilibrium; the unique Nash equilibrium requires each player to play Heads with probability $p^* = q^* = 1/2$. Including $[p]$ and $[q]$ in the strategy names makes the equilibrium condition explicit. The column width auto-adjusts to accommodate the wider labels.

```typst
#game-normal-form(
  [P1], [P2],
  ([H #h(1mm) $[p]$],     [T #h(1mm) $[1-p]$]),
  ([H $[q]$], [T $[1-q]$]),
  (
    (([$1$], [$-1$]), ([$-1$], [$1$])),
    (([$-1$], [$1$]), ([$1$], [$-1$])),
  ),
)
```

#align(center, game-normal-form(
  [P1], [P2],
  ([$[p]$ #h(1mm) H],     [$[1-p]$ #h(1mm) T]),
  ([$[q]$\ H], [$[1-q]$\ T]),
  (
    (([$1$], [$-1$]), ([$-1$], [$1$])),
    (([$-1$], [$1$]), ([$1$], [$-1$])),
  ),
))

=== Parametric Payoffs: 3×3 Coordination Game

Payoff values may contain mathematical variables and expressions of any complexity. Auto-sizing measures the actual rendered width of each expression to determine the cell size. The symmetric 3×3 coordination game has payoff $a$ when players match and $b$ otherwise; all three pure-strategy Nash equilibria $(A,A)$, $(B,B)$, $(C,C)$ exist for any $a > b$.

```typst
#game-normal-form(
  [P1], [P2],
  ([A], [B], [C]),
  ([A], [B], [C]),
  (
    (([$a$], [$a$]), ([$b$], [$b$]), ([$b$], [$b$])),
    (([$b$], [$b$]), ([$a$], [$a$]), ([$b$], [$b$])),
    (([$b$], [$b$]), ([$b$], [$b$]), ([$a$], [$a$])),
  ),
  p1-best: ((0, 0), (1, 1), (2, 2)),
  p2-best: ((0, 0), (1, 1), (2, 2)),
  nash:    ((0, 0), (1, 1), (2, 2)),
)
```

#align(center, game-normal-form(
  [P1], [P2],
  ([A], [B], [C]),
  ([A], [B], [C]),
  (
    (([$a$], [$a$]), ([$b$], [$b$]), ([$b$], [$b$])),
    (([$b$], [$b$]), ([$a$], [$a$]), ([$b$], [$b$])),
    (([$b$], [$b$]), ([$b$], [$b$]), ([$a$], [$a$])),
  ),
  p1-best: ((0, 0), (1, 1), (2, 2)),
  p2-best: ((0, 0), (1, 1), (2, 2)),
  nash:    ((0, 0), (1, 1), (2, 2)),
))

= `game-three-player-normal-form`

== Payoff Array Structure

The `payoffs` argument is a 3-dimensional array. Element `payoffs.at(k).at(r).at(c)` holds a 3-element array `(v1, v2, v3)`:

/ `k` (outermost): index of Player 3's strategy.
/ `r`: index of Player 1's strategy (row).
/ `c`: index of Player 2's strategy (column).

```typst
payoffs: (
  // k = 0  (first Player 3 strategy)
  (
    ((v1, v2, v3), (v1, v2, v3)),  // r = 0
    ((v1, v2, v3), (v1, v2, v3)),  // r = 1
  ),
  // k = 1  (second Player 3 strategy)
  (
    ((v1, v2, v3), (v1, v2, v3)),
    ((v1, v2, v3), (v1, v2, v3)),
  ),
)
```

Best-response and Nash coordinates use 3-element tuples `(k, row, col)` throughout.

== Layout and Auto-Sizing

Sub-matrices are placed left to right in rows of at most `games-per-row` sub-matrices (default `2`). If Player 3 has more strategies than fit in a row, additional rows are added below. A lone sub-matrix in the last row is horizontally centred within the full row width.

All sub-matrices share identical cell dimensions, computed once from the entire payoff array: the function scans every payoff triple in every cell and every sub-matrix to find the widest rendered content, then combines that with the widest Player 2 strategy label to determine cell width.

Above each sub-matrix (from bottom to top): Player 2's strategy labels, then Player 2's name in bold, then Player 3's strategy label in bold. Player 1's name and strategy labels appear once per row of sub-matrices, to the left. Player 3's player name appears once above the first row of sub-matrices.

== Example: Three-Player Stag Hunt

All three players must cooperate to catch the stag (payoff 3). A player who deviates and hunts the hare alone gets 1; players who pursue the stag without all partners cooperating get 0. Hunting hare is always safe, so $(H,H,H)$ is always a Nash equilibrium; $(S,S,S)$ is the other.

```typst
#game-three-player-normal-form(
  [P1], [P2], [P3],
  ([S], [H]),
  ([S], [H]),
  ([S], [H]),
  (
    // P3 plays S
    (
      (([3],[3],[3]), ([0],[1],[0])),
      (([1],[0],[0]), ([1],[1],[0])),
    ),
    // P3 plays H
    (
      (([0],[0],[1]), ([0],[1],[1])),
      (([1],[0],[1]), ([1],[1],[1])),
    ),
  ),
  nash:    ((0,0,0), (1,1,1)),
  p1-best: ((0,0,0), (0,1,1), (1,1,0), (1,1,1)),
  p2-best: ((0,0,0), (0,1,1), (1,0,1), (1,1,1)),
  p3-best: ((0,0,0), (1,0,1), (1,1,0), (1,1,1)),
)
```

#align(center, game-three-player-normal-form(
  [P1], [P2], [P3],
  ([S], [H]),
  ([S], [H]),
  ([S], [H]),
  (
    (
      (([3],[3],[3]), ([0],[1],[0])),
      (([1],[0],[0]), ([1],[1],[0])),
    ),
    (
      (([0],[0],[1]), ([0],[1],[1])),
      (([1],[0],[1]), ([1],[1],[1])),
    ),
  ),
  nash:    ((0,0,0), (1,1,1)),
  p1-best: ((0,0,0), (0,1,1), (1,1,0), (1,1,1)),
  p2-best: ((0,0,0), (0,1,1), (1,0,1), (1,1,1)),
  p3-best: ((0,0,0), (1,0,1), (1,1,0), (1,1,1)),
))

= Configuration — Normal-Form Games

All constants are ordinary `let` bindings. Override them by redefining the binding _after_ importing the library:

```typst
#import "pi-games.typ": *
#let game-pal = (        // custom player colours
  rgb("#005f73"), rgb("#94d2bd"), rgb("#e9d8a6"),
  rgb("#ee9b00"), rgb("#ae2012"),
)
#let game-nash-color = rgb("#ff6b6b")   // custom Nash highlight
#let game-fg         = rgb("#222222")   // custom foreground
#let game-cell-width  = 6em            // wider cells
#let game-cell-height = 2.5em          // taller cells
#let game-games-per-row = 3            // three sub-matrices per row
```

#table(
  columns: (auto, auto, 2fr),
  table.header([Name], [Default], [Role]),
  [`game-pal`],           [5-colour list],   [Player colours (index 0 = Player 1, 1 = Player 2, 2 = Player 3).],
  [`game-nash-color`],    [`rgb("#22c4c7")`],[Nash equilibrium cell outline colour.],
  [`game-fg`],            [`rgb("#111111")`],[Cell borders, comma separators, and punctuation.],
  [`game-cell-width`],    [`5em`],           [Minimum payoff cell width; auto-grown to fit content.],
  [`game-cell-height`],   [`2em`],           [Fixed payoff cell height; increase for multi-line content.],
  [`game-games-per-row`], [`2`],             [Maximum sub-matrices per row in three-player games.],
)


#part-divider[Extensive-Form Game Trees]

= `game-node` — Decision Nodes

A decision node is a circle in the player's colour. By default it is solid-filled (`style: "filled"`). Pass `style: "open"` for a hollow circle or `style: "dot"` for a smaller disc suitable for compact trees.

The `label` parameter accepts arbitrary Typst content (plain text, math, formatted content). The direction `la` controls which side of the node the label appears on. The eight compass directions `"n"`, `"ne"`, `"e"`, `"se"`, `"s"`, `"sw"`, `"w"`, `"nw"` are all supported. The default is `"n"` (label above the node).

Assign a `name` when the node coordinate must be referenced later — for example, to connect nodes in `game-infoset`.

```typst
#cetz.canvas({
  import cetz.draw: *
  game-node((0, 0),
      player: 1,
      label: [Player 1],
      la: "n")
  game-node((2, 0),
      player: 2,
      label: [Player 2],
      la: "n",
      style: "open")
  game-node((4, 0),
      player: 3,
      label: [P3],
      la: "n",
      style: "dot")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  game-node((0, 0),  player: 1, label: [Player 1], la: "n")
  game-node((2, 0),  player: 2, label: [Player 2], la: "n", style: "open")
  game-node((4, 0),  player: 3, label: [P3],        la: "n", style: "dot")
}))

== `game-nature` — Nature / Chance Nodes

A Nature node is drawn identically to `game-node` but always in `game-nature-color` (grey). The default label is $N$; any content may be substituted.

```typst
#cetz.canvas({
  import cetz.draw: *
  game-nature((0, 0), label: [$cal(N)$], la: "n")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  game-nature((0, 0), label: [$cal(N)$], la: "n")
}))

== `game-terminal` — Terminal Nodes

A terminal node is a small filled dot (radius `game-terminal-radius`) followed by a payoff vector. Each player's payoff is coloured with that player's colour. The direction `la` places the vector below (`"s"`, default), above, or to either side of the dot. Pass `parens: false` to suppress parentheses.

```typst
#cetz.canvas({
  import cetz.draw: *
  game-terminal((0, 0),
      payoffs: ([2], [1]),
      la: "s")
  game-terminal((2, 0),
      payoffs: ([$a$], [$b$]),
      la: "s",
      parens: false)
  game-terminal((4, 0),
      payoffs: ([$-1$], [0], [1]),
      la: "s")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  game-terminal((0, 0), payoffs: ([2], [1]),         la: "s")
  game-terminal((2, 0), payoffs: ([$a$], [$b$]),     la: "s", parens: false)
  game-terminal((4, 0), payoffs: ([$-1$], [0], [1]), la: "s")
}))


= `game-branch` — Branches

A branch is a straight line from `from` to `to`. The optional `action` label is placed at the fractional position `apos` along the branch (default 0.5 = midpoint). The `arrow` parameter adds a CeTZ arrowhead at the child end.

== Label Placement: `side`

The `side` parameter controls how the action label is positioned:

- `side: none` (default): the label sits directly on the branch line, covered by a white rectangle so the line does not bleed through the text.
- `side: "e"`: the label is offset to the *east* (absolute right) side of the branch by `act` centimetres, anchored at its west edge.
- `side: "w"`: the label is offset to the *west* (absolute left) side of the branch by `act` centimetres, anchored at its east edge.

East and west are defined absolutely (positive and negative $x$) regardless of the slope of the branch. The correct 90° perpendicular is computed automatically from the branch direction vector. Using `"west"` and `"east"` CeTZ anchors ensures that labels with different capital heights are baseline-consistent across branches.

```typst
#cetz.canvas({
  import cetz.draw: *
  // Label on the line
  game-branch((0, 0), (0, -2),
      action: [On line],
      player: 1)
  // West side
  game-branch((2, 0), (2, -2),
      action: [West],
      player: 1,
      side: "w")
  // East side
  game-branch((4, 0), (4, -2),
      action: [East],
      player: 1,
      side: "e")
  // Diagonal branch with side "e"
  game-branch((6, 0), (7.5, -2),
      action: [Diag E],
      player: 2,
      side: "e")
  // Nodes drawn last so they appear on top of branch endpoints
  for x in (0, 2, 4, 6) { game-node((x, 0), player: 1) }
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  game-branch((0, 0), (0, -2), action: [On line], player: 1)
  game-branch((4, 0), (4, -2), action: [East],    player: 1, side: "e")
  game-branch((2, 0), (2, -2), action: [West],    player: 1, side: "w")
  game-branch((6, 0), (7.5, -2), action: [Diag E], player: 2, side: "e")
  for x in (0, 2, 4, 6) { game-node((x, 0), player: 1) }
}))

== Label Position: `apos` and `act`

`apos` moves the label along the branch: `0.3` places it closer to the parent, `0.7` closer to the child. `act` controls the perpendicular distance (in cm) from the branch line to the label anchor — increase it when labels would otherwise overlap a nearby branch.

== `game-prob` — Probability Labels

`game-prob` is a thin wrapper around `game-branch` that sets `player: 0`, rendering the action label in `game-nature-color`. All other parameters are identical to `game-branch`. Use it to annotate Nature branches with probabilities.

```typst
#cetz.canvas({
  import cetz.draw: *
  game-prob((0, 0), (-2, -2), action: [$p$],     side: "w")
  game-prob((0, 0), ( 2, -2), action: [$1 - p$], side: "e")
  game-nature((0, 0), la: "n")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  game-prob((0, 0), (-2, -2), action: [$p$],     side: "w")
  game-prob((0, 0), ( 2, -2), action: [$1 - p$], side: "e")
  game-nature((0, 0), la: "n")
}))


= `game-infoset` — Information Sets

An information set connects two or more decision nodes to indicate that the player at those nodes cannot distinguish between them. Two call forms are accepted:

/ Two-point form: `game-infoset(pos1, pos2, …)` — two separate positional arguments.
/ List form: `game-infoset((pos1, pos2, pos3, …), …)` — a single argument that is an array of positions. Draws segments $p_1 arrow p_2$, $p_2 arrow p_3$, … in order.

== Dashed Style

The default `style: "dashed"` draws dashed line segments between consecutive points. An optional `label` is placed at the midpoint of the span; `la` controls its direction.

```typst
#cetz.canvas({
  import cetz.draw: *
  game-branch(( 0, 0), (-1.5, -2), action: [L], player: 1, side: "w")
  game-branch(( 0, 0), ( 1.5, -2), action: [R], player: 1, side: "e")
  game-infoset((-1.5, -2), (1.5, -2),
      player: 2,
      label: [Player 2],
      la: "n")
  game-node((0, 0), player: 1, label: [Player 1], la: "n")
  game-node((-1.5, -2), player: 2)
  game-node(( 1.5, -2), player: 2)
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  game-branch(( 0, 0), (-1.5, -2), action: [L], player: 1, side: "w")
  game-branch(( 0, 0), ( 1.5, -2), action: [R], player: 1, side: "e")
  game-infoset((-1.5, -2), (1.5, -2), player: 2, label: [Player 2], la: "n")
  game-node((0, 0), player: 1, label: [Player 1], la: "n")
  game-node((-1.5, -2), player: 2)
  game-node(( 1.5, -2), player: 2)
}))

== Bracket Style

`style: "bracket"` draws a rounded bracket ribbon. Two dashed rails run `game-tick` cm to each side of the spine between the given points; each endpoint is closed by an outward-facing half-circle arc. The bracket visually groups the nodes into a single decision region without crossing any branches.

```typst
#cetz.canvas({
  import cetz.draw: *
  game-branch(( 0, 0), (-1.5, -2), action: [L], player: 1, side: "w")
  game-branch(( 0, 0), ( 1.5, -2), action: [R], player: 1, side: "e")
  game-infoset((-1.5, -2), (1.5, -2),
      player: 2,
      style: "bracket",
      label: [Player 2],
      la: "s")
  game-node((0, 0), player: 1, label: [Player 1], la: "n")
  game-node((-1.5, -2), player: 2)
  game-node(( 1.5, -2), player: 2)
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  game-branch(( 0, 0), (-1.5, -2), action: [L], player: 1, side: "w")
  game-branch(( 0, 0), ( 1.5, -2), action: [R], player: 1, side: "e")
  game-infoset((-1.5, -2), (1.5, -2), player: 2,
    style: "bracket", label: [Player 2], la: "s")
  game-node((0, 0), player: 1, label: [Player 1], la: "n")
  game-node((-1.5, -2), player: 2)
  game-node(( 1.5, -2), player: 2)
}))

== Curvature: `angle`

Any segment can be bent with the `angle` parameter. A positive angle curves the segment toward its CCW perpendicular (away from the tree's branches for typical horizontal information sets). The Bézier control point is displaced from the segment midpoint by $"chord" times tan("angle") slash 2$. For `"bracket"` style both rails bend by the same angle. An array of angles applies one per segment.

```typst
#cetz.canvas({
  import cetz.draw: *
  // Dashed, bent downward (angle < 0 for southward bow)
  game-infoset((-2, 0), (2, 0),
      player: 2,
      style: "dashed",
      label: [dashed, angle: –25°],
      la: "n",
      angle: -25deg)
  // Bracket, bent upward
  game-infoset((-2, -1.5), (2, -1.5),
      player: 2,
      style: "bracket",
      label: [bracket, angle: 20°],
      la: "s",
      angle: 20deg)
  for x in (-2, 2) {
    game-node((x, 0),    player: 2)
    game-node((x, -1.5), player: 2)
  }
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  game-infoset((-2, 0), (2, 0), player: 2,
    style: "dashed", label: [dashed, angle: –25°], la: "n", angle: 25deg)
  game-infoset((-2, -1.5), (2, -1.5), player: 2,
    style: "bracket", label: [bracket, angle: 20°], la: "s", angle: -20deg)
  for x in (-2, 2) {
    game-node((x, 0),    player: 2)
    game-node((x, -1.5), player: 2)
  }
}))

== Multi-Point Information Sets

Pass an array of three or more positions as the first argument to span a broken-line information set. Each intermediate rail point uses the bisector of its two adjacent segment perpendiculars, so the rails meet cleanly at any bend angle.

```typst
#cetz.canvas({
  import cetz.draw: *
  game-infoset(
    ((-3, 0), (0, 0), (3, 0)),
    player: 2, style: "bracket", label: [three nodes], la: "s",
  )
  for x in (-3, 0, 3) { game-node((x, 0), player: 2) }
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  game-infoset(
    ((-3, 0), (0, 0), (3, 0)),
    player: 2, style: "bracket", label: [three nodes], la: "s",
  )
  for x in (-3, 0, 3) { game-node((x, 0), player: 2) }
}))


= Complete Examples

== Entry Deterrence (Sequential, Perfect Information)

A #game-player(1)[Challenger] decides whether to enter a market. If she enters, the #game-player(2)[Incumbent] either _fights_ or _accommodates_. The unique subgame-perfect Nash equilibrium (SPNE) survives backward induction: the Challenger enters, the Incumbent accommodates, yielding payoffs #game-payoffs(([1], [1])). The bold path shows the SPNE.

```typst
#cetz.canvas({
  import cetz.draw: *
  game-branch((0,0), (-2.5,-2.2), action: [Out], player: 1, side: "w")
  game-terminal((-2.5,-2.2), payoffs: ([0], [2]))
  game-branch((0,0), ( 2.5,-2.2), action: [In], player: 1, side: "e")
  game-branch((2.5,-2.2), (1.2,-4.2), action: [Fight], player: 2, side: "w")
  game-terminal((1.2,-4.2), payoffs: ([$-1$], [0]))
  game-branch((2.5,-2.2), (3.8,-4.2), action: [Accommodate], player: 2, side: "e")
  game-terminal((3.8,-4.2), payoffs: ([1], [1]))
  game-highlight((0,0), (2.5,-2.2))
  game-highlight((2.5,-2.2),(3.8,-4.2))
  game-node((0,0), player: 1, label: [Challenger], la: "n")
  game-node((2.5,-2.2), player: 2, label: [Incumbent],  la: "e")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  game-branch((0,0), (-2.5,-2.2), action: [Out], player: 1, side: "w")
  game-terminal((-2.5,-2.2), payoffs: ([0], [2]))
  game-branch((0,0), ( 2.5,-2.2), action: [In], player: 1, side: "e")
  game-branch((2.5,-2.2), (1.2,-4.2), action: [Fight], player: 2, side: "w")
  game-terminal((1.2,-4.2), payoffs: ([$-1$], [0]))
  game-branch((2.5,-2.2), (3.8,-4.2), action: [Accommodate], player: 2, side: "e")
  game-terminal((3.8,-4.2), payoffs: ([1], [1]))
  game-highlight((0,0), (2.5,-2.2))
  game-highlight((2.5,-2.2),(3.8,-4.2))
  game-node((0,0), player: 1, label: [Challenger], la: "n")
  game-node((2.5,-2.2), player: 2, label: [Incumbent],  la: "e")
}))

== Battle of the Sexes (Simultaneous Moves)

#game-player(1)[Player 1] moves first in the tree, but #game-player(2)[Player 2] does not observe the move — the two #game-player(2)[Player 2] nodes therefore belong to the same information set (dashed line). This makes the game strategically equivalent to its normal form. There are two pure-strategy Nash equilibria: #game-payoffs(([2],[1])) and #game-payoffs(([1],[2])).

```typst
#cetz.canvas({
  import cetz.draw: *
  game-branch((0,0), (-2.8,-2),
      action: [Opera],
      player: 1,
      side: "w")
  game-branch((0,0), ( 2.8,-2),
      action: [Football],
      player: 1,
      side: "e")
  game-infoset((-2.8,-2), (2.8,-2),
      player: 2,
      style: "dashed",
      label: [no observation],
      la: "n")
  game-branch((-2.8,-2), (-3.8,-4),
      action: [Opera],
      player: 2,
      side: "w")
  game-terminal((-3.8,-4), payoffs: ([2], [1]))
  game-branch((-2.8,-2), (-1.8,-4),
      action: [Football],
      player: 2,
      side: "e")
  game-terminal((-1.8,-4), payoffs: ([0], [0]))
  game-branch(( 2.8,-2), ( 1.8,-4),
      action: [Opera],
      player: 2,
      side: "w")
  game-terminal(( 1.8,-4), payoffs: ([0], [0]))
  game-branch(( 2.8,-2), ( 3.8,-4),
      action: [Football],
      player: 2,
      side: "e")
  game-terminal(( 3.8,-4), payoffs: ([1], [2]))
  game-node((0, 0), player: 1, label: [Player 1], la: "n")
  game-node((-2.8,-2), player: 2, label: [Player 2], la: "w")
  game-node(( 2.8,-2), player: 2, label: [Player 2], la: "e")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  game-branch((0,0), (-2.8,-2), action: [Opera],    player: 1, side: "w")
  game-branch((0,0), ( 2.8,-2), action: [Football], player: 1, side: "e")
  game-infoset((-2.8,-2), (2.8,-2), player: 2,
    style: "dashed", label: [no observation], la: "n")
  game-branch((-2.8,-2), (-3.8,-4), action: [Opera],    player: 2, side: "w")
  game-terminal((-3.8,-4), payoffs: ([2], [1]))
  game-branch((-2.8,-2), (-1.8,-4), action: [Football], player: 2, side: "e")
  game-terminal((-1.8,-4), payoffs: ([0], [0]))
  game-branch(( 2.8,-2), ( 1.8,-4), action: [Opera],    player: 2, side: "w")
  game-terminal(( 1.8,-4), payoffs: ([0], [0]))
  game-branch(( 2.8,-2), ( 3.8,-4), action: [Football], player: 2, side: "e")
  game-terminal(( 3.8,-4), payoffs: ([1], [2]))
  game-node((0, 0),    player: 1, label: [Player 1], la: "n")
  game-node((-2.8,-2), player: 2, label: [Player 2], la: "w")
  game-node(( 2.8,-2), player: 2, label: [Player 2], la: "e")
}))

== Adverse Selection with Nature

Nature draws a buyer's valuation: _Low_ ($theta_L$) with probability $1/3$ and _High_ ($theta_H$) with probability $2/3$. Only the buyer observes her type; the seller offers a price $p$ without knowing the realised type. The seller's ignorance is modelled by a bracket-style information set spanning the two buyer nodes.

```typst
#cetz.canvas({
  import cetz.draw: *
  game-prob((0,0), (-3,-2), action: [$p = 1/3$], side: "w")
  game-prob((0,0), ( 3,-2), action: [$p = 2/3$], side: "e")
  game-branch((-3,-2), (-4.2,-4), action: [Buy],  player: 1)
  game-terminal((-4.2,-4), payoffs: ([$p - c$], [$theta_L - p$]))
  game-branch((-3,-2), (-1.8,-4), action: [Pass], player: 1)
  game-terminal((-1.8,-4), payoffs: ([0], [0]))
  game-branch(( 3,-2), ( 1.8,-4), action: [Buy],  player: 1)
  game-terminal(( 1.8,-4), payoffs: ([$p - c$], [$theta_H - p$]))
  game-branch(( 3,-2), ( 4.2,-4), action: [Pass], player: 1)
  game-terminal(( 4.2,-4), payoffs: ([0], [0]))
  game-infoset((-3,-2), (3,-2), player: 1, style: "bracket")
  game-nature((0,0), label: [$cal(N)$], la: "n")
  game-node((-3,-2), player: 1, label: [$theta_L$], la: "w")
  game-node(( 3,-2), player: 1, label: [$theta_H$], la: "e")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  game-prob((0,0), (-3,-2), action: [$p = 1/3$], side: "w")
  game-prob((0,0), ( 3,-2), action: [$p = 2/3$], side: "e")
  game-branch((-3,-2), (-4.2,-4), action: [Buy],  player: 1)
  game-terminal((-4.2,-4), payoffs: ([$p - c$], [$theta_L - p$]))
  game-branch((-3,-2), (-1.8,-4), action: [Pass], player: 1)
  game-terminal((-1.8,-4), payoffs: ([0], [0]))
  game-branch(( 3,-2), ( 1.8,-4), action: [Buy],  player: 1)
  game-terminal(( 1.8,-4), payoffs: ([$p - c$], [$theta_H - p$]))
  game-branch(( 3,-2), ( 4.2,-4), action: [Pass], player: 1)
  game-terminal(( 4.2,-4), payoffs: ([0], [0]))
  game-infoset((-3,-2), (3,-2), player: 1, style: "bracket")
  game-nature((0,0), label: [$cal(N)$], la: "n")
  game-node((-3,-2), player: 1, label: [$theta_L$], la: "w")
  game-node(( 3,-2), player: 1, label: [$theta_H$], la: "e")
}))

== Beer–Quiche Signalling Game (Cho–Kreps 1987)

Nature draws the #game-player(1)[Sender]'s type: _Strong_ ($S$, probability 0.7) or _Weak_ ($W$, probability 0.3). The Sender signals with _Beer_ (B) or _Quiche_ (Q). The #game-player(2)[Receiver] observes the signal but not the type, then chooses _Duel_ (D) or _No Duel_ (N). Two information sets — one bent downward (`angle: -33deg`, bracket style) and one bent upward (`angle: 33deg`, dashed style) — connect nodes reached by the same signal. The unique pooling Perfect Bayesian Equilibrium has both types choose Beer; the Receiver duels after Quiche (off-path belief: Weak). PBNE payoffs: #game-payoffs(([3],[1])) for Strong, #game-payoffs(([2],[0])) for Weak.

```typst
#cetz.canvas(
    {
    import cetz.draw: *
    game-prob((0,0),(-3,0),action: [$p$],
        side: "w",
        act: 0.3)
    game-prob((0,0),(3,0), action: [$1-p$],
        side: "e",
        act: 0.3,
        apos: 0.3)
    game-branch((-3,0),(-3,2), action: [Q], side: "w")
    game-branch((-3,0),(-3,-2), action: [B], side: "w")
    game-branch((3,0),(3,2), action: [Q], side: "e")
    game-branch((3,0),(3,-2), action: [B], side: "e")
    game-infoset((-3,2),(3,2), style: "bracket",
        label: [Quiche])
    game-infoset((-3,-2),(3,-2), style: "bracket",
        label: [Beer],
        la: "n")
    game-branch((-3,2),(-5,4), action: [M], side: "e")
    game-terminal((-5,4), payoffs: ([3],[0]), la: "n")
    game-branch((-3,2),(-1,4), action: [$not$M], side: "w")
    game-terminal((-1,4), payoffs: ([1],[1]), la: "n")
    game-branch((-3,-2),(-5,-4), action: [M], side: "e")
    game-terminal((-5,-4), payoffs: ([2],[0]), la: "s")
    game-branch((-3,-2),(-1,-4), action: [$not$M], side: "w")
    game-terminal((-1,-4), payoffs: ([0],[1]), la: "s")
    game-branch((3,2),(5,4), action: [M], side: "w")
    game-terminal((5,4), payoffs: ([3],[0]), la: "n")
    game-branch((3,2),(1,4), action: [$not$M], side: "e")
    game-terminal((1,4), payoffs: ([1],[1]), la: "n")
    game-branch((3,-2),(5,-4), action: [M], side: "w")
    game-terminal((5,-4), payoffs: ([2],[0]), la: "s")
    game-branch((3,-2),(1,-4), action: [$not$M], side: "e")
    game-terminal((1,-4), payoffs: ([0],[1]), la: "s")
    game-nature((0,0), label: [$cal(N)$], la: "n")
    game-node((-3,0), label: [S], la: "w")
    game-node((3,0), label: [W], la: "e")
    game-node((-3,2), label: [B], player: 2, la: "w")
    game-node((-3,-2), label: [B], player: 2, la: "w")
    game-node((3,2), label: [B], player: 2, la: "e")
    game-node((3,-2), label: [B], player: 2, la: "e")
    }
  )
```

#align(center)[
#cetz.canvas(
    {
    import cetz.draw: *
    game-prob((0,0),(-3,0),action: [$p$],
        side: "w",
        act: 0.3)
    game-prob((0,0),(3,0), action: [$1-p$],
        side: "e",
        act: 0.3,
        apos: 0.3)
    game-branch((-3,0),(-3,2), action: [Q], side: "w")
    game-branch((-3,0),(-3,-2), action: [B], side: "w")
    game-branch((3,0),(3,2), action: [Q], side: "e")
    game-branch((3,0),(3,-2), action: [B], side: "e")
    game-infoset((-3,2),(3,2), style: "bracket",
        label: [Quiche])
    game-infoset((-3,-2),(3,-2), style: "bracket",
        label: [Beer],
        la: "n")
    game-branch((-3,2),(-5,4), action: [M], side: "e")
    game-terminal((-5,4), payoffs: ([3],[0]), la: "n")
    game-branch((-3,2),(-1,4), action: [$not$M], side: "w")
    game-terminal((-1,4), payoffs: ([1],[1]), la: "n")
    game-branch((-3,-2),(-5,-4), action: [M], side: "e")
    game-terminal((-5,-4), payoffs: ([2],[0]), la: "s")
    game-branch((-3,-2),(-1,-4), action: [$not$M], side: "w")
    game-terminal((-1,-4), payoffs: ([0],[1]), la: "s")
    game-branch((3,2),(5,4), action: [M], side: "w")
    game-terminal((5,4), payoffs: ([3],[0]), la: "n")
    game-branch((3,2),(1,4), action: [$not$M], side: "e")
    game-terminal((1,4), payoffs: ([1],[1]), la: "n")
    game-branch((3,-2),(5,-4), action: [M], side: "w")
    game-terminal((5,-4), payoffs: ([2],[0]), la: "s")
    game-branch((3,-2),(1,-4), action: [$not$M], side: "e")
    game-terminal((1,-4), payoffs: ([0],[1]), la: "s")
    game-nature((0,0), label: [$cal(N)$], la: "n")
    game-node((-3,0), label: [S], la: "w")
    game-node((3,0), label: [W], la: "e")
    game-node((-3,2), label: [B], player: 2, la: "w")
    game-node((-3,-2), label: [B], player: 2, la: "w")
    game-node((3,2), label: [B], player: 2, la: "e")
    game-node((3,-2), label: [B], player: 2, la: "e")
    }
  )
]

= Annotations

== Equilibrium Highlights: `game-highlight`

`game-highlight` draws a bold coloured line over an existing branch to mark the equilibrium path. It is shortened by `game-node-radius` at each end so the highlight does not overlap the node circles. Call it _after_ the branches but _before_ the nodes so the nodes remain on top.

```typst
#cetz.canvas({
  import cetz.draw: *
  game-branch((0,0), (-1.5,-2), action: [L], player: 1, side: "w")
  game-branch((0,0), ( 1.5,-2), action: [R], player: 1, side: "e")
  // Highlight the right branch in player 1's colour
  game-highlight((0,0), (1.5,-2), color: game-pal.at(0))
  game-node((0,0), player: 1)
  game-terminal((-1.5,-2), payoffs: ([0],[1]))
  game-terminal(( 1.5,-2), payoffs: ([2],[0]))
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  game-branch((0,0), (-1.5,-2), action: [L], player: 1, side: "w")
  game-branch((0,0), ( 1.5,-2), action: [R], player: 1, side: "e")
  game-highlight((0,0), (1.5,-2), color: game-pal.at(0))
  game-node((0,0), player: 1)
  game-terminal((-1.5,-2), payoffs: ([0],[1]))
  game-terminal(( 1.5,-2), payoffs: ([2],[0]))
}))

== Proper-Subgame Markers: `game-subgame`

`game-subgame` draws a dotted, lightly shaded triangle with its apex at the subgame root. `depth` controls the height of the triangle and `width` its half-base width. An optional `label` is placed inside at roughly 42% of the height from the base.

```typst
#cetz.canvas({
  import cetz.draw: *
  game-branch((0,0), (-1.5,-1), action: [L], player: 1, side: "w")
  game-branch((0,0), ( 1.5,-1), action: [R], player: 1, side: "e")
  game-subgame((-1.5,-1), depth: 1.5, width: 0.7, label: [$G_L$])
  game-subgame(( 1.5,-1), depth: 1.5, width: 0.7, label: [$G_R$])
  game-node((0,0), player: 1, label: [P1], la: "n")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  game-branch((0,0), (-1.5,-1), action: [L], player: 1, side: "w")
  game-branch((0,0), ( 1.5,-1), action: [R], player: 1, side: "e")
  game-subgame((-1.5,-1), depth: 1.5, width: 0.7, label: [$G_L$])
  game-subgame(( 1.5,-1), depth: 1.5, width: 0.7, label: [$G_R$])
  game-node((0,0), player: 1, label: [P1], la: "n")
}))


= Inline Text Helpers

== Coloured Payoff Vectors: `game-payoffs`

`game-payoffs` typesets a payoff vector in body text or captions, colouring each entry in that player's colour. It returns ordinary Typst content and can be used anywhere — inside and outside `cetz.canvas` alike.

```typst
The unique NE payoff vector is #game-payoffs(([2], [1])).

In math: $u = #game-payoffs(([$a - c$], [$b$]), parens: false)$.
```

The unique NE payoff vector is #game-payoffs(([2], [1])).

In math: $u = #game-payoffs(([$a - c$], [$b$]), parens: false)$.

== Player Names in Colour: `game-player` and `game-player-default`

`game-player(n)[label]` typesets arbitrary content in player $n$'s colour (bold). `game-player-default(n)` is a shortcut that produces "Player $n$" without requiring a label argument.

```typst
#game-player(1)[Challenger] moves first;
#game-player(2)[Incumbent] responds.
Payoffs: #game-payoffs(([1], [1])).
Both players are #game-player-default(1) and #game-player-default(2).
```

#game-player(1)[Challenger] moves first; #game-player(2)[Incumbent] responds.
Payoffs: #game-payoffs(([1], [1])).
Both players are #game-player-default(1) and #game-player-default(2).


= Configuration — Extensive-Form Trees <sec-config>

All geometric and typographic constants are ordinary `let` bindings. Override them by redefining the binding _after_ importing the library:

```typst
#import "pi-games.typ": *
#let game-node-radius               = 0.15    // larger decision nodes
#let game-terminal-radius              = 0.08    // smaller terminal dots
#let game-act             = 0.3     // more space for action labels
#let game-fsl             = 10pt    // smaller player-label font
#let game-highlight-color = rgb("#e53e3e")  // custom highlight colour
#let game-pal   = (      // custom player colours
  rgb("#005f73"), rgb("#94d2bd"), rgb("#e9d8a6"),
  rgb("#ee9b00"), rgb("#ae2012"),
)
```

The full list of configuration bindings and their defaults is given in the API Reference below.

#table(
  columns: (auto, auto, 2fr),
  table.header([Name], [Default], [Role]),
  [`game-pal`],              [5-colour list],    [Player colours (index 0 = Player 1).],
  [`game-nature-color`],     [`rgb("#666666")`], [Nature / chance node colour.],
  [`game-fg`],               [`rgb("#111111")`], [Branch lines, terminal dots, payoff punctuation.],
  [`game-highlight-color`],  [`rgb("#e53e3e")`], [Default `game-highlight` overlay colour.],
  [`game-infoset-color`],    [`luma(90)`],       [Information-set colour when no `player:` is given.],
  [`game-subgame-stroke`],   [`luma(130)`],      [Subgame triangle outline colour.],
  [`game-subgame-fill`],     [`luma(247)`],      [Subgame triangle fill colour.],
  [`game-subgame-label`],    [`luma(145)`],      [Subgame triangle label colour.],
  [`game-node-radius`],            [`0.1` cm],       [Decision node radius.],
  [`game-terminal-radius`],           [`0.1` cm],       [Terminal dot radius.],
  [`game-gap`],          [`0.2` cm],       [Node edge to label gap.],
  [`game-act`],          [`0.2` cm],       [Branch-line to action-label offset.],
  [`game-apos`],         [`0.5`],          [Fractional label position along branch.],
  [`game-tick`],         [`0.20` cm],      [Bracket tick half-length.],
  [`game-sw-b`],         [`1pt`],          [Branch stroke width.],
  [`game-sw-n`],         [`1pt`],          [Decision-node stroke width.],
  [`game-sw-ni`],        [`1pt`],          [Nature-node stroke width.],
  [`game-sw-i`],         [`1pt`],          [Information-set stroke width.],
  [`game-sw-h`],         [`2pt`],          [Highlight stroke width.],
  [`game-fsl`],          [`11pt`],         [Player / node label font size.],
  [`game-fsa`],          [`11pt`],         [Action label font size.],
  [`game-fsp`],          [`11pt`],         [Payoff label font size.],
)

#set heading(numbering: none)
= API Reference

== `pi-game-normal.typ`

#let docs-normal = tidy.parse-module(read("src/pi-game-normal.typ"), name: none, label-prefix: "normal-")
#tidy.show-module(docs-normal)

== `pi-game-trees.typ`

#let docs-trees = tidy.parse-module(read("src/pi-game-trees.typ"), name: none, label-prefix: "trees-")
#tidy.show-module(docs-trees)
