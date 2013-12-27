{div, h1, h2, h3, textarea, span, form, input, br,
table, tbody, tr, th, td, ul, li, a} = React.DOM

# http://stackoverflow.com/a/17903018/742872
do -> Array::uniq ?= ->
  @.reduce (p, c) ->
    p.push(c) if (p.indexOf(c) < 0)
    p
  , []

class TicTacToeReferee
  constructor: (@fieldValues) ->

  validFields: ["X", "O"]

  areFieldsEqual: (id1, id2, id3) ->
    unique = [@fieldValues[id1], @fieldValues[id2], @fieldValues[id3]].uniq()
    if unique.length == 1
      true
    else
      false

  anyEmptyCells: ->
    null in @fieldValues

  decision: ->
    winningStates = [
      [0, 1, 2], [0, 3, 6], [0, 4, 8],
      [1, 4, 7],
      [2, 5, 8], [2, 4, 6],
      [3, 4, 5],
      [6, 7, 8]
    ]

    winner = null

    for states in winningStates
      cellValue = @fieldValues[states[0]]

      if cellValue in @validFields and @areFieldsEqual(states[0], states[1], states[2])
        winner = cellValue
        break

    if winner
      winner
    else
      if @anyEmptyCells()
        "continue"
      else
        "tie"

Game = React.createClass({
  getInitialState: ->
    return {
      turn: "O"
      currentTableId: null
      tableStates: [null, null, null, null, null, null, null, null, null]
    }

  gameState: ->
    referee = new TicTacToeReferee @.state.tableStates
    dec = referee.decision()

  isFinished: ->
    @.gameState() != "continue"

  nextTurnBy: ->
    currentTurn = @.state.turn
    nextTurn = if currentTurn == "X" then "O" else "X"
    return nextTurn

  handleTableClick: (data)->
    state = @.state

    unless @.isFinished()
      # if table isn't finished
      if @.state.tableStates[data.nextTableId] == null
        currentTableId = data.nextTableId
      else
        currentTableId = null

      state.turn = @.nextTurnBy()
      state.currentTableId = currentTableId
    else
      # make all tables non-clickable
      state.currentTableId = 1337
    @.setState state


  markTableAsFinished: (tableId, gameState) ->
    state = @.state
    state.tableStates[tableId] = gameState
    @.setState state

  progress: ->
    if @.isFinished()
      if @.gameState() == "tie"
        "It's a tie!"
      else
        "#{@.gameState()} won!"
    else
      "It's #{@.state.turn} turn!"

  render: ->
    renderTables = (range) =>
      return range.map (i) =>
        return Table({
          turn: @.state.turn
          tableId: i
          currentTableId: @.state.currentTableId
          handleTableClick: @.handleTableClick
          markTableAsFinished: @.markTableAsFinished
        })

    return (
      (div {className: "big-table"}, [
        (div {className: "info"}, [
          (h1 {}, "Ultimate TTT")
          (a {
            href: "http://mathwithbaddrawings.com/2013/06/16/ultimate-tic-tac-toe/"
          }, (h3 {}, "Read the rules")),
          (h2 {}, @.progress()),
          (a {
            href: ""
          }, (h3 {}, "Restart the game")) if @.isFinished(),
        ])
        (div {className: "game-row"}, renderTables([0..2])),
        (div {className: "game-row"}, renderTables([3..5])),
        (div {className: "game-row"}, renderTables([6..8]))
      ])
    )
})

Table = React.createClass({
  getInitialState: ->
    return {cellOwners: [null, null, null, null, null, null, null, null, null]}

  gameState: ->
    referee = new TicTacToeReferee @.state.cellOwners
    referee.decision()

  isActive: ->
    if @.isFinished()
      false
    else
      unless @.props.currentTableId == null
        @.props.currentTableId == @.props.tableId
      else
        true

  isFinished: ->
    @.gameState() != "continue"

  setCellOwner: (owner, cellId) ->
    state = @.state
    state.cellOwners[cellId] = owner
    @.setState state

  handleCellClick: (cellId) ->
    @.setCellOwner @.props.turn, cellId

    @.props.markTableAsFinished(@.props.tableId, @.gameState()) if @.isFinished()

    @.props.handleTableClick({nextTableId: cellId, tableId: @.props.tableId})

  render: ->
    cellProps = (count) =>
      return {
        turn: @.props.turn
        cellId: count
        handleCellClick: @.handleCellClick
        owner: @.state.cellOwners[count]
      }

    renderCells = (range) ->
      cells = range.map (i) =>
        return Cell(cellProps(i))
      return cells

    renderOverlay = =>
      className = "overlay"
      content = null

      if @.isFinished()
        className += " finished"
        content = @.gameState()

      return (div {className: className}, content)

    return (
      (div {className: "table-container"}, [
        renderOverlay() unless @.isActive(),
        (table {className: "small-table table table-bordered #{"active-table box-shadow" if @.isActive()}"},
          (tbody {}, [
            (tr {}, renderCells([0..2])),
            (tr {}, renderCells([3..5])),
            (tr {}, renderCells([6..8]))
          ])
        )
      ])
    )
})

Cell = React.createClass({
  handleClick: ->
    # There's no point in updating a cell
    # if it already has an owner.
    unless @.props.owner
      @.props.handleCellClick(@.props.cellId)

  render: ->
    owner = @.props.owner || "none"
    return (td {className: "cell #{owner}", onClick: @.handleClick})
})

React.renderComponent(
  Game({}),
  document.getElementById('game')
)
