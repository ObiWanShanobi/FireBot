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
          hipchatter.invite_member {room_name: room.id, user_email: requesterEmail}, {reason: 'A DTR has been created'}, (err) ->
            return
        
        if assigneeEmail and assigneeEmail != requesterEmail
          hipchatter.invite_member {room_name: room.id, user_email: assigneeEmail}, {reason: 'A DTR has been created'}, (err) ->
            return
        
        res.end ""
    else
      res.end ""

getHipchatter = () ->
  if @hipchatter
    return @hipchatter
  else
    @hipchatter = new hipchatter(process.env.HUBOT_HIPCHAT_TOKEN)
    return @hipchatter
