#import "@preview/tidy:0.4.3"
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/cetz:0.5.2" as cetz
#import "pi-game-trees.typ": *

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

// Pogrubione nagłówki tabeli
#show table.cell.where(y: 0): set text(weight: "bold")

// Obramowania tabeli w stylu akademickim
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
  title: [pi-game-trees: Extensive-Form Game Trees in Typst],
  author: "Piotr Kuszewski",
)

#align(center)[
  #v(1em)
  #text(weight: "bold", size: 20pt)[$pi$-game-trees\ Extensive-Form Games in Typst]
  #v(0.5em)
  Piotr Kuszewski #h(2em) May 2026
  #v(1em)
]

= Introduction

The `pi-game-trees` library provides Typst macros for drawing _extensive-form_ game trees of the kind used in graduate and advanced undergraduate game theory courses. It is built on `@preview/cetz:0.5.2` and requires no other dependencies beyond Typst itself.

The library covers the full vocabulary of extensive-form games:
- `gtree-node`: a decision node for a named player, drawn as a filled or outlined circle in that player's colour.
- `gtree-nature`: a Nature / chance node, drawn in neutral grey.
- `gtree-terminal`: a terminal (leaf) node with a coloured payoff vector.
- `gtree-branch`: a directed edge with an optional action label, placed either on the branch line or to its east or west side.
- `gtree-prob`: convenience wrapper around `gtree-branch` that renders the label in Nature's grey — intended for probability annotations.
- `gtree-infoset`: an information set connecting two or more decision nodes, drawn either as a dashed line or as a rounded bracket ribbon.
- `gtree-subgame`: a proper-subgame triangle marker (Osborne–Rubinstein style).
- `gtree-highlight`: a bold coloured overlay for marking equilibrium paths.
- `gtree-payoffs`, `gtree-player`, `gtree-player-default`: inline text helpers for body text and captions.

Import the library at the top of your document:

```typst
#import "@preview/cetz:0.5.2" as cetz
#import "pi-game-trees.typ": *
```

Every tree is drawn inside a `cetz.canvas` block:

```typst
#figure(
  cetz.canvas({
    import cetz.draw: *
    // gtree-… calls go here
  }),
  caption: [My game tree],
)
```

Player colours are shown below. They can be overridden by redefining `gtree-pal` after import (see @sec-config).

#box(inset: (y: 4pt), [
  #for i in range(1, 6) {
    h(4pt)
    box(fill: gtree-pal.at(i - 1).lighten(75%), inset: 4pt, radius: 2pt)[
      #text(fill: gtree-pal.at(i - 1), weight: "bold", [Player #i])
    ]
    h(4pt)
  }
  #h(4pt)
  #box(fill: gtree-nature-color.lighten(75%), inset: 4pt, radius: 2pt)[
    #text(fill: gtree-nature-color, weight: "bold", [Nature])
  ]
])

== Coordinate System

CeTZ uses a standard mathematical coordinate system: the $x$-axis points right and the $y$-axis points _up_. Extensive-form game trees conventionally grow _downward_, so the root node is placed at $y = 0$ and each successive level has a more negative $y$-coordinate. A typical vertical tree uses level spacing $Delta y approx -2$ cm and sibling spacing $Delta x approx 1.5$–$3$ cm per level.

The order of calls within a `cetz.canvas` block determines the drawing order (painter's algorithm). Draw branches and information sets _before_ the nodes so that node circles appear on top of the line endpoints. Place `gtree-highlight` calls between the branches and the nodes for the same reason.


= `gtree-node` — Decision Nodes

A decision node is a circle in the player's colour. By default it is solid-filled (`style: "filled"`). Pass `style: "open"` for a hollow circle or `style: "dot"` for a smaller disc suitable for compact trees.

The `label` parameter accepts arbitrary Typst content (plain text, math, formatted content). The direction `la` controls which side of the node the label appears on. The eight compass directions `"n"`, `"ne"`, `"e"`, `"se"`, `"s"`, `"sw"`, `"w"`, `"nw"` are all supported. The default is `"n"` (label above the node).

Assign a `name` when the node coordinate must be referenced later — for example, to connect nodes in `gtree-infoset`.

```typst
#cetz.canvas({
  import cetz.draw: *
  gtree-node((0, 0),
      player: 1,
      label: [Player 1],
      la: "n")
  gtree-node((2, 0),
      player: 2,
      label: [Player 2],
      la: "n",
      style: "open")
  gtree-node((4, 0),
      player: 3,
      label: [P3],
      la: "n",
      style: "dot")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  gtree-node((0, 0),  player: 1, label: [Player 1], la: "n")
  gtree-node((2, 0),  player: 2, label: [Player 2], la: "n", style: "open")
  gtree-node((4, 0),  player: 3, label: [P3],        la: "n", style: "dot")
}))

== `gtree-nature` — Nature / Chance Nodes

A Nature node is drawn identically to `gtree-node` but always in `gtree-nature-color` (grey). The default label is $N$; any content may be substituted.

```typst
#cetz.canvas({
  import cetz.draw: *
  gtree-nature((0, 0), label: [$cal(N)$], la: "n")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  gtree-nature((0, 0), label: [$cal(N)$], la: "n")
}))

