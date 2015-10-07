_ = require('lodash')
ical = require('ical')

Utils = require('./utils')

calendars =
  german:
    nation: 'Germany'
    events: []
  italian:
    nation: 'Italy'
    events: []
  russian:
    nation: 'Russia'
    events: []
  uk:
    nation: 'UK'
    events: []

getSummary = (ev) ->
  return ev.summary.replace('(regional holiday)', '').trim()

initNationalCalendars = (callback) ->
  i = 0

  checkCallback = () ->
    i += 1
    if i is ids.length
      callback()

  load = (natId) ->
    url = "https://www.google.com/calendar/ical/en.#{natId}%23holiday%40group.v.calendar.google.com/public/basic.ics"
    ical.fromURL url, {}, (err, data) ->
      if err
        console.log "A error occurs when get national calendar #{natId} #{errReq}"
      else
        calendars[natId].events = _.values(data)

      checkCallback()


  ids = _.keys(calendars)
  for id in ids
    load(id)


getIncomingEvents = (advance, eventsToSkip) ->
  incomings = {}
  for id in _.keys(calendars)
    events = calendars[id].events
    nation = calendars[id].nation

    for ev in events
      if Utils.isComing(ev, advance)
        continue if _.contains(eventsToSkip, ev.uid)
        eventsToSkip.push(ev.uid)

        duration = Utils.getDurationInDays(ev)

        summary = getSummary(ev)
        if not incomings.hasOwnProperty(summary)
          incomings[summary] = {}

        incomingEvent = incomings[summary]

        if not incomingEvent.hasOwnProperty(duration)
          incomingEvent[duration] = []

        incomingEvent[duration].push(nation)

  return incomings

getNextEvent = () ->
  minDate = null
  result = null

  for id in _.keys(calendars)
    nation = calendars[id].nation
    events = calendars[id].events
    for ev in events
      sixMonths = new Date(new Date().getTime() + new Date('1970 6 1').getTime())
      continue unless Utils.isComing(ev, sixMonths)
      eventTime = Utils.getDate(ev)

      summary = getSummary(ev)

      if minDate is null or eventTime < minDate
        minDate = eventTime
        result = {}
        result.summary = summary
        result.start = ev.start
        result.nations = [nation]

      else if eventTime == minDate
        result.nations.push(nation)

  return result

module.exports.init = initNationalCalendars
module.exports.getIncomingEvents = getIncomingEvents
module.exports.getNextEvent = getNextEvent
