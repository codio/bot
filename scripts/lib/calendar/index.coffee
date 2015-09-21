National = require('./national')
Google = require('./google')

alreadyReturnedEvents = []

module.exports.getGoogleIncomingEvents = (calendarId, advance, callback) ->
  Google.getIncomingEvents calendarId, advance, alreadyReturnedEvents, callback


module.exports.getNationalIncomingEvents = (advance) ->
  National.getIncomingEvents advance, alreadyReturnedEvents

module.exports.getGoogleNextEvents = (calendarId, callback) ->
  Google.getNextEvents calendarId, callback

module.exports.getNationalNextEvent = () ->
  National.getNextEvent()

module.exports.init = (callback) ->
  Google.init () ->
    National.init () ->
      callback()


module.exports.utils = require('./utils')
