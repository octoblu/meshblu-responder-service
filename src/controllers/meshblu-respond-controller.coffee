class MeshbluRespondController
  constructor: ({@meshbluRespondService}) ->

  message: (request, response) =>
    message = request.body
    meshbluConfig = request.meshbluAuth
    @meshbluRespondService.message {message, meshbluConfig}, (error) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.sendStatus(204)

module.exports = MeshbluRespondController
