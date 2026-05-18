// pi-game-trees-example.typ  —  Demonstration of extensive-form game tree macros
// Place pi-game-trees.typ in the same folder and compile with:
//   typst compile pi-game-trees-example.typ

#import "@preview/cetz:0.5.2" as cetz
#import "pi-game-trees.typ": *

// Better looking tables
#show table.cell.where(y: 0): set text(weight: "bold")
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

#set page(numbering: "1")
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true)

= `pi-game-trees.typ` — Extensive-Form Game Trees in CeTZ

This document demonstrates the `pi-game-trees.typ` macro library for drawing
extensive-form game trees in Typst using CeTZ 0.5.2.  The visual design
follows the conventions of the _xgames_ LaTeX package: each player's
name, action labels, and payoffs are rendered in a dedicated colour for
clarity.  Unlike xgames, the syntax conforms strictly to Typst and CeTZ
conventions.

*Player colours:*\
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

== Example 1 — Entry Deterrence (Sequential, Perfect Information)

A #gtree-player(1)[Challenger] decides whether to enter a market.
If she enters, the #gtree-player(2)[Incumbent] either _fights_ or
_accommodates_.  The unique SPNE survives backward induction: the Challenger
enters, the Incumbent accommodates, yielding payoffs
#gtree-payoffs(([1], [1])).

#figure(
  cetz.canvas({
    import cetz.draw: *

    // Left child: "Out" — terminal immediately
    gtree-branch((0,0), (-2.5,-2.2), action: [Out], player: 1, side: "w")
    gtree-terminal((-2.5,-2.2), payoffs: ([0], [2]), la: "s")

    // Right child: "In" — leads to Incumbent
    gtree-branch((0,0), (2.5,-2.2), action: [In], player: 1, side: "e")

    // Incumbent's children
    gtree-branch((2.5,-2.2), (1.2,-4.2), action: [Fight], player: 2, side: "w")
    gtree-terminal((1.2,-4.2), payoffs: ([$-1$], [0]))

    gtree-branch((2.5,-2.2), (3.8,-4.2), action: [Accommodate], player: 2, side: "e")
    gtree-terminal((3.8,-4.2), payoffs: ([1], [1]))

    // ── Highlight SPNE path ────────────────────────────────────
    gtree-highlight((0,0),    (2.5,-2.2))
    gtree-highlight((2.5,-2.2),(3.8,-4.2))

    // ── Nodes ──────────────────────────────────────────────────
    gtree-node((0, 0), player: 1, label: [Challenger], la: "n")
    gtree-node((2.5,-2.2), player: 2, label: [Incumbent], la: "e")
  }),
  caption: [Entry Deterrence — the bold path is the SPNE.]
)

The highlighted branches show the backward-induction equilibrium:
#gtree-player(2)[Incumbent] prefers to accommodate
(payoff $1 > 0$), so #gtree-player(1)[Challenger] enters.

== Example 2 — Battle of the Sexes (Simultaneous Moves)

#gtree-player(1)[Player 1] moves first in the tree, but
#gtree-player(2)[Player 2] does not observe the move — hence
the two #gtree-player(2)[Player 2] nodes belong to the same
*information set* (dashed line).  This makes the game strategically
equivalent to its normal form.

