request = require "request"
https   = require "https"
config  = require "../../modules/config"


describe "server", ->
  error = undefined
  response = undefined
  body = undefined
  # could take a while
  it "should respond on port "+(config.port+1), (done) ->
    console.log "//////////////////////////////////////////////"
    req = https.request 
      host: "localhost"
      port: (config.port+1)
      path: '/'
      method: 'GET'
      rejectUnauthorized: false
      requestCert: true
      agent: false
    , (res) ->
      console.log res
      console.log "************************************************"
      #error = _error
      response = res

      #body = _body
      

      #expect(error).toBeNull()
      done()
    req.on "error", (error) ->
      console.log error
    req.end()
  , 10000

  it "should return statusCode 200", (done) ->
    expect(response.statusCode).toBe 200
    done()

  it "should have a body defined", (done) ->
    expect(body).toBeDefined()
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
