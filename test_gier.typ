// Diagrams
#import "@preview/cetz:0.5.2" as cetz
#import "@preview/fletcher:0.5.8": diagram, edge, node
// Code
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
#show: codly-init.with()
#codly(languages: codly-languages)
// Games
#import "pi-games.typ": *
#import "pi-games-fletcher.typ": *
// Basic setup
#set page(numbering: "1")
#set text(lang: "en")
#set heading(numbering: "1.1")
#set par(justify: true)

#set document(
    title: "Drawing extensive form games",
    author: "Piotr Kuszewski",
)

#title()
Piotr Kuszewski, May 2026


= Introduction
The goal of this short note is to summarize how to draw extensive form games in `fletcher`. First, we develop a simple drawing style and methodology using basic `fletcher` constructs. After that, we investigate how to add extra elements to extensive form games drawn with `fletcher` in Typst. Finally, we will try to replicate games from the `xgames` LaTeX package and other widely used packages for drawing extensive form games. We will also try to replicate the style used in _The Course in Game Theory_ by Martin J. Osborne and Ariel Rubinstein.


= Extensive form games with `fletcher`

== Some extra setup

```typst
#let pi_thick_red_arrow = (stroke: 2pt + red, 
    marks: (none, (inherit: ">", size: 1.5)))
#let pi_thick_blue_arrow = (stroke: 2pt + blue, 
    marks: (none, (inherit: ">", size: 1.5)))
#let pi_label_inside = (label-fill: true, label-anchor: "center")
```

== Examples

```typst
#diagram(
    spacing: (20mm, 10mm),
    node((0,0), [*1*]),
    edge((-1,1), "->", label: [A]),
    edge((1,1), "->", label: [B]),
    node((-1,1),[*2*]),
    edge((-1.75,2), "->", label: [C]),
    edge((-0.25,2), "->", label: [D]),
    node((-1.75,2), [(3, 8)]),
    node((-0.25,2), [(8, 3)]),
    node((1,1), [*2*]),
    edge((0.25, 2), "->", [E]),
    edge((1.75, 2), "->", [F]),
    node((0.25,2), [(5, 5)]),
    node((1.75,2), [*1*]),
    edge((1.25,3), "->", label: [G]),
    edge((2.25, 3), "->", label: [H]),
    node((1.25,3), [(2, 10)]),
    node((2.25, 3), [(1, 0)])
)
```
#align(center)[
    #diagram(
        spacing: (20mm, 10mm),
        node((0,0), [*1*]),
        edge((-1,1), "->", label: [A]),
        edge((1,1), "->", label: [B]),
        node((-1,1),[*2*]),
        edge((-1.75,2), "->", label: [C]),
        edge((-0.25,2), "->", label: [D]),
        node((-1.75,2), [(3, 8)]),
        node((-0.25,2), [(8, 3)]),
        node((1,1), [*2*]),
        edge((0.25, 2), "->", [E]),
        edge((1.75, 2), "->", [F]),
        node((0.25,2), [(5, 5)]),
        node((1.75,2), [*1*]),
        edge((1.25,3), "->", label: [G]),
        edge((2.25, 3), "->", label: [H]),
        node((1.25,3), [(2, 10)]),
        node((2.25, 3), [(1, 0)])
    )
]

```typst
#diagram(
    spacing: (20mm, 15mm),
    node((0,0), [*1*]),
    edge((-1,1), "->", label: [L]),
    edge((1,1), "->", label: [R]),
    edge((-1,1), "dashed", bend: -35deg),
    node((-1,1),[*1*]),
    edge((-1.75,2), "->", label: [L]),
    edge((-0.25,2), "->", label: [R]),
    node((-1.75,2), [(1, 0)]),
    node((-0.25,2), [(100, 100)]),
    node((1,1), [*2*]),
    edge((0.25, 2), "->", [U]),
    edge((1.75, 2), "->", [D]),
    node((0.25,2), [(5, 1)]),
    node((1.75,2), [(2,2)]),
)
```

#align(center)[
    #diagram(
        spacing: (20mm, 15mm),
        node((0,0), [*1*]),
        edge((-1,1), "->", label: [L]),
        edge((1,1), "->", label: [R]),
        edge((-1,1), "dashed", bend: -35deg),
        node((-1,1),[*1*]),
        edge((-1.75,2), "->", label: [L]),
        edge((-0.25,2), "->", label: [R]),
        node((-1.75,2), [(1, 0)]),
        node((-0.25,2), [(100, 100)]),
        node((1,1), [*2*]),
        edge((0.25, 2), "->", [U]),
        edge((1.75, 2), "->", [D]),
        node((0.25,2), [(5, 1)]),
        node((1.75,2), [(2,2)]),
    )
]


