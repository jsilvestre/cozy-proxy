bcrypt = require 'bcrypt'
passport = require 'passport'
LocalStrategy = require('passport-local').Strategy

userManager = require '../models/user'

module.exports = ->

    # session variable
    passport.currentUser = null

    # serialize the user to cookie
    passport.serializeUser = (user, done) ->
        done null, user._id

    # deserialize the user from cookie
    passport.deserializeUser = (id, req, done) ->
        if passport.currentUser? and id is passport.currentUser._id
            done null, passport.currentUser
        else
            done null, false

    # strategy to use to identify the user
    passport.use new LocalStrategy (email, password, done) ->
        userManager.all (err, users) ->
            if err or (users is undefined or not users?) \
            or (users? and users.length is 0)
                done err, false
            else
                user = users[0].value
                bcrypt.compare password, user.password, (err, res) ->
                    if err
                        done err, false
                    else if res
                        passport.currentUser = user
                        passport.currentUser.id = user._id
                        done err, user
                    else
                        done err, false

