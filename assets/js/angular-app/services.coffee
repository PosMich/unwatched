# Unwatched - Angular Services
# ============================




"use strict"
class RTCService

    @::ReceiveChunkFiles  = []
    @::sendChunkFileCounter = 0
    # chunkFileId: 123, chunks: []
    @::isMaster = false
    ###
    @::iceServers = [
        { url: "stun:stun01.sipphone.com" }
        { url: "stun:stun.ekiga.net" }
        { url: "stun:stun.fwdnet.net" }
        { url: "stun:stun.ideasip.com" }
        { url: "stun:stun.iptel.org" }
        { url: "stun:stun.rixtelecom.se" }
        { url: "stun:stun.schlund.de" }
        { url: "stun:stun.l.google.com:19302" }
        { url: "stun:stun1.l.google.com:19302" }
        { url: "stun:stun2.l.google.com:19302" }
        { url: "stun:stun3.l.google.com:19302" }
        { url: "stun:stun4.l.google.com:19302" }
        { url: "stun:stunserver.org" }
        { url: "stun:stun.softjoys.com" }
        { url: "stun:stun.voiparound.com" }
        { url: "stun:stun.voipbuster.com" }
        { url: "stun:stun.voipstunt.com" }
        { url: "stun:stun.voxgratia.org" }
        { url: "stun:stun.xten.com" }
        {
            url: "turn:numb.viagenie.ca"
            credential: "muazkh"
            username: "webrtc@live.com"
        }
        {
            url: "turn:192.158.29.39:3478?transport=udp"
            credential: "JZEOEt2V3Qb0y27GRntt2u2PAYA="
            username: "28224511:1379330808"
        }
        {
            url: "turn:192.158.29.39:3478?transport=tcp"
            credential: "JZEOEt2V3Qb0y27GRntt2u2PAYA="
            username: "28224511:1379330808"
        }
    ]
    ###
    @::iceServers = [
        { url: "stun:stun.l.google.com:19302" }
        { url: "stun:stun1.l.google.com:19302" }
        { url: "stun:stun2.l.google.com:19302" }
        { url: "stun:stun3.l.google.com:19302" }
        { url: "stun:stun4.l.google.com:19302" }
        { url: "stun:stunserver.org" }
        { url: "stun:stun.softjoys.com" }
        { url: "stun:stun.voiparound.com" }
        { url: "stun:stun.voipbuster.com" }
        { url: "stun:stun.voipstunt.com" }
        { url: "stun:stun.voxgratia.org" }
        { url: "stun:stun.xten.com" }
        {
            url: "turn:numb.viagenie.ca"
            credential: "muazkh"
            username: "webrtc@live.com"
        }
        {
            url: "turn:192.158.29.39:3478?transport=udp"
            credential: "JZEOEt2V3Qb0y27GRntt2u2PAYA="
            username: "28224511:1379330808"
        }
        {
            url: "turn:192.158.29.39:3478?transport=tcp"
            credential: "JZEOEt2V3Qb0y27GRntt2u2PAYA="
            username: "28224511:1379330808"
        }
    ]
    @::signalServer = "wss://localhost:3001"

    ab2str: (uint8) ->
        String.fromCharCode.apply(null,
            new Uint16Array(uint8.buffer.slice(uint8.byteOffset))).trim()

    #        return String.fromCharCode.apply(null, uint8).trim();
    str2ab: (str) ->
        buf = new ArrayBuffer(str.length * 2) # 2 bytes for each char
        bufView = new Uint16Array(buf)
        i = 0
        strLen = str.length

        while i < strLen
            bufView[i] = str.charCodeAt(i)
            i++

        #        return buf;
        new Uint8Array(buf)

    ab2ascii: (buf) ->
        String.fromCharCode.apply(null, buf).trim()

    # json to binary array, binary array to string
    ascii2ab: (str, padding) ->
        buf = new Uint8Array(str.length)
        i = 0

        while i < str.length
            buf[i] = str.charCodeAt(i)
            i++
        if padding
            j = str.length

            while j < padding
                buf[j] = " "
            j++
        buf # was return buf

    # JSON --> to String --> binary array --> split --> to String --> send
    # receive --> concat --> binary array --> string --> json

    createChunks: (msg, userId) ->
        console.log "createChunks", msg
        chunks = []


        #   {
        #       "type":"chunk",
        #       "userId": 12345,
        #       "id":1073741824,
        #       "chunkId":1073741824,
        #       "length":1073741824,
        #       "data":""
        #   }
        maxChunkSize = 1000


        message = JSON.stringify(msg)

        if message.length < maxChunkSize
            return [msg]

        index = 0
        start = 0
        while index * maxChunkSize < message.length
            chunks.push message.slice(start, start + maxChunkSize)
            start += maxChunkSize
            ++index

        id = ++@sendChunkFileCounter
        sendMessages = []
        i = 0
        while i < chunks.length
            sendMessages.push
                type: "chunk"
                userId: userId
                id: id
                chunkId: i
                length: chunks.length
                data: chunks[i]
            ++i

        console.log "sendMessages =", sendMessages
        sendMessages

    #   {
    #       "type":"chunk",
    #       "userId": 12345,
    #       "id":1073741824, <-- user dependend
    #       "chunkId":1073741824,
    #       "length":1073741824,
    #       "data":""
    #   }
    receiveChunk: (chunk, userId) ->
        currentChunkFile = false
        for chunkFile in @ReceiveChunkFiles
            if chunkFile.id is chunk.id and chunkFile.userId is userId
                currentChunkFile = chunkFile
                break
        #console.log "currentChunkFile", currentChunkFile
        alltogether = ""
        if currentChunkFile
            console.log "chunk file exists", chunk.data
            currentChunkFile.chunks.push chunk.data

            if currentChunkFile.chunks.length is chunk.length
                for chunk in currentChunkFile.chunks
                    console.log chunk.id
                    alltogether += chunk

                if @isMaster
                    for client in @handler.signallingClients
                        if client.id is userId
                            client.DChandleMessage
                                data: alltogether
                else
                    @handler.DChandleMessage
                        data: alltogether

                #complete, put together, reset ChunkFiles storage
                for chunkFile, index in @ReceiveChunkFiles
                    if chunkFile.id is chunk.id and chunkFile.userId is userId
                        @ReceiveChunkFiles.splice index, 1
        else
            console.log "push chunk file"
            @ReceiveChunkFiles.push
                id: chunk.id
                chunks: [chunk.data]
                userId: userId

            # add to Chunkfiles


    class Master
        @::roomId            = null
        @::signallingClients = []
        @::p2pClients        = []
        @::password          = null
        @::id                = 0
        @::sdpConstraints =
            optional: []
            mandatory:
                OfferToReceiveAudio: false
                OfferToReceiveVideo: false

        class P2pPairs
            @::idCounter = 0
            @::p2pPairs  = []
            class P2pClient
                constructor: (@id, @client1Id, @client2Id) ->
            add: (client1Id, client2Id) ->
                @p2pPairs.push new P2pClient(++@idCounter, client1Id, client2Id)
            getClient1: (id) ->
                for pair in @p2pPairs
                    return pair.client1Id if pair.id is id
                return false
            getClient2: (id) ->
                for pair in @p2pPairs
                    return pair.client2Id if pair.id is id
                return false

        # this is a slaves upstream to the master
        class SlaveRTC
            @::id         = null
            @::connection = null
            @::signaller  = null
            @::dataChannel = null
            @::debug      = true
            @::loginAttempts = 3
            @::authenticated = false

            constructor: (@signaller, @id) ->
                @connection = new RTCPeerConnection(
                    iceServers: @signaller.service.iceServers
                ,
                    null
                    #optional: [
                    #        DtlsSrtpKeyAgreement: true
                    #    ,
                    #        RtpDataChannels: true
                    #]
                )
                @connection.onicecandidate = @handleOwnIce

                @connection.onnegotiationneeded = @handleNegotiation
                @connection.onsignalingstatechange = @handleStateChange

                @connection.onaddstream = @onAddStream
                @connection.onremovestream = @onRemoveStream

                try
                    @dataChannel = @connection.createDataChannel "control",
                        reliable: false
                    @dataChannel.onmessage = @DChandleMessage
                    @dataChannel.onerror   = @DChandleError
                    @dataChannel.onopen    = @DChandleOpen
                    @dataChannel.onclose   = @DChandleClose
                catch error
                    console.log "error creating Data Channel", error.message

            handleOwnIce: (event) =>
                console.log "handleOwnIce" if @debug
                if event.candidate
                    @signaller.signalSend
                        type: "candidate"
                        label: event.candidate.sdpMLineIndex
                        id: event.candidate.sdpMid
                        candidate: event.candidate.candidate
                        clientId: @id
                else
                    console.log "end of candidates"

            createOffer: -> # send to client
                console.log "create offer" if @debug
                @connection.createOffer (description) =>
                    @connection.setLocalDescription description
                    description.clientId = @id
                    @signaller.signalSend description
                , null, @signaller.sdpConstraints
            handleAnswer: (answer) -> # received from client
                console.log "handle answer", answer if @debug
                @connection.setRemoteDescription new RTCSessionDescription(
                    answer
                )

            handleIce: (ice) ->
                console.log "handleIce" if @debug
                @connection.addIceCandidate new RTCIceCandidate(
                    sdpMLineIndex: ice.label
                    candidate: ice.candidate
                )

            handleNegotiation: => # here we will send the offer
                console.log "handleNegotiation" if @debug
                @createOffer()

            handleStateChange: ->
                console.log "handle state change" if @debug

            # DataChannel Handlers
            DChandleMessage: (msg) =>
                # console.log "got a message from DC", msg

                parsedMsg = JSON.parse(msg.data)
                console.log parsedMsg.type
                # console.log "parsed"
                # console.log parsedMsg
                switch parsedMsg.type
                    when "chunk"
                        @signaller.service.receiveChunk(parsedMsg, @id)
                    when "chat"
                        @signaller.service.ChatService.addMessage(
                            parsedMsg.message, parsedMsg.sender
                        )

                    when "password"
                        console.log "parsed: " + parsedMsg.password
                        console.log "signaller: " + @signaller.password
                        if parsedMsg.password isnt @signaller.password
                            @DCsend
                                type: "password"
                                passwordIsValid: false

                            --@loginAttempts

                            @dataChannel.close() if @loginAttempts <= 0

                            @signaller.removeSlave(@id)
                        else
                            @authenticated = true
                            @id = @signaller.service.UserService
                                .addUser("Unnamed")
                            room = @signaller.service.RoomService
                            # if password is true, send back the init data

                            initData =
                                type: "password"
                                passwordIsValid: true
                                init:
                                    userId: @id
                                    users: @signaller.service.UserService.users
                                    messages:
                                        @signaller.service.ChatService.messages
                                    shares:
                                        @signaller.service.SharesService.shares
                                    room:
                                        id: @signaller.roomId
                                        name: room.name
                                        created:
                                            room.created
                                        description:
                                            room.description
                                        url:
                                            room.url

                            @DCsend initData

                    when "userNameHasChanged"
                        @signaller.service.UserService.changeName(
                            parsedMsg.message.userId, parsedMsg.message.userName
                        )

                        for client in @signaller.signallingClients
                            if !client.authenticated
                                continue
                            if client.id isnt parsedMsg.message.userId
                                client.DCsend
                                    type: "userNameHasChanged"
                                    message: parsedMsg.message

                    when "userPicHasChanged"
                        @signaller.service.UserService.changePic(
                            parsedMsg.message.userId, parsedMsg.message.userPic
                        )


                        for client in @signaller.signallingClients
                            if !client.authenticated
                                continue

                            if client.id isnt parsedMsg.message.userId
                                client.DCsend
                                    type: "userPicHasChanged"
                                    message: parsedMsg.message

                    when "userDeleted"
                        @signaller.service.UserService.delete parsedMsg.userId
                        @dataChannel.close()
                        @signaller.removeSlave(@id)

                        for client in @signaller.signallingClients
                            if !client.authenticated
                                continue
                            if client.id isnt parsedMsg.userId
                                client.DCsend parsedMsg

                    when "newCodeItem"
                        @signaller.service.SharesService.shares.push(
                            parsedMsg.codeItem )

                        for client in @signaller.signallingClients
                            if !client.authenticated
                                continue
                            if client.id isnt parsedMsg.codeItem.author
                                client.DCsend parsedMsg

                    when "codeItemHasChanged"
                        @signaller.service.SharesService.updateItem(
                            parsedMsg.itemId, parsedMsg.change
                        )

                        item = @signaller.service.SharesService.get(
                            parsedMsg.itemId
                        )

                        for client in @signaller.signallingClients
                            if !client.authenticated
                                continue
                            if client.id isnt parsedMsg.id
                                client.DCsend parsedMsg

                    when "codeDocumentHasChanged"
                        item = @signaller.service.SharesService.get(
                            parsedMsg.itemId )
                        item.deltas = parsedMsg.change

                        active_contributors = []

                        for contributor in item.contributors
                            if contributor.active
                                active_contributors.push contributor.id

                        for client in @signaller.signallingClients
                            if !client.authenticated
                                continue
                            if active_contributors.indexOf( client.id ) isnt -1
                                if client.id isnt parsedMsg.userId
                                    console.log "sending code to client with id", client.id
                                    client.DCsend parsedMsg

                    when "cursorHasChanged"
                        item = @signaller.service.SharesService.get(
                            parsedMsg.itemId )

                        @signaller.service.$rootScope.markersChanged = true
                        for marker in @signaller.service.$rootScope.markers
                            if marker.contributorId is parsedMsg.userId
                                marker.cursor = parsedMsg.change
                                console.log "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

                        active_contributors = []

                        for contributor in item.contributors
                            if contributor.active
                                active_contributors.push contributor.id

                        for client in @signaller.signallingClients
                            if !client.authenticated
                                continue
                            if active_contributors.indexOf( client.id ) isnt -1
                                if client.id isnt parsedMsg.userId
                                    client.DCsend parsedMsg

                    when "codeItemDeleted"
                        @signaller.service.SharesService.delete parsedMsg.itemId

                        for client in @signaller.signallingClients
                            if !client.authenticated
                                continue
                            if client.id isnt parsedMsg.userId
                                client.DCsend parsedMsg


                    else
                        console.log "DChandle: unknown msg"

                if !@signaller.service.$rootScope.$$phase
                    @signaller.service.$rootScope.$apply()

            DChandleError: (error) ->
                console.log "got an DC error!", error if @debug

            DChandleOpen: =>
                console.log "DC is open!" if @debug
                if !@signaller.service.$rootScope.$$phase
                    @signaller.service.$rootScope.$apply()

            DChandleClose: ->
                console.log "DC is closed!" if @debug

            DCsend: (message) ->
                messages = @signaller.service.createChunks(message, @id)
                #console.log "DCsend" + JSON.stringify(message)
                #console.log message
                #@dataChannel.send JSON.stringify(message)
                #console.log "sent?"
                for message in messages
                    @dataChannel.send JSON.stringify(message)
                    console.log "sent?", message

        constructor: (@service) ->
            console.log "setup" if @debug
            @signalConnection = new WebSocket(@service.signalServer)
            @signalConnection.onopen    = @handleSignalOpen
            @signalConnection.onmessage = @handleSignalMessage
            @signalConnection.onerror   = @handleSignalError
            @signalConnection.onclose   = @handleSignalClose

            @signalSend type: "new"
        signalSend: (msg) ->
            if @signalConnection.readyState is 1
                @signalConnection.send JSON.stringify(msg)
            else
                console.log "Signalling Channel isn't ready"
                setTimeout =>
                    @signalSend msg
                , 25

        handleSignalOpen: (event) ->
            console.log "Signalling Channel Opened"

        handleSignalMessage: (event) =>
            console.log "got message!", event if @debug
            try
                parsedMsg = JSON.parse(event.data)

                if !parsedMsg.type
                    throw new Error("message Type not defined")

            catch e
                console.log "wasn't able to parse message", e.message

            switch parsedMsg.type
                when "id" # room creation successful
                    console.log "got id: " + parsedMsg.roomId if @debug
                    @roomId = parsedMsg.roomId
                    console.log "created room: " + parsedMsg.roomId

                when "connect"  # new client
                    console.log "client want's to connect"  if @debug
                    @signallingClients.push new SlaveRTC(@, parsedMsg.clientId)

                when "answer"
                    for slave in @signallingClients
                        if slave.id is parsedMsg.clientId
                            slave.handleAnswer parsedMsg
                            console.log "answer" if @debug
                            break

                when "candidate"
                    for slave in @signallingClients
                        if slave.id is parsedMsg.clientId
                            slave.handleIce parsedMsg
                            console.log "candidate for client" if @debug
                            break

                else
                    console.log "other message", parsedMsg

            @service.$rootScope.$apply() if !@service.$rootScope.$$phase

        handleSignalError: (event) ->
            console.log "Signalling Channel Error", event

        handleSignalClose: (event) ->
            console.log "Signalling Channel Closed", event

        setPassword: (@password) ->

        removeSlave: (slaveId) ->
            for index of @signallingClients
                if @signallingClients[index].id is slaveId
                    @signallingClients.splice index, 1
                    break


    # only 1 pc to the server
    class Slave
        @::signalServer = "wss://localhost:3001"
        @::roomId       = null
        @::id           = null
        @::connection   = null
        @::debug        = true
        @::dataChannel  = null
        @::sdpConstraints =
            optional: []
            mandatory:
                OfferToReceiveAudio: false
                OfferToReceiveVideo: false

        constructor: (@service) ->
            console.log "setup" if @debug
            @signalConnection = new WebSocket(@service.signalServer)
            @signalConnection.onopen    = @handleSignalOpen
            @signalConnection.onmessage = @handleSignalMessage
            @signalConnection.onerror   = @handleSignalError
            @signalConnection.onclose   = @handleSignalClose

            @connection = new RTCPeerConnection(
                iceServers: @service.iceServers
            ,
                null
                #optional: [
                #        DtlsSrtpKeyAgreement: true
                #    ,
                #        RtpDataChannels: true
                #]
            )
            @connection.onicecandidate = @handleOwnIce

            @connection.onnegotiationneeded = @handleNegotiation
            @connection.onsignalingstatechange = @handleStateChange

            @connection.onaddstream = @onAddStream
            @connection.onremovestream = @onRemoveStream

            @connection.ondatachannel = @gotDataChannel

            @signalSend
                type: "connect"
                roomId: @service.roomId

        signalSend: (msg) ->
            if @signalConnection.readyState is 1
                @signalConnection.send JSON.stringify(msg)
            else
                console.log "Signalling Channel isn't ready"
                setTimeout =>
                    @signalSend msg
                , 25
        handleSignalOpen: (event) ->
            console.log "Signalling Channel Opened"
        handleSignalMessage: (event) =>
            console.log "got message!" if @debug
            try
                parsedMsg = JSON.parse(event.data)

                if !parsedMsg.type
                    throw new Error("message Type not defined")

                switch parsedMsg.type
                    when "id" # room creation successful
                        console.log "got id: " + parsedMsg.clientId if @debug
                        @id = parsedMsg.clientId

                    when "offer"
                        @handleOffer( parsedMsg )

                    when "candidate"
                        @handleIce( parsedMsg )
                    else
                        console.log "other message"
                        console.log parsedMsg
            catch e
                console.log "wasn't able to parse message"
                console.log e.message
                console.log event
                console.log event.data
        handleSignalError: (event) ->
            console.log "Signalling Channel Error"
            console.log event
        handleSignalClose: (event) ->
            console.log "Signalling Channel Closed"
        handleOwnIce: (event) =>
            console.log "handleOwnIce" if @debug
            if event.candidate
                @signalSend
                    type: "candidate"
                    label: event.candidate.sdpMLineIndex
                    id: event.candidate.sdpMid
                    candidate: event.candidate.candidate
                    clientId: @id
            else
                console.log "end of candidates"
        handleIce: (ice) ->
            console.log "handleIce" if @debug
            @connection.addIceCandidate new RTCIceCandidate(
                sdpMLineIndex: ice.label
                candidate: ice.candidate
            )
        handleOffer: (offer) =>
            console.log "handle offer" if @debug
            @connection.setRemoteDescription new RTCSessionDescription(offer)
            @createAnswer()
        createAnswer: ->
            console.log "create answer" if @debug
            @connection.createAnswer (description) =>
                @connection.setLocalDescription description
                description.clientId = @id
                console.log @id if @debug
                console.log "answer sent?" if @debug
                @signalSend description
            , null, @sdpConstraints
        handleNegotiation: ->
            console.log "handleNegotiation"
        handleStateChange: ->
            console.log "stateChange"
        onAddStream: ->
            console.log "stream added"
        onRemoveStream: ->
            console.log "stream removed"
        gotDataChannel: (event) =>
            console.log "RTConnection gotDataChannel"
            @dataChannel = event.channel
            @dataChannel.onmessage = @DChandleMessage
            @dataChannel.onerror   = @DChandleError
            @dataChannel.onopen    = @DChandleOpen
            @dataChannel.onclose   = @DChandleClose

        DChandleMessage: (msg) =>
            console.log "got a message from DC",
            console.log msg


            parsedMsg = JSON.parse(msg.data)
            console.log "parsed"
            console.log parsedMsg
            switch parsedMsg.type#
                when "chunk"
                    console.log "received chunk"
                    @service.receiveChunk(parsedMsg, @id)
                when "chat"
                    # message
                    # sender
                    @service.ChatService.addMessage parsedMsg.message,
                        parsedMsg.sender
                when "user"
                    # user
                    @service.UserService.addInitUser parsedMsg.user

                when "roomNameHasChanged"
                    @service.RoomService.name = parsedMsg.roomName

                when "roomDescriptionHasChanged"
                    @service.RoomService.description = parsedMsg.roomDescription

                when "userNameHasChanged"
                    @service.UserService.changeName(
                        parsedMsg.message.userId, parsedMsg.message.userName
                    )

                when "userPicHasChanged"
                    @service.UserService.changePic(
                        parsedMsg.message.userId, parsedMsg.message.userPic
                    )

                when "roomClosed"
                    @service.RoomService.isClosed = true

                when "newCodeItem"
                    console.log "got new code item: ", parsedMsg.codeItem
                    @service.SharesService.shares.push parsedMsg.codeItem

                when "codeItemHasChanged"
                    @service.SharesService.updateItem( parsedMsg.itemId,
                        parsedMsg.change )

                when "codeDocumentHasChanged"
                    item = @service.SharesService.get parsedMsg.itemId
                    item.deltas = parsedMsg.change

                when "cursorHasChanged"
                    @service.$rootScope.markersChanged = true
                    for marker in @service.$rootScope.markers
                        if marker.contributorId is parsedMsg.userId
                            marker.cursor = parsedMsg.change

                when "codeItemDeleted"
                    @service.SharesService.delete parsedMsg.itemId

                when "password"
                    if parsedMsg.passwordIsValid
                        @passwordIsValid = parsedMsg.passwordIsValid
                        @id = @service.$rootScope.userId = parsedMsg.init.userId
                        @service.RoomService.id = parsedMsg.init.room.id
                        @service.RoomService.name = parsedMsg.init.room.name
                        @service.RoomService.description =
                            parsedMsg.init.room.description

                        for user in parsedMsg.init.users
                            @service.UserService.addInitUser user

                        @service.ChatService.messages = parsedMsg.init.messages
                        @service.SharesService.shares = parsedMsg.init.shares
                else
                    console.log "DChandle: unknown msg"

            @service.$rootScope.$apply() if !@service.$rootScope.$$phase
        DChandleError: (error) ->
            console.log "got an DC error!", error
        DChandleOpen: =>
            console.log "DC is open!"
            @service.$rootScope.$apply() if !@service.$rootScope.$$phase
        DChandleClose: ->
            console.log "DC is closed!"

        DCsend: (message) ->
            messages = @service.createChunks(message, @id)

            for message in messages
                @dataChannel.send JSON.stringify(message)
                console.log "DCsend", message
            #@dataChannel.send JSON.stringify(message)


    constructor: (@$rootScope, @UserService, @ChatService, @RoomService, @SharesService) ->

    setup: (@roomId) ->
        console.log "setup done"
        if !@roomId # this is a master
            @handler = new Master(@)
            @isMaster = true
            @handler.listeners = @listeners

            @$rootScope.$watch =>
                @ChatService.messages
            , (new_messages, old_messages) =>
                i = old_messages.length
                while i < new_messages.length
                    for client in @handler.signallingClients
                        if client.id isnt new_messages[i].sender
                            client.DCsend
                                type: "chat"
                                message: new_messages[i].message
                                sender: new_messages[i].sender
                    ++i
            , true

            @$rootScope.$watch =>
                @UserService.users
            , (new_users, old_users) =>
                i = old_users.length
                while i < new_users.length
                    for client in @handler.signallingClients
                        if client.authenticated
                            if new_users[i].id isnt client.id
                                client.DCsend
                                    type: "user"
                                    user: new_users[i]
                    ++i
            , true

            @$rootScope.$watch =>
                @RoomService.name
            , (new_room_name) =>
                for client in @handler.signallingClients
                    client.DCsend
                        type: "roomNameHasChanged"
                        roomName: new_room_name
            , true

            @$rootScope.$watch =>
                @RoomService.description
            , (new_room_description) =>
                for client in @handler.signallingClients
                    client.DCsend
                        type: "roomDescriptionHasChanged"
                        roomDescription: new_room_description
            , true

        else # this is a slave
            @handler = new Slave(@)
            @handler.listeners = @listeners

            @$rootScope.$watch =>
                @ChatService.messages
            , (new_messages, old_messages) =>
                i = old_messages.length
                while i < new_messages.length
                    if new_messages[i].sender is @$rootScope.userId
                        console.log "sending message ", new_messages[i]
                        @handler.DCsend
                            type: "chat"
                            message: new_messages[i].message
                            sender: new_messages[i].sender

                    ++i
            , true


    setPassword: (password) ->
        if @handler.password is null
            @handler.setPassword password

    checkPassword: (password) ->
        console.log "checkPassword: " + password
        @handler.DCsend
            type: "password"
            password: password

    sendUserChanges: (type, message) ->
        @handler.DCsend
            type: type
            message: message


    broadcastUserChanges: (type, message) ->
        for client in @handler.signallingClients
            if !client.authenticated
                continue
            client.DCsend
                type: type
                message: message



    sendUserDeleted: (user) ->
        if !user.isMaster
            @handler.DCsend
                type: "userDeleted"
                userId: user.id
        else
            for client in @handler.signallingClients
                if !client.authenticated
                    continue
                client.DCsend
                    type: "roomClosed"

            window.setTimeout((->
                window.location "/"
            ), 5000)

    sendNewCodeItem: (codeItem, isMaster) ->

        dataChannelMessage =
            type: "newCodeItem"
            codeItem: codeItem

        if !isMaster
            @handler.DCsend dataChannelMessage
        else
            for client in @handler.signallingClients
                if !client.authenticated
                    continue
                client.DCsend dataChannelMessage

    sendCodeItemHasChanged: (change, itemId, isMaster) ->

        dataChannelMessage =
            type: "codeItemHasChanged"
            change: change
            itemId: itemId

        if !isMaster
            @handler.DCsend dataChannelMessage

        else
            for client in @handler.signallingClients
                if !client.authenticated
                    continue
                client.DCsend dataChannelMessage

    broadcastCodeDocumentHasChanged: (change, itemId, user) ->

        dataChannelMessage =
            type: "codeDocumentHasChanged"
            itemId: itemId
            change: change
            userId: user.id

        if !user.isMaster
            @handler.DCsend dataChannelMessage

        else
            active_contributors = []
            for contributor in @SharesService.get(itemId).contributors
                if contributor.active
                    active_contributors.push contributor.id

            for client in @handler.signallingClients
                if !client.authenticated
                    continue
                if active_contributors.indexOf( client.id ) isnt -1
                    client.DCsend dataChannelMessage

    broadcastCursorHasChanged: (cursor, user, itemId) ->

        dataChannelMessage =
            type: "cursorHasChanged"
            change: cursor
            userId: user.id
            itemId: itemId

        if !user.isMaster
            @handler.DCsend dataChannelMessage

        else
            active_contributors = []
            for contributor in @SharesService.get(itemId).contributors
                if contributor.active
                    active_contributors.push contributor.id

            for client in @handler.signallingClients
                if !client.authenticated
                    continue
                if active_contributors.indexOf( client.id ) isnt -1
                    client.DCsend dataChannelMessage

    sendCodeItemDeleted: (user, itemId) ->

        dataChannelMessage =
            type: "codeItemDeleted"
            userId: user.id
            itemId: itemId

        if !user.isMaster
            @handler.DCsend dataChannelMessage

        else
            for client in @handler.signallingClients
                if !client.authenticated
                    continue
                client.DCsend dataChannelMessage

