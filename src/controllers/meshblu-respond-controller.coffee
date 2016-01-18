debug = require('debug')('meshblu-responder-service:controller')

class MeshbluRespondController
  constructor: ({@meshbluRespondService}) ->

  message: (request, response) =>
    message = request.body
    meshbluConfig = request.meshbluAuth
    debug 'got message request', message: message, uuid: meshbluConfig.uuid
    @meshbluRespondService.message {message, meshbluConfig}, (error, message) =>
      debug 'responding to message error', error: error.toString(), code: error.code if error?
      return response.status(error.code || 500).send(error: error.message) if error?
      debug 'responding to message success'
      response.status(200).send message: message

  config: (request, response) =>
    properties = request.body
    meshbluConfig = request.meshbluAuth
    debug 'got update request', properties: properties, uuid: meshbluConfig.uuid
    @meshbluRespondService.config {properties, meshbluConfig}, (error, device) =>
      debug 'responding to update error', error: error.toString(), code: error.code if error?
      return response.status(error.code || 500).send(error: error.message) if error?
      debug 'responding to update success'
      response.status(200).send device: device

module.exports = MeshbluRespondController
