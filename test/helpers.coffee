http = require 'http'
Client = require('request-json').JsonClient
module.exports = helpers = {}

if process.env.COVERAGE
    helpers.prefix = '../instrumented/'
else if process.env.USE_JS
    helpers.prefix = '../build/'
else
    helpers.prefix = '../'

# server management
helpers.options =
    serverHost: process.env.HOST or 'localhost'
    serverPort: process.env.PORT or 9104

# default client
client = new Client "http://#{helpers.options.serverHost}:#{helpers.options.serverPort}/", jar: true

# set the configuration for the server
process.env.HOST = helpers.options.serverHost
process.env.PORT = helpers.options.serverPort

# Returns a client if url is given, default app client otherwise
helpers.getClient = (url = null) ->
    if url?
        return new Client url, jar: true
    else
        return client

initializeApplication = require "#{helpers.prefix}server"

helpers.startApp = (done) ->
    @timeout 15000
    initializeApplication (app, server) =>
        @app = app
        @app.server = server
        done()

helpers.stopApp = (done) ->
    @timeout 10000
    setTimeout =>
        #delete require.cache[require.resolve("#{helpers.prefix}server/config")]
        @app.server.close done
    , 1000


User = require "#{helpers.prefix}server/models/user"

helpers.deleteAllUsers = (done) ->
    @timeout 5000
    User.requestDestroy 'all', done

helpers.patchCookieJar = ->
    # https://gist.github.com/jfromaniello/4087861
    # use request cookiejar with socket.io-client
    originalXHR = require('xmlhttprequest').XMLHttpRequest
    xhrPackage = 'socket.io-client/node_modules/xmlhttprequest'
    request = require 'request-json/node_modules/request'
    @jar = jar = {}

    require(xhrPackage).XMLHttpRequest = ->
        originalXHR.apply @, arguments
        @setDisableHeaderCheck true
        stdOpen = @open

        @open = ->
            stdOpen.apply @, arguments
            header = jar.authCookie
            @setRequestHeader 'cookie', header
        @

helpers.patchSocketIO = ->
    jar = @jar
    WS = require('socket.io-client/lib/transports/websocket').websocket
    ioutil = require('socket.io-client/lib/util').util

    WS.prototype.open = ->
        query = ioutil.query this.socket.options.query
        self = this

        Socket = require 'socket.io-client/node_modules/ws'

        unless Socket
            Socket = global.MozWebSocket or global.WebSocket

        url = @prepareUrl() + query
        @websocket = new Socket url, headers: 'Cookie': jar.authCookie

        @websocket.onopen = ->
            self.onOpen()
            self.socket.setBuffer false

        @websocket.onmessage = (ev) -> self.onData ev.data

        @websocket.onclose = ->
            self.onClose()
            self.socket.setBuffer true

        @websocket.onerror = (e) -> self.onError e

      return @

helpers.login = (password) -> (done) ->
    client = helpers.getClient()
    client.post 'login', password: password, (err, res) =>
        if res.headers['set-cookie']
            cookie = res.headers["set-cookie"][0]
            values = cookie.split ';'
            @jar.authCookie = values[0]
        done()

helpers.createUser = (email, pass) -> (done) ->
    {cryptPassword} = require "#{helpers.prefix}server/lib/helpers"
    user =
        email: email
        owner: true
        password: cryptPassword(pass).hash
        activated: true

    User.create user, done

helpers.fakeServer = (name, port, json, prepare) -> (done) ->
    @fakeServers ?= {}
    @fakeServers[name] = http.createServer (req, res) =>
        @fakeServers[name].lastUrl = req.url
        res.writeHead 200, 'Content-Type': 'application/json'
        res.end JSON.stringify json
    prepare? @fakeServers[name]
    @fakeServers[name].listen port, done

helpers.closeFakeServers = ->
    for name, server of @fakeServers
        server.close()
    @fakeServers = {}