class Users
    @::users = []
    @::colors = [
        [125,217,148]
        [203,85,215]
        [223,93,43]
        [55,48,67]
        [120,163,213]
        [199,217,74]
        [144,111,47]
        [95,132,115]
        [211,79,152]
        [130,117,214]
        [220,79,95]
        [206,205,158]
        [93,142,56]
        [104,216,71]
        [127,210,208]
        [134,57,88]
        [206,163,192]
        [59,70,37]
        [112,63,130]
        [91,45,35]
        [197,137,112]
        [215,169,64]
        [80,99,136]
        [153,55,39]
    ]

    class User
        @::isMaster = false
        @::name     = ""
        @::pic      = ""
        @::id       = -1
        @::color    = null
        @::frontendColor = null
        @::joinedDate = null
        @::isActive   = true
        constructor: (@name, @id, @color, @isMaster, @pic = false,
            joinedDate = false) ->
            console.log "new user: " + @name
            @joinedDate = if !joinedDate then new Date() else joinedDate
            if !pic
                @pic = "/images/avatar.png"
                if Math.round(Math.random()) is 0
                    @pic = "/images/avatar_inverted.png"
            @frontendColor = @getColorAsHex()



        getColorAsHex: ->
            "#" +
            @color[0].toString(16) +
            @color[1].toString(16) +
            @color[2].toString(16)
        getColorAsRGB: ->
            "rgb(" +
            @color[0] + "," +
            @color[1] + "," +
            @color[2] + ")"
        getColorWithOpacity: (opacity) ->
            "rgba(" +
            @color[0] + "," +
            @color[1] + "," +
            @color[2] + "," +
            opacity + ")"
        changePic: (@pic) ->
        changeName: (@name) ->

    constructor: (@$rootScope) ->
        style = document.createElement "style"
        style.type = "text/css"
        style.innerHTML = ""
        classes = ""
        for color, index in @colors
            style.innerHTML += ".marker#{index}.ace_start {" +
                "position: absolute;" +
                "z-index: 5;" +
                "border-left: 2px solid rgb(" +
                "#{color[0]},#{color[1]},#{color[2]});" +
                "background-color: rgba(#{color[0]}," +
                "#{color[1]},#{color[2]}, 0.5)}"

        document.getElementsByTagName("head")[0].appendChild style

    getUser: (id) ->
        for user in @users
            if user.id is id
                return user

    delete: (id) ->
        for user, index in @users
            if user.id is id
                @users.splice(id, 1)

    nameIsOccupied: (id, name) ->
        for user in @users
            continue if user.id is id
            if user.name is name
                return true
        return false

    addUser: (name, isMaster = false) ->
        id = @users.length
        tmp_name = @getFirstFreeName(id, name)

        if isMaster
            for user in @users
                return if user.isMaster

        @users.push new User( tmp_name, id, @colors[id], isMaster )

        return id

    addInitUser: (user) ->
        @users.push new User( user.name, user.id, user.color,
            user.isMaster, user.pic, user.joinedDate )

    setInactive: (id) ->
        user = @getUser id
        user.isActive = false
        @$rootScope.$apply() if !@$rootScope.$$phase

    setActive: (id) ->
        user = @getUser id
        user.isActive = true
        @$rootScope.$apply() if !@$rootScope.$$phase

    changeName: (id, newName) ->
        return if @nameIsOccupied( id, newName )
        user = @getUser id
        user.changeName newName
        @$rootScope.$apply() if !@$rootScope.$$phase

    changePic: (id, newPic) ->
        user = @getUser id
        user.changePic newPic
        @$rootScope.$apply() if !@$rootScope.$$phase

    getFirstFreeName: (id, name) ->
        occupied = @nameIsOccupied( id, name )
        counter = 0
        tmp_name = name
        while occupied
            counter++
            tmp_name = name + " (" + counter + ")"
            occupied = @nameIsOccupied( id, tmp_name )

        return tmp_name