== `gtree-terminal` — Terminal Nodes

A terminal node is a small filled dot (radius `gtree-Rt`) followed by a payoff vector. Each player's payoff is coloured with that player's colour. The direction `la` places the vector below (`"s"`, default), above, or to either side of the dot. Pass `parens: false` to suppress parentheses.

```typst
#cetz.canvas({
  import cetz.draw: *
  gtree-terminal((0, 0),
      payoffs: ([2], [1]),
      la: "s")
  gtree-terminal((2, 0),
      payoffs: ([$a$], [$b$]),
      la: "s",
      parens: false)
  gtree-terminal((4, 0),
      payoffs: ([$-1$], [0], [1]),
      la: "s")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  gtree-terminal((0, 0), payoffs: ([2], [1]),         la: "s")
  gtree-terminal((2, 0), payoffs: ([$a$], [$b$]),     la: "s", parens: false)
  gtree-terminal((4, 0), payoffs: ([$-1$], [0], [1]), la: "s")
}))


= `gtree-branch` — Branches

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
  gtree-branch((0, 0), (0, -2), 
      action: [On line],
      player: 1)
  // West side
  gtree-branch((2, 0), (2, -2),
      action: [West],
      player: 1,
      side: "w")
  // East side
  gtree-branch((4, 0), (4, -2),
      action: [East],
      player: 1,
      side: "e")
  // Diagonal branch with side "e"
  gtree-branch((6, 0), (7.5, -2), 
      action: [Diag E], 
      player: 2, 
      side: "e")
  // Nodes drawn last so they appear on top of branch endpoints
  for x in (0, 2, 4, 6) { gtree-node((x, 0), player: 1) }
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  gtree-branch((0, 0), (0, -2), action: [On line], player: 1)
  gtree-branch((4, 0), (4, -2), action: [East],    player: 1, side: "e")
  gtree-branch((2, 0), (2, -2), action: [West],    player: 1, side: "w")
  gtree-branch((6, 0), (7.5, -2), action: [Diag E], player: 2, side: "e")
  for x in (0, 2, 4, 6) { gtree-node((x, 0), player: 1) }
}))

== Label Position: `apos` and `act`

`apos` moves the label along the branch: `0.3` places it closer to the parent, `0.7` closer to the child. `act` controls the perpendicular distance (in cm) from the branch line to the label anchor — increase it when labels would otherwise overlap a nearby branch.

== `gtree-prob` — Probability Labels

`gtree-prob` is a thin wrapper around `gtree-branch` that sets `player: 0`, rendering the action label in `gtree-nature-color`. All other parameters are identical to `gtree-branch`. Use it to annotate Nature branches with probabilities.

```typst
#cetz.canvas({
  import cetz.draw: *
  gtree-prob((0, 0), (-2, -2), action: [$p$],     side: "w")
  gtree-prob((0, 0), ( 2, -2), action: [$1 - p$], side: "e")
  gtree-nature((0, 0), la: "n")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  gtree-prob((0, 0), (-2, -2), action: [$p$],     side: "w")
  gtree-prob((0, 0), ( 2, -2), action: [$1 - p$], side: "e")
  gtree-nature((0, 0), la: "n")
}))


= `gtree-infoset` — Information Sets

An information set connects two or more decision nodes to indicate that the player at those nodes cannot distinguish between them. Two call forms are accepted:

/ Two-point form: `gtree-infoset(pos1, pos2, …)` — two separate positional arguments.
/ List form: `gtree-infoset((pos1, pos2, pos3, …), …)` — a single argument that is an array of positions. Draws segments $p_1 arrow p_2$, $p_2 arrow p_3$, … in order.

