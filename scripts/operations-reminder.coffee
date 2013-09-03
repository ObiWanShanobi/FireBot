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
    if thisHour < 8 or thisHour > 15
        return
    if thisHour != hour
        hour = thisHour
        for room in allRooms
            if /operations/i.test(room)
                robot.messageRoom room, '@all Hey, it\'s the top of the hour. Make sure you\'re on the right queue or enjoying your Project Time.'