app = angular.module "unwatched.services", []


app.factory "P2PFactory", [
    "SharesService",
    "RTCService",
    (SharesService, RTCService) ->
        # directly shared?
        # --> webcam --> audio/video
        # --> screen --> audio/video
        # --> files  --> DataChannel only

        # what happens?
        # a user requests a file from an other user,
        # so he sends a request for a p2p connection to the master
        #
        # something like
        #   type: "p2p"
        #   userId: 12
        #   fileId: 12345
        #
        # master sends this message to the resolver
        # resolver sends back an offer , master sends it to user
        # user sends back an answer to master, master sends it to resolver
        # ice exchange
        #
        # after this, both peers talk to each other via datachannel and handle the request
        # everthing should happen automaticaly, cause

    #window.getP2P = ->
        new class P2P
            @::debug          = true
            @::signaller      = null
            @::isOfferer      = true
            @::signalServer   = null
            @::connection     = null
            @::id             = null
            @::sdpConstraints =
                optional: []
                mandatory:
                    OfferToReceiveAudio: true
                    OfferToReceiveVideo: true
            @::streamOptions = [
                RtpDataChannels: true
            ]
            constructor: () ->

            setup: -> (@signaller, @requestUserId, @fileId, @isOfferer = true, @dataOnly = true) ->
                console.log "P2P setup" if @debug

                if @dataOnly
                    @streamOptions = null
                    @sdpConstraints = null


                @connection = new RTCPeerConnection(
                    iceServers:  @signaller.iceServers
                ,
                    @streamOptions
                )
                @connection.onicecandidate = @handleOwnIce

                @connection.onnegotiationneeded = @handleNegotiation
                @connection.onsignalingstatechange = @handleStateChange

                @connection.onaddstream = @onAddStream
                @connection.onremovestream = @onRemoveStream

                @connection.ondatachannel = @gotDataChannel

            signalSend: (msg) ->
                if @signalConnection.readyState is 1
                    @signalConnection.send JSON.stringify(msg)
                else
                    console.log "Signalling Channel isn't ready"
                    setTimeout =>
                        @signalSend msg
                    , 25
            handleSignalOpen: (event) ->
                console.log "Signalling Channel Opened"
            handleSignalMessage: (event) =>
                console.log "got message!", event.data if @debug
                try
                    parsedMsg = JSON.parse(event.data)

                    if !parsedMsg.type
                        throw new Error("message Type not defined")

                    switch parsedMsg.type
                        when "offer"
                            @handleOffer( parsedMsg )
                        when "answer"
                            @handleAnswer( parsedMsg )
                        when "candidate"
                            @handleIce( parsedMsg )
                        else
                            console.log "other message"
                            console.log parsedMsg
                catch e
                    console.log "wasn't able to parse message"
                    console.log e.message
            handleSignalError: (event) ->
                console.log "Signalling Channel Error"
                console.log event
            handleSignalClose: (event) ->
                console.log "Signalling Channel Closed"
            handleOwnIce: (event) =>
                console.log "handleOwnIce" if @debug
                if event.candidate
                    @signalSend
                        type: "candidate"
                        label: event.candidate.sdpMLineIndex
                        id: event.candidate.sdpMid
                        candidate: event.candidate.candidate
                        shareId: @id
                else
                    console.log "end of candidates"
            handleIce: (ice) ->
                console.log "handleIce" if @debug
                @connection.addIceCandidate new RTCIceCandidate(
                    sdpMLineIndex: ice.label
                    candidate: ice.candidate
                )
            handleOffer: (offer) =>
                console.log "handle offer" if @debug
                @connection.setRemoteDescription new RTCSessionDescription(offer)
                @createAnswer()
            createAnswer: ->
                console.log "create answer" if @debug
                @connection.createAnswer (description) =>
                    @connection.setLocalDescription description
                    description.clientId = @id
                    console.log @id if @debug
                    console.log "answer sent?" if @debug
                    @signalSend description
                , null, @sdpConstraints
            createOffer: ->
                console.log "create offer" if @debug
                @connection.createOffer (description) =>
                    @connection.setLocalDescription description
                    description.clientId = @id
                    @signalSend description
                , null, @sdpConstraints
            handleAnswer: (answer) ->
                console.log "handle answer", answer if @debug
                @connection.setRemoteDescription new RTCSessionDescription(
                    answer
                )
            handleNegotiation: ->
                console.log "handleNegotiation"
                if @isOfferer
                    createoffer()
                    try
                        @dataChannel = @connection.createDataChannel "control",
                            reliable: false
                        @dataChannel.onmessage = @DChandleMessage
                        @dataChannel.onerror   = @DChandleError
                        @dataChannel.onopen    = @DChandleOpen
                        @dataChannel.onclose   = @DChandleClose
                    catch error
                        console.log "error creating Data Channel", error.message
            handleStateChange: ->
                console.log "stateChange"
            onAddStream: ->
                console.log "stream added"
            onRemoveStream: ->
                console.log "stream removed"
            gotDataChannel: (event) =>
                console.log "RTConnection gotDataChannel"
                @dataChannel = event.channel
                @dataChannel.onmessage = @DChandleMessage
                @dataChannel.onerror   = @DChandleError
                @dataChannel.onopen    = @DChandleOpen
                @dataChannel.onclose   = @DChandleClose

            DChandleMessage: (msg) =>
                console.log "got a message from DC",
                console.log msg


                parsedMsg = JSON.parse(msg.data)
                console.log "parsed"
                console.log parsedMsg
                switch parsedMsg.type#
                    when ""
                    else
                        console.log "DChandle: unknown msg"
            DChandleError: (error) ->
                console.log "got an DC error!", error
            DChandleOpen: =>
                console.log "DC is open!"
            DChandleClose: ->
                console.log "DC is closed!"
            DCsend: (message) ->
                #messages =
                console.log "DCsend", message
                @dataChannel.send JSON.stringify(message)

]

