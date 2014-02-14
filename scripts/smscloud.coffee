# Description:
#   Display SMSCloud status information
#
# Commands:
#   hubot smscloud queue - Display SMSCloud message queue size
#   hubot smscloud our queue size - Look up the queue size for the configured API key
#   hubot smscloud our did queues - List all DID queues for the configured API key
#   hubot smscloud culprit - Display the largest DID queue
#   hubot smscloud send an sms to <toNumber> [from <fromNumber>] [with message <message>] - Sends an SMS to a given number, from a given number, with a given message (or "test")
#   hubot smscloud what carrier for <number> - NVS lookup for a given number

jayson = require('jayson')

mainFromNumber = process.env.HUBOT_SMSCLOUD_FROMNUMBER
smsCloudApiKey = process.env.HUBOT_SMSCLOUD_API_KEY

smscloudClient = jayson.client.http({
    hostname: 'api.smscloud.com',
    path: '/jsonrpc?key=' + smsCloudApiKey
})

module.exports = (robot) ->
  smscloudUpdateIntervalId = null

  robot.respond /smscloud queue/i, (msg) ->
    smscloudQueue msg
  
  robot.respond /smscloud our queue size/i, (msg) ->
    smscloudKeyQueue msg, (result) ->
      queueSize = 0
      for did, queue of result.queues
        queueSize = queueSize + parseInt(queue.length)
      msg.send "Our queue is #{queueSize} messages right now"
  
  robot.respond /smscloud our did queues/i, (msg) ->
    smscloudKeyQueue msg, (result) ->
      queueList = []
      for did, queue of result.queues
        queueList.push("#{queue.did}: #{queue.length}")
      msg.send queueList.join("\n")
  
  robot.respond /smscloud culprit/i, (msg) ->
    smscloudLargestQueue msg
  
  robot.respond /send (?:an )?sms to ([\+\d]+)(?: from ([\+\d]+))?(?: with message (.*))?/i, (msg) ->
    toNumber = msg.match[1].trim()
    if msg.match[2] != undefined
      fromNumber = msg.match[2].trim()
    else
      fromNumber = mainFromNumber
    message = "test"
    if msg.match[3] != undefined
      message = msg.match[3].trim()
    
    smscloudMessage msg, toNumber, fromNumber, message, (result) ->
      msg.send "Message sent (#{result.sms_id})"

  robot.respond /(?:what|which) carrier for ([\+\d]+)/i, (msg) ->
    number = msg.match[1]
    smscloudCarrierLookup msg, number, (info) ->
      msg.send "That number is from a #{info.carrier_type} carrier, #{info.carrier_name} in #{info.location}"

smscloudQueue = (msg) ->
  msg.robot.logger.debug "Looking up SMSCloud queue size"
  msg.http('http://smscloud.com/status/queue-size')
    .get() (err, resp, body) ->
      msg.robot.logger.debug "Got SMSCloud queue size response, parsing"
      status = JSON.parse(body)
      if status.status == "okay"
        msg.send "SMSCloud is doing fine with #{status.length} messages queued"
      else if status.status == "warning"
        msg.send "SMSCloud is busy with #{status.length} messages queued"
      else if status.status == "alert"
        msg.send "SMSCloud is having a hard time with #{status.length} messages queued"
        smscloudLargestQueue msg

smscloudLargestQueue = (msg) ->
  msg.robot.logger.debug "Looking up SMSCloud largest queue"
  msg.http('http://smscloud.com/status/largest-queue')
    .get() (err, resp, body) ->
      msg.robot.logger.debug "Got SMSCloud largest queue response, parsing"
      queue = JSON.parse(body)
      msg.send "The largest DID queue is #{queue.length} message(s), for #{queue.number}"

smscloudMessage = (msg, toNumber, fromNumber, message, cb) ->
  msg.robot.logger.debug "Sending a message using SMSCloud"
  smscloudClient.request 'sms.send', [fromNumber, toNumber, message, 1], (err, response) ->
    msg.robot.logger.debug "Got a response to sending a message using SMSCloud, parsing"
    if err || response.result == null
      msg.send "Sorry, I couldn't send that message"
    else
      cb response.result

smscloudCarrierLookup = (msg, number, cb) ->
  msg.robot.logger.debug "Looking up a number using SMSCloud NVS"
  smscloudClient.request 'nvs.carrierLookup', [number], (err, response) ->
    msg.robot.logger.debug "Got a response to looking up a number using SMSCloud, parsing"
    if err || response.result == null
      msg.send "Sorry, I couldn't look that number up"
    else
      cb response.result

smscloudKeyQueue = (msg, cb) ->
  msg.robot.logger.debug "Looking up SMSCloud queue for API key " + smsCloudApiKey
  smscloudClient.request 'sms.queueSizes', [], (err, response) ->
    msg.robot.logger.debug "Got SMSCloud queue, parsing"
    if err || response.result == null
      msg.send "Sorry, the queue size isn't available right now"
    else
      cb response.result
