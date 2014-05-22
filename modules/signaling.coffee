WebSocketServer = require("ws").Server

###
    WebSocket stuff
###

exports.connect = (server) ->
    #console.log server
    wss = new WebSocketServer(server: server)
    wss.on "connection", (ws) ->
        console.log "new ws connection"
        ws.on "message", (msg) ->
            console.log 'ws received: '
            console.log msg

            try
                msg = JSON.parse msg

                
            catch e
                debug.error e
                ws.close()

        ws.on "close", ->
            console.log "ws connection closed: "