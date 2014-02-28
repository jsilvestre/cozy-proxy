httpProxy = require 'http-proxy'
async = require 'async'
passport = require 'passport'
americano = require 'americano'
config = require '../config'
logger = require('printit')
            date: false
            prefix: 'lib:proxy'

router = require './router'

# singleton variable
proxy = null

module.exports.getProxy = -> return proxy

module.exports.initializeProxy = (app, server) ->

    # create proxy server
    proxy = httpProxy.createProxyServer()

    # proxy error handling
    proxy.on 'error', (err) ->
        logger.error err

    # Manage socket.io's websocket
    server.on 'upgrade', (req, socket, head) ->
        # Dirty trick to authenticate websockets
        req.originalUrl = req.url
        fakeRes = on: ->
        [cookieParser, sessionParser, initialize, session] = config.authSteps
        async.series [
            (callback) -> cookieParser req, fakeRes, callback
            (callback) -> sessionParser req, fakeRes, callback
            (callback) -> initialize req, fakeRes, callback
            (callback) -> session req, fakeRes, callback
        ], (err) ->
            if req.isAuthenticated() and not err
                # this can break at any express upgrade
                if slug = app._router.matchRequest(req).params.name
                    routes = router.getRoutes()
                    req.url = req.url.replace "/apps/#{slug}", ''
                    port = routes[slug].port
                else
                    port = process.env.DEFAULT_REDIRECT_PORT

                proxy.ws req, socket, head,
                    target: "ws://localhost:#{port}"
                    ws: true
            else
                logger.error err if err?
                logger.error "Socket unauthorized"

