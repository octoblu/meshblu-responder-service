_              = require 'lodash'
{EventEmitter} = require 'events'

class FakeMeshblu extends EventEmitter
  constructor: ->

  createConnection: ->
    _.delay =>
      @emit 'ready'
    , 10
    return @

  message: (message) ->
    @emit 'message', message

module.exports = FakeMeshblu