```typst
#diagram(
    spacing: (2mm, 15mm),
    node((0,0), [*A*]),
    edge((-3.5,1), "->", label: [K], label-fill: true, label-anchor: "center"),
    edge((3.5,1), "->", label: [T], label-fill: true, label-anchor: "center"),
    node((-3.5,1),[*B*]),
    edge((-5,2), "->", label: [D], label-fill: true, label-anchor: "center"),
    edge((-2,2), "->", label: [$not$D], label-fill: true, label-anchor: "center"),
    edge((3.5,1), "dashed"),
    node((3.5,1), [*B*]),
    edge((2, 2), "->", [$not$D], label-fill: true, label-anchor: "center"),
    edge((5, 2), "->", [D], label-fill: true, label-anchor: "center"),
    node((-5, 2), [*B*]),
    edge((-6,3), "->", label: [K], label-fill: true, label-anchor: "center"),
    edge((-4,3), "->", label: [T], label-fill: true, label-anchor: "center"),
    node((-2,2), [*B*]),
    edge((-3,3), "->", label: [K], label-fill: true, label-anchor: "center"),
    edge((-1,3), "->", label: [T], label-fill: true, label-anchor: "center"),   
    edge((2,2), "dashed"),
    node((2,2), [*B*]),
    edge((1, 3), "->", label: [K], label-fill: true, label-anchor: "center"),
    edge((3, 3), "->", label: [T], label-fill: true, label-anchor: "center"),
    node((5,2), [*B*]),
    edge((4, 3), "->", label: [K], label-fill: true, label-anchor: "center"),
    edge((6, 3), "->", label: [T], label-fill: true, label-anchor: "center"),
    node((-6,3), [(3, 1)]),
    node((-4,3), [(0, 0)]),
    node((-3,3), [(3, 1)]),
    node((-1,3), [(0, 0)]),
    node((6,3), [(1, 3)]),
    node((4,3), [(0, 0)]),
    node((3,3), [(1, 3)]),
    node((1,3), [(0, 0)]),
)
```

#align(center)[
    #diagram(
        spacing: (2mm, 15mm),
        node((0,0), [*A*]),
        edge((-3.5,1), "->", label: [K], label-fill: true, label-anchor: "center"),
        edge((3.5,1), "->", label: [T], label-fill: true, label-anchor: "center"),

        node((-3.5,1),[*B*]),
        edge((-5,2), "->", label: [D], label-fill: true, label-anchor: "center"),
        edge((-2,2), "->", label: [$not$D], label-fill: true, label-anchor: "center"),
        edge((3.5,1), "dashed"),

        node((3.5,1), [*B*]),
        edge((2, 2), "->", [$not$D], label-fill: true, label-anchor: "center"),
        edge((5, 2), "->", [D], label-fill: true, label-anchor: "center"),

        node((-5, 2), [*B*]),
        edge((-6,3), "->", label: [K], label-fill: true, label-anchor: "center"),
        edge((-4,3), "->", label: [T], label-fill: true, label-anchor: "center"),

        node((-2,2), [*B*]),
        edge((-3,3), "->", label: [K], label-fill: true, label-anchor: "center"),
        edge((-1,3), "->", label: [T], label-fill: true, label-anchor: "center"),   

        edge((2,2), "dashed"),

        node((2,2), [*B*]),
        edge((1, 3), "->", label: [K], label-fill: true, label-anchor: "center"),
        edge((3, 3), "->", label: [T], label-fill: true, label-anchor: "center"),

        node((5,2), [*B*]),
        edge((4, 3), "->", label: [K], label-fill: true, label-anchor: "center"),
        edge((6, 3), "->", label: [T], label-fill: true, label-anchor: "center"),

        node((-6,3), [(3, 1)]),
        node((-4,3), [(0, 0)]),
        node((-3,3), [(3, 1)]),
        node((-1,3), [(0, 0)]),

        node((6,3), [(1, 3)]),
        node((4,3), [(0, 0)]),
        node((3,3), [(1, 3)]),
        node((1,3), [(0, 0)]),
    )
]