app.service "RTCService", [
    "$rootScope"
    "UserService"
    "ChatService"
    "RoomService"
    "SharesService"
    RTCService
]

class Shares
    @::shares = []
    class Item
        @::id = 0
        @::name = ""
        @::size = 0
        @::author = ""
        @::created = undefined
        @::uploaded = undefined
        @::last_edited = undefined
        @::category = ""
        @::thumbnail = []
        @::content = ""
        @::path = ""
        @::extension = ""
        @::templateUrl = ""
        @::contributors = undefined
        @::deltas = undefined
        constructor: (@id, @name, @author, @category) ->
            @templateUrl = "/partials/items/thumbnails/" +
                category + ".html"
            @size = 0

            if @category isnt "file" and @category isnt "image"
                @created = new Date()
            else
                @uploaded = new Date()

            if @category is "code" or @category is "note"
                @contributors = []
                @contributors.push
                    id: @author
                    active: true

            @extension = ""

        setName: (@name) ->

        setSize: (@size) ->

        setThumbnail: (@thumbnail) ->

        setContent: (content) ->
            @content = content
            if @category isnt "code" and @category isnt "note"
                return
            @last_edited = new Date()

        setPath: (@path) ->

        setExtension: (@extension) ->

        setCreated: (@created) ->


    constructor: (@$rootScope) ->

    getItemIndex: (item_id) =>
        item = {}
        for i of @shares
            item = @shares[i]
            if item.id is parseInt(item_id)
                return i

    getFirstFreeId: =>
        ids = []
        freeId = 0
        for i of @shares
            ids.push @shares[i].id

        while true
            if ids.indexOf(freeId) isnt -1
                freeId++
            else
                return freeId

        return freeId

    getItems: ->
        @shares

    get: (id) ->
        @shares[ @getItemIndex(id) ]

    delete: (id) ->
        @shares.splice( @getItemIndex(id), 1 )


    create: (author, category) ->
        id = @getFirstFreeId()
        name = "Untitled " + category
        @shares.push new Item( id, name, author, category )
        return id

    updateItem: (itemId, change) ->
        item = @get(itemId)
        changeKeys = Object.keys(change)

        for changeKey of changeKeys
            item[changeKeys[changeKey]] = change[changeKeys[changeKey]]

        # @$rootScope.$apply() if !@$rootScope.$$phase

    getContributor: (itemId, contributorId) ->
        item = @get(itemId)

        for contributor in item.contributors
            if contributor.id is contributorId
                return contributor

        return false

    setContributorInactive: (itemId, contributorId) ->
        item = @get(itemId)

        for contributor in item.contributors
            if contributor.id is contributorId
                contributor.active = false

