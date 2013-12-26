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
    return {turn: whoStarts, currentTableId: null}

  nextTurnBy: ->
    currentTurn = @.state.turn
    nextTurn = if currentTurn == "xs" then "os" else "xs"
    return nextTurn

  handleCellClick: (clickedCellId)->
    @.setState({turn: @.nextTurnBy(), currentTableId: clickedCellId})

  render: ->
    tables = [1..9].map (i) =>
      return Table(
        {
          turn: @.state.turn
          tableId: i
          currentTableId: @.state.currentTableId
          handleCellClick: @.handleCellClick
        }
      )

    return (
      (div {className: "big-table"}, [
        (h2 {}, "It's #{@.state.turn} turn!"),
        (div {}, tables)
      ])
    )
})

Table = React.createClass({
  isActive: ->
    if @.props.currentTableId
      @.props.currentTableId == @.props.tableId
    else
      true

  render: ->
    cellProps = (count) =>
      return {
        turn: @.props.turn
        cellId: count
        handleCellClick: @.props.handleCellClick
      }

    renderCells = (range) ->
      cells = range.map (i) =>
        return Cell(cellProps(i))
      return cells

    return (
      (div {className: "col-md-4"}, [
        (div {className: "overlay"}) unless @.isActive(),
        (table {className: "smallTable table table-bordered #{"active-table" if @.isActive()}"},
          (tbody {}, [
            (tr {}, renderCells([1..3])),
            (tr {}, renderCells([4..6])),
            (tr {}, renderCells([7..9]))
          ])
        )
      ])
    )
})

Cell = React.createClass({
  getInitialState: ->
    return {owner: null}

  handleClick: ->
    # There's no point in updating a cell
    # if it already has an owner.
    unless @.state.owner
      @.setState {owner: @.props.turn}
      @.props.handleCellClick(@.props.cellId)

  render: ->
    owner = @.state.owner || "none"
    return (td {className: "cell #{owner}", onClick: @.handleClick})
})

React.renderComponent(
  Game({}),
  document.getElementById('game')
)