== Dashed Style

The default `style: "dashed"` draws dashed line segments between consecutive points. An optional `label` is placed at the midpoint of the span; `la` controls its direction.

```typst
#cetz.canvas({
  import cetz.draw: *
  gtree-branch(( 0, 0), (-1.5, -2), action: [L], player: 1, side: "w")
  gtree-branch(( 0, 0), ( 1.5, -2), action: [R], player: 1, side: "e")
  gtree-infoset((-1.5, -2), (1.5, -2),
      player: 2, 
      label: [Player 2],
      la: "n")
  gtree-node((0, 0), player: 1, label: [Player 1], la: "n")
  gtree-node((-1.5, -2), player: 2)
  gtree-node(( 1.5, -2), player: 2)
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  gtree-branch(( 0, 0), (-1.5, -2), action: [L], player: 1, side: "w")
  gtree-branch(( 0, 0), ( 1.5, -2), action: [R], player: 1, side: "e")
  gtree-infoset((-1.5, -2), (1.5, -2), player: 2, label: [Player 2], la: "n")
  gtree-node((0, 0), player: 1, label: [Player 1], la: "n")
  gtree-node((-1.5, -2), player: 2)
  gtree-node(( 1.5, -2), player: 2)
}))

== Bracket Style

`style: "bracket"` draws a rounded bracket ribbon. Two dashed rails run `gtree-tick` cm to each side of the spine between the given points; each endpoint is closed by an outward-facing half-circle arc. The bracket visually groups the nodes into a single decision region without crossing any branches.

```typst
#cetz.canvas({
  import cetz.draw: *
  gtree-branch(( 0, 0), (-1.5, -2), action: [L], player: 1, side: "w")
  gtree-branch(( 0, 0), ( 1.5, -2), action: [R], player: 1, side: "e")
  gtree-infoset((-1.5, -2), (1.5, -2), 
      player: 2,
      style: "bracket", 
      label: [Player 2], 
      la: "s")
  gtree-node((0, 0), player: 1, label: [Player 1], la: "n")
  gtree-node((-1.5, -2), player: 2)
  gtree-node(( 1.5, -2), player: 2)
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  gtree-branch(( 0, 0), (-1.5, -2), action: [L], player: 1, side: "w")
  gtree-branch(( 0, 0), ( 1.5, -2), action: [R], player: 1, side: "e")
  gtree-infoset((-1.5, -2), (1.5, -2), player: 2,
    style: "bracket", label: [Player 2], la: "s")
  gtree-node((0, 0), player: 1, label: [Player 1], la: "n")
  gtree-node((-1.5, -2), player: 2)
  gtree-node(( 1.5, -2), player: 2)
}))

== Curvature: `angle`

Any segment can be bent with the `angle` parameter. A positive angle curves the segment toward its CCW perpendicular (away from the tree's branches for typical horizontal information sets). The Bézier control point is displaced from the segment midpoint by $"chord" times tan("angle") slash 2$. For `"bracket"` style both rails bend by the same angle. An array of angles applies one per segment.

```typst
#cetz.canvas({
  import cetz.draw: *
  // Dashed, bent downward (angle < 0 for southward bow)
  gtree-infoset((-2, 0), (2, 0), 
      player: 2,
      style: "dashed", 
      label: [dashed, angle: –25°], 
      la: "n", 
      angle: -25deg)
  // Bracket, bent upward
  gtree-infoset((-2, -1.5), (2, -1.5), 
      player: 2,
      style: "bracket", 
      label: [bracket, angle: 20°], 
      la: "s", 
      angle: 20deg)
  for x in (-2, 2) {
    gtree-node((x, 0),    player: 2)
    gtree-node((x, -1.5), player: 2)
  }
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  gtree-infoset((-2, 0), (2, 0), player: 2,
    style: "dashed", label: [dashed, angle: –25°], la: "n", angle: 25deg)
  gtree-infoset((-2, -1.5), (2, -1.5), player: 2,
    style: "bracket", label: [bracket, angle: 20°], la: "s", angle: -20deg)
  for x in (-2, 2) {
    gtree-node((x, 0),    player: 2)
    gtree-node((x, -1.5), player: 2)
  }
}))

== Multi-Point Information Sets

Pass an array of three or more positions as the first argument to span a broken-line information set. Each intermediate rail point uses the bisector of its two adjacent segment perpendiculars, so the rails meet cleanly at any bend angle.

```typst
#cetz.canvas({
  import cetz.draw: *
  gtree-infoset(
    ((-3, 0), (0, 0), (3, 0)),
    player: 2, style: "bracket", label: [three nodes], la: "s",
  )
  for x in (-3, 0, 3) { gtree-node((x, 0), player: 2) }
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  gtree-infoset(
    ((-3, 0), (0, 0), (3, 0)),
    player: 2, style: "bracket", label: [three nodes], la: "s",
  )
  for x in (-3, 0, 3) { gtree-node((x, 0), player: 2) }
}))


