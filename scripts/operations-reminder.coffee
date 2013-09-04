# Description:
#   Send a reminder at the top of each hour.
#
# Commands:

module.exports = (robot) ->
  allRooms = process.env.HUBOT_ANNOUNCE_ROOMS.split(',')
  timeCheck = (ms, func) -> setInterval func, ms
  hour = new Date().getHours()

  timeCheck 1000, ->
    thisHour = new Date().getHours()
    if thisHour < 7 or thisHour > 16
        return
    if thisHour != hour
        hour = thisHour
        for room in allRooms
            if /operations/i.test(room)
                robot.http('http://catfacts-api.appspot.com/api/facts?number=1')
                    .get() (error, response, body) ->
                        # passes back the complete reponse
                        response = JSON.parse(body)
                        if response.success == "true"
                            robot.messageRoom room, '@all Did you know... ' + response.facts[0] + '. Oh, and by the way - don\'t forget to log into the right phone or chat queue.'
                        else
                            robot.messageRoom room, '@all Hey, sorry I don\'t have any facts right now, but it\'s the top of the hour. Make sure you\'re on the right queue or enjoying your Project Time.'
