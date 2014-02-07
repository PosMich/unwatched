request = require("request")

console.log "blubb"

describe "App" ->
  describe "index" ->
    it "should respond with hello world", (done) ->
      request "http://localhost:3000/hello", (error, response, body) ->
        expect(body).toEqual "hello world"
        done()
