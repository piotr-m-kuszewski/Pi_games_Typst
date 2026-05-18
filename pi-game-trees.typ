// pi-game-trees.typ — Extensive-form game tree macros for CeTZ 0.5.2
// SGH Warsaw School of Economics · dr Piotr Kuszewski
//
// Inspired by the xgames LaTeX package (B. Bernard, 2025).
//
// Quick start:
//   #import "pi-game-trees.typ": *
//   cetz.canvas({
//     import cetz.draw: *
//     gtree-node((0,0), player: 1, label: [Player 1])
//     gtree-branch((0,0), (-1.5,-2), action: [Left], player: 1, side: "w")
//     gtree-terminal((-1.5,-2), payoffs: ([2],[3]))
//   })

#import "@preview/cetz:0.5.2" as cetz
#import "pi-game-palette.typ": *

// ── Colour palette ────────────────────────────────────────────────

/// Per-player colour palette. Index 0 = Player 1, index 4 = Player 5.
/// Defaults to `pi-player-colors` from `pi-game-palette`.
/// Override after import: `#let gtree-pal = (rgb("…"), …)`.
#let gtree-pal = pi-player-colors

/// Colour for Nature / chance nodes and probability labels.
/// Defaults to `pi-nature-color` from `pi-game-palette`.
/// Override after import: `#let gtree-nature-color = rgb("…")`.
#let gtree-nature-color = pi-nature-color

/// Foreground colour for branches, terminal dots, and payoff punctuation.
/// Defaults to `pi-fg` from `pi-game-palette`.
/// Override after import: `#let gtree-fg = rgb("…")`.
#let gtree-fg = pi-fg

// ── Geometry and typography defaults ─────────────────────────────

/// Radius of decision nodes [cm].
#let gtree-R      = 0.1
/// Radius of terminal filled-dot nodes [cm].
#let gtree-Rt     = 0.1
/// Gap between node edge and adjacent player/payoff label [cm].
#let gtree-gap    = 0.2
/// Default perpendicular distance from a branch line to an action label [cm].
#let gtree-act    = 0.2
/// Default fractional position of an action label along a branch (0 = parent, 1 = child).
#let gtree-apos   = 0.5
/// Half-length of the bracket tick marks at information-set endpoints [cm].
#let gtree-tick   = 0.20

/// Stroke width for ordinary branches.
#let gtree-sw-b   = 1pt
/// Stroke width for decision-node outlines.
#let gtree-sw-n   = 1pt
/// Stroke width for nature-node outlines.
#let gtree-sw-ni  = 1pt
/// Stroke width for information-set lines.
#let gtree-sw-i   = 1pt
/// Stroke width for highlight overlays.
#let gtree-sw-h   = 2pt

/// Font size for player and node labels.
#let gtree-fsl    = 11pt
/// Font size for action labels.
#let gtree-fsa    = 11pt
/// Font size for payoff labels.
#let gtree-fsp    = 11pt

// ── Internal helpers (private, prefix _g) ─────────────────────────

// Player index → colour; 0 = Nature.
#let _gc(p) = {
  if p == 0 { gtree-nature-color }
  else { gtree-pal.at(calc.min(p, gtree-pal.len()) - 1) }
}

// Direction abbreviation → unit vector (CeTZ: y-axis points up).
#let _gD = (
  "n":  ( 0,       1      ),  "s":  ( 0,      -1      ),
  "e":  ( 1,       0      ),  "w":  (-1,       0      ),
  "ne": ( 0.7071,  0.7071 ),  "nw": (-0.7071,  0.7071 ),
  "se": ( 0.7071, -0.7071 ),  "sw": (-0.7071, -0.7071 ),
)

// Direction → opposing CeTZ content anchor (label floats away from the node).
#let _gA = (
  "n":  "south",      "s":  "north",
  "e":  "west",       "w":  "east",
  "ne": "south-west", "nw": "south-east",
  "se": "north-west", "sw": "north-east",
)

