#import "@preview/tidy:0.4.3"
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "pi-games.typ": *

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
#set par(first-line-indent: 0pt, justify: true)
#set page(numbering: "1")
#set document(
  title: [pi-games: Normal-Form Games in Typst],
  author: "Piotr Kuszewski",
)

#align(center)[
  #v(1em)
  #text(weight: "bold", size: 20pt)[$pi$-games: Normal-Form Games in Typst]
  #v(0.5em)
  Piotr Kuszewski #h(2em) April 2026
  #v(1em)
]

= Introduction

The `pi-games` library provides two Typst functions for typesetting _normal-form_ (strategic-form) games of the kind common in game theory courses and research:

/ `normal-form-game`: draws a two-player N×M payoff matrix. Each cell displays both players' payoffs separated by a comma, coloured by player.
/ `three-player-normal-form-game`: draws a three-player game as a collection of N×M matrices — one per strategy of Player 3 — laid out in rows.

Both functions are built on the `@preview/cetz` drawing package. They measure content at layout time and automatically size each cell to fit its widest payoff expression or strategy label, so the typesetter never needs to specify column widths by hand.

Import the library at the top of your document:

```typst
#import "pi-games.typ": *
```

= `normal-form-game`

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

+ *`cell_width`*: the user-supplied lower bound (default `5em`).
+ *Strategy-label width*: the rendered width of the widest Player 2 strategy label plus `2em` of horizontal padding. This ensures each column is never narrower than its header.
+ *Payoff width*: the rendered width of the widest payoff pair `v1, v2` — including best-response underlines where active — plus `2em` of padding.

The measurement happens inside a `context` block, so it uses the exact font metrics of every piece of content, including mathematical formulas of arbitrary complexity. The *left margin* (Player 1 strategy labels and rotated player name) is auto-sized to the widest Player 1 label; the *top margin* (Player 2 strategy labels and player name) is auto-sized to the tallest Player 2 label. *Cell height* is fixed at `cell_height` (default `2em`) and is not auto-sized, since all payoff content is placed on a single line.

== Best Responses and Nash Equilibria

- *`p1-best` / `p2-best`*: arrays of `(row, col)` tuples. In each listed cell the respective player's payoff is underlined with a 1 pt stroke in their colour.
- *`nash`*: array of `(row, col)` tuples. A coloured rectangle (`nash-color`, default `teal`) is drawn just inside the cell border.

Both underlines and Nash rectangles are taken into account when auto-sizing, so highlighting never causes payoffs to overflow their cells.

== Examples

=== Prisoner's Dilemma

The Prisoner's Dilemma is the textbook example of a dominant-strategy equilibrium. Defection strictly dominates Cooperation for both players, so $(D,D)$ is the unique Nash equilibrium even though $(C,C)$ Pareto-dominates it.

```typst
#normal-form-game(
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

#align(center, normal-form-game(
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
#normal-form-game(
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

#align(center, normal-form-game(
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
#normal-form-game(
  [P1], [P2],
  ([H #h(1mm) $[p]$],     [T #h(1mm) $[1-p]$]),
  ([H $[q]$], [T $[1-q]$]),
  (
    (([$1$], [$-1$]), ([$-1$], [$1$])),
    (([$-1$], [$1$]), ([$1$], [$-1$])),
  ),
)
```

#align(center, normal-form-game(
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
#normal-form-game(
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

#align(center, normal-form-game(
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

= `three-player-normal-form-game`

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
#three-player-normal-form-game(
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

#align(center, three-player-normal-form-game(
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

= API Reference

#let docs = tidy.parse-module(read("pi-games.typ"), name: none)
#tidy.show-module(docs)
