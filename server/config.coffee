americano = require 'americano'
passport = require 'passport'
randomstring = require 'randomstring'
middlewares = require './middlewares/middlewares'

error = (err, req, res, next) ->
    console.log "middleware error"
    console.log err.stack
    res.send 500, err.message

# /!\ CAREFUL /!\
# Middlewares order matters to authenticate websockets
# See ./server/lib/proxy.coffee
authSteps = [
    americano.cookieParser randomstring.generate()
    americano.session
        secret: randomstring.generate()
        cookie: maxAge: 30 * 86400 * 1000
    passport.initialize()
    passport.session()
]

config =
    authSteps: authSteps
    common:
        use: [
            americano.errorHandler
                dumpExceptions: true
                showStack: true
            americano.static __dirname + ' /../public'
            middlewares.selectiveBodyParser
            middlewares.tracker
            authSteps[0]
            authSteps[1]
            authSteps[2]
            authSteps[3]
            error
        ]
        set: [
            views: '../views'
        ]

    development: [
        americano.logger 'dev'
    ]

    production: [
        americano.logger 'short'
    ]

    plugins: []

module.exports = config