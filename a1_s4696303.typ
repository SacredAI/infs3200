#import "./template.typ": (
  PRINT_MARGIN, default-config, end-page, executive-summary, feature-list, image-break, image-divider,
  invisible-heading, style-text, styled-outline, table-list, template,
)
#import "@preview/pintorita:0.1.4"

#set heading(numbering: "1.")

#show raw.where(lang: "pintora"): it => pintorita.render(it.text)

#let colors = (
  primary-background: rgb(173, 216, 230),
  primary-color: rgb("#59ade0"),
  secondary-color: rgb("#e0a0aa"),
  accent-color-1: rgb(186, 85, 211),
  accent-color-2: rgb(144, 238, 144),
  text-dark: rgb(51, 51, 51),
  text-light: rgb(51, 51, 51),
)

#let config = (
  ..default-config,
  colors: colors,
  title: "INFS3200 A1",
  sub-title: "Alex Donnellan (46963037)",
  paper: "us-letter",
  show-title: true,
)

#show: template.with(
  title: config.title,
  sub-title: config.sub-title,
  colors: config.colors,
  config: config,
)

#show: body => {
  for elem in body.children {
    if elem.func() == math.equation and elem.block {
      let numbering = if "label" in elem.fields().keys() { "(1)" } else { none }
      set math.equation(numbering: numbering)
      elem
    } else {
      elem
    }
  }
}

#styled-outline()

#pagebreak()


