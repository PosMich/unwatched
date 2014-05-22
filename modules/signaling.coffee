WebSocketServer = require("ws").Server
logger = require "./logger"
###
    WebSocket stuff
###

exports.connect = (server) ->
    logger.error "should work"
    wss = new WebSocketServer( server: server )
    wss.on "connection", (ws) ->
        logger.error "new ws connection"
        ws.on "message", (msg) ->
            logger.info 'ws received: ', msg

            try
                msg = JSON.parse msg

            catch e
                logger.error e
                #ws.close()

        ws.on "close", ->
            logger.info "ws connection closed"