= Complete Examples

== Entry Deterrence (Sequential, Perfect Information)

A #gtree-player(1)[Challenger] decides whether to enter a market. If she enters, the #gtree-player(2)[Incumbent] either _fights_ or _accommodates_. The unique subgame-perfect Nash equilibrium (SPNE) survives backward induction: the Challenger enters, the Incumbent accommodates, yielding payoffs #gtree-payoffs(([1], [1])). The bold path shows the SPNE.

```typst
#cetz.canvas({
  import cetz.draw: *
  gtree-branch((0,0), (-2.5,-2.2), action: [Out], player: 1, side: "w")
  gtree-terminal((-2.5,-2.2), payoffs: ([0], [2]))
  gtree-branch((0,0), ( 2.5,-2.2), action: [In], player: 1, side: "e")
  gtree-branch((2.5,-2.2), (1.2,-4.2), action: [Fight], player: 2, side: "w")
  gtree-terminal((1.2,-4.2), payoffs: ([$-1$], [0]))
  gtree-branch((2.5,-2.2), (3.8,-4.2), action: [Accommodate], player: 2, side: "e")
  gtree-terminal((3.8,-4.2), payoffs: ([1], [1]))
  gtree-highlight((0,0), (2.5,-2.2))
  gtree-highlight((2.5,-2.2),(3.8,-4.2))
  gtree-node((0,0), player: 1, label: [Challenger], la: "n")
  gtree-node((2.5,-2.2), player: 2, label: [Incumbent],  la: "e")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  gtree-branch((0,0), (-2.5,-2.2), action: [Out], player: 1, side: "w")
  gtree-terminal((-2.5,-2.2), payoffs: ([0], [2]))
  gtree-branch((0,0), ( 2.5,-2.2), action: [In], player: 1, side: "e")
  gtree-branch((2.5,-2.2), (1.2,-4.2), action: [Fight], player: 2, side: "w")
  gtree-terminal((1.2,-4.2), payoffs: ([$-1$], [0]))
  gtree-branch((2.5,-2.2), (3.8,-4.2), action: [Accommodate], player: 2, side: "e")
  gtree-terminal((3.8,-4.2), payoffs: ([1], [1]))
  gtree-highlight((0,0), (2.5,-2.2))
  gtree-highlight((2.5,-2.2),(3.8,-4.2))
  gtree-node((0,0), player: 1, label: [Challenger], la: "n")
  gtree-node((2.5,-2.2), player: 2, label: [Incumbent],  la: "e")
}))

== Battle of the Sexes (Simultaneous Moves)

#gtree-player(1)[Player 1] moves first in the tree, but #gtree-player(2)[Player 2] does not observe the move — the two #gtree-player(2)[Player 2] nodes therefore belong to the same information set (dashed line). This makes the game strategically equivalent to its normal form. There are two pure-strategy Nash equilibria: #gtree-payoffs(([2],[1])) and #gtree-payoffs(([1],[2])).

```typst
#cetz.canvas({
  import cetz.draw: *
  gtree-branch((0,0), (-2.8,-2), 
      action: [Opera],
      player: 1, 
      side: "w")
  gtree-branch((0,0), ( 2.8,-2),
      action: [Football],
      player: 1,
      side: "e")
  gtree-infoset((-2.8,-2), (2.8,-2),
      player: 2,
      style: "dashed",
      label: [no observation],
      la: "n")
  gtree-branch((-2.8,-2), (-3.8,-4),
      action: [Opera],
      player: 2,
      side: "w")
  gtree-terminal((-3.8,-4), payoffs: ([2], [1]))
  gtree-branch((-2.8,-2), (-1.8,-4),
      action: [Football], 
      player: 2,
      side: "e")
  gtree-terminal((-1.8,-4), payoffs: ([0], [0]))
  gtree-branch(( 2.8,-2), ( 1.8,-4),
      action: [Opera],
      player: 2,
      side: "w")
  gtree-terminal(( 1.8,-4), payoffs: ([0], [0]))
  gtree-branch(( 2.8,-2), ( 3.8,-4),
      action: [Football],
      player: 2,
      side: "e")
  gtree-terminal(( 3.8,-4), payoffs: ([1], [2]))
  gtree-node((0, 0), player: 1, label: [Player 1], la: "n")
  gtree-node((-2.8,-2), player: 2, label: [Player 2], la: "w")
  gtree-node(( 2.8,-2), player: 2, label: [Player 2], la: "e")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  gtree-branch((0,0), (-2.8,-2), action: [Opera],    player: 1, side: "w")
  gtree-branch((0,0), ( 2.8,-2), action: [Football], player: 1, side: "e")
  gtree-infoset((-2.8,-2), (2.8,-2), player: 2,
    style: "dashed", label: [no observation], la: "n")
  gtree-branch((-2.8,-2), (-3.8,-4), action: [Opera],    player: 2, side: "w")
  gtree-terminal((-3.8,-4), payoffs: ([2], [1]))
  gtree-branch((-2.8,-2), (-1.8,-4), action: [Football], player: 2, side: "e")
  gtree-terminal((-1.8,-4), payoffs: ([0], [0]))
  gtree-branch(( 2.8,-2), ( 1.8,-4), action: [Opera],    player: 2, side: "w")
  gtree-terminal(( 1.8,-4), payoffs: ([0], [0]))
  gtree-branch(( 2.8,-2), ( 3.8,-4), action: [Football], player: 2, side: "e")
  gtree-terminal(( 3.8,-4), payoffs: ([1], [2]))
  gtree-node((0, 0),    player: 1, label: [Player 1], la: "n")
  gtree-node((-2.8,-2), player: 2, label: [Player 2], la: "w")
  gtree-node(( 2.8,-2), player: 2, label: [Player 2], la: "e")
}))