```typst
#diagram(
    spacing: (8mm, 10mm),
    node((3.5, 0), [*A*]),
    edge((0.5, 2), "->", [X], ..pi_label_inside),
    edge((2.5, 2), "->", [Y], ..pi_label_inside),
    edge((5.5, 1), "->", [Z], ..pi_label_inside),
    node((0.5, 2), [*B*]),
    edge(((2.5, 2)), "dashed"),
    edge((0, 3), "->", label: "L", ..pi_label_inside),
    edge((1, 3), "->", label: "R", ..pi_label_inside),
    node((0, 3), [(3, 1)]),
    node((1, 3), [(0, 0)]),
    node((2.5, 2), [*B*]),
    edge(((4.5, 2)), "dashed"),
    edge((2, 3), "->", label: "L", ..pi_label_inside),
    edge((3, 3), "->", label: "R", ..pi_label_inside),
    node((2, 3), [(3, 1)]),
    node((3, 3), [(0,0)]),
    node((5.5, 1), [*Los*]),
    edge((4.5,2), "->", [1/2], ..pi_label_inside),
    edge((6.5,2), "->", [1/2], ..pi_label_inside),
    node((4.5, 2), [*B*]),
    edge((4, 3), "->", label: "L", ..pi_label_inside),
    edge((5, 3), "->", label: "R", ..pi_label_inside),
    node((4, 3), [(0, 0)]),
    node((5, 3), [(1, 3)]),
    node((6.5, 2), [*B*]),
    edge((6, 3), "->", label: "L", ..pi_label_inside),
    edge((7, 3), "->", label: "R", ..pi_label_inside),
    node((6, 3), [(0, 0)]),
    node((7, 3), [(1, 3)]),
)
```

#align(center)[
    #diagram(
        spacing: (8mm, 10mm),

        node((3.5, 0), [*A*]),
        edge((0.5, 2), "->", [X], ..pi_label_inside),
        edge((2.5, 2), "->", [Y], ..pi_label_inside),
        edge((5.5, 1), "->", [Z], ..pi_label_inside),

        node((0.5, 2), [*B*]),
        edge(((2.5, 2)), "dashed"),
        edge((0, 3), "->", label: "L", ..pi_label_inside),
        edge((1, 3), "->", label: "R", ..pi_label_inside),
        node((0, 3), [(3, 1)]),
        node((1, 3), [(0, 0)]),

        node((2.5, 2), [*B*]),
        edge(((4.5, 2)), "dashed"),
        edge((2, 3), "->", label: "L", ..pi_label_inside),
        edge((3, 3), "->", label: "R", ..pi_label_inside),
        node((2, 3), [(3, 1)]),
        node((3, 3), [(0,0)]),


        node((5.5, 1), [*Los*]),
        edge((4.5,2), "->", [1/2], ..pi_label_inside),
        edge((6.5,2), "->", [1/2], ..pi_label_inside),

        node((4.5, 2), [*B*]),
        edge((4, 3), "->", label: "L", ..pi_label_inside),
        edge((5, 3), "->", label: "R", ..pi_label_inside),
        node((4, 3), [(0, 0)]),
        node((5, 3), [(1, 3)]),

        node((6.5, 2), [*B*]),
        edge((6, 3), "->", label: "L", ..pi_label_inside),
        edge((7, 3), "->", label: "R", ..pi_label_inside),
        node((6, 3), [(0, 0)]),
        node((7, 3), [(1, 3)]),
    )
]

=== Gra bufetowej (_beer-quiche game_)

```typst
#diagram(
    spacing: (10mm, 10mm),
    node((0,0), [*Los*]),
    edge((-2,0), "->", label: [$p$]),
    edge((2,0), "->", label: [$1-p$]),
    node((-2,0), [*S*]),
    edge((-2,-1), "->", label: [K]),
    edge((-2,1), "->", label: [P]),
    node((2,0), [*N*]),
    edge((2,-1), "->", label: [K]),
    edge((2,1), "->", label: [P]),
    node((-2,-1), [*B*]),
    edge((-3,-2), "->", label: [M], ..pi_label_inside ),
    edge((-1,-2), "->", label: [$not$M], ..pi_label_inside),
    edge((2,-1), "dashed"),
    node((-2,1), [*B*]),
    edge((-3,2), "->", label: [M], ..pi_label_inside),
    edge((-1,2), "->", label: [$not$M], ..pi_label_inside),
    edge((2,1), "dashed"),
    node((2,-1), [*B*]),
    edge((3,-2), "->", label: [M],..pi_label_inside),
    edge((1,-2), "->", label: [$not$M],..pi_label_inside),
    node((2,1), [*B*]),
    edge((3,2), "->", label: [M], ..pi_label_inside),
    edge((1,2), "->", label: [$not$M], ..pi_label_inside),
    node((-3,-2), [(3, 0)]),
    node((-1,-2), [(1, 1)]),
    node((1,-2), [(0, 0)]),
    node((3,-2), [(2, 1)]),
    node((-3,2), [(2, 0)]),
    node((-1,2), [(0, 1)]),
    node((1,2), [(1, 0)]),
    node((3,2), [(3, 1)]),
)
```

