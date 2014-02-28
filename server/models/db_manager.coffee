Client = require('request-json').JsonClient
helpers = require '../../helpers'

# Main class used to manage models.
# It requires to be extend and "typed". See examples below.
module.exports = class DbManager

    constructor: ->
        @dbClient = new Client "http://localhost:9101/"
        @name = process.env.NAME
        @token = process.env.TOKEN
        if process.env.NODE_ENV is "production" or process.env.NODE_ENV is "test"
            @dbClient.setBasicAuth @name, @token

    all: (callback) ->
        path = "request/#{@type.toLowerCase()}/all/"
        @dbClient.post path, {}, (err, response, models) =>
            if err
                callback err
            else if response.statusCode isnt 200
                callback new Error(models)
            else
                callback null, models

    create: (model, callback) ->
        model.docType = @type
        @dbClient.post "data/", model, (err, response, model) =>
            if err
                callback err, 500
            else if response.statusCode isnt 201
                callback new Error("Error occured"), response.statusCode
            else
                callback null, 201, model

    merge: (model, data, callback) ->
        @dbClient.put "data/merge/#{model._id}/", data, (err, res, body) =>
            if err
                callback err
            else if res.statusCode is 404
                callback new Error("Model does not exist")
            else if res.statusCode isnt 200
                callback new Error(body)
            else
                callback null

    deleteAll: (callback) ->
        path = "request/#{@type.toLowerCase()}/all/destroy/"
        @dbClient.put path, {}, (err, response) ->
            if err
                callback err
            else if response.statusCode isnt 204
                callback new Error("Server error")
            else
                callback null