== Adverse Selection with Nature

Nature draws a buyer's valuation: _Low_ ($theta_L$) with probability $1/3$ and _High_ ($theta_H$) with probability $2/3$. Only the buyer observes her type; the seller offers a price $p$ without knowing the realised type. The seller's ignorance is modelled by a bracket-style information set spanning the two buyer nodes.

```typst
#cetz.canvas({
  import cetz.draw: *
  gtree-prob((0,0), (-3,-2), action: [$p = 1/3$], side: "w")
  gtree-prob((0,0), ( 3,-2), action: [$p = 2/3$], side: "e")
  gtree-branch((-3,-2), (-4.2,-4), action: [Buy],  player: 1)
  gtree-terminal((-4.2,-4), payoffs: ([$p - c$], [$theta_L - p$]))
  gtree-branch((-3,-2), (-1.8,-4), action: [Pass], player: 1)
  gtree-terminal((-1.8,-4), payoffs: ([0], [0]))
  gtree-branch(( 3,-2), ( 1.8,-4), action: [Buy],  player: 1)
  gtree-terminal(( 1.8,-4), payoffs: ([$p - c$], [$theta_H - p$]))
  gtree-branch(( 3,-2), ( 4.2,-4), action: [Pass], player: 1)
  gtree-terminal(( 4.2,-4), payoffs: ([0], [0]))
  gtree-infoset((-3,-2), (3,-2), player: 1, style: "bracket")
  gtree-nature((0,0), label: [$cal(N)$], la: "n")
  gtree-node((-3,-2), player: 1, label: [$theta_L$], la: "w")
  gtree-node(( 3,-2), player: 1, label: [$theta_H$], la: "e")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  gtree-prob((0,0), (-3,-2), action: [$p = 1/3$], side: "w")
  gtree-prob((0,0), ( 3,-2), action: [$p = 2/3$], side: "e")
  gtree-branch((-3,-2), (-4.2,-4), action: [Buy],  player: 1)
  gtree-terminal((-4.2,-4), payoffs: ([$p - c$], [$theta_L - p$]))
  gtree-branch((-3,-2), (-1.8,-4), action: [Pass], player: 1)
  gtree-terminal((-1.8,-4), payoffs: ([0], [0]))
  gtree-branch(( 3,-2), ( 1.8,-4), action: [Buy],  player: 1)
  gtree-terminal(( 1.8,-4), payoffs: ([$p - c$], [$theta_H - p$]))
  gtree-branch(( 3,-2), ( 4.2,-4), action: [Pass], player: 1)
  gtree-terminal(( 4.2,-4), payoffs: ([0], [0]))
  gtree-infoset((-3,-2), (3,-2), player: 1, style: "bracket")
  gtree-nature((0,0), label: [$cal(N)$], la: "n")
  gtree-node((-3,-2), player: 1, label: [$theta_L$], la: "w")
  gtree-node(( 3,-2), player: 1, label: [$theta_H$], la: "e")
}))

== Beer–Quiche Signalling Game (Cho–Kreps 1987)

Nature draws the #gtree-player(1)[Sender]'s type: _Strong_ ($S$, probability 0.7) or _Weak_ ($W$, probability 0.3). The Sender signals with _Beer_ (B) or _Quiche_ (Q). The #gtree-player(2)[Receiver] observes the signal but not the type, then chooses _Duel_ (D) or _No Duel_ (N). Two information sets — one bent downward (`angle: -33deg`, bracket style) and one bent upward (`angle: 33deg`, dashed style) — connect nodes reached by the same signal. The unique pooling Perfect Bayesian Equilibrium has both types choose Beer; the Receiver duels after Quiche (off-path belief: Weak). PBNE payoffs: #gtree-payoffs(([3],[1])) for Strong, #gtree-payoffs(([2],[0])) for Weak.

```typst
#cetz.canvas(
    {
    import cetz.draw: *
    gtree-prob((0,0),(-3,0),action: [$p$], 
        side: "w",
        act: 0.3)
    gtree-prob((0,0),(3,0), action: [$1-p$],
        side: "e", 
        act: 0.3,
        apos: 0.3)
    gtree-branch((-3,0),(-3,2), action: [K], side: "w")
    gtree-branch((-3,0),(-3,-2), action: [P], side: "w")
    gtree-branch((3,0),(3,2), action: [K], side: "e")
    gtree-branch((3,0),(3,-2), action: [P], side: "e")
    gtree-infoset((-3,2),(3,2), style: "bracket", 
        label: [Kefir])
    gtree-infoset((-3,-2),(3,-2), style: "bracket", 
        label: [Piwo], 
        la: "n")
    gtree-branch((-3,2),(-5,4), action: [M], side: "e")
    gtree-terminal((-5,4), payoffs: ([3],[0]), la: "n")
    gtree-branch((-3,2),(-1,4), action: [$not$M], side: "w")
    gtree-terminal((-1,4), payoffs: ([1],[1]), la: "n")
    gtree-branch((-3,-2),(-5,-4), action: [M], side: "e")
    gtree-terminal((-5,-4), payoffs: ([2],[0]), la: "s")
    gtree-branch((-3,-2),(-1,-4), action: [$not$M], side: "w")
    gtree-terminal((-1,-4), payoffs: ([0],[1]), la: "s")
    gtree-branch((3,2),(5,4), action: [M], side: "w")
    gtree-terminal((5,4), payoffs: ([3],[0]), la: "n")
    gtree-branch((3,2),(1,4), action: [$not$M], side: "e")
    gtree-terminal((1,4), payoffs: ([1],[1]), la: "n")
    gtree-branch((3,-2),(5,-4), action: [M], side: "w")
    gtree-terminal((5,-4), payoffs: ([2],[0]), la: "s")
    gtree-branch((3,-2),(1,-4), action: [$not$M], side: "e")
    gtree-terminal((1,-4), payoffs: ([0],[1]), la: "s")    
    gtree-nature((0,0), label: [$cal(N)$], la: "n")
    gtree-node((-3,0), label: [S], la: "w")
    gtree-node((3,0), label: [N], la: "e")
    gtree-node((-3,2), label: [B], player: 2, la: "w")
    gtree-node((-3,-2), label: [B], player: 2, la: "w")
    gtree-node((3,2), label: [B], player: 2, la: "e")
    gtree-node((3,-2), label: [B], player: 2, la: "e")  
    }
  )
