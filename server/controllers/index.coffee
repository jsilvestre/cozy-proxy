{getProxy} = require '../lib/proxy'
router = require '../lib/router'
statusChecker = require '../lib/status_checker'
deviceManager = require '../models/device'

module.exports.defaultRedirect = (req, res) ->
    homePort = process.env.DEFAULT_REDIRECT_PORT
    getProxy().web req, res, target: "http://localhost:#{homePort}"

module.exports.showRoutes = (req, res) -> res.send 200, router.getRoutes()

module.exports.resetRoutes = (req, res) ->
    router.reset (error) ->
        if error?
            res.send 500, error
        else
            res.send 200, success: true

module.exports.status = (req, res) ->
    statusChecker.checkAllStatus (err, status) ->
        if err then res.send 500
        else res.send status
