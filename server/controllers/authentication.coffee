passport = require 'passport'
randomstring = require 'randomstring'

userManager = require '../models/user'
instanceManager = require '../models/user'
helpers = require '../../helpers'

passwordKeys = require '../lib/password_keys'

module.exports.registerIndex = (req, res) ->
    userManager.all (err, users) ->
        if not users? or users.length is 0
            res.render 'register.jade', title: 'Cozy Home - Sign up'
        else
            res.redirect 'login'

module.exports.register = (req, res, next) ->

    email = req.body.email
    password = req.body.password
    user =
        email: email
        password: password

    createUser = (url) ->
        hash = helpers.cryptPassword password
        user =
            email: email
            owner: true
            password: hash.hash
            salt: hash.salt
            activated: true
            docType: "User"

        userManager.createUser user, (err, code, user) =>
            if err
                console.log err
                res.send 500, "Server error occured."
            else
                req.body.username = "owner"
                next()

    if userManager.isValid user
        userManager.all (err, users) =>
            if err
                console.log err
                res.send 500, "Server error occured."
            else if users.length
                res.send 400, "User already registered."
            else
                createUser()
    else
        res.send 400, error: userManager.error

module.exports.loginIndex = (req, res) ->
    userManager.all (err, users) ->
        if users?.length > 0 and not err
            name = helpers.hideEmail users[0].value.email
            if name?
                name = name.charAt(0).toUpperCase() + name.slice(1)
            res.render 'login.jade',
                username: name
                title: 'Cozy Home - Sign in'
        else
            res.redirect 'register'

module.exports.login = (req, res, next) ->
    req.body.username = "owner"
    next()

module.exports.forgotPassword = (req, res) ->
    sendEmail = (instances, user, key) =>
        if instances.length > 0
            instance = instances[0].value
        else
            instance = domain: "domain.not.set"

        helpers.sendResetEmail instance, user, key, (err, result) ->
            if err
                res.send 500, error: "Email cannot be sent"
            else
                res.send 200, success: "Reset email sent."

    userManager.all (err, users) ->
        if err
            res.send 500, "Server error occured."
        else if users.length is 0
            res.send 500, error: "No user set, register first error occured."
        else
            user = users[0].value
            resetKey = randomstring.generate()
            instanceManager.resetKey = resetKey
            instanceManager.all (err, instances) =>
                if err
                    res.send 500, "Server error occured."
                else
                    sendEmail instances, user, resetKey

module.exports.resetPasswordIndex = (req, res) ->
    if instanceManager.resetKey is req.params.key
        res.render 'reset.jade',
            resetKey: req.params.key
            title: 'Cozy Home - Reset password'
    else
        res.redirect '/'

module.exports.resetPassword = (req, res) ->
    key = req.params.key
    newPassword = req.body.password

    checkKey = (user) =>
        if instanceManager.resetKey is req.params.key
            changeUserData user
        else
            res.send 400, error: "Key is not valid."

    changeUserData = (user) ->
        if newPassword? and newPassword.length > 5
            data = password: helpers.cryptPassword(newPassword).hash
            userManager.mergeUser user, data, (err) ->
                if err
                    res.send 500, error: 'User cannot be updated'
                else
                    instanceManager.resetKey = null
                    passwordKeys.resetKeys (err) ->
                        if err
                            res.send 500, error: "Server error occured"
                        else
                            res.send 200, success: true
        else
            res.send 400, error: 'Password is too short'

    userManager.all (err, users) ->
        if err
            res.send 500, error: "Server error occured."
        else if users.length is 0
            res.send 400, error: "No user registered."
        else
            checkKey users[0].value

module.exports.logout = (req, res) ->
    passwordKeys.deleteKeys (err) ->
        if err
            console.log err
            res.send 500, error: "An error occurred while logging out"
        else
            req.logout()
            res.send 200, success: true

module.exports.authenticated = (req, res) ->
    res.send 200, isAuthenticated: req.isAuthenticated()