```

#align(center)[
#cetz.canvas(
    {
    import cetz.draw: *
    gtree-prob((0,0),(-3,0),action: [$p$], 
        side: "w",
        act: 0.3)
    gtree-prob((0,0),(3,0), action: [$1-p$],
        side: "e", 
        act: 0.3,
        apos: 0.3)
    gtree-branch((-3,0),(-3,2), action: [K], side: "w")
    gtree-branch((-3,0),(-3,-2), action: [P], side: "w")
    gtree-branch((3,0),(3,2), action: [K], side: "e")
    gtree-branch((3,0),(3,-2), action: [P], side: "e")
    gtree-infoset((-3,2),(3,2), style: "bracket", 
        label: [Kefir])
    gtree-infoset((-3,-2),(3,-2), style: "bracket", 
        label: [Piwo], 
        la: "n")
    gtree-branch((-3,2),(-5,4), action: [M], side: "e")
    gtree-terminal((-5,4), payoffs: ([3],[0]), la: "n")
    gtree-branch((-3,2),(-1,4), action: [$not$M], side: "w")
    gtree-terminal((-1,4), payoffs: ([1],[1]), la: "n")
    gtree-branch((-3,-2),(-5,-4), action: [M], side: "e")
    gtree-terminal((-5,-4), payoffs: ([2],[0]), la: "s")
    gtree-branch((-3,-2),(-1,-4), action: [$not$M], side: "w")
    gtree-terminal((-1,-4), payoffs: ([0],[1]), la: "s")
    gtree-branch((3,2),(5,4), action: [M], side: "w")
    gtree-terminal((5,4), payoffs: ([3],[0]), la: "n")
    gtree-branch((3,2),(1,4), action: [$not$M], side: "e")
    gtree-terminal((1,4), payoffs: ([1],[1]), la: "n")
    gtree-branch((3,-2),(5,-4), action: [M], side: "w")
    gtree-terminal((5,-4), payoffs: ([2],[0]), la: "s")
    gtree-branch((3,-2),(1,-4), action: [$not$M], side: "e")
    gtree-terminal((1,-4), payoffs: ([0],[1]), la: "s")    
    gtree-nature((0,0), label: [$cal(N)$], la: "n")
    gtree-node((-3,0), label: [S], la: "w")
    gtree-node((3,0), label: [N], la: "e")
    gtree-node((-3,2), label: [B], player: 2, la: "w")
    gtree-node((-3,-2), label: [B], player: 2, la: "w")
    gtree-node((3,2), label: [B], player: 2, la: "e")
    gtree-node((3,-2), label: [B], player: 2, la: "e")  
    }
  )
]

= Annotations

== Equilibrium Highlights: `gtree-highlight`

`gtree-highlight` draws a bold coloured line over an existing branch to mark the equilibrium path. It is shortened by `gtree-R` at each end so the highlight does not overlap the node circles. Call it _after_ the branches but _before_ the nodes so the nodes remain on top.

```typst
#cetz.canvas({
  import cetz.draw: *
  gtree-branch((0,0), (-1.5,-2), action: [L], player: 1, side: "w")
  gtree-branch((0,0), ( 1.5,-2), action: [R], player: 1, side: "e")
  // Highlight the right branch in player 1's colour
  gtree-highlight((0,0), (1.5,-2), color: gtree-pal.at(0))
  gtree-node((0,0), player: 1)
  gtree-terminal((-1.5,-2), payoffs: ([0],[1]))
  gtree-terminal(( 1.5,-2), payoffs: ([2],[0]))
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  gtree-branch((0,0), (-1.5,-2), action: [L], player: 1, side: "w")
  gtree-branch((0,0), ( 1.5,-2), action: [R], player: 1, side: "e")
  gtree-highlight((0,0), (1.5,-2), color: gtree-pal.at(0))
  gtree-node((0,0), player: 1)
  gtree-terminal((-1.5,-2), payoffs: ([0],[1]))
  gtree-terminal(( 1.5,-2), payoffs: ([2],[0]))
}))

