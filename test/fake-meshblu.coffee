_              = require 'lodash'
{EventEmitter} = require 'events'

class FakeMeshblu extends EventEmitter
  constructor: ->

  failOnEvent: (event) =>
    @_failOnEvent = event

  fireNotReady: =>
    @_fireNotReady = true

  _emit: (event) =>
    return if @_failOnEvent == event
    @emit arguments...

  createConnection: ->
    _.delay =>
      return @_emit 'notReady' if @_fireNotReady
      @_emit 'ready'
    , 10
    return @

  message: (message) ->
    @_emit 'message', message

  close: (callback) -> callback()
  
module.exports = FakeMeshblu
