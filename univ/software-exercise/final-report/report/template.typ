#let project(title: "", author: "", affiliation: "", body) = {
  // Set the document's basic properties.
  set document(author: author, title: title)
  set page(numbering: "1", number-align: center)
  set text(font: "Noto Sans CJK JP", lang: "ja")
  // Set the numbering
  set heading(numbering: "1.")
  set math.equation(numbering: "(1)")
  // Set the table style.
  show table.cell.where(y: 0): set text(weight: "bold")
  // Title row.
  align(center)[
    #block(text(weight: 700, 1.75em, title))
  ]
  // Author information.
  align(right)[
    #block(affiliation)
    #block(author)
  ]
  // Main body.
  set par(justify: true)
  body
}