https     = require "https"
WebSocket = require "ws"

config  = require "../../userconfig"

describe "server", ->
    error = undefined
    response = undefined
    body = undefined

    # could take a while
    it "should respond on port "+(config.port.https), (done) ->
        error = null
        body = ""
        response = null

        req = https.request 
            host: "localhost"
            port: (config.port.https)
            path: '/'
            method: 'GET'
            rejectUnauthorized: false
            requestCert: true
            agent: false
        , (res) ->
            response = res
            res.on "data", (data) ->
                body += data.toString()
                done()


        req.end()
        req.on "end", ->
            expect(error).toBeNull()
            done()
        req.on "error", (error) ->
            expect(error).toBeNull()
            done()
    , 10000

    it "should return statusCode 200", (done) ->
        expect(response.statusCode).toBe 200
        done()

    it "should have a body defined", (done) ->
        expect(body).not.toBe ""
        done()

    it "should contain a doctype at the beginning of the page", (done) ->
        expect(body).toMatch /^<!DOCTYPE html>/
        done()

    it "should contain the ng-app tag", (done) ->
        expect(body).toMatch /<html ng-app="[a-zA-Z0-9]+">/
        done()

    it "should contain a head, title and body", (done) ->
        expect(body).toMatch /<head>/i
        expect(body).toMatch /<title>(.)+<\/title>/i
        expect(body).toMatch /<body>([\s\S])+<\/body>/i
        done()


describe "websocket", ->
    it "should be able to connect to the ws server", (done) ->
        ws = new WebSocket("wss://localhost:#{config.port.https}/",
            rejectUnauthorized: false
            requestCert: true
        )
        ws.on "open", ->
            done()
            #ws.send Date.now().toString(),
                #mask: true

        ws.on "message", (data, flags) ->
            console.log "Roundtrip time: " + (Date.now() - parseInt(data)) + "ms", flags
            #setTimeout (->
                #ws.send Date.now().toString(),
                #    mask: true

            # ), 500
          