== Proper-Subgame Markers: `gtree-subgame`

`gtree-subgame` draws a dotted, lightly shaded triangle with its apex at the subgame root. `depth` controls the height of the triangle and `width` its half-base width. An optional `label` is placed inside at roughly 42% of the height from the base.

```typst
#cetz.canvas({
  import cetz.draw: *
  gtree-branch((0,0), (-1.5,-1), action: [L], player: 1, side: "w")
  gtree-branch((0,0), ( 1.5,-1), action: [R], player: 1, side: "e")
  gtree-subgame((-1.5,-1), depth: 1.5, width: 0.7, label: [$G_L$])
  gtree-subgame(( 1.5,-1), depth: 1.5, width: 0.7, label: [$G_R$])
  gtree-node((0,0), player: 1, label: [P1], la: "n")
})
```

#align(center, cetz.canvas({
  import cetz.draw: *
  gtree-branch((0,0), (-1.5,-1), action: [L], player: 1, side: "w")
  gtree-branch((0,0), ( 1.5,-1), action: [R], player: 1, side: "e")
  gtree-subgame((-1.5,-1), depth: 1.5, width: 0.7, label: [$G_L$])
  gtree-subgame(( 1.5,-1), depth: 1.5, width: 0.7, label: [$G_R$])
  gtree-node((0,0), player: 1, label: [P1], la: "n")
}))


