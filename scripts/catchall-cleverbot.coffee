# Description
#   Send all uncaught commands to cleverbot.
#   Based on:
#   https://github.com/github/hubot-scripts/blob/master/src/scripts/cleverbot.coffee
#
# Dependencies:
#   "cleverbot-node": "0.1.1"
#
# Commands:
#   hubot (.*) - If not caught by another script, replies with cleverbot response.
#
# Author:
#   EvanDotPro

cleverbot = require('cleverbot-node')

module.exports = (robot) ->
  c = new cleverbot()

  robot.catchAll (msg) ->
    search = new RegExp("^@?" + msg.robot.name + "(.+)", "i")
    if msg.message.text and msg.message.text.match(search)
        replace = new RegExp("^(@?" + msg.robot.name + "[:,]?)", "i")
        data = msg.message.text.trim().replace(replace, '').trim()
        console.log('« CLEVERBOT: ' + data)
        c.write(data, (c) =>
            console.log('» CLEVERBOT: ' + c.message)
            msg.send(c.message)
        )
