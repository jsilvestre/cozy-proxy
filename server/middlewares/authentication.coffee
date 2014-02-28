passport = require 'passport'
qs = require 'querystring'

passwordKeys = require '../lib/password_keys'

module.exports.authenticate = (req, res, next) ->
    process = (err, user) ->
        if err
            res.send 500, error: "Server error occured."
        else if user is undefined or not user
            res.send 400, error: "Wrong password"
        else
            passwordKeys.initializeKeys req.body.password, (err) ->
                if err
                    res.send 500, error: "Keys aren't initialized"
                else
                    req.logIn user, (err, info) ->
                        if err
                            res.send 401, error: "Login failed"
                        else
                            res.send 200, success: true
    passport.authenticate('local', process)(req, res, next)

module.exports.isAuthenticated = (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        url = "/login#{req.url}"
        url += "?#{qs.stringify req.query}" if req.query.length
        res.redirect url
