MeshbluRespondController = require './controllers/meshblu-respond-controller'

class Router
  constructor: ({@meshbluRespondService}) ->
  route: (app) =>
    meshbluRespondController = new MeshbluRespondController {@meshbluRespondService}

    app.post '/messages', meshbluRespondController.message
    app.post '/config', meshbluRespondController.config

module.exports = Router