= Inline Text Helpers

== Coloured Payoff Vectors: `gtree-payoffs`

`gtree-payoffs` typesets a payoff vector in body text or captions, colouring each entry in that player's colour. It returns ordinary Typst content and can be used anywhere — inside and outside `cetz.canvas` alike.

```typst
The unique NE payoff vector is #gtree-payoffs(([2], [1])).

In math: $u = #gtree-payoffs(([$a - c$], [$b$]), parens: false)$.
```

The unique NE payoff vector is #gtree-payoffs(([2], [1])).

In math: $u = #gtree-payoffs(([$a - c$], [$b$]), parens: false)$.

== Player Names in Colour: `gtree-player` and `gtree-player-default`

`gtree-player(n)[label]` typesets arbitrary content in player $n$'s colour (bold). `gtree-player-default(n)` is a shortcut that produces "Player $n$" without requiring a label argument.

```typst
#gtree-player(1)[Challenger] moves first;
#gtree-player(2)[Incumbent] responds.
Payoffs: #gtree-payoffs(([1], [1])).
Both players are #gtree-player-default(1) and #gtree-player-default(2).
```

#gtree-player(1)[Challenger] moves first; #gtree-player(2)[Incumbent] responds.
Payoffs: #gtree-payoffs(([1], [1])).
Both players are #gtree-player-default(1) and #gtree-player-default(2).


= Global Configuration <sec-config>

All geometric and typographic constants are ordinary `let` bindings. Override them by redefining the binding _after_ importing the library:

```typst
#import "pi-game-trees.typ": *
#let gtree-R     = 0.15   // larger decision nodes
#let gtree-Rt    = 0.08   // smaller terminal dots
#let gtree-act   = 0.3    // more space for action labels
#let gtree-fsl   = 10pt   // smaller player-label font
#let gtree-pal   = (      // custom player colours
  rgb("#005f73"), rgb("#94d2bd"), rgb("#e9d8a6"),
  rgb("#ee9b00"), rgb("#ae2012"),
)
```

The full list of configuration bindings and their defaults is given in the API Reference below.

#table(
  columns: (auto, auto, 2fr),
  table.header([Name], [Default], [Role]),
  [`gtree-pal`],          [5-colour list],  [Player colours (index 0 = Player 1).],
  [`gtree-nature-color`], [`rgb("#666666")`],[Nature / chance node colour.],
  [`gtree-fg`],           [`rgb("#111111")`],[Branch lines, terminal dots, payoff punctuation.],
  [`gtree-R`],            [`0.1` cm],       [Decision node radius.],
  [`gtree-Rt`],           [`0.1` cm],       [Terminal dot radius.],
  [`gtree-gap`],          [`0.2` cm],       [Node edge to label gap.],
  [`gtree-act`],          [`0.2` cm],       [Branch-line to action-label offset.],
  [`gtree-apos`],         [`0.5`],          [Fractional label position along branch.],
  [`gtree-tick`],         [`0.20` cm],      [Bracket tick half-length.],
  [`gtree-sw-b`],         [`1pt`],          [Branch stroke width.],
  [`gtree-sw-n`],         [`1pt`],          [Decision-node stroke width.],
  [`gtree-sw-ni`],        [`1pt`],          [Nature-node stroke width.],
  [`gtree-sw-i`],         [`1pt`],          [Information-set stroke width.],
  [`gtree-sw-h`],         [`2pt`],          [Highlight stroke width.],
  [`gtree-fsl`],          [`11pt`],         [Player / node label font size.],
  [`gtree-fsa`],          [`11pt`],         [Action label font size.],
  [`gtree-fsp`],          [`11pt`],         [Payoff label font size.],
)

#set heading(numbering: none)
= API Reference

#let docs = tidy.parse-module(read("pi-game-trees.typ"), name: none)
#tidy.show-module(docs)
