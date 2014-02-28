DbManager = require './db_manager'
helpers = require '../../helpers'

class UserManager extends DbManager
    type: 'User'

    isValid: (user) ->
        if user.password? and user.password.length > 4
            if helpers.checkMail user.email
                @error = null
                true
            else
                @error = 'Wrong email format'
                false
        else
            @error = 'Password is too short'
            false

    createUser: (model, callback) ->
        model.docType = @type
        @dbClient.post "user/", model, (err, response, model) ->
            if err
                callback err, 500
            else if response.statusCode isnt 201
                callback new Error("Error occured"), response.statusCode
            else
                callback null, 201, model

    mergeUser: (model, data, callback) ->
        @dbClient.put "user/merge/#{model._id}/", data, (err, res, body) ->
            if err
                callback err
            else if res.statusCode is 404
                callback new Error "Model does not exist"
            else if res.statusCode isnt 200
               callback new Error body
            else
                callback null

    getUser: (callback) ->
        @all (err, users) ->
            if err then callback err
            else if users.length is 0 then callback null, null
            else callback null, users[0]

module.exports = new UserManager()