#align(center)[
    #diagram(
        spacing: (10mm, 10mm),

        // Natura — środek poziomej kreski H
        node((0,0), [*Los*]),
        edge((-2,0), "->", label: [$p$]),
        edge((2,0), "->", label: [$1-p$]),

        // Spolegliwy — środek lewej pionowej kreski H
        node((-2,0), [*S*]),
        edge((-2,-1), "->", label: [K]),
        edge((-2,1), "->", label: [P]),

        // Niepokorny — środek prawej pionowej kreski H
        node((2,0), [*N*]),
        edge((2,-1), "->", label: [K]),
        edge((2,1), "->", label: [P]),

        // Bufetowa — górny lewy róg H (S zamówił K)
        node((-2,-1), [*B*]),
        edge((-3,-2), "->", label: [M], ..pi_label_inside ),
        edge((-1,-2), "->", label: [$not$M], ..pi_label_inside),
        edge((2,-1), "dashed"),

        // Bufetowa — dolny lewy róg H (S zamówił P)
        node((-2,1), [*B*]),
        edge((-3,2), "->", label: [M], ..pi_label_inside),
        edge((-1,2), "->", label: [$not$M], ..pi_label_inside),
        edge((2,1), "dashed"),

        // Bufetowa — górny prawy róg H (N zamówił K)
        node((2,-1), [*B*]),
        edge((3,-2), "->", label: [M],..pi_label_inside),
        edge((1,-2), "->", label: [$not$M],..pi_label_inside),

        // Bufetowa — dolny prawy róg H (N zamówił P)
        node((2,1), [*B*]),
        edge((3,2), "->", label: [M], ..pi_label_inside),
        edge((1,2), "->", label: [$not$M], ..pi_label_inside),

        // Wypłaty — góra (zamówiono K; wychodzą ponad H)
        node((-3,-2), [(3, 0)]),
        node((-1,-2), [(1, 1)]),
        node((1,-2), [(0, 0)]),
        node((3,-2), [(2, 1)]),

        // Wypłaty — dół (zamówiono P; wychodzą poniżej H)
        node((-3,2), [(2, 0)]),
        node((-1,2), [(0, 1)]),
        node((1,2), [(1, 0)]),
        node((3,2), [(3, 1)]),
    )
]

== Decorations

```typst
#diagram(
    spacing: (6mm, 15mm),
    node((0,0), text(fill: blue)[*A*]),
    edge((-2,1), ..pi_thick_blue_arrow, label: [K]),
    edge((2,1), "->", label: [T], ),
    node((-2,1),text(fill: red)[*B*]),
    edge((-3,2), ..pi_thick_red_arrow, label: [K]),
    edge((-1,2), "->", label: [T]),
    node((2,1), text(fill: red)[*B*]),
    edge((1,2), "->", label: [K]),
    edge((3,2), ..pi_thick_red_arrow, label: [T]),
    node((-3,2), [(3, 1)]),
    node((-1,2), [(0, 0)]),
    node((3,2), [(1, 3)]),
    node((1,2), [(0, 0)]),
)
```

#align(center)[
    #diagram(
        spacing: (6mm, 15mm),
        node((0,0), text(fill: blue)[*A*]),
        edge((-2,1), ..pi_thick_blue_arrow, label: [K]),
        edge((2,1), "->", label: [T], ),

        node((-2,1),text(fill: red)[*B*]),
        edge((-3,2), ..pi_thick_red_arrow, label: [K]),
        edge((-1,2), "->", label: [T]),

        node((2,1), text(fill: red)[*B*]),
        edge((1,2), "->", label: [K]),
        edge((3,2), ..pi_thick_red_arrow, label: [T]),


        node((-3,2), [(3, 1)]),
        node((-1,2), [(0, 0)]),

        node((3,2), [(1, 3)]),
        node((1,2), [(0, 0)]),
    )
]

Open issues:
- information sets,
- randomization along some edges (triangle, pie shape?)

== Replicating other extensive games drawing styles

#align(center)[
    #cetz.canvas(
        length: 15mm,
        {
        import cetz.draw: *
        line((0,0), (-2,-1))
        line((0,0), (2,-1))
        line((-2,-1),(-3,-2))
        line((-2,-1),(-1,-2))
        line((2,-1),(1,-2))
        line((2,-1),(3,-2))

        circle((0,0), radius: 1mm, fill: white)
        circle((-2,-1), radius: 1mm, fill: black)
        circle((2,-1), radius: 1mm, fill: black)

        circle((3,-2), radius: 1mm, fill: black)
        circle((1,-2), radius: 1mm, fill: black)
        circle((3,-2), radius: 1mm, fill: black)
        circle((-3,-2), radius: 1mm, fill: black)
        circle((1,-2), radius: 1mm, fill: black)
        circle((-1,-2), radius: 1mm, fill: black)

        content((0,0), [A], anchor: "south-east", padding: 0.5em)
        content((-2,-1), [B], anchor: "south-east", padding: 0.5em)
        content((2,-1), [B], anchor: "south-west", padding: 0.5em)
    })
]