#figure(
  cetz.canvas({
    import cetz.draw: *

    // ── Player 1 branches ─────────────────────────────────────
    gtree-branch((0,0), (-2.8,-2), action: [Opera], player: 1, side: "w")
    gtree-branch((0,0), (2.8,-2), action: [Football], player: 1, side: "e")

    // Information set: Player 2 cannot distinguish the two nodes
    gtree-infoset((-2.8,-2), (2.8,-2), player: 2, style: "dashed", label: [no observation], la: "n")

    // ── Player 2 branches — left node ─────────────────────────
    gtree-branch((-2.8,-2), (-3.8,-4), action: [Opera], player: 2, side: "w")
    gtree-terminal((-3.8,-4), payoffs: ([2], [1]))

    gtree-branch((-2.8,-2), (-1.8,-4), action: [Football], player: 2, side: "e")
    gtree-terminal((-1.8,-4), payoffs: ([0], [0]))

    // ── Player 2 branches — right node ────────────────────────
    gtree-branch((2.8,-2), (1.8,-4), action: [Opera], player: 2, side: "w")
    gtree-terminal((1.8,-4), payoffs: ([0], [0]))

    gtree-branch((2.8,-2), (3.8,-4), action: [Football], player: 2, side: "e")
    gtree-terminal((3.8,-4), payoffs: ([1], [2]))

    // ── Player 2 nodes (in the same information set) ──────────
    gtree-node((-2.8,-2), player: 2, label: [Player 2], la: "w",
      name: "p2l")
    gtree-node(( 2.8,-2), player: 2, label: [Player 2], la: "e",
      name: "p2r")
     // ── Root ───────────────────────────────────────────────────
    gtree-node((0,0), player: 1, label: [Player 1], la: "n")
  }),
  caption: [
    Battle of the Sexes — extensive form with information set.
    Two pure-strategy NE: #gtree-payoffs(([2],[1])) and #gtree-payoffs(([1],[2])).
  ]
)

== Example 3 — Adverse Selection with Nature

*Nature* draws a buyer's valuation: _Low_ ($theta_L$) with probability
$1/3$ and _High_ ($theta_H$) with probability $2/3$.
Only the buyer observes her type; the seller offers a price $p$.

#figure(
  cetz.canvas({
    import cetz.draw: *

    // ── Nature branches (with probability labels) ─────────────
    gtree-prob((0,0), (-3,-2.0), action: [$p = 1/3$], side: "w")
    gtree-prob((0,0), ( 3,-2.0), action: [$p = 2/3$], side: "e")

    // ── Buyer's actions — Low type ────────────────────────────
    gtree-branch((-3,-2.0), (-4.2,-4.0), action: [Buy],  player: 1)
    gtree-terminal((-4.2,-4.0), payoffs: ([$p-c$], [$theta_L - p$]))

    gtree-branch((-3,-2.0), (-1.8,-4.0), action: [Pass], player: 1)
    gtree-terminal((-1.8,-4.0), payoffs: ([0], [0]))

    // ── Buyer's actions — High type ───────────────────────────
    gtree-branch((3,-2.0), (1.8,-4.0), action: [Buy],  player: 1)
    gtree-terminal((1.8,-4.0), payoffs: ([$p - c$], [$theta_H - p$]))

    gtree-branch((3,-2.0), (4.2,-4.0), action: [Pass], player: 1)
    gtree-terminal((4.2,-4.0), payoffs: ([0], [0]))

    // ── Seller does not observe type: info set on buyer nodes ──
    // (Seller chooses p before knowing type; here shown
    //  to illustrate bracket-style information sets)
    gtree-infoset((-3,-2.0), (3,-2.0), player: 1, style: "bracket")

    // ── Nature node ───────────────────────────────────────────
    gtree-nature((0,0), label: [$cal(N)$], la: "n", name: "nat")
     // ── Type labels at child nodes ────────────────────────────
    gtree-node((-3,-2.0), player: 1, label: [$theta_L$], la: "w")
    gtree-node(( 3,-2.0), player: 1, label: [$theta_H$], la: "e")
  }),
  caption: [
    Adverse selection — Nature draws the buyer's type;
    bracket-style information set on the two buyer nodes.
  ]
)

