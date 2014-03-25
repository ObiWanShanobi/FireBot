# Description:
#   React to new DTRs via webhooks
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#
# URLS:
#   /jira/dtr

hipchatter = require "hipchatter"

module.exports = (robot) ->

  robot.router.post "/jira/dtr/:issue", (req, res) ->
    hipchatter = getHipchatter()
  
    issue = req.params.issue
    hook = req.body
    
    requesterEmail = hook.user.emailAddress
    assigneeEmail = hook.issue.fields.assignee.emailAddress
    
    if hook.webhookEvent == "jira:issue_created"
      hipchatter.create_room {name: issue}, (err, room) ->
        if requesterEmail
          hipchatter.invite_member {
            room_name: room.id,
            user_email: requesterEmail
          }, {
            reason: 'A DTR has been created'
          }, (err) ->
            return
        
        hipchatter.invite_member {
          room_name: room_id,
          user_email: 'evanatmtd+firebot@gmail.com'
        }, {
          reason: 'A DTR has been created'
        }, (err) ->
          return
        
        if assigneeEmail and assigneeEmail != requesterEmail
          hipchatter.invite_member {
            room_name: room.id,
            user_email: assigneeEmail
          }, {
            reason: 'A DTR has been created'
          }, (err) ->
            return
        
        hipchatter.set_topic room.id, hook.issue.fields.summary
      
        hipchatter.notify room.id, {
          message: "#{hook.issue.fields.summary} created by #{hook.issue.fields.reporter.displayName} (#{hook.issue.fields.created})\n\n#{hook.issue.fields.description}",
          message_format: 'text',
          token: 'deprecated'
        }
        
        res.end ""
    else if hook.webhookEvent == "jira:issue_updated"
      result = closeDtr hook.issue.key, false for item in hook.changelog.items when item.field is 'status' and item.to.name == 'Resolved'
    else
      res.end ""

  robot.respond /dtr close(?: (.*))?/i, (msg) ->
    if msg.match[1]?
      key = msg.match[1].trim()
    else
      key = msg.envelope.room
  
    result = closeDtr key, true
    
    if result == true
      msg.send "DTR #{msg.envelope.room} Closed"
    else
      msg.send "No such DTR issue exists"

getHipchatter = () ->
  if @hipchatter
    return @hipchatter
  else
    @hipchatter = new hipchatter(process.env.HUBOT_HIPCHAT_TOKEN)
    return @hipchatter

closeDtr = (key, close) ->
  jiraGet msg, "issue/#{key}", (issue) ->
    if issue.key?
      hipchatter = getHipchatter()
      
      hipchatter.get_room key, (err, room) ->
        history = rollUpHipChatHistory room
      
        hipchatter.update_room {
          name: room.id,
          privacy: room.privacy,
          is_archived: true,
          is_guest_accessible: room.is_guest_accessible,
          topic: room.topic
        }
      
      return true
    else
      return false

jiraGet = (msg, where, cb) ->
  httprequest = msg.http(process.env.HUBOT_JIRA_URL + "/rest/api/latest/" + where)
  if (process.env.HUBOT_JIRA_USER)
    authdata = new Buffer(process.env.HUBOT_JIRA_USER+':'+process.env.HUBOT_JIRA_PASSWORD).toString('base64')
    httprequest = httprequest.header('Authorization', 'Basic ' + authdata)
  httprequest.get() (err, res, body) ->
    cb JSON.parse(body)

rollUpHipChatHistory = (room) ->
  histories = []
  curdate = new Date(room.created)
  end = new Date(Date.now())
  finishTimeoutFunction = () ->
    histories = histories.sort (a, b) ->
      if a.date < b.date
        return -1
      else if b.date < a.date
        return 1
      else if b.date == a.date and a.index < b.index
        return -1
      else if b.date == a.date and b.index < a.index
        return -1
      
      return 0
    
    historyData = ""
    for history in histories
      do (history) ->
        for item in history
          do (item) ->
            historyData += "[#{item.date}] #{item.from.name}: #{item.message}\n"
    
    console.log(historyData)
  
  finishTimeout = setTimeout finishTimeoutFunction, 5000
  while curdate <= end
    (() ->
      historyDate = new Date(curdate.getTime())
      makeRequest = (historyDate, histories, index) ->
        hipchatter.request 'get', "room/#{room.id}/history", {
          date: historyDate.getFullYear() + '-' + (historyDate.getMonth() + 1) + '-' + historyDate.getDate(),
          'start-index': index
        }, (err, history) ->
          histories.push({
            date: historyDate,
            index: index,
            items: history.items
          })
          
          if history.links.next?
            clearTimeout finishTimeout
            setTimeout finishTimeoutFunction, 5000
            makeRequest historyDate, histories, history.startIndex + history.maxResults
      
      makeRequest historyDate, histories, 0
    )()
      
    curdate.setDate(curdate.getDate() + 1)
