# Description:
#   Random excuse from http://programmingexcuses.com/
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   excuse - Gives a programming excuse
#
# Author:
#   Mathieu Van der Haegen


module.exports = (robot) ->
    robot.hear /\bexcuse\b/i, (msg) ->
        robot.http("http://programmingexcuses.com/")
        .get() (err, res, body) ->
            matches = body.match /<a [^>]+>(.+)<\/a>/i

            if matches and matches[1]
                msg.send matches[1]