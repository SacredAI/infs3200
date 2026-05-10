#import "../template.typ": (
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

= Task 1

= Q1

```python
from a2.src import P4
from a2.src.helpers import nested_loop
from p4.DataLinkage_py.src.data.db_loader import db_loader
from p4.DataLinkage_py.src.data.measurement import calc_measure, load_benchmark


# REF: https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Python
def levenshtein(s1, s2):
    if len(s1) < len(s2):
        return levenshtein(s2, s1)

    # len(s1) >= len(s2)
    if len(s2) == 0:
        return len(s1)

    previous_row = range(len(s2) + 1)
    for i, c1 in enumerate(s1):
        current_row = [i + 1]
        for j, c2 in enumerate(s2):
            insertions = (
                previous_row[j + 1] + 1
            )  # j+1 instead of j since previous_row and current_row are one character longer
            deletions = current_row[j] + 1  # than s2
            substitutions = previous_row[j] + (c1 != c2)
            current_row.append(min(insertions, deletions, substitutions))
        previous_row = current_row

    return previous_row[-1]


if __name__ == "__main__":
    restaurants = db_loader()
    benchmark = load_benchmark(P4 / "data" / "restaurant_pair.csv")
    for t in [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]:
        count = 0
        res = []
        for i, j in nested_loop(restaurants):
            name1 = i.get_name()
            name2 = j.get_name()
            edi_dist = levenshtein(name1, name2)
            sim = 1 - (edi_dist / max(len(name1), len(name2)))
            if sim >= t:
                count += 1
                res.append(f"{str(i.get_id())}_{str(j.get_id())}")

        print(f"Threshold: {t} similar count: {count}")
        calc_measure(res, benchmark)
        print("------------------------------")
```

#image("assets/t1.1.png")

== Q2
