#import "@preview/cetz:0.4.2"

/// Draws a general N×M normal form game table with colored payoffs,
/// best-response underlines, and Nash equilibrium highlights.
///
/// -> content
#let normal-form-game(
  /// Name of the row player, displayed rotated 90° on the left side of the matrix.
  /// Accepts any Typst content, e.g. `[Alice]` or `[$P_1$]`. -> content
  p1,
  /// Name of the column player, displayed in bold above the column strategy labels.
  /// Accepts any Typst content. -> content
  p2,
  /// Array of strategy labels for Player 1, one element per row.
  /// The number of rows equals `s1.len()`. Each label is content and may include
  /// math or line breaks (e.g. `[$p$\ C]` for a two-line label). -> array
  s1,
  /// Array of strategy labels for Player 2, one element per column.
  /// The number of columns equals `s2.len()`. Column width auto-adjusts to the
  /// widest label in this array. -> array
  s2,
  /// 2D array of payoff pairs indexed as `payoffs.at(row).at(col) = (v1, v2)`.
  /// Both `v1` (Player 1) and `v2` (Player 2) are Typst content and may contain
  /// arbitrary markup or mathematics. Example for a 2×2 game:
  /// ```
  /// (
  ///   (([$3$],[$ 3$]), ([$0$],[$5$])),   // row 0
  ///   (([$5$],[$0$]), ([$1$],[$1$])),    // row 1
  /// )
  /// ```
  payoffs,
  /// Color applied to Player 1's name and payoff values. -> color
  p1-color: blue,
  /// Color applied to Player 2's name and payoff values. -> color
  p2-color: red,
  /// Color of the rectangle drawn around Nash equilibrium cells. -> color
  nash-color: teal,
  /// Array of `(row, col)` tuples identifying cells where Player 1 plays a best
  /// response. Player 1's payoff in those cells is underlined in `p1-color`.
  p1-best: (),
  /// Array of `(row, col)` tuples identifying cells where Player 2 plays a best
  /// response. Player 2's payoff in those cells is underlined in `p2-color`.
  p2-best: (),
  /// Array of `(row, col)` tuples of Nash equilibrium cells.
  /// A rectangle in `nash-color` is drawn just inside the cell border.
  nash: (),
  /// Minimum cell width. The actual width is the maximum of this value, the widest
  /// Player 2 strategy label width plus `2em`, and the widest payoff pair width
  /// plus `2em`. Increase to enforce a larger minimum regardless of content. -> length
  cell_width: 5em,
  /// Fixed cell height. Content is placed at the cell centre; this value is not
  /// auto-sized, so increase it when payoffs span multiple lines. -> length
  cell_height: 2em,
) = context {
  cetz.canvas({
    import cetz.draw: *

    let max-width(strings) = {
      strings.fold(0pt, (acc, s) => {
        let w = measure(text(s)).width
        if w > acc { w } else { acc }
      })
    }

    let max-height(strings) = {
      strings.fold(0pt, (acc, s) => {
        let w = measure(text(s)).height
        if w > acc { w } else { acc }
      })
    }
  
    let rows = s1.len()
    let cols = s2.len()
    
    // Geometry settings
    let max-payoff-width = range(rows).map(r =>
      range(cols).map(c => {
        let pay = payoffs.at(r).at(c)
        let v1 = pay.at(0)
        let v2 = pay.at(1)
        let sv1 = if (r, c) in p1-best { underline(stroke: p1-color + 1pt, v1) } else { v1 }
        let sv2 = if (r, c) in p2-best { underline(stroke: p2-color + 1pt, v2) } else { v2 }
        measure([#text(fill: p1-color, sv1)#text(fill: black)[, ]#text(fill: p2-color, sv2)]).width
      })
    ).flatten().fold(0pt, (acc, w) => if w > acc { w } else { acc })
    let w = calc.max(cell_width.to-absolute(), max-width(s2).to-absolute() + (2em).to-absolute(), max-payoff-width + (2em).to-absolute())
    let h = cell_height.to-absolute() // Cell height
    let w_sep = calc.max(max-width(s1).to-absolute() + (2em).to-absolute())
    let h_sep = calc.max(max-height(s2).to-absolute() + (1em).to-absolute())

    // Draw The Grid and Payoffs
    for r in range(rows) {
      for c in range(cols) {
        let x = c * w
        let y = -r * h
        
        // Draw Cell Border
        rect((x, y), (x + w, y - h), stroke: 0.5pt)

        // Extract Payoffs
        let pay = payoffs.at(r).at(c)
        let v1 = pay.at(0)
        let v2 = pay.at(1)

        // Draw Nash equilibrium if applicable
        if (r, c) in nash {
           // circle((x + w/2, y - h/2), radius: (w*0.35, h*0.4), stroke: 2pt + gray)
           rect((x + (0.3em).to-absolute(), y - (0.3em).to-absolute()), (x + w - (0.3em).to-absolute(), y - h + (0.3em).to-absolute()), stroke: 1pt + nash-color)
        }

        // Determine Styles (Underline if Best Response)
        let style-v1 = if (r, c) in p1-best { underline(stroke: p1-color + 1pt, v1) } else { v1 }
        let style-v2 = if (r, c) in p2-best { underline(stroke: p2-color + 1pt, v2) } else { v2 }

        // Construct Content string with colors
        let cell-content = [
            #text(fill: p1-color, style-v1)#text(fill: black)[, ]#text(fill: p2-color, style-v2)
        ]

        // Place Payoff Text
        content((x + w/2, y - h/2), cell-content)
      }
    }

    // Draw Strategies (Row Player / Left)
    for (i, strat) in s1.enumerate() {
       content((-1em, -i*h - h/2), strat, anchor: "east")
    }

    // Draw Strategies (Column Player / Top)
    for (i, strat) in s2.enumerate() {
       content((i*w + w/2, 0.5em), align(center)[#strat], anchor: "base")
    }

    // Draw Player 2 (horizontal) name above strategies, centered above columns
    content((w*cols/2, h_sep), text(fill: p2-color, weight: "bold", align(center)[#p2]), anchor: "base") 

    // Draw Player 1 (vertical) name to the left of strategies, centered left of rows
    content((-w_sep, -h*rows/2), text(fill: p1-color, weight: "bold", align(center)[#p1]), angle: 90deg, anchor: "base" ) 
  })
}

/// Draws a three-player normal form game as a collection of N×M payoff matrices,
/// one per strategy of Player 3, laid out in rows of at most `games-per-row` matrices.
/// All sub-matrices share the same cell dimensions. Payoffs for all three players
/// are shown in each cell. Strategy labels of Player 3 appear above each sub-matrix.
///
/// -> content
#let three-player-normal-form-game(
  /// Name of the row player (Player 1), displayed rotated 90° to the left of each
  /// row of sub-matrices. -> content
  p1,
  /// Name of the column player (Player 2), displayed in bold above the strategy
  /// labels of each sub-matrix. -> content
  p2,
  /// Name of the matrix player (Player 3), displayed once in bold above the first
  /// row of sub-matrices. -> content
  p3,
  /// Array of strategy labels for Player 1, shared across all sub-matrices.
  /// Determines the number of rows; `s1.len()` rows are drawn. -> array
  s1,
  /// Array of strategy labels for Player 2, shared across all sub-matrices.
  /// Determines the number of columns; `s2.len()` columns are drawn. -> array
  s2,
  /// Array of strategy labels for Player 3. One sub-matrix is drawn per entry,
  /// so `s3.len()` sub-matrices are produced in total. -> array
  s3,
  /// 3D array of payoff triples indexed as `payoffs.at(k).at(r).at(c) = (v1, v2, v3)`.
  /// `k` is the Player 3 strategy index (outermost), `r` the row (Player 1),
  /// `c` the column (Player 2). All three values are Typst content.
  payoffs,
  /// Color applied to Player 1's name and payoff values. -> color
  p1-color: blue,
  /// Color applied to Player 2's name and payoff values. -> color
  p2-color: red,
  /// Color applied to Player 3's name, strategy labels, and payoff values. -> color
  p3-color: green,
  /// Color of the rectangle drawn inside Nash equilibrium cells. -> color
  nash-color: teal,
  /// Array of `(k, row, col)` tuples where Player 1 plays a best response.
  /// Player 1's payoff is underlined in `p1-color` at those cells.
  p1-best: (),
  /// Array of `(k, row, col)` tuples where Player 2 plays a best response.
  /// Player 2's payoff is underlined in `p2-color` at those cells.
  p2-best: (),
  /// Array of `(k, row, col)` tuples where Player 3 plays a best response.
  /// Player 3's payoff is underlined in `p3-color` at those cells.
  p3-best: (),
  /// Array of `(k, row, col)` tuples of Nash equilibrium cells.
  /// A rectangle in `nash-color` is drawn inside those cells.
  nash: (),
  /// Minimum cell width, auto-grown to fit the widest payoff triple or Player 2
  /// strategy label across all sub-matrices. -> length
  cell_width: 5em,
  /// Fixed cell height. Increase when payoff content spans multiple lines. -> length
  cell_height: 2em,
  /// Maximum number of sub-matrices placed side by side. If Player 3 has more
  /// strategies than this, additional rows of sub-matrices are added below.
  /// A lone sub-matrix in the last row is horizontally centred. -> int
  games-per-row: 2,
) = context {
  cetz.canvas({
    import cetz.draw: *

    let max-w(strings) = strings.fold(0pt, (acc, s) => {
      let ww = measure(text(s)).width
      if ww > acc { ww } else { acc }
    })
    let max-h(strings) = strings.fold(0pt, (acc, s) => {
      let hh = measure(text(s)).height
      if hh > acc { hh } else { acc }
    })

    let rows = s1.len()
    let cols = s2.len()
    let n3   = s3.len()

    // Cell width: wide enough for widest payoff triple across all sub-matrices
    let max-payoff-w = range(n3).map(k =>
      range(rows).map(r =>
        range(cols).map(c => {
          let pay = payoffs.at(k).at(r).at(c)
          let v1 = pay.at(0)
          let v2 = pay.at(1)
          let v3 = pay.at(2)
          let sv1 = if (k, r, c) in p1-best { underline(stroke: p1-color + 1pt, v1) } else { v1 }
          let sv2 = if (k, r, c) in p2-best { underline(stroke: p2-color + 1pt, v2) } else { v2 }
          let sv3 = if (k, r, c) in p3-best { underline(stroke: p3-color + 1pt, v3) } else { v3 }
          measure([#text(fill: p1-color, sv1)#text(fill: black)[, ]#text(fill: p2-color, sv2)#text(fill: black)[, ]#text(fill: p3-color, sv3)]).width
        })
      )
    ).flatten().fold(0pt, (acc, ww) => if ww > acc { ww } else { acc })

    let w      = calc.max(cell_width.to-absolute(), max-w(s2).to-absolute() + (2em).to-absolute(), max-payoff-w + (2em).to-absolute())
    let h      = cell_height.to-absolute()
    let gw     = cols * w
    let gh     = rows * h
    let w_sep  = max-w(s1).to-absolute() + (2em).to-absolute()
    let h_sep  = max-h(s2).to-absolute() + (1em).to-absolute()   // space for P2 strats + P2 name
    let h_p3   = max-h(s3).to-absolute() + (1em).to-absolute()   // space for P3 strategy label
    let h_above = h_sep + h_p3                                    // total label height above each grid
    let gap_x  = (3em).to-absolute()
    let gap_y  = (2em).to-absolute()
    let row_step = gh + h_above + gap_y

    for (k, strat3) in s3.enumerate() {
      let gc = calc.rem(k, games-per-row)
      let gr = int(k / games-per-row)
      // Center a lone sub-matrix in the last row
      let lone-last = calc.rem(n3, games-per-row) == 1 and gr == int((n3 - 1) / games-per-row)
      let ox = if lone-last { (games-per-row - 1) * (gw + gap_x) / 2 } else { gc * (gw + gap_x) }
      let oy = -(gr * row_step)

      // Grid cells
      for r in range(rows) {
        for c in range(cols) {
          let x = ox + c * w
          let y = oy - r * h

          rect((x, y), (x + w, y - h), stroke: 0.5pt)

          let pay = payoffs.at(k).at(r).at(c)
          let v1  = pay.at(0)
          let v2  = pay.at(1)
          let v3  = pay.at(2)

          if (k, r, c) in nash {
            rect(
              (x + (0.3em).to-absolute(), y - (0.3em).to-absolute()),
              (x + w - (0.3em).to-absolute(), y - h + (0.3em).to-absolute()),
              stroke: 1pt + nash-color
            )
          }

          let sv1 = if (k, r, c) in p1-best { underline(stroke: p1-color + 1pt, v1) } else { v1 }
          let sv2 = if (k, r, c) in p2-best { underline(stroke: p2-color + 1pt, v2) } else { v2 }
          let sv3 = if (k, r, c) in p3-best { underline(stroke: p3-color + 1pt, v3) } else { v3 }

          content(
            (x + w/2, y - h/2),
            [#text(fill: p1-color, sv1)#text(fill: black)[, ]#text(fill: p2-color, sv2)#text(fill: black)[, ]#text(fill: p3-color, sv3)]
          )
        }
      }

      // P2 strategy labels
      for (i, strat) in s2.enumerate() {
        content((ox + i*w + w/2, oy + 0.5em), align(center)[#strat], anchor: "base")
      }

      // P2 player name
      content(
        (ox + gw/2, oy + h_sep),
        text(fill: p2-color, weight: "bold", align(center)[#p2]),
        anchor: "base"
      )

      // P3 strategy label (above P2 name)
      content(
        (ox + gw/2, oy + h_above),
        text(fill: p3-color, weight: "bold", align(center)[#strat3]),
        anchor: "base"
      )

      // P1 strategy labels and name — only for the leftmost sub-matrix in each row
      if gc == 0 {
        for (i, strat) in s1.enumerate() {
          content((ox - 1em, oy - i*h - h/2), strat, anchor: "east")
        }
        content(
          (ox - w_sep, oy - gh/2),
          text(fill: p1-color, weight: "bold", align(center)[#p1]),
          angle: 90deg,
          anchor: "base"
        )
      }
    }

    // P3 player name once, centered over the full row width (matches lone-game centering)
    let top_w = games-per-row * gw + (games-per-row - 1) * gap_x
    content(
      (top_w / 2, h_above + (1.5em).to-absolute()),
      text(fill: p3-color, weight: "bold")[#p3],
      anchor: "base"
    )
  })
}
