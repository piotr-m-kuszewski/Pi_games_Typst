// pi-games-example.typ — Usage examples for the pi-games normal-form game library
// Piotr Kuszewski · SGH Warsaw School of Economics
//
// Compile with: typst compile pi-games-example.typ

#import "pi-games.typ": *

// ── 1. Prisoner's Dilemma ────────────────────────────────────────────────────

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

// ── 2. Battle of Sexes ───────────────────────────────────────────────────────

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

// ── 3. Matching Pennies with probabilities in strategy labels ─────────────────

#game-normal-form(
  [P1], [P2],
  ([$[p]$ #h(1mm) H],     [$[1-p]$ #h(1mm) T]),
  ([$[q]$\ H], [$[1-q]$\ T]),
  (
    (([$1$], [$-1$]), ([$-1$], [$1$])),
    (([$-1$], [$1$]), ([$1$], [$-1$])),
  ),
)

// ── 4. 3×3 Coordination Game with parametric payoffs ─────────────────────────

#game-normal-form(
  [P1], [P2],
  ([A], [B], [C]),
  ([A], [B], [C]),
  (
    (([$a$], [$a$]), ([$b$], [$b$]), ([$b$], [$b$])),
    (([$b$], [$b$]), ([$a$], [$a$]), ([$b$], [$b$])),
    (([$b$], [$b$]), ([$b$], [$b$]), ([$a$], [$a$])),
  ),
  nash:    ((0, 0), (1, 1), (2, 2)),
)

// ── 5. Three-Player Stag Hunt ────────────────────────────────────────────────

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
