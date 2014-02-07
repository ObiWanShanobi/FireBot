# Description:
#   Play a game of chess!
#
# Dependencies:
#   "chess": "0.2.0"
#
# Configuration:
#   None
#
# Commands:
#   hubot chess start <nick> - Creates a new game between yourself and <nick>
#   hubot chess status <nick> - Gets the current state of the board
#   hubot chess status <nick1> <nick2> - Gets the current state of the board
#   hubot chess move <nick> <to> - Moves a piece to the coordinate position using standard chess notation
#   hubot chess undo <nick> - Reverts the last move
#   hubot chess clear <nick> - Clears the game between you and <nick>
#
# Author:
#   EvanDotPro, original by thallium205
#

Chess       = require 'chess'
ShortUrl    = require 'shorturl'
#urlShortner = 'arseh.at'
urlShortner = false

module.exports = (robot) ->
  robot.respond /chess clear +([^ ]+)/i, (msg) ->
    name = getMentionName robot, msg.message.user.name
    game = getGame robot.brain, name, msg.match[1]
    if not game
      msg.send 'No game found between ' + name + ' and ' + msg.match[1]
      return
    deleteGame robot.brain, name, msg.match[1]
    msg.send 'Game cleared.'

  robot.respond /chess start +([^ ]+)/i, (msg) ->
    name = getMentionName robot, msg.message.user.name
    game = createGame robot.brain, name, msg.match[1]
    if not game
      msg.send 'Game already exists. Use `chess clear ' + msg.match[1] + '` to reset the game or `chess status ' + msg.match[1] + '` to see the game.'
      return

    boardToFen game.getStatus(), (status, fen) ->
      url = 'http://webchess.freehostia.com/diag/chessdiag.php?fen=' + encodeURIComponent(fen) + '&size=large&coord=yes&cap=yes&stm=yes&fb=no&theme=classic&format=auto&color1=E3CEAA&color2=635147&color3=000000&.png'
      MyShortUrl url, urlShortner, (result) ->
        msg.send 'New game created: ' + result

  robot.respond /chess undo +([^ ]+)/i, (msg) ->
    name = getMentionName robot, msg.message.user.name
    try
      game = hasGame robot.brain, name, msg.match[1]
      if not game
        msg.send 'No game found between ' + name + ' and ' + msg.match[1]
        return
      undoMove robot.brain, name, msg.match[1]
      game = getGame robot.brain, name, msg.match[1]
      boardToFen game.getStatus(), (status, fen) ->
        if status
          msg.send status
        url = 'http://webchess.freehostia.com/diag/chessdiag.php?fen=' + encodeURIComponent(fen) + '&size=large&coord=yes&cap=yes&stm=yes&fb=no&theme=classic&format=auto&color1=E3CEAA&color2=635147&color3=000000&.png'
        MyShortUrl url, urlShortner, (result) ->
          msg.send 'Last move reverted: ' + result
    catch e
      msg.send e

  robot.respond /chess status ([^ ]+) ([^ ]+)/i, (msg) ->
    try
      game = getGame robot.brain, msg.match[1], msg.match[2]
      if not game
        msg.send 'No games found between ' + msg.match[1] + ' and ' + msg.match[2]
        return
      boardToFen game.getStatus(), (status, fen) ->
        if status
          msg.send status
        url = 'http://webchess.freehostia.com/diag/chessdiag.php?fen=' + encodeURIComponent(fen) + '&size=large&coord=yes&cap=yes&stm=yes&fb=no&theme=classic&format=auto&color1=E3CEAA&color2=635147&color3=000000&.png'
        MyShortUrl url, urlShortner, (result) ->
          msg.send msg.match[1] + ' vs. ' + msg.match[2] + ': ' + result
    catch e
      msg.send e

  robot.respond /chess status ([^ ]+) *$/i, (msg) ->
    name = getMentionName robot, msg.message.user.name
    try
      game = getGame robot.brain, name, msg.match[1]
      if not game
        msg.send 'No game found between ' + name + ' and ' + msg.match[1]
        return
      boardToFen game.getStatus(), (status, fen) ->
        if status
          msg.send status
        url = 'http://webchess.freehostia.com/diag/chessdiag.php?fen=' + encodeURIComponent(fen) + '&size=large&coord=yes&cap=yes&stm=yes&fb=no&theme=classic&format=auto&color1=E3CEAA&color2=635147&color3=000000&.png'
        MyShortUrl url, urlShortner, (result) ->
          msg.send result
    catch e
      msg.send e

  robot.respond /chess move +([^ ]+) +(.*)/i, (msg) ->
    name = getMentionName robot, msg.message.user.name
    try
      game = hasGame robot.brain, name, msg.match[1]
      if not game
        msg.send 'No game found between ' + name + ' and ' + msg.match[1]
        return
      game = addMove robot.brain, name, msg.match[1], msg.match[2]
      boardToFen game.getStatus(), (status, fen) ->
        if status
          msg.send status
        url = 'http://webchess.freehostia.com/diag/chessdiag.php?fen=' + encodeURIComponent(fen) + '&size=large&coord=yes&cap=yes&stm=yes&fb=no&theme=classic&format=auto&color1=E3CEAA&color2=635147&color3=000000&.png'
        MyShortUrl url, urlShortner, (result) ->
          msg.send result
    catch e
      msg.send e

