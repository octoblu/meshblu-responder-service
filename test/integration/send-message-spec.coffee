http    = require 'http'
request = require 'request'
shmock  = require '@octoblu/shmock'
Server  = require '../../src/server'
FakeMeshblu = require '../fake-meshblu'

describe 'Send Message', ->
  beforeEach (done) ->
    @meshblu = shmock 0xd00d

    serverOptions =
      port: undefined,
      disableLogging: true

    meshbluConfig =
      server: 'localhost'
      port: 0xd00d

    meshblu = new FakeMeshblu
    uuid =
      v1: sinon.stub().returns 'some-response-uuid'

    @server = new Server serverOptions, {meshbluConfig, uuid, meshblu}

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @meshblu.close done

  describe 'On POST /messages', ->
    beforeEach (done) ->
      userAuth = new Buffer('user-uuid:user-token').toString 'base64'

      @authDevice = @meshblu
        .get '/v2/whoami'
        .set 'Authorization', "Basic #{userAuth}"
        .reply 200, uuid: 'user-uuid', token: 'user-token'

      options =
        uri: '/messages'
        baseUrl: "http://localhost:#{@serverPort}"
        auth:
          username: 'user-uuid'
          password: 'user-token'
        json:
          foo: 'bar'

      request.post options, (error, @response, @body) =>
        done error

    it 'should auth the device', ->
      @authDevice.done()

    it 'should return a 204', ->
      expect(@response.statusCode).to.equal 204
