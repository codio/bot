# Description:
#   Random 9gag image
#
# Dependencies:
#   request
#
# Configuration:
#   None
#
# Commands:
#   9gag - Display a random 9gag image
#
# Author:
#   dignifiedquire

request = require 'request'

url = "http://infinigag.eu01.aws.af.cm/trending/0"

fetchImage = (callback) ->
  request url: url, (err, res, body) ->
    return console.log('Request failed', err) if err

    parsed = JSON.parse(body)
    elem = parsed.data[0]
    callback "**#{elem.caption}:** #{elem.images.normal}"

module.exports = (robot) ->
  robot.hear /\b(9gag)\b/i, (msg) ->
    fetchImage (result) ->
      msg.send result
