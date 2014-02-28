index = require './index'
auth = require './authentication'
devices = require './devices'
apps = require './applications'

utils = require '../middlewares/authentication'

passport = require 'passport'

module.exports =

    'routes': get: index.showRoutes
    'routes/reset': get: index.resetRoutes

    'register':
        get: auth.registerIndex
        post: [auth.register, utils.authenticate]

    'login': post: [auth.login, utils.authenticate]
    'login/forgot': post: auth.forgotPassword
    'login*': get: auth.loginIndex
    'logout': get: [utils.isAuthenticated, auth.logout]

    'password/reset/:key':
        get: auth.resetPasswordIndex
        post: auth.resetPassword

    'authenticated': get: auth.authenticated
    'status': get: index.status

    'public/:name/*': all: apps.publicApp
    'device*':
        post: devices.management
        del: devices.management

    'apps/:name/*': all: [utils.isAuthenticated, apps.app]
    'apps/:name*': all: [utils.isAuthenticated, apps.appWithSlash]

    'cozy/*': devices.replication

    '*': all: [
        utils.isAuthenticated
        index.defaultRedirect
    ]
