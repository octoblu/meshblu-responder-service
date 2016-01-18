http    = require 'http'
request = require 'request'
shmock  = require '@octoblu/shmock'
Server  = require '../../src/server'
FakeMeshblu = require '../fake-meshblu'

xdescribe 'Update', ->
  beforeEach (done) ->
    @meshblu = shmock 0xd00d

    serverOptions =
      port: undefined,
      disableLogging: true

    meshbluConfig =
      server: 'localhost'
      port: 0xd00d

    @fakeMeshblu = new FakeMeshblu
    uuid =
      v1: sinon.stub().returns 'some-response-uuid'

    @server = new Server serverOptions, {meshbluConfig, uuid, meshblu: @fakeMeshblu}

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @meshblu.close done

  describe 'On POST /config', ->
    describe 'when it succeeds', ->
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

    describe 'when it times out', ->
      beforeEach (done) ->
        @timeout 3000
        userAuth = new Buffer('user-uuid:user-token').toString 'base64'

        @authDevice = @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{userAuth}"
          .reply 200, uuid: 'user-uuid', token: 'user-token'

        @fakeMeshblu.failOnEvent 'update'

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

      it 'should return a 408', ->
        expect(@response.statusCode).to.equal 408


    describe 'when it fires not ready', ->
      beforeEach (done) ->
        userAuth = new Buffer('user-uuid:user-token').toString 'base64'

        @authDevice = @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{userAuth}"
          .reply 200, uuid: 'user-uuid', token: 'user-token'

        @fakeMeshblu.fireNotReady()

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

      it 'should return a 500', ->
        expect(@response.statusCode).to.equal 500
