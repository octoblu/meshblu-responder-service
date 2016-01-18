MeshbluRespondController = require './controllers/meshblu-respond-controller'

class Router
  constructor: ({@meshbluRespondService}) ->
  route: (app) =>
    meshbluRespondController = new MeshbluRespondController {@meshbluRespondService}

    app.post '/messages', meshbluRespondController.message

module.exports = Router