app.service "UserService", ["$rootScope", Users ]

app.service "SharesService", ["$rootScope", Shares ]

app.service "ChatService", [
    "$rootScope",
    class Messages
        @::messages = []
        class Message
            @::sent_at
            constructor: (@sender, @message) ->
                @sent_at = new Date()

        constructor: (@$rootScope) ->

        addMessage: (message, sender = @$rootScope.userId) ->
            @messages.push new Message(sender, message)
            @$rootScope.$apply() if !@$rootScope.$$phase
]

app.service "RoomService", [
    "$filter"
    "$rootScope"
    "$http"
    "SERVER_URL"
    "SERVER_PORT"
    class Room
        @::id = ""
        @::name
        @::created
        @::usersLength
        @::filesLength
        @::description
        @::url = ""
        @::isClosed = false

        constructor: (@$filter, @$rootScope, @$http, @SERVER_URL,
            @SERVER_PORT) ->
            @created = @$filter("date")(new Date(), "dd.MM.yyyy H:mm")
            @description = "Room description"
            isClose = false

        setName: (name) ->
            @name = name

        setUrl: (longUrl) ->
            apiUrl = "https://www.googleapis.com/urlshortener/v1/url?"
            url = @SERVER_URL + ":" + @SERVER_PORT + longUrl

            @$http.post( apiUrl, longUrl: url ).success (data) =>
                @url = data.id
]


