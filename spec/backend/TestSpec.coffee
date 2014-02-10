request = require "request"
config  = require "../../modules/config"

describe "server", ->
  error = undefined
  response = undefined
  body = undefined
  # could take a while
  it "should respond on port "+config.port, (done) ->
    request "http://localhost:"+config.port, (_error, _response, _body) ->
      error = _error
      response = _response
      body = _body

      expect(error).toBeNull()
      done()
  , 5000

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