MyShortUrl = (url, urlShortner, callback) ->
  if not urlShortner
    callback url
    return
  ShortUrl url, urlShortner, callback

getMentionName = (robot, name) ->
  console.log 'Searching for: ' + name
  for id, user of robot.brain.data.users
    console.log '  - ' + user.name
    if user.name == name
      return user.mention_name
  return name

createGame = (brain, player1, player2) ->
  if not brain.data.chessGames?
    brain.data.chessGames = {}
  key = gameKey player1, player2
  if not brain.data.chessGames[key]?
    brain.data.chessGames[key] = []
    return Chess.create()
  return false

addMove = (brain, player1, player2, move) ->
  if not brain.data.chessGames?
    brain.data.chessGames = {}
  key = gameKey player1, player2
  game = getGame brain, player1, player2
  try
    game.move move
    brain.data.chessGames[key].push(move)
  catch e
    throw e
  return game

deleteGame = (brain, player1, player2) ->
  if not brain.data.chessGames?
    brain.data.chessGames = {}
  key = gameKey player1, player2
  delete brain.data.chessGames[key]

undoMove = (brain, player1, player2) ->
  if not brain.data.chessGames?
    brain.data.chessGames = {}
  key = gameKey player1, player2
  brain.data.chessGames[key].pop()

hasGame = (brain, player1, player2) ->
  if not brain.data.chessGames?
    brain.data.chessGames = {}
  key = gameKey player1, player2
  if not brain.data.chessGames[key]?
    return false
  return true

getGame = (brain, player1, player2) ->
  if not brain.data.chessGames?
    brain.data.chessGames = {}
  key = gameKey player1, player2
  if not brain.data.chessGames[key]?
    return false
  moves = getGameMoves brain, player1, player2
  game = Chess.create()
  game.move move for move in moves
  return game

getGameMoves = (brain, player1, player2) ->
  if not brain.data.chessGames?
    brain.data.chessGames = {}
  game = gameKey player1, player2
  return brain.data.chessGames[game]

gameKey = (player1, player2) ->
  key = [player1.toLowerCase().replace('@',''), player2.toLowerCase().replace('@','')].sort().toString()
  console.log 'Game key: ' + key
  return key

boardToFen = (status, callback) ->
  fen = [[],[],[],[],[],[],[],[]]
  blank = 0
  lastRank = 0
  for square in status.board.squares
    if lastRank isnt square.rank
      if blank isnt 0
        fen[lastRank - 1].push(blank)
        blank = 0
    if square.piece is null
      blank = blank + 1
    else
      if square.piece.type is 'pawn'
        if blank is 0
          fen[square.rank - 1].push(if square.piece.side.name is 'white' then 'P' else 'p')
        else
          fen[square.rank - 1].push(blank)
          fen[square.rank - 1].push(if square.piece.side.name is 'white' then 'P' else 'p')
          blank = 0
      else
        if blank is 0
          fen[square.rank - 1].push(if square.piece.side.name is 'white' then square.piece.notation.toUpperCase() else square.piece.notation.toLowerCase())
        else
          fen[square.rank - 1].push(blank)
          fen[square.rank - 1].push(if square.piece.side.name is 'white' then square.piece.notation.toUpperCase() else square.piece.notation.toLowerCase())
          blank = 0
    lastRank = square.rank
  for rank in fen
    rank = rank.join()
  fen = fen.reverse().join('/').replace(/,/g,'')

  msg = ''
  if status.isCheck
    msg += 'Check! '
  if status.isCheckmate
    msg += 'Checkmate! '
  if status.isRepetition
    msg += 'Threefold Repetition!  A draw can be called. '
  if status.isStalemate
    msg += 'Stalemate! '
  if Object.keys(status.notatedMoves).length > 0
    if status.notatedMoves[Object.keys(status.notatedMoves)[0]].src.piece.side.name is 'white'
      fen += ' w'
    else
      fen += ' b'

  callback msg, fen

