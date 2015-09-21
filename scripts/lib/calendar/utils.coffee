formatUrl = require('url').format

isComing = (ev, advance) ->
  start = getDate(ev)
  current = new Date()
  diff = start - current.getTime()
  nextYear = current.setYear(current.getFullYear() + 1)
  return diff >= 0 and diff < advance and start < nextYear

getDate = (ev, field) ->
  if field is undefined
    field = 'start'
  if typeof ev[field].getTime is 'function'
    return ev[field].getTime()
  else
    return new Date(ev[field].date || ev[field].dateTime).getTime()

getDiffMinutes = (ev) ->
  start = getDate(ev)
  current = new Date().getTime()
  return new Date(start - current).getMinutes()

getDurationInDays = (ev) ->
  start = getDate(ev)
  end = getDate(ev, 'end')
  return new Date(end - start).getDate() - 1

getCreator = (ev) ->
  if ev.creator.displayName
    return ev.creator.displayName.split(' ')[0]
  else return ev.creator.email.split('@')[0]

getSearchUrl = (str) ->
  strFormated = formatUrl(str)
  return "[#{str}](https://www.google.com/webhp?#q=#{strFormated})"

humanJoin = (values, limitator='') ->
  result = values.join("#{limitator}, #{limitator}")
  result = limitator + result + limitator
  lastComma = result.lastIndexOf(',')
  if lastComma != null and lastComma >= 0
    result = result.substring(0, lastComma) + ' and' + result.substring(lastComma + 1)
  return result

module.exports.isComing = isComing
module.exports.getDate = getDate
module.exports.getDiffMinutes = getDiffMinutes
module.exports.getDurationInDays = getDurationInDays
module.exports.getCreator = getCreator
module.exports.getSearchUrl = getSearchUrl
module.exports.humanJoin = humanJoin
