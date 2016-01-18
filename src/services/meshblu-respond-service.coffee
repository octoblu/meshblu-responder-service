request     = require 'request'
_           = require 'lodash'

class MeshbluRespondService
  constructor: ({@uuid, @meshblu}) ->
    @uuid ?= require 'uuid'
    @meshblu ?= require 'meshblu'

  message: ({meshbluConfig, message}, callback) =>
    timeout = setTimeout =>
      onceCallback @_createError 408, 'Request Timed out'
    , 2000

    onceCallback = _.once (error) =>
      clearTimeout timeout
      meshbluConn.close (closeError) =>
        return callback error if error?
        callback closeError

    meshbluConn = @meshblu.createConnection meshbluConfig

    fullMessage =
      devices: [meshbluConfig.uuid]
      payload:
        responseId: @uuid.v1()
        message: message

    meshbluConn.once 'ready', =>
      meshbluConn.on 'message', (message) =>
        onceCallback null if fullMessage.payload?.responseId == message.payload?.responseId
      meshbluConn.message fullMessage

    meshbluConn.once 'notReady', =>
      onceCallback @_createError 500, 'Unable to connect to Meshblu'

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = MeshbluRespondService
