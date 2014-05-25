crypto = require "crypto"
WebSocketServer = require("ws").Server
logger = require "./logger"
###
    WebSocket stuff
###

###
roomList = []

class Room
    constructor: (@name, @ws) ->
###


class Rooms
    class Room 
        constructor: (@id, @masterId) ->

    constructor: (@roomList = []) ->
    newId: ->
        crypto.randomBytes(20).toString "hex"
    createId: ->
        id = null
        exist = true
        while exist
            exist = false
            id = @newId()
            for room in @roomList
                if room.id is id
                    exist = true
        return id

    add: (masterId) ->
        for room in @roomList
            return false if room.masterId is masterId 
        id = @createId()
        @roomList.push new Room(id, masterId)
        return true
    get: (roomId) ->
        for room in @roomList
            return room if room.id is roomId
        return 
    getMasterId: (roomId) ->
        for room in @roomList
            console.log "room: "
            console.log room
            return room.masterId if room.id is roomId
        return
    getRoomId: (masterId) ->
        for room in @roomList
            return room.id if room.masterId is masterId


exports.connect = (server) ->
    rooms = new Rooms
    wss = new WebSocketServer( server: server )
    

    logger.info "wss init"
    wss.on "connection", (wsConnection) ->
        exists = true
        while exists
            exists = false
            id = crypto.randomBytes(20).toString "hex"
            for client in wss.clients
                if client.clientId? is id
                    exists true
        
        wsConnection.clientId = id
        wsConnection.roomId   = null
        wsConnection.isMaster = false
        wsConnection.master   = null
        wsConnection.peers    = []

        
        logger.info "new ws connection"
        #console.log wsConnection

        wsConnection.on "message", (msg) ->
            logger.info "got msg from"
            logger.info msg
            #console.log wsConnection
            #console.log wsConnection.client
            try 
                parsedMsg = JSON.parse msg
                if !parsedMsg.type
                    throw new Error("msg.type not defined!")

                switch parsedMsg.type 
                    when "new" # master --> server
                        logger.info "ws: got 'new' msg"

                        if rooms.add(wsConnection.clientId)
                            logger.info "created new room"
                            # tell the master his roomId
                            wsConnection.send JSON.stringify( 
                                type: "id"
                                roomId: rooms.getRoomId(wsConnection.clientId)
                            )
                        else
                            logger.warn "this Client allready created a room"
                            wsConnection.send JSON.stringify(
                                type: "error"
                                message: "allready created a room"
                            )

                    when "connect" # client --> server --> master
                        logger.info "ws: got 'connect' msg"
                        masterId = rooms.getMasterId(parsedMsg.roomId)
                        console.log "master's id: "+masterId
                        for master in wss.clients
                            console.log "clientId: "+master.clientId
                            if master.clientId is masterId
                                console.log "room found"
                                master.send JSON.stringify(
                                    type: "connect"
                                    clientId: wsConnection.clientId
                                )
                                wsConnection.masterId = master.clientId
                                logger.info "sent connect msg"
                                break

                    when "offer" # master --> client                                
                        logger.info "ws: got 'offer' msg"
                        for client in wss.clients
                            if client.clientId is parsedMsg.clientId
                                client.send JSON.stringify(parsedMsg.data)
                                logger.info "offer sent to client"
                                break
                                                          
                    when "answer" # client --> master     
                        logger.info "ws: got 'answer' msg"
                        for master in wss.clients
                            if master.clientId is wsConnection.masterId
                                master.send JSON.stringify(
                                    clientId: wsConnection.clientId
                                    data: msg
                                )
                                logger.info "answer sent to master"
                                break

                    when "candidate" # send to other host
                        logger.info "ws: got 'candidate' msg"
                        if parsedMsg.clientId? # msg is from master
                            for client in wss.clients
                                if client.clientId is parsedMsg.clientId
                                    client.send JSON.stringify(parsedMsg.data)
                        else #msg is from client
                            for master in wss.clients
                                if master.clientId is wsConnection.masterId
                                    master.send JSON.stringify(
                                        clientId: wsConnection.clientId
                                        data: msg
                                    )
                    else
                        logger.warn "type?"
            catch error
                logger.error error.message
        ###
            #logger.info 'ws received: ', msg
            try
                originalMsg = msg
                msg = JSON.parse msg
                #console.log msg
                
                
                if !msg.type
                    throw new Error("msg.type not defined")

                #logger.info "msg", msg

                switch msg.type
                    # master creates new room
                    when "new" 
                        logger.info "ws: got 'new' msg"

                        exists = true
                        roomId = crypto.randomBytes(20).toString "hex"
                        
                        while exists
                            exists = false
                            
                            for client in wss.clients
                                console.log "client"
                                if client.roomId? is roomId
                                    exists = true
                                    roomId = crypto.randomBytes(20).toString "hex"
                                    break   
                            if exists is false
                                break
                        
                        ws.roomId = roomId
                        ws.isMaster = true
                        
                        # tell the master his roomId
                        ws.send JSON.stringify( 
                            type: "id"
                            value: @roomId
                        )
                        logger.info "created new room"
                    # client connects to master (=room)
                    when "connect" 
                        logger.info "ws: got 'connect' msg"
                        for client in wss.clients
                            if client.isMaster and client.roomId is msg.id
                                console.log "room found"
                                console.log client
                                ws.master = client
                                console.log "1"
                                ws.isMaster = false
                                console.log "2"
                                ws.roomId = client.roomId
                                console.log "3"
                                client.peers.push ws
                                console.log "4"
                                client.send "connected"
                        ws.send "connected"
                        #console.log ws
                        logger.info "sent connect msg"
                    when "offer" # client --> master                                add Client id?
                        logger.info "ws: got 'offer' msg"
                        #console.log ws.master
                        #console.log ws
                        console.log ws.isMaster
                        console.log ws.master
                        if !ws.isMaster and ws.master
                            console.log "send 'offer' to master"
                            ws.master.send JSON.stringify msg
                    # master --> peer                                           <-- hm... peer id or what? <<<======
                    when "answer" 
                        logger.info "ws: got 'answer' msg"
                        if ws.isMaster and msg.clientId
                            for peer in ws.peers
                                if peer.clientId is msg.clientId
                                    console.log "send 'answer' to client"
                                    peer.send originalMsg
                        
                    when "candidate" # send to other host
                        return
                        logger.info "ws: got 'candidate' msg"
                        msg.clientId = ws.clientId
                        if ws.isMaster and ws.peers
                            for peer in ws.peers
                                if msg.peerId is peer.clientId
                                    peer.send JSON.stringify(msg)
                                    break
                        else if ws.master
                            ws.master.send JSON.stringify(msg)
                    else 
                        logger.error "ws: unknown msg"
                
            catch e
                logger.error e
                logger.error "wasn't able to decode msg"
                #ws.close()
        ###

        wsConnection.on "close", ->
            #for room in roomList
            #    if room.ws is 
            logger.info "ws connection closed"