// 2D vector arithmetic.
#let _vs(a, b)   = (a.at(0) - b.at(0),  a.at(1) - b.at(1))
#let _va(a, b)   = (a.at(0) + b.at(0),  a.at(1) + b.at(1))
#let _vm(v, s)   = (v.at(0) * s,         v.at(1) * s)
#let _vn(v) = {
  let l = calc.sqrt(v.at(0)*v.at(0) + v.at(1)*v.at(1))
  if l < 1e-9 { (1, 0) } else { (v.at(0)/l, v.at(1)/l) }
}
// Left perpendicular: CCW 90°  (-y, x).
#let _vpl(v)  = (-v.at(1),  v.at(0))
// Right perpendicular: CW 90°  ( y, -x).
#let _vpr(v)  = ( v.at(1), -v.at(0))

// Best CeTZ content anchor for a vector direction v.
#let _gvanch(v) = {
  if calc.abs(v.at(0)) >= calc.abs(v.at(1)) {
    if v.at(0) > 0 { "west" } else { "east" }
  } else {
    if v.at(1) > 0 { "south" } else { "north" }
  }
}

// Return `(name: n)` dict when n is not none; else empty dict.
#let _gname(n) = if n != none { (name: n) } else { (:) }


// ── gtree-node ────────────────────────────────────────────────────
/// Draw a decision (non-terminal) node for a given player.
#let gtree-node(
  /// Node centre as a CeTZ coordinate pair `(x, y)`. -> array
  pos,
  /// Player index. `1`–`5` use the corresponding colour from
  /// `gtree-pal`; `0` uses `gtree-nature-color` (grey). Default: `1`. -> int
  player: 1,
  /// Player name or label placed near the node. Pass `none` to suppress. -> content
  label:  none,
  /// Direction for the label offset from the node centre. 
  /// One of `"n"`, `"s"`, `"e"`, `"w"`, `"ne"`, `"nw"`, `"se"`, `"sw"`. -> str
  la:     "n",
  /// CeTZ coordinate name assigned to this node for later
  /// reference (e.g. in `gtree-infoset`). Pass `none` to skip. -> str
  name:   none,
  /// Visual style of the node circle.
  ///   `"filled"` — solid filled circle (default);
  ///   `"open"` — hollow circle with coloured outline;
  ///   `"dot"` — small solid disc for compact trees. -> str
  style:  "filled",
) = {
  import cetz.draw: *
  let col  = _gc(player)
  let r    = if style == "dot" { 0.07 } else { gtree-R }
  let fill = if style == "filled" { col }
            else if style == "dot" { col }
            else { white }

  circle(pos, radius: r, fill: fill,
    stroke: if style == "dot" { none }
            else { (paint: col, thickness: gtree-sw-n) },
    .._gname(name),
  )

  if label != none {
    let dv = _gD.at(la, default: (0, 1))
    let lp = _va(pos, _vm(dv, r + gtree-gap))
    content(lp,
      text(fill: col, weight: "bold", size: gtree-fsl, label),
      anchor: _gA.at(la, default: "south"),
    )
  }
}


// ── gtree-nature ──────────────────────────────────────────────────
/// Draw a Nature / chance node (grey filled circle).
#let gtree-nature(
  /// Node centre as a CeTZ coordinate pair `(x, y)`. -> array
  pos,
  /// Label placed near the node. Pass `none` to suppress. Default: `$N$`. -> content
  label: [$N$],
  /// Direction for the label offset from the node centre.
  /// One of `"n"`, `"s"`, `"e"`, `"w"`, `"ne"`, `"nw"`, `"se"`, `"sw"`. Default: `"n"`. -> str
  la:    "n",
  /// CeTZ coordinate name for this node. Pass `none` to skip. Default: `none`. -> str
  name:  none,
) = {
  import cetz.draw: *
  let col = gtree-nature-color
  circle(pos, radius: gtree-R,
    fill:   col,
    stroke: (paint: col, thickness: gtree-sw-ni),
    .._gname(name),
  )
  if label != none {
    let dv = _gD.at(la, default: (0, 1))
    let lp = _va(pos, _vm(dv, gtree-R + gtree-gap))
    content(lp,
      text(fill: col, weight: "bold", size: gtree-fsl, label),
      anchor: _gA.at(la, default: "south"),
    )
  }
}