#figure(
  cetz.canvas({
    import cetz.draw: *

    // ── Nature branches (with probability labels) ─────────────
    gtree-prob((0,0), (-3,-2.0), action: [$p = 1/3$], side: "w")
    gtree-prob((0,0), ( 3,-4.0), action: [$p = 2/3$], side: "e")

    // ── Buyer's actions — Low type ────────────────────────────
    gtree-branch((-3,-2.0), (-4.2,-4.0), action: [Buy],  player: 1)
    gtree-terminal((-4.2,-4.0), payoffs: ([$p-c$], [$theta_L - p$]))

    gtree-branch((-3,-2.0), (-1.8,-4.0), action: [Pass], player: 1)
    gtree-terminal((-1.8,-4.0), payoffs: ([0], [0]))

    // ── Buyer's actions — High type ───────────────────────────
    gtree-branch((3,-4.0), (1.8,-6.0), action: [Buy],  player: 1)
    gtree-terminal((1.8,-6.0), payoffs: ([$p - c$], [$theta_H - p$]))

    gtree-branch((3,-4.0), (4.2,-6.0), action: [Pass], player: 1)
    gtree-terminal((4.2,-6.0), payoffs: ([0], [0]))

    // ── Seller does not observe type: info set on buyer nodes ──
    // (Seller chooses p before knowing type; here shown
    //  to illustrate bracket-style information sets)
    gtree-infoset((-3,-2.0), (3,-4.0), player: 1, style: "bracket", angle: 20deg)

    // ── Nature node ───────────────────────────────────────────
    gtree-nature((0,0), label: [$cal(N)$], la: "n", name: "nat")
     // ── Type labels at child nodes ────────────────────────────
    gtree-node((-3,-2.0), player: 1, label: [$theta_L$], la: "w")
    gtree-node(( 3,-4.0), player: 1, label: [$theta_H$], la: "e")
  }),
  caption: [
    Adverse selection — Nature draws the buyer's type;
    bracket-style information set on the two buyer nodes.
  ]
)

== Example 4 — Beer–Quiche Signalling Game

The classic Cho–Kreps (1987) signalling game.
*Nature* draws the #gtree-player(1)[Sender]'s type: _Strong_ ($S$,
probability $0.7$) or _Weak_ ($W$, probability $0.3$).
The Sender signals by choosing _Beer_ (B) or _Quiche_ (Q).
The #gtree-player(2)[Receiver] observes the signal but not the
type, then chooses _Fight_ (F) or _Not Fight_ ($not$F).
Two information sets link nodes reached by the same signal.

#figure(
  cetz.canvas(
    {
    import cetz.draw: *
    gtree-prob((0,0),(-3,0),action: [$p$], 
        side: "w",
        act: 0.3)
    gtree-prob((0,0),(3,0), action: [$1-p$],
        side: "e", 
        act: 0.3,
        apos: 0.3)
    gtree-branch((-3,0),(-3,2), action: [Q], side: "w")
    gtree-branch((-3,0),(-3,-2), action: [B], side: "w")
    gtree-branch((3,0),(3,2), action: [Q], side: "e")
    gtree-branch((3,0),(3,-2), action: [B], side: "e")
    gtree-infoset((-3,2),(3,2), 
        style: "bracket", 
        label: [Quiche])
    gtree-infoset((-3,-2),(3,-2), 
        style: "bracket", 
        label: [Beer], 
        la: "n")
    gtree-branch((-3,2),(-5,4), action: [F], side: "e")
    gtree-terminal((-5,4), payoffs: ([3],[0]), la: "n")
    gtree-branch((-3,2),(-1,4), action: [$not$F], side: "w")
    gtree-terminal((-1,4), payoffs: ([1],[1]), la: "n")
    gtree-branch((-3,-2),(-5,-4), action: [F], side: "e")
    gtree-terminal((-5,-4), payoffs: ([2],[0]), la: "s")
    gtree-branch((-3,-2),(-1,-4), action: [$not$F], side: "w")
    gtree-terminal((-1,-4), payoffs: ([0],[1]), la: "s")
    gtree-branch((3,2),(5,4), action: [F], side: "w")
    gtree-terminal((5,4), payoffs: ([3],[0]), la: "n")
    gtree-branch((3,2),(1,4), action: [$not$F], side: "e")
    gtree-terminal((1,4), payoffs: ([1],[1]), la: "n")
    gtree-branch((3,-2),(5,-4), action: [F], side: "w")
    gtree-terminal((5,-4), payoffs: ([2],[0]), la: "s")
    gtree-branch((3,-2),(1,-4), action: [$not$F], side: "e")
    gtree-terminal((1,-4), payoffs: ([0],[1]), la: "s")    
    gtree-nature((0,0), label: [$cal(N)$], la: "n")
    gtree-node((-3,0), label: [W], la: "w")
    gtree-node((3,0), label: [S], la: "e")
    gtree-node((-3,2), label: [B], player: 2, la: "w")
    gtree-node((-3,-2), label: [B], player: 2, la: "w")
    gtree-node((3,2), label: [B], player: 2, la: "e")
    gtree-node((3,-2), label: [B], player: 2, la: "e")  
    }
  ),
  caption: [Beer–Quiche signalling game (Cho–Kreps 1987).  Payoffs: (Sender, Receiver).],
) <fig-beer-quiche-3>