app.service "ChatStateService", ->

    @chat_state = "minimized"
    @chat_state_history = "compressed"

    @setChatState = (chat_state) ->
        @chat_state = chat_state

    @setChatStateHistory = (chat_state_history) ->
        @chat_state_history = chat_state_history

    return

app.service "LayoutService", ->

    @layout = "layout-icons"

    @setLayout = (layout) ->
        @layout = layout

    return

app.service "AceSettingsService", [
    "font_sizes", "ace_themes"
    (font_sizes, ace_themes) ->

        @font_size = font_sizes[1]
        @theme = ace_themes[0]

        @setFontSize = (font_size) ->
            @font_size = font_size

        @setTheme = (theme) ->
            @theme = theme


        return
]

app.service "StreamService", [
    "$rootScope", "SharesService"
    ($rootScope, SharesService) ->

        @screenStream = undefined
        @screenVideo = undefined
        @screen_item_id = undefined
        @webcamStream = undefined
        @webcamVideo = undefined
        @webcam_item_id = undefined

        @setScreenStream = (stream) ->
            @screenStream = stream
            @screenStream.onended = @killScreenStream

        @setWebcamStream = (stream) ->
            @webcamStream = stream
            @webcamStream.onended = @killWebcamStream

        @setScreenVideo = (video) ->
            @screenVideo = video

        @setWebcamVideo = (video) ->
            @webcamVideo = video

        @setScreenItemId = (item_id) ->
            @screen_item_id = item_id

        @setWebcamItemId = (item_id) ->
            @webcam_item_id = item_id

        @startScreenVideo = ->
            @screenVideo.src = window.URL.createObjectURL @screenStream
            @screenVideo.play()
            $rootScope.video.show.screen = true
            $rootScope.$apply()

        @startWebcamVideo = ->
            @webcamVideo.src = window.URL.createObjectURL @webcamStream
            @webcamVideo.play()
            $rootScope.video.show.webcam = true
            $rootScope.$apply()

        @killScreenStream = =>
            $rootScope.video.show.screen = false
            window.setTimeout((=>
                @screenVideo.pause()
                @screenVideo.src = null
                if @screenStream?
                    @screenStream.stop()
                    @screenStream = undefined
                    SharesService.delete(@screen_item_id)

                $rootScope.$apply()  if !$rootScope.$$phase
            ), 500)

        @killWebcamStream = =>
            $rootScope.video.show.webcam = false
            window.setTimeout((=>
                @webcamVideo.pause()
                @webcamVideo.src = null
                if @webcamStream?
                    @webcamStream.stop()
                    @webcamStream = undefined
                    SharesService.delete(@webcam_item_id)

                $rootScope.$apply()  if !$rootScope.$$phase
            ), 500)

        return

]

app.constant "available_extensions", [
    { value: "", name: "Choose language", extension: "" }
    { value: "html", name: "HTML", extension: "html" }
    { value: "css", name: "CSS", extension: "css" }
    { value: "js", name: "JavaScript", extension: "js" }
    { value: "java", name: "Java", extension: "java" }
    { value: "rb", name: "Ruby", extension: "rb" }
    { value: "py", name: "Python", extension: "py" }
]

app.constant "font_sizes", [
    { value: 12, name: "12px"}
    { value: 14, name: "14px"}
    { value: 16, name: "16px"}
    { value: 18, name: "18px"}
    { value: 20, name: "20px"}
]

app.constant "ace_themes", [
    { value: "monokai", name: "Monokai"}
    { value: "github", name: "Github"}
    { value: "ambiance", name: "Ambiance"}
    { value: "mono_industrial", name: "Mono Industrial"}
    { value: "terminal", name: "Terminal"}
]

app.constant "SERVER_URL", "https://localhost"
app.constant "SERVER_PORT", "3001"
