# Description:
#   Allows hubot to send Codio Calendar Events
#
# Dependencies:
#   lodash google-auth-library googleapis ical
#
# Configuration:
#   HUBOT_CALENDAR_CODIO_ENG_ID      - The codio Calendar Enginerring ID
#   HUBOT_CALENDAR_CODIO_HOL_ID      - The codio Calendar Holidays ID
#   HUBOT_CALENDAR_GOOGLE_KEY_PATH   - The path to the google key (absolute)
#   HUBOT_CALENDAR_CREDENTIALS_PATH  - The file path were google credentials will be stored (absolute)
#
# Commands:
#   calendar next - show next events
#
# Notes:
#   First time you run this script you must uncomment the
#   "FIRST RUN" line below and exec this file alone.
#   You will prompt to follow ad URL in Google and past a code.
#   This is step is needed for authentication.
#

_ = require('lodash')
moment = require('moment')

Calendar = require('./lib/calendar')
Utils = Calendar.utils

TIME_CODIO_ENG_ADV = 60 * 15 * 1000  # 15 minutes
TIME_HOLIDAY = 60 * 60 * 12 * 1000   # 12 hours
TIME_SLEEP = 60 * 5000 # 5 mins

CODIO_ENG = process.env.HUBOT_CALENDAR_CODIO_ENG_ID
CODIO_HOL = process.env.HUBOT_CALENDAR_CODIO_HOL_ID

handleNationalHolidays = (callback) ->

  incomings = Calendar.getNationalIncomingEvents(TIME_HOLIDAY)
  if _.isEmpty(incomings)
    return

  eventsToString = []
  for summary in _.keys(incomings)
    for duration in _.keys(incomings[summary])
      summaryUrl = Utils.getSearchUrl(summary)
      nations = Utils.humanJoin(incomings[summary][duration], '**')

      if duration <= 1
        evStr = "is #{summaryUrl} in #{nations}"
      else
        evStr = "starts #{summaryUrl} in #{nations} for **#{duration} days**"

      eventsToString.push(evStr)

  eventsToString = eventsToString.join(', and ')
  callback "@team did you know that tomorrow #{eventsToString}?"


handleCodioHolidays = (callback) ->
  id = CODIO_HOL
  Calendar.getGoogleIncomingEvents id, TIME_HOLIDAY, (events) ->
    for ev in events
      days = Utils.getDurationInDays(ev)
      creator = Utils.getCreator(ev)
      if days <= 1
        callback "Hey @team tomorrow **#{creator}** has a **day off**"
      else
        callback "Hey @team from tomorrow **#{creator}** will be in " +
                 "Holiday for **#{days} days**! Have a good one #{creator}!"


handleCodioEngineering = (callback) ->
  id = CODIO_ENG
  Calendar.getGoogleIncomingEvents id, TIME_CODIO_ENG_ADV, (events) ->
    for ev in events
      diffMin = Utils.getDiffMinutes(ev)
      info = if ev.hangoutLink then "[[hangout](#{ev.hangoutLink})]" else ''
      callback "@team **#{ev.summary}** in **#{diffMin} minutes**! #{info}"


getNextEvents = (callback) ->
  result = []
  fetched = 0

  checkCallback = () ->
    fetched += 1
    if fetched == 3
      callback(result.join('\n'))

  # Next Event in Codio Engineering
  Calendar.getGoogleNextEvents CODIO_ENG, (evsCodioEng) ->
    for ev in evsCodioEng
      datetime = moment(Utils.getDate(ev)).format('[**]MMM Do[**] [at] [**]hh:mma[**]')
      result.push "We have **#{ev.summary}** the #{datetime}"
    checkCallback()

  Calendar.getGoogleNextEvents CODIO_HOL, (evsCodioHol) ->
    # Next codio Holidays
    for ev in evsCodioHol
      days = Utils.getDurationInDays(ev)
      if days <= 1
        duration = "one day"
      else
        duration = "#{days} days"
      creator = Utils.getCreator(ev)
      datetime = moment(Utils.getDate(ev)).format('MMM Do')
      result.push "The **#{datetime}** **#{creator}** will go off for **#{duration}**"
    checkCallback()

  # Next National Event
  evNatHol = Calendar.getNationalNextEvent()
  datetime = moment(Utils.getDate(evNatHol)).format('MMM Do')
  nations = Utils.humanJoin(evNatHol.nations, '**')
  summary = Utils.getSearchUrl(evNatHol.summary)
  result.push "**#{datetime}** is #{summary} in #{nations}"
  checkCallback()



run = (callback) ->
  handleCodioHolidays(callback)
  handleCodioEngineering(callback)
  handleNationalHolidays(callback)


start = (callback, inLoop=true) ->
  looper = () ->
    run callback
    unless !inLoop then setTimeout looper, TIME_SLEEP

  Calendar.init () ->
      looper()

#For testing
# TIME_HOLIDAY = TIME_HOLIDAY * 100
# TIME_CODIO_ENG_ADV = TIME_CODIO_ENG_ADV * 1000
# TIME_SLEEP = 500
# start console.log, false

# setTimeout () ->
#   getNextEvents console.log
#   , 10000


# FIRST RUN
# start console.log, false

module.exports = (robot) ->
  robot.enter (res) ->
    start (result) ->
      res.send result

  robot.hear /calendar next/i, (res) ->
    getNextEvents (result) ->
      res.send result