// ── gtree-terminal ────────────────────────────────────────────────
/// Draw a terminal node (small filled dot) with a coloured payoff vector.
#let gtree-terminal(
  /// Node centre as a CeTZ coordinate pair `(x, y)`. -> array
  pos,
  /// Array of content, one element per player, e.g. `([2], [3])` or `([$p-c$], [$v-p$])`.
  /// Pass `none` or an empty array to draw only the dot. Default: `none`. -> array
  payoffs: none,
  /// Direction for the payoff label.
  /// One of `"n"`, `"s"`, `"e"`, `"w"`, `"ne"`, `"nw"`, `"se"`, `"sw"`. Default: `"s"`. -> str
  la:      "s",
  /// Wrap the payoff vector in parentheses. Default: `true`. -> bool
  parens:  true,
) = {
  import cetz.draw: *

  circle(pos, radius: gtree-Rt, stroke: none, fill: gtree-fg)

  if payoffs != none and payoffs.len() > 0 {
    let sep   = text(fill: gtree-fg, size: gtree-fsp, [,#h(0.5pt)])
    let items = payoffs.enumerate().map(((i, v)) =>
      text(fill: _gc(i + 1), size: gtree-fsp, v)
    )
    let inner = items.join(sep)
    let lbl   = if parens {
      text(fill: gtree-fg, size: gtree-fsp, "(") + inner + text(fill: gtree-fg, size: gtree-fsp, ")")
    } else { inner }

    let dv = _gD.at(la, default: (0, -1))
    let lp = _va(pos, _vm(dv, gtree-Rt + gtree-gap))
    content(lp, lbl, anchor: _gA.at(la, default: "north"))
  }
}


// ── gtree-branch ──────────────────────────────────────────────────
/// Draw a branch (edge) from a parent node to a child node, with an optional action label.
#let gtree-branch(
  /// Parent node centre `(x, y)`. -> array
  from,
  /// Child node centre `(x, y)`. -> array
  to,
  /// Action label text. Pass `none` for no label. Default: `none`. -> content
  action: none,
  /// Player whose colour is used for the label. `0` uses `gtree-nature-color`. Default: `1`. -> int
  player: 1,
  /// Side of the branch for the label.
  /// `none` — centred on the line with a white background (default);
  /// `"e"` — east (absolute) side, label anchored `"west"`;
  /// `"w"` — west (absolute) side, label anchored `"east"`. -> str
  side:   none,
  /// Perpendicular distance in cm from the branch line to the label anchor.
  /// Effective only when `side` is `"e"` or `"w"`. Default: `gtree-act`. -> float
  act:    gtree-act,
  /// Fractional position of the label along the branch.
  /// `0` = parent end, `1` = child end. Default: `gtree-apos`. -> float
  apos:   gtree-apos,
  /// Draw an arrowhead at the child end of the branch. Default: `false`. -> bool
  arrow:  false,
) = {
  import cetz.draw: *

  let mark = if arrow { (end: ">") } else { none }
  line(from, to,
    stroke: (paint: gtree-fg, thickness: gtree-sw-b),
    mark:   mark,
  )

  if action != none {
    let col = _gc(player)
    let dv  = _vs(to, from)
    let mid = _va(from, _vm(dv, apos))

    if side == none or side == "in" {
      content(mid,
        text(fill: col, size: gtree-fsa, action),
        anchor: "center",
        frame:  "rect",
        fill:   white,
        stroke: none,
        padding: 1pt,
      )
    } else {
      // _vpl.x = -dy; the east-pointing perp has a non-negative x-component.
      let dvn     = _vn(dv)
      let perp_l  = _vpl(dvn)
      let east_p  = if perp_l.at(0) >= 0 { perp_l } else { _vpr(dvn) }
      let perp    = if side == "e" { east_p } else { _vm(east_p, -1) }
      let anchor  = if side == "e" { "west" } else { "east" }
      let lp      = _va(mid, _vm(perp, act))
      content(lp,
        text(fill: col, size: gtree-fsa, action),
        anchor: anchor,
        frame:  "rect",
        fill:   white,
        stroke: none,
        padding: 1pt,
      )
    }
  }
}


// ── gtree-infoset ─────────────────────────────────────────────────
/// Draw an information set connecting two or more decision nodes.
#let gtree-infoset(
  /// Node positions. Two-point form: two separate coordinate pairs `(x, y)`.
  /// List form: one argument that is itself an array of pairs `((x1,y1), (x2,y2), …)`. -> array
  ..pts-arg,
  /// Player index for the colour. `1`–`5` use `gtree-pal`; `none` uses dark grey. Default: `none`. -> int
  player: none,
  /// Drawing style. `"dashed"` — dashed line(s) between consecutive points (default);
  /// `"bracket"` — rounded bracket ribbon with half-circle caps at each endpoint. -> str
  style:  "dashed",
  /// Segment curvature. `none` — straight (default); a single angle — same bend for every segment;
  /// an array of angles — one per segment (length = number of points − 1).
  /// Positive angle bends toward the CCW perpendicular. For `"bracket"` only the first entry is used. -> angle
  angle:  none,
  /// Label at the midpoint of the first-to-last span.
  /// For `"dashed"` style, only shown when exactly two points are given. Default: `none`. -> content
  label:  none,
  /// Direction for the label offset.
  /// One of `"n"`, `"s"`, `"e"`, `"w"`, `"ne"`, `"nw"`, `"se"`, `"sw"`. Default: `"s"`. -> str
  la:     "s",
) = {
  import cetz.draw: *
  let col = if player != none { _gc(player) } else { pi-infoset-color }

  // Two call forms:
  //   f(pos1, pos2)            — two separate positional args
  //   f((pos1, pos2, pos3, …)) — one positional arg that is a list of points
  // A coordinate pair like (0,0) is an array of numbers; a list of points is
  // an array of arrays. type(first_elem) == array distinguishes them.
  let raw = pts-arg.pos()
  let pts = if raw.len() == 2 {
    raw
  } else {
    let first = raw.at(0)
    if type(first.at(0)) == array { first } else { raw }
  }
  let nseg = pts.len() - 1

  let angs = if angle == none {
    range(nseg).map(_ => none)
  } else if type(angle) == array {
    angle
  } else {
    range(nseg).map(_ => angle)
  }

  if style == "dashed" {
    let st = (paint: col, thickness: gtree-sw-i, dash: "dashed")
    for i in range(nseg) {
      let a  = pts.at(i)
      let b  = pts.at(i + 1)
      let ag = angs.at(i)
      if ag == none {
        line(a, b, stroke: st)
      } else {
        let dv   = _vs(b, a)
        let len  = calc.sqrt(dv.at(0) * dv.at(0) + dv.at(1) * dv.at(1))
        let ctrl = _va(
          _va(a, _vm(dv, 0.5)),
          _vm(_vpl(_vn(dv)), len * calc.tan(ag) * 0.5),
        )
        bezier(a, b, ctrl, stroke: st)
      }
    }
    // Label base = chord midpoint; shifted toward the Bézier peak only when
    // the peak is on the same side as `la` (dot product > 0), so the label
    // stays outside the curve even when `la` and `angle` disagree.
    if label != none and pts.len() == 2 {
      let pa  = pts.at(0)
      let pb  = pts.at(1)
      let dv  = _vs(pb, pa)
      let mid = _va(pa, _vm(dv, 0.5))
      let ldv = _gD.at(la, default: (0, -1))
      let base = if angs.at(0) != none {
        let len  = calc.sqrt(dv.at(0)*dv.at(0) + dv.at(1)*dv.at(1))
        let offs = _vm(_vpl(_vn(dv)), len * calc.tan(angs.at(0)) * 0.25)
        let dot  = offs.at(0)*ldv.at(0) + offs.at(1)*ldv.at(1)
        if dot > 0 { _va(mid, offs) } else { mid }
      } else {
        mid
      }
      content(_va(base, _vm(ldv, gtree-gap)),
        text(fill: col, size: gtree-fsl, label),
        anchor: _gA.at(la, default: "north"),
      )
    }

  } else if style == "bracket" {
    // Bracket ribbon. Rail points are offset ±gtree-tick along the local
    // perpendicular. Intermediate points use the bisector of adjacent segment
    // perps so both rails meet cleanly at any bend angle.
    let st  = (paint: col, thickness: gtree-sw-i, dash: "dashed")
    let t   = gtree-tick
    let n   = pts.len()

    let dirs = range(nseg).map(i => _vn(_vs(pts.at(i + 1), pts.at(i))))

    let perps = range(n).map(i => {
      if i == 0          { _vpl(dirs.at(0)) }
      else if i == n - 1 { _vpl(dirs.at(nseg - 1)) }
      else               { _vn(_va(_vpl(dirs.at(i - 1)), _vpl(dirs.at(i)))) }
    })

    let tops = range(n).map(i => _va(pts.at(i), _vm(perps.at(i),  t)))
    let bots = range(n).map(i => _va(pts.at(i), _vm(perps.at(i), -t)))

    if angs.all(a => a == none) {
      line(..tops, stroke: st)
      line(..bots, stroke: st)
    } else {
      for i in range(nseg) {
        let ag   = angs.at(i)
        let top0 = tops.at(i);  let top1 = tops.at(i + 1)
        let bot0 = bots.at(i);  let bot1 = bots.at(i + 1)
        if ag == none {
          line(top0, top1, stroke: st)
          line(bot0, bot1, stroke: st)
        } else {
          let dv  = _vs(pts.at(i + 1), pts.at(i))
          let len = calc.sqrt(dv.at(0)*dv.at(0) + dv.at(1)*dv.at(1))
          let bow = _vm(_vpl(dirs.at(i)), len * calc.tan(ag) * 0.5)
          bezier(top0, top1,
            _va(_va(top0, _vm(_vs(top1, top0), 0.5)), bow), stroke: st)
          bezier(bot0, bot1,
            _va(_va(bot0, _vm(_vs(bot1, bot0), 0.5)), bow), stroke: st)
        }
      }
    }

    // Half-circle caps at both endpoints. Typst calc.atan2 takes (x, y).
    // First cap: top rail → CCW 180° → bottom rail (outward = th_f + 90°).
    // Last cap: bottom rail → CCW 180° → top rail (start = th_l - 180°).
    let th_f = calc.atan2(perps.at(0).at(0),       perps.at(0).at(1))
    let th_l = calc.atan2(perps.at(n - 1).at(0),   perps.at(n - 1).at(1))
    arc(pts.first(), radius: t, start: th_f,           stop: th_f + 180deg, anchor: "origin", stroke: st)
    arc(pts.last(),  radius: t, start: th_l - 180deg,  stop: th_l,          anchor: "origin", stroke: st)

    // Label base shifted to Bézier peak only when peak is on the la side
    // (dot product > 0); otherwise stays at chord midpoint.
    if label != none {
      let pa  = pts.first()
      let pb  = pts.last()
      let dv  = _vs(pb, pa)
      let mid = _va(pa, _vm(dv, 0.5))
      let ldv = _gD.at(la, default: (0, -1))
      let base = if nseg == 1 and angs.at(0) != none {
        let len  = calc.sqrt(dv.at(0)*dv.at(0) + dv.at(1)*dv.at(1))
        let offs = _vm(_vpl(_vn(dv)), len * calc.tan(angs.at(0)) * 0.25)
        let dot  = offs.at(0)*ldv.at(0) + offs.at(1)*ldv.at(1)
        if dot > 0 { _va(mid, offs) } else { mid }
      } else {
        mid
      }
      content(_va(base, _vm(ldv, gtree-gap + t)),
        text(fill: col, size: gtree-fsl, label),
        anchor: _gA.at(la, default: "north"),
      )
    }
  }
}


