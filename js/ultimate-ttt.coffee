{div, h1, h2, h3, textarea, span, form, input, br,
table, tbody, tr, th, td, ul, li} = React.DOM

# http://coffeescriptcookbook.com/chapters/arrays/shuffling-array-elements
do -> Array::shuffle ?= ->
  for i in [@length-1..1]
    j = Math.floor Math.random() * (i + 1)
    [@[i], @[j]] = [@[j], @[i]]
  @

Game = React.createClass({
  getInitialState: ->
    whoStarts = ["xs", "os"].shuffle()[0]
    return {turn: whoStarts}

  nextTurnBy: ->
    currentTurn = @.state.turn
    nextTurn = if currentTurn == "xs" then "os" else "xs"
    return nextTurn

  handleCellClick: ->
    @.setState({turn: this.nextTurnBy()})

  render: ->
    tables = [1..9].map =>
      return Table({turn: this.state.turn, handleCellClick: this.handleCellClick})

    return (
      (div {className: "bigTable"}, [
        (h2 {}, "It's #{this.state.turn} turn!"),
        (div {className: "row"}, tables)
      ])
    )
})

Table = React.createClass({
  render: ->
    rows = [1..3].map =>
      return TableRow({turn: this.props.turn, handleCellClick: this.props.handleCellClick})

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
    cells = [1..3].map =>
      return Cell({turn: this.props.turn, handleCellClick: this.props.handleCellClick})

    return (tr {className: 'tableRow'}, cells)
})

Cell = React.createClass({
  getInitialState: ->
    return {owner: null}

  handleClick: ->
    # There's no point in updating a cell
    # if it already has an owner.
    unless this.state.owner
      @.setState {owner: this.props.turn}
      this.props.handleCellClick()

  render: ->
    owner = this.state.owner || "none"
    return (td {className: "cell #{owner}", onClick: this.handleClick})
})

React.renderComponent(
  Game({}),
  document.getElementById('game')
)
