#import "@preview/shadowed:0.2.0": shadowed

// This function defines and returns your template's components (functions, variables).
// It does NOT apply global settings yet.
//

#let DEBUG = false
#let PRINT_MARGIN = (inside: 2.5cm, outside: 1cm, y: 1cm)

#let debugger(info) = {
  if DEBUG {
    set text(size: 10pt, weight: "bold", fill: rgb("#FF0000"))
    text(info)
  }
}

#let default-config = (
  title-font: "Aptos Display",
  font: "Aptos Display", // Default font for the document
  colors: (
    primary-background: rgb("#FEF4FE"), /* Light Sky Blue */
    primary-color: rgb("#59ade0"), /* Soft Light Blue */
    secondary-color: rgb("#e0a0aa"), /* Light Pink */
    accent-color-1: rgb(186, 85, 211), /* Medium Orchid (Lavender) */
    accent-color-2: rgb(144, 238, 144), /* Light Green / Mint */
    text-dark: rgb(51, 51, 51), /* Slightly off-black for text */
    text-light: rgb(255, 255, 255), /* Pure white for light text */
  ),
  margin: (
    top: 1cm,
    bottom: 1cm,
    left: 1cm,
    right: 1cm,
  ),
  paper: "us-letter",
  show-title: true,
)


#let text-styles(config: default-config) = (
  h1: (
    font: config.title-font,
    size: 2em,
    weight: "light",
    color: config.colors.primary-color,
  ),
  headline: (
    font: config.title-font,
    size: 4em,
    weight: "regular",
    color: config.colors.text-dark,
  ),
  // TODO: Add more text styles as needed
)

#let invisible-heading(title, depth: 1) = {
  set text(size: 0pt)
  hide(heading(title, depth: depth))
}

#let style-text(content, config: default-config, style: "h1", depth: none) = {
  let texts = text-styles(config: config)
  if depth != none {
    invisible-heading(content, depth: depth)
  }

  let debug-info = [
    DEBUG INFO:
    - style parameter: #repr(style)
    - style == "h1": #repr(style == "h1")
    - texts.h1: #repr(texts.h1)
    - config.colors: #repr(config.colors)
  ]

  debugger(debug-info)
  if style in texts {
    set text(
      font: texts.at(style).font,
      size: texts.at(style).size,
      weight: texts.at(style).weight,
      texts.at(style).color,
    )
    content
  } else {
    panic(style + "is not a valid choice")
  }
}

#let end-page(logo-path) = {
  pagebreak()
  align(center + horizon)[
    #if (type(logo-path) == str) {
      image(logo-path, width: 3in)
    } else {
      logo-path
    }]
}

