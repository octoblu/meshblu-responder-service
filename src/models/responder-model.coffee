_     = require 'lodash'
async = require 'async'
debug = require('debug')('meshblu-responder-service:model')

class ResponderModel
  constructor: ({@meshbluConfig, @Meshblu, @onReady}) ->
    @Meshblu ?= require 'meshblu'

  _connect: (callback) =>
    debug 'connecting'
    @meshblu = @Meshblu.createConnection @meshbluConfig
    @meshblu.socket.on 'connect_error', callback
    @meshblu.socket.on 'error', callback
    @meshblu.on 'notReady', =>
      debug 'error'
      callback message: 'Unable to connect to meshblu', code: 500
    @meshblu.on 'ready', =>
      debug 'connected'
      callback null, @meshblu

  _disconnect: (callback) =>
    @meshblu.close()
    debug 'disconnected'
    callback null

  _afterTask: (callback) =>
    debug 'completed task'
    callback null

  do: (callback) =>
    done = _.once (error) =>
      clearTimeout @timeout
      callback error

    @timeout = _.delay =>
      @_disconnect =>
        done message: 'Request timeout', code: 408
    , 3000

    async.waterfall [
      async.apply @_connect
      async.apply @onReady
      async.apply @_afterTask
      async.apply @_disconnect
    ], done

module.exports = ResponderModel