The unique *pooling* Perfect Bayesian Equilibrium has both types choose
Beer; the Receiver duels after Quiche (off-path belief: Weak).  The
PBNE payoffs are #gtree-payoffs(([3],[1])) for Strong and
#gtree-payoffs(([2],[0])) for Weak.

== Macro Reference

=== Nodes

#table(
  columns: (1fr, 2fr),
  table.header([Macro], [Description]),
  [`gtree-node(pos, player:, label:, la:, name:, style:)`],
    [Decision node. `style`: `"filled"` (default), `"open"`, `"dot"`.],
  [`gtree-nature(pos, label:, la:, name:)`],
    [Nature/chance node (grey, lightly shaded). Default label $N$.],
  [`gtree-terminal(pos, payoffs:, la:, parens:)`],
    [Terminal dot + coloured payoff vector.],
)

=== Branches

#table(
  columns: (1fr, 2fr),
  table.header([Macro], [Description]),
  [`gtree-branch(from, to, action:, player:, side:, act:, apos:, arrow:)`],
    [Edge with optional action label. Default: label centred on the line (white background). `side: "e"` / `"w"` offsets the label to the east/west side; `act:` sets the real perpendicular distance (default `gtree-act`).],
  [`gtree-prob(from, to, action:, side:, act:, apos:, arrow:)`],
    [Edge with probability label in Nature's grey colour.],
  [`gtree-highlight(from, to, color:, width:)`],
    [Bold coloured overlay to mark an equilibrium path.],
)

=== Information Sets & Subgames

#table(
  columns: (1fr, 2fr),
  table.header([Macro], [Description]),
  [`gtree-infoset(pos1, pos2, player:, style:, label:, la:)`],
    [`style: "dashed"` (default) or `"bracket"`.],
  [`gtree-subgame(apex, depth:, width:, label:)`],
    [Dotted triangle proper-subgame marker.],
)

=== Text Helpers

#table(
  columns: (1fr, 2fr),
  table.header([Macro], [Description]),
  [`gtree-payoffs(payoffs, parens:)`],
    [Inline coloured payoff vector for body text.],
  [`gtree-player(player)[label]`],
    [Player name (or custom label) in that player's colour.],
)

=== Geometry & Style Overrides

To override defaults, redefine the `let` bindings *after* importing:

```typst
#import "pi-game-trees.typ": *
#let gtree-R     = 0.18   // larger nodes
#let gtree-fsl   = 9pt    // bigger player labels
#let gtree-pal   = (      // custom colours
  rgb("#005f73"), rgb("#94d2bd"), rgb("#e9d8a6"), …
)
```

=== Coordinate Convention

Trees grow *downward*: root at $y = 0$, leaves at $y < 0$.
Typical level spacing: $Delta y approx -1.8 "cm"$; sibling spacing:
$Delta x approx 1.5 "cm"$ per level of the tree.

For horizontal trees (growing rightward), rotate the coordinate system
— set $y$-differences to $0$ and vary $x$, then use `la: "n"` or `la: "s"`
for action labels instead of `"l"` / `"r"`.
