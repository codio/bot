# Description:
#   Listens for patterns matching youtrack issues and provides information about them
#
# Dependencies:
#   url, https, request, xml2js
#
# Configuration:
#   HUBOT_YOUTRACK_URL  = <scheme>://<username>:<password>@<host:port>/<basepath>
#
# Commands:
#   project-number - responds with a summary of the issue
#   #number - responds with a summary of the issue for codio project
#
# Author:
#   Joel Moss

URL = require "url"
https = require 'https'
request = require 'request'
parseString = require('xml2js').parseString

yt_url = process.env.HUBOT_YOUTRACK_URL
url_parts = URL.parse(yt_url)
scheme = url_parts.protocol
username = url_parts.auth.split(":")[0]
password = url_parts.auth.split(":")[1]
host = url_parts.host
path = url_parts.pathname if url_parts.pathname?


module.exports = (robot) ->

  robot.hear /codio-([\d]+)/gi, (msg) -> getIssue msg

  robot.hear /#(\d+)/g, (msg) -> getIssue msg, "codio-"

  getIssue = (msg, prefix="") ->
    handleIssue(msg, "#{prefix}#{match.replace(/^#/, '')}") for match, i in msg.match


  handleIssue = (msg, issueId) ->
    askYoutrack "/rest/issue/#{issueId}", (err, issue) ->
      console.log err
      return msg.send "I'd love to tell you about it, but there was an error looking up that issue" if err? || !issue?
      if issue.field
        summary = field.value for field in issue.field when field.$.name == 'summary'
        type = field.value for field in issue.field when field.$.name == 'Type'
        state = field.value for field in issue.field when field.$.name == 'State'
        msg.send "#{type} ##{issueId} - *[#{state}]* [#{summary}](#{scheme}//#{host}/youtrack/issue/#{issueId})"
      else
        msg.send "I'd love to tell you about it, but I couldn't find that issue"

  askYoutrack = (_path, callback) ->
    login (login_err, login_res, login_body) ->
      ask_options =
        url: "#{scheme}//#{host}#{path}#{_path}"
        headers:
          "Cookie": login_res.headers['set-cookie'].join(";")
          "Content-Type": "application/xml"

      request ask_options, (err, res, body) ->
        parseString body, (error, result) ->
          console.log result
          callback null, result.issue

  login = (handler) ->
    request.post "#{scheme}//#{host}#{path}/rest/user/login?login=#{username}&password=#{password}", handler