// ── gtree-prob ────────────────────────────────────────────────────
/// Place a probability label on a Nature branch. Wrapper around `gtree-branch` with `player: 0`.
#let gtree-prob(
  /// Parent node centre `(x, y)`. -> array
  from,
  /// Child node centre `(x, y)`. -> array
  to,
  /// Probability expression, e.g. `[$p$]`. Default: `none`. -> content
  action: none,
  /// Label placement. `none` — on the branch line (default);
  /// `"e"` — east side; `"w"` — west side. See `gtree-branch`. -> str
  side:   none,
  /// Perpendicular offset in cm from the branch line. Default: `gtree-act`. -> float
  act:    gtree-act,
  /// Fractional position of the label along the branch. Default: `gtree-apos`. -> float
  apos:   gtree-apos,
  /// Draw arrowhead at the child end. Default: `false`. -> bool
  arrow:  false,
) = {
  gtree-branch(from, to, action: action, player: 0, side: side, act: act, apos: apos, arrow: arrow)
}


// ── gtree-subgame ─────────────────────────────────────────────────
/// Draw a proper-subgame triangle marker (dotted, lightly filled, apex at the root).
#let gtree-subgame(
  /// Position of the subgame root node `(x, y)`. -> array
  apex,
  /// Height of the triangle downward in cm. Default: `1.0`. -> float
  depth: 1.0,
  /// Half-width of the base in cm. Default: `0.6`. -> float
  width: 0.6,
  /// Label inside the triangle at ~42% of the height from the base.
  /// Pass `none` to suppress. Default: `none`. -> content
  label: none,
) = {
  import cetz.draw: *
  let (ax, ay) = apex
  let by = ay - depth
  line(apex, (ax - width, by), (ax + width, by),
    close: true,
    stroke: (paint: pi-subgame-stroke, thickness: gtree-sw-i, dash: "dotted"),
    fill:   pi-subgame-fill,
  )
  if label != none {
    content((ax, by + depth * 0.42),
      text(fill: pi-subgame-label, size: gtree-fsl, label))
  }
}


