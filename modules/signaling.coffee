WebSocketServer = require("ws").Server
logger = require "./logger"
###
    WebSocket stuff
###

roomList = []

class Room
    constructor: (@name, @ws) ->

# new Room 
# new SingleRoom
# connect to Room

exports.connect = (server) ->

    wss = new WebSocketServer( server: server )

    wss.broadcast = (data) ->
        for i of @clients
            @clients[i].send data
        return
    
    wss.on "connection", (ws) ->
        logger.info "new ws connection"
        ws.on "message", (msg) ->
            logger.info 'ws received: ', msg

            wss.broadcast msg

            console.log "----"+msg

            try
                msg = JSON.parse msg
                
                console.log "----"

                if !msg.type
                    throw new Error("msg.type not defined")

                logger.info "msg", msg

                switch msg.type
                    when "newRoom"
                        logger.info "ws: got newRoom msg"
                    when "newSingleRoom"
                        logger.info "ws: got newSingleRoom msg"
                    when "connect"
                        logger.info "ws: got connect msg"
                    when "offer"
                        logger.info "ws: got offer msg"
                    when "answer"
                        logger.info "ws: got answer msg"
                    when "canditate"
                        logger.info "ws: got answer msg"
                    else 
                        console.log "asdfasfd"
                        logger.error "ws: unknown msg"
                
            catch e
                logger.error e
                #ws.close()

        ws.on "close", ->
            logger.info "ws connection closed"