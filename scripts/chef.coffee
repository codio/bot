# Description:
#   Allows hubot to run commands using chef/knife.
#
# Dependencies:
#   knife installed in your $PATH
#
# Configuration:
#   knife configured in your $PATH, you'll see a WARNING in console if you don't have it
#
# Commands:
#   hubot chef status - chef: Display status for all nodes
#   hubot chef node <name> - chef: Display node info
#   hubot chef nodes - chef: Lists all nodes
#
# Author:
#   jjasghar
#   mattdbridges
#

exec  = require('child_process').exec

execCommand = (msg, cmd) ->
  exec cmd, (error, stdout, stderr) ->
    msg.send error if error
    msg.send stdout
    msg.send stderr if stderr

knifeOptions = "--config /etc/chef/client.rb"
checkKnife = "which knife"
exec checkKnife, (error, stdout, stderr) ->
  if stdout == "" or stdout is "knife not found"
    console.log "WARN: you don't have knife in your $PATH, so this probably won't work....."

module.exports = (robot) ->

  robot.respond /chef status$/i, (msg) ->
    command = "knife status #{knifeOptions}"

    msg.send "Outputing status for all nodes..."
    execCommand msg, command

  robot.respond /chef nodes$/i, (msg) ->
    command = "knife node list #{knifeOptions}"

    msg.send "Listing nodes..."
    execCommand msg, command

  robot.respond /chef node (.*)$/i, (msg) ->
    nodeName = msg.match[1]
    command = "knife node show #{nodeName} #{knifeOptions}"

    msg.send "Showing node for #{nodeName}..."
    execCommand msg, command