// ── gtree-highlight ───────────────────────────────────────────────
/// Draw a bold coloured overlay on an existing branch to mark an equilibrium path.
#let gtree-highlight(
  /// Start node centre `(x, y)`. -> array
  from,
  /// End node centre `(x, y)`. -> array
  to,
  /// Highlight colour. Default: `pi-highlight-color` (red). -> color
  color: pi-highlight-color,
  /// Stroke width. Default: `gtree-sw-h` (2pt). -> length
  width: gtree-sw-h,
) = {
  import cetz.draw: *
  let dn = _vn(_vs(to, from))
  line(
    _va(from, _vm(dn,  gtree-R)),
    _va(to,   _vm(dn, -gtree-R)),
    stroke: (paint: color, thickness: width),
  )
}


// ── gtree-payoffs ─────────────────────────────────────────────────
/// Build a coloured inline payoff vector for body text or math. Each payoff is coloured by player.
/// -> content
#let gtree-payoffs(
  /// Array of content, one element per player, e.g. `([2], [1])` or `([$p-c$], [$v-p$])`. -> array
  payoffs,
  /// Wrap the payoff vector in parentheses. Default: `true`. -> bool
  parens: true,
) = {
  let items = payoffs.enumerate().map(((i, v)) =>
    text(fill: _gc(i + 1), v)
  )
  let inner = items.join(text(fill: gtree-fg, [, ]))
  if parens { [(#inner)] } else { inner }
}


// ── gtree-player ──────────────────────────────────────────────────
/// Typeset arbitrary content in a player's colour (bold).
/// -> content
#let gtree-player(
  /// Player index. `1`–`5` use `gtree-pal`; `0` uses `gtree-nature-color`. -> int
  player,
  /// Text to render in the player's colour. -> content
  label,
) = {
  let col = _gc(player)
  text(fill: col, weight: "bold", label)
}

/// Typeset the default label "Player N" in player N's colour (bold).
/// -> content
#let gtree-player-default(
  /// Player index. `1`–`5` use `gtree-pal`; `0` uses `gtree-nature-color`. -> int
  player,
) = {
  let col = _gc(player)
  text(fill: col, weight: "bold", [Player #player])
}
