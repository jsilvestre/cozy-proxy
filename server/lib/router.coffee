Client = require('request-json').JsonClient
logger = require('printit')
            date: false
            prefix: 'lib:router'

class Router

    routes: {}

    constructor: ->
        homePort = process.env.DEFAULT_REDIRECT_PORT
        @client = new Client "http://localhost:#{homePort}/"

    getRoutes: -> return @routes

    displayRoutes: (callback) ->
        for slug, route of @routes
            logger.info "#{slug} (#{route.state}) on port #{route.port}"

        callback() if callback?

    reset: (callback) ->
        logger.info 'Start resetting routes...'
        @routes = {}
        @client.get "api/applications/", (error, res, apps) =>
            return callback error if error
            return callback new Error apps.msg if apps.error?
            try
                for app in apps.rows
                    @routes[app.slug] = {}
                    @routes[app.slug].port = app.port if app.port?
                    @routes[app.slug].state = app.state if app.state?
                logger.info "Routes have been successfully reset."
                callback()
            catch err
                logger.error "Oops, something went wrong during routes reset."
                return callback err

module.exports = new Router()