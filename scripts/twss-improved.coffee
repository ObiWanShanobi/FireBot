# Description
#   Improved version of twss.coffee.
#
# Dependencies:
#   "twss": "0.1.6"
#
# Commands:
#   (.*) - Replies "That's what she said!" if appropriate.
#
# Author:
#   EvanDotPro

twss = require('twss')

module.exports = (robot) ->

  twss.threshold = 0.97

  robot.catchAll (msg) ->
    if not msg.message.text
        return

    # Only run for non-mention messages.
    if msg.message.text.match(new RegExp("^@?" + msg.robot.name + "(.+)", "i"))
        return

    # This is only really needed if you remove the bit above
    replace = new RegExp("^(@?" + msg.robot.name + "[:,]?)", "i")
    data = msg.message.text.trim().replace(replace, '').trim()

    if data.match(new RegExp("^can you (.+)", "i"))
        return

    if msg.message.text and twss.is(data)
        console.log 'TWSS: ' + data
        console.log "TWSS Probability: " + twss.prob(data)
        msg.send("That's what she said!")