#let template(
  title: none,
  sub-title: none, // Optional
  bg-image-path: none, // Optional
  title-font: default-config.title-font,
  font: default-config.font, // Default font for the document
  colors: default-config.colors,
  margin: default-config.margin,
  config: default-config, // Default configuration
  doc,
) = {
  // Define helper styles/functions *within this scope*
  // They will 'capture' the color parameters passed to my-template
  set text(
    size: 1.2em,
    font: font,
    colors.text-dark,
  )


  let title-style(body) = {
    set text(5em, weight: "extrabold", colors.text-light, font: title-font)
    par(leading: 0.4em, body)
  }

  let subtitle-style(body) = {
    set text(1.5em, weight: "extrabold", colors.text-light, font: title-font)
    par(body)
  }

  let styled-block(body) = {
    block(fill: colors.secondary-color, inset: 1em, radius: 5pt)[
      #set text(foreground: colors.text-light)
      #body
    ]
  }

  let highlight-text(body) = {
    text(foreground: accent-color-1)[#body]
  }

  let title-page(doc-title, doc-subtitle, bg-image-path) = {
    set page(
      paper: config.paper,
      margin: margin,
      // background: image(bg-image-path, width: 100%, height: 100%, fit: "cover"),
    )

    // align(top + left)[
    //   #if (type(logos.title-page) == str) {
    //     image(logos.title-page, width: 1.5in)
    //   } else {
    //     logos.title-page
    //   }
    // ]

    align(horizon + center)[
      #title-style(doc-title)
      #subtitle-style(doc-subtitle)
    ]
  }

  if config.show-title {
    title-page(
      title,
      sub-title,
      bg-image-path,
    )
    pagebreak()
  }

  counter(page).update(1)

  set page(
    paper: config.paper,
    margin: margin,
    background: none,
    footer: context [#text(gray)[Alex Donnellan (46963037)] #h(1fr) Page #counter(page).display("1")],
  )
  show heading.where(level: 1): it => {
    // pagebreak()
    // v(1fr)
    v(2em)
    let texts = text-styles(config: config)
    set text(
      font: texts.h1.font,
      size: texts.h1.size,
      weight: texts.h1.weight,
      texts.h1.color,
    )

    align(left)[ #it ] // Include numbering
    // v(0.8em)
    // line(length: 100%, stroke: (1pt, colors.primary-color))
    // v(0.8em)
    // v(1em)
    // v(2fr) // Fill remaining space below
  }

  if "top" in margin {
    set page(
      margin: (
        top: margin.top + 1cm,
        bottom: margin.bottom + 1cm,
        left: margin.left,
        right: margin.right,
      ),
      header-ascent: 50%,
      footer-descent: 50%,
    )
  } else {
    set page(
      margin: (
        y: margin.y + 1cm,
        inside: margin.inside,
        outside: margin.outside,
      ),
      header-ascent: 50%,
      footer-descent: 50%,
    )
  }

  doc

  // end-page(logos.end-page)
}



#let styled-outline() = {
  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 2): set outline.entry(fill: none)
  show outline.entry.where(level: 3): set outline.entry(fill: none)
  show outline.entry.where(level: 4): set outline.entry(fill: none)
  show outline.entry.where(level: 5): set outline.entry(fill: none)
  show outline.entry.where(level: 6): set outline.entry(fill: none)

  show outline.entry.where(level: 1): set block(above: 2em, width: 40%)
  show outline.entry.where(level: 2): set block(above: 0.5em, width: 40%)
  show outline.entry.where(level: 3): set block(above: 0.5em, width: 40%)
  show outline.entry.where(level: 4): set block(above: 0.5em, width: 40%)
  show outline.entry.where(level: 5): set block(above: 0.5em, width: 40%)
  show outline.entry.where(level: 6): set block(above: 0.5em, width: 40%)


  text(size: 32pt, weight: "regular")[Contents]
  v(0.5em)

  outline(
    title: none,
    // indent: 0em,
    depth: 2,
  )
}

// #let full-page-image(
//   image-path,
//   background-pattern: None,
//   text-content: none,
//   font-color: white,
//   landscape: true,
//   res: 720,
// ) = {
//   set page(
//     paper: "us-letter",
//     flipped: landscape,
//     margin: 0cm,
//     background: image(
//       cpath(background-pattern, res: res),
//       width: 100%,
//       height: 100%,
//       fit: "cover",
//     ),
//   )

//   align(center + horizon)[
//     #shadowed(
//       fill: white,
//       radius: 8pt,
//       inset: 0pt,
//       clip: true,
//       shadow: 8pt,
//       color: rgb(89, 85, 101, 30%),
//     )[
//       #if landscape { image(image-path, width: 85%) } else {
//         image(image-path, height: 85%)
//       }
//     ]
//   ]

//   if text-content != none {
//     align(center + horizon)[
//       #text(size: 3em, weight: "bold", font-color)[#text-content]
//     ]
//   }
// }


#let image-break(image-path, side: "top", height: auto, inset: 0pt) = {
  if side == "top" {
    pagebreak()
    align(top + center)[#box(
      image(image-path, width: 100%, height: height, fit: "cover"),
      inset: inset,
      clip: true,
    )]
  } else if side == "bottom" {
    align(bottom + center)[
      #box(
        image(image-path, width: 100%, height: height, fit: "cover"),
        inset: inset,
        clip: true,
      )
    ]
    pagebreak()
  } else {
    panic("Invalid side for image-break. Use 'top' or 'bottom'.")
  }
}



#let image-divider(
  image-path,
  height: 20%,
  vertical-space: 1fr,
  vertical-pad: 2em,
  fit: "cover",
) = {
  v(vertical-space)
  pad(
    box(
      width: 100%,
      height: height,
      image(
        image-path,
        width: 100%,
        height: auto,
        fit: fit,
      ),
    ),
    top: vertical-pad,
    bottom: vertical-pad,
    left: 0em,
    right: 0em,
  )
  v(vertical-space)
}

// Define the feature-list block with a 2-column grid
#let feature-list(
  title: "Title",
  subtitle: "Subtitle",
  description: none,
  image-path: none,
  features: none,
  colors: default-config.colors,
  row-space: 0.5em,
) = grid(
  columns: (1fr, 2fr),
  // gutter: 2em,
  inset: (top: row-space, bottom: row-space, left: 0em, right: 0em),
  // First row: title section and image
  grid.hline(stroke: 0.5pt + black),

  block[
    // #v(1em)
    #heading(title, depth: 2)
    #text(subtitle)
    #v(1em)
    #text(description)
  ],
  // block[],block[],

  align(right + bottom)[
    #v(1em)
    #image(image-path, width: 90%)
  ],
  grid.hline(stroke: 0.5pt + black),

  // Subsequent rows: feature titles and lists
  ..features
    .enumerate()
    .map(((i, feature)) => (
      {
        set text(size: 10pt)
        heading(
          [
            #text(fill: colors.secondary-color, weight: "bold")[#upper(
              ("0" + str(i + 1)).slice(-2) + ". ",
            )]#upper(feature.title)
          ],
          depth: 3,
        )
      },
      {
        set text(size: 10pt)
        list(..feature.points)
      },
      grid.hline(stroke: 0.5pt + black),
    ))
    .flatten(),
)





