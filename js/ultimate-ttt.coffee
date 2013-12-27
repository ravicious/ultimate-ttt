{div, h1, h2, h3, textarea, span, form, input, br,
table, tbody, tr, th, td, ul, li} = React.DOM

# http://coffeescriptcookbook.com/chapters/arrays/shuffling-array-elements
do -> Array::shuffle ?= ->
  for i in [@length-1..1]
    j = Math.floor Math.random() * (i + 1)
    [@[i], @[j]] = [@[j], @[i]]
  @

# http://stackoverflow.com/a/17903018/742872
do -> Array::uniq ?= ->
  @.reduce (p, c) ->
    p.push(c) if (p.indexOf(c) < 0)
    p
  , []

class TicTacToeReferee
  constructor: (@state) ->

  checkIfFieldsAreEqual: (id1, id2, id3) ->
    unique = [@state[id1], @state[id2], @state[id3]].uniq()
    if unique.length == 1 and unique[0] != null
      true
    else
      false

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
      if @checkIfFieldsAreEqual(states[0], states[1], states[2])
        winner = @state[states[0]]
        break

    if winner
      winner
    else
      # if there's no empty cells
      if @state.indexOf(null) == -1
        "tie"
      else
        "continue"

Game = React.createClass({
  getInitialState: ->
    whoStarts = ["xs", "os"].shuffle()[0]
    return {turn: whoStarts, currentTableId: null, finishedTables: []}

  nextTurnBy: ->
    currentTurn = @.state.turn
    nextTurn = if currentTurn == "xs" then "os" else "xs"
    return nextTurn

  handleTableClick: (data)->
    state = @.state

    # if table isn't finished
    if @.state.finishedTables.indexOf(data.nextTableId) == -1
      currentTableId = data.nextTableId
    else
      currentTableId = null

    state.turn = @.nextTurnBy()
    state.currentTableId = currentTableId
    @.setState state

  markTableAsFinished: (tableId) ->
    state = @.state
    state.finishedTables.push tableId
    @.setState state

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
        (h1 {className: "info"}, "Ultimate TTT"),
        (h2 {className: "info"}, "It's #{@.state.turn} turn!"),
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
    @.props.markTableAsFinished(@.props.tableId) if @.isFinished()

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
