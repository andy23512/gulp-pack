require! <[querystring]>
if process.title is \node # via command line
  console.log \node
else # via gulp/express or apache/lighttpd
  if process.title is \gulp # via gulp/express
    dir = \.
  else if process.env.HTTP_HOST? # via apache/lighttpd
    dir = \..
    Do process.env.QUERY_STRING, console

!function Do query, outputer
  param = querystring.parse query
  if typeof! outputer.log is \Function => outputer.log "Content-type: text/plain\n" # console object
  process.on \uncaughtException (!-> ERR it) # catch err

  switch param.action
  | \test
    output \nanoha


  ################################################################################
  # utility
  function ERR
    if it.stack # node error
      console.log it.stack
      output err: it.message
    else # outside (google) error
      output it
    false

  !function output
    if typeof! outputer.log is \Function => outputer.log it # console object
    else if typeof! outputer.send is \Function => outputer.send it # response object of express

module.exports = Do

# vi:et:fdm=indent:ft=ls:nowrap:sw=2:ts=2