// #let annotated-image(
//   annotations: (),
//   colors: default-config.colors,
//   cap-radius: 3pt,
//   fill: none,
//   light-mode: true,
//   background: {
//     align(bottom + right)[
//       #image(
//         "/Typst/figures/Deep Insight - pipelines dashboard.png",
//         width: 80%,
//         height: auto,
//       )
//     ]
//   },
// ) = {
//   set page(
//     flipped: true,
//     footer: none,
//     header: none,
//     fill: fill,
//     background: background,
//     foreground: {
//       for annotation in annotations {
//         place(
//           top + left,
//           dx: annotation.start.x * 100% - cap-radius / 2 - 5pt / 4,
//           dy: annotation.start.y * 100% - cap-radius / 2,
//           circle(radius: cap-radius, fill: colors.accent-color-2, stroke: none),
//         )
//         place(
//           top + left,
//           dx: annotation.start.x * 100%,
//           dy: annotation.start.y * 100%,
//           line(
//             start: (0pt, 0pt),
//             end: (
//               (annotation.end.x - annotation.start.x) * 100%,
//               (annotation.end.y - annotation.start.y) * 100%,
//             ),
//             stroke: cap-radius / 1.5 + colors.accent-color-2,
//           ),
//         )

//         // Calculate text position and alignment based on the align parameter
//         // FIXME: the top and bottom haven't been refined or tested.
//         let text-align = annotation.at("align", default: "right")
//         let (text-dx, text-dy, block-align) = if text-align == "top" {
//           (
//             annotation.end.x * 100% - 75pt,
//             annotation.end.y * 100% - 30pt,
//             center,
//           )
//         } else if text-align == "bottom" {
//           (annotation.end.x * 100%, annotation.end.y * 100% + 10pt, left)
//         } else if text-align == "left" {
//           (
//             annotation.end.x * 100%
//               - if "width" in annotation { annotation.width + 10pt } else {
//                 160pt
//               },
//             annotation.end.y * 100% - 5pt,
//             right,
//           )
//         } else {
//           // default "right"
//           (annotation.end.x * 100% + 5pt, annotation.end.y * 100% - 5pt, left)
//         }

//         place(
//           top + left,
//           dx: text-dx,
//           dy: text-dy,
//           align(block-align)[
//             #block(
//               width: if "width" in annotation { annotation.width } else {
//                 150pt
//               },
//               inset: (left: 0.25em, top: 0.25em),
//               fill: if light-mode { white } else { black },
//             )[
//               #text(
//                 size: 16pt,
//                 fill: if light-mode { black } else { white },
//                 weight: "extrabold",
//                 annotation.title,
//               )
//               #linebreak()
//               #text(
//                 size: 14pt,
//                 fill: if light-mode { rgb("#5f5c5cb3") } else {
//                   rgb("#a0a0a0")
//                 },
//                 weight: "bold",
//                 annotation.body,
//               )
//             ]
//           ],
//         )
//       }
//     },
//   )
// }


#let table-list(
  items: (
    (
      heading: "Impactful words",
      content: "This is a list of impactful words that can be used in your document.",
    ),
    (
      heading: "More words",
      content: "This is a list of impactful words that can be used in your document.",
    ),
  ),
  row-space: 1em,
  content-emphasis: "subtle",
  config: default-config,
) = {
  let text-size = if (content-emphasis == "regular") { 12pt } else if (
    content-emphasis == "subtle"
  ) { 10pt } else {
    panic("Invalid content-emphasis. Use 'regular' or 'subtle'.")
  }
  grid(
    columns: (3em, auto, 1fr),
    // gutter: 2em,
    inset: (top: row-space, bottom: row-space, left: 0em, right: 2em),

    // block[],block[],

    // Subsequent rows: feature titles and lists
    ..items
      .enumerate()
      .map(((i, item)) => (
        text(fill: config.colors.secondary-color, weight: "bold")[#upper(
          ("0" + str(i + 1)).slice(-2) + ". ",
        )],
        {
          set text(size: text-size)
          heading(
            [
              #upper(item.heading)
            ],
            depth: 3,
          )
        },
        {
          set text(size: text-size)
          item.content
        },
        if i != items.len() - 1 {
          grid.hline(stroke: 0.5pt + black)
        },
      ))
      .flatten()
  )
}

#let executive-summary(
  headline: "Big Bold Statement",
  outline-heading: "Executive Summary",
  config: default-config,
  body,
) = {
  // pagebreak()
  set page(
    // fill: config.colors.primary-background,
    header: none,
    footer: none,
  )

  align(top + left)[
    #block(width: 70%)[
      #style-text(
        headline,
        config: default-config,
        style: "headline",
        depth: none,
      )
    ]
  ]
  invisible-heading(outline-heading, depth: 1)
  v(5mm)
  body
  // pagebreak()
}
