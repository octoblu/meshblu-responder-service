request = require 'request'
_       = require 'lodash'
debug   = require('debug')('meshblu-responder-service:service')

class MeshbluRespondService
  constructor: ({@uuid, @meshblu}) ->
    @uuid ?= require 'uuid'
    @meshblu ?= require 'meshblu'

  message: ({meshbluConfig, message}, callback) =>
    timeout = setTimeout =>
      debug 'timing out request'
      onceCallback @_createError 408, 'Request Timeout'
    , 3000

    onceCallback = _.once (error, message) =>
      debug 'calling callback'
      clearTimeout timeout
      meshbluConn.close()
      callback error, message

    meshbluConn = @meshblu.createConnection meshbluConfig

    fullMessage =
      devices: [meshbluConfig.uuid]
      payload:
        responseId: @uuid.v1()
        message: message

    meshbluConn.once 'ready', =>
      meshbluConn.on 'message', (message) =>
        debug 'received message', message
        onceCallback null, message if fullMessage.payload?.responseId == message.payload?.responseId
      meshbluConn.message fullMessage
      debug 'sending message', fullMessage

    meshbluConn.once 'notReady', =>
      onceCallback @_createError 500, 'Unable to connect to Meshblu'

  config: ({meshbluConfig, properties}, callback) =>
    timeout = setTimeout =>
      debug 'timing out request'
      onceCallback @_createError 408, 'Request Timeout'
    , 3000

    onceCallback = _.once (error, message) =>
      debug 'calling callback'
      clearTimeout timeout
      meshbluConn.close()
      callback error, message

    meshbluConn = @meshblu.createConnection meshbluConfig

    responseId = @uuid.v1()
    properties.uuid = meshbluConfig.uuid
    properties[responseId] = true

    meshbluConn.once 'ready', =>
      meshbluConn.on 'config', (device) =>
        debug 'received device', device
        onceCallback null, device if device[responseId]?
      meshbluConn.update properties
      debug 'updating device', properties

    meshbluConn.once 'notReady', =>
      onceCallback @_createError 500, 'Unable to connect to Meshblu'

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = MeshbluRespondService
