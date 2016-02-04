_              = require 'lodash'
request        = require 'request'
ResponderModel = require '../models/responder-model'
debug          = require('debug')('meshblu-responder-service:service')

class MeshbluRespondService
  constructor: ({@uuid, @Meshblu}) ->
    @uuid ?= require 'uuid'

  message: ({meshbluConfig, message}, callback) =>
    onReady = (meshblu, next) =>
      fullMessage =
        devices: [meshbluConfig.uuid]
        payload:
          responseId: @uuid.v1()
          message: message

      meshblu.on 'message', (message) =>
        next null if fullMessage.payload?.responseId == message.payload?.responseId
      meshblu.message fullMessage

    responderModel = new ResponderModel {meshbluConfig, onReady, @Meshblu}
    responderModel.do (error) =>
      return callback @_createError error if error?
      callback null

  config: ({meshbluConfig, properties}, callback) =>
    onReady = (meshblu, next) =>
      responseId = @uuid.v1()
      properties.uuid = meshbluConfig.uuid
      properties.responseId = responseId

      meshblu.on 'config', (device) =>
        next null if device.responseId = responseId
      meshblu.update properties

    responderModel = new ResponderModel {meshbluConfig, @Meshblu, onReady}
    responderModel.do (error) =>
      return callback @_createError error if error?
      callback null

  _createError: ({code, message}) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = MeshbluRespondService
