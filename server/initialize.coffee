configurePassport = require './lib/passport_configurator'
router = require './lib/router'
{initializeProxy} = require './lib/proxy'
deviceManager = require './models/device'

module.exports = (app, server, callback) ->

    # noop
    unless callback? then callback = ->

    # configure passport which handles authentication
    configurePassport()

    # initialize Proxy server
    initializeProxy app, server

    # initialize device authentication
    deviceManager.update ->

        # reset (load) and display the routes
        router.reset -> router.displayRoutes -> callback app, server