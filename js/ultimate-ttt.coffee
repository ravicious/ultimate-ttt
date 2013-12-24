{div, h1, h2, h3, textarea, span, form, input, br,
table, tbody, tr, th, td, ul, li} = React.DOM

# http://coffeescriptcookbook.com/chapters/arrays/shuffling-array-elements
do -> Array::shuffle ?= ->
  for i in [@length-1..1]
    j = Math.floor Math.random() * (i + 1)
    [@[i], @[j]] = [@[j], @[i]]
  @

BigTable = React.createClass({
  getInitialState: ->
    whoStarts = ["xs", "os"].shuffle()[0]
    return {turn: whoStarts}

  render: ->
    smallTables = [1..9].map ->
      return SmallTable({})

    return (
      (div {className: "bigTable"}, [
        (h2 {}, "It's #{this.state.turn} turn!"),
        (div {className: "row"}, smallTables)
      ])
    )
})

SmallTable = React.createClass({
  render: ->
    rows = [1..3].map ->
      return TableRow({})

    return (
      (div {className: "col-md-4"},
        (table {className: "smallTable table table-bordered"},
          (tbody {}, rows)
        )
      )
    )
})

TableRow = React.createClass({
  render: ->
    cells = [1..3].map ->
      return Cell({})

    return (tr {className: 'tableRow'}, cells)
})

Cell = React.createClass({
  render: ->
    return (td {className: 'cell'})
})

React.renderComponent(
  BigTable({}),
  document.getElementById('game')
)
