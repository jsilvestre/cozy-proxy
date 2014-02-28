should = require('chai').Should()
helpers = require './helpers'

client = helpers.getClient()

email = "test@cozycloud.cc"
password = "password"

describe "Register / Login", ->

    before helpers.createUserAllRequest
    before helpers.deleteAllUsers
    before helpers.startApp
    after helpers.stopApp
    after helpers.deleteAllUsers

    describe "Register", ->

        it "When I send a request to register", (done) ->
            data = email: email, password: password
            client.post "register", data, (error, response, body) =>
                console.log response.headers
                @body = body
                @response = response
                done()

        it "Then I got a success response", ->
            @response.statusCode.should.equal 200
            should.exist @body
            @body.success.should.equal true

    describe "Login", ->

        it "When I send a request to login", (done) ->
            client.post "login", password: password, (error, response, body) =>
                @body = body
                console.log response.headers
                @response = response
                done()

        it "Then user is authenticated", (done) ->
            client.get "authenticated", (error, response, body) ->
                response.statusCode.should.equal 200
                body.should.have.property 'isAuthenticated'
                body.isAuthenticated.should.be.ok
                done()

    describe "Logout", ->

        it "When I send a request to logout", (done) ->
            client.get "logout", (error, response, body) ->
                console.log response.headers
                response.statusCode.should.equal 200
                done()

        it "Then user is authenticated", (done) ->
            client.get "authenticated", (error, response, body) ->
                body.should.have.property 'isAuthenticated'
                body.isAuthenticated.should.not.be.ok
                done()

        it "When I send a request to login again", (done) ->
            client = helpers.getClient helpers.defaultClientUrl
            client.post "login", password: password, (error, response, body) =>
                @body = body
                console.log response.headers
                @response = response
                done()

describe "Register failure", ->

    before helpers.createUserAllRequest
    before helpers.deleteAllUsers
    before helpers.startApp
    after helpers.stopApp
    after helpers.deleteAllUsers

    it "When I send a register request with a wrong string as email", (done) ->
        data = email: "wrongemail", password: password
        client.post "register", data, (error, response, body) =>
            @response = response
            @body = body
            done()

    it "Then an error response is returned.", ->
        @response.statusCode.should.equal 400
        @body.should.have.property 'error'

    it "When I send a register request with a too short password", (done) ->
        data = email: email, password: "pas"
        client.post "register", data, (error, response, body) =>
            @response = response
            @body = body
            done()

    it "Then an error response is returned.", ->
        @response.statusCode.should.equal 400
