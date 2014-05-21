debug   = require "./debug"


WebSocketServer = require("ws").Server

###
    WebSocket stuff

    type of messages:
        --> "login": from driver/car to server
            --> if msg.user is car
                --> check Cars for id, validate password
                    --> password correct: add to driver, enable signalling
            --> if msg.user is driver
        --> "offer": from driver to car
            --> if signalling enabled
                --> sent offer to car
            --> else
                --> kill connection
        --> "answer": from car to driver
            --> if signalling enabled
                --> send answer to driver
            --> else
                --> kill connection
        --> "candidate": from car to driver vice versa
            --> if signalling enabled
                --> exchange canditates
            --> else
                --> kill connection
        --> "bye": from car to driver vice versa
            --> don't know
###

exports.signaling = (server) ->
    wss = new WebSocketServer(server: server)
    wss.on "connection", (ws) ->

        ws.on "message", (msg) ->
            debug.info 'ws received: '
            console.log msg

            try
                msg = JSON.parse msg

                
            catch e
                debug.error e
                ws.close()

        ws.on "close", ->
            debug.info "ws connection closed: "