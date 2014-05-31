# Unwatched - Angular Services
# ============================

"use strict"
class RTCService

    @::ChunkFiles  = []
    @::isMaster = false

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

    createChunks: (msg) ->
        console.log "createChunks", msg
        chunks = []


        #   {
        #       "type":"chunk",
        #       "id":1073741824,
        #       "chunkId":1073741824,
        #       "length":1073741824,
        #       "data":""
        #   }
        # -> without data: 83 chars
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


        sendMessages = []
        i = 0
        while i < chunks.length
            sendMessages.push
                type: "chunk"
                id: 0
                chunkId: i
                length: chunks.length
                data: chunks[i]
            ++i

        console.log "sendMessages", sendMessages
        sendMessages

    receiveChunk: (chunk, id) ->
        currentChunkFile = false
        for chunkFile in @ChunkFiles
            if chunkFile.id is chunk.id
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
                        if client.id is id
                            client.DChandleMessage
                                data: alltogether
                else
                    @handler.DChandleMessage
                        data: alltogether

                #complete, put together, reset ChunkFiles storage
                @ChunkFiles = []
        else
            console.log "push chunk file"
            @ChunkFiles.push
                id: chunk.id
                chunks: [chunk.data]

            # add to Chunkfiles


    class Master
        @::signalServer      = "wss://localhost:3001"
        @::roomId            = null
        @::signallingClients = []
        @::password          = null
        @::id                = 0
        @::sdpConstraints =
            optional: []
            mandatory:
                OfferToReceiveAudio: false
                OfferToReceiveVideo: false


        # this is a slaves upstream to the master
        class SlaveRTC
            @::id         = null
            @::connection = null
            @::signaller  = null
            @::dataChannel = null
            @::debug      = true
            @::loginAttempts = 3

            constructor: (@signaller, @id) ->
                @connection = new RTCPeerConnection(
                    iceServers: [
                        url: "stun:stun.l.google.com:19302"
                    ]
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
                                    room:
                                        id: @signaller.roomId
                                        name: room.name
                                        created:
                                            room.created
                                        description:
                                            room.description
                                        url:
                                            room.url

                            messages = @signaller.service.createChunks(initData)

                            for message in messages
                                @DCsend message

                    when "userNameHasChanged"
                        @signaller.service.UserService.changeName(
                            parsedMsg.message.userId, parsedMsg.message.userName
                        )

                        for client in @signaller.signallingClients
                            if client.id isnt parsedMsg.message.userId
                                client.DCsend
                                    type: "userNameHasChanged"
                                    message: parsedMsg.message

                    when "userPicHasChanged"
                        @signaller.service.UserService.changePic(
                            parsedMsg.message.userId, parsedMsg.message.userPic
                        )

                        message =
                            type: "userPicHasChanged"
                            message: parsedMsg.message

                        messages = @signaller.service.createChunks(message)

                        for client in @signaller.signallingClients
                            for msg in messages
                                if client.id isnt parsedMsg.message.userId
                                    client.DCsend msg



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
                console.log "DCsend" + JSON.stringify(message)
                console.log message
                @dataChannel.send JSON.stringify(message)
                console.log "sent?"

        constructor: (@service) ->
            console.log "setup" if @debug
            @signalConnection = new WebSocket(@signalServer)
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
            @signalConnection = new WebSocket(@signalServer)
            @signalConnection.onopen    = @handleSignalOpen
            @signalConnection.onmessage = @handleSignalMessage
            @signalConnection.onerror   = @handleSignalError
            @signalConnection.onclose   = @handleSignalClose

            @connection = new RTCPeerConnection(
                iceServers: [
                    url: "stun:stun.l.google.com:19302"
                ]
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
            # console.log "DCsend", message
            @dataChannel.send JSON.stringify(message)


    constructor: (@$rootScope, @UserService, @ChatService, @RoomService) ->

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
        dataChannelMessage =
            type: type
            message: message

        if type is "userNameHasChanged"
            @handler.DCsend dataChannelMessage

        else if type is "userPicHasChanged"
            messages = @createChunks(dataChannelMessage)

            for msg in messages
                @handler.DCsend msg

    broadcastUserChanges: (type, message) ->
        broadcastMessage =
            type: type
            message: message

        if type is "userNameHasChanged"
            for client in @handler.signallingClients
                client.DCsend broadcastMessage

        else if type is "userPicHasChanged"
            messages = @createChunks(broadcastMessage)

            for client in @handler.signallingClients
                for msg in messages
                    client.DCsend msg

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

    getUser: (id) ->
        for user in @users
            console.log user
            if user.id is id
                return user

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

    onMessage: (message) =>
        console.log "UserService :: received message"
        console.log message
        user_data = message.message
        @users.push new User( user_data.name, user_data.id, user_data.color,
            user_data.isMaster )

        @$rootScope.$apply() if !@$rootScope.$$phase

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

app.service "RTCService", [
    "$rootScope"
    "UserService"
    "ChatService"
    "RoomService"
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
        @::content = []
        @::path = ""
        @::extension = ""
        @::templateUrl = ""
        constructor: (@id, @name, @author, @category) ->
            @templateUrl = "/partials/items/thumbnails/" +
                category + ".html"

            if @category isnt "file" and @category isnt "image"
                @created = new Date()
            else
                @uploaded = new Date()

            @extension = ""

        setName: (@name) ->

        setSize: (@size) ->

        setThumbnail: (@thumbnail) ->

        setContent: (content) ->
            @content = content
            if @category isnt "code" and @category isnt "note"
                return

            @last_edited = new Date()

            # keep thumb up-to-date
            @updateThumbnail()

        setPath: (@path) ->

        setExtension: (@extension) ->

        setCreated: (@created) ->

        insertContentAt: (start, end, content_to_insert) ->
            if start.row != end.row
                # new line
                @insertRow end.row
            else
                if end.row >= @content.length
                    @insertRow end.row

                @content[start.row] = [
                    @content[start.row].slice(0, start.column)
                    content_to_insert
                    @content[start.row].slice(end.column)
                ].join ""

            @last_edited = new Date()
            if start.row < 5 or end.row < 5
                @updateThumbnail()

        deleteContentAtRow: (start_row, end_row, start_col, end_col) ->
            if start_row isnt end_row
                if end_row isnt @content.length
                    # shift content from end_row at the end of the start_row
                    @content[start_row] += @content[end_row]
                @deleteRows end_row, 1
            else
                tmp_content = @content[start_row].slice(0, start_col)
                tmp_content += @content[start_row].slice(
                    end_col, @content[start_row].length)
                @content[start_row] = tmp_content

            @last_edited = new Date()
            if start_row < 5 or end_row < 5
                @updateThumbnail()

        deleteRows: (row, amount) ->
            @content.splice row, amount
            if @content.length is 0
                @content[0] = ""

        insertRow: (position) ->
            @content.splice position, 0, ""

        insertRows: (rows, position) ->
            i = position
            for row in rows
                @insertRow i
                @content[i] = row
                i++

        updateThumbnail: ->
            thumbnail = ""
            i = 0
            max = 5
            max = @content.length if @content.length < max
            while i < max
                thumbnail += @content[i] + "\n"
                i++

            @setThumbnail thumbnail

        getContent: ->
            content = ""
            if @category is "code"
                for row of @content
                    content += @content[row] + "\n"

            else if @category is "note"
                for row of @content
                    content += @content[row]

            return content


    constructor: (@rootScope) ->

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
        name = "Untitled " + category + " item"
        @shares.push new Item( id, name, author, category )
        return id




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

        constructor: (@$filter, @$rootScope, @$http, @SERVER_URL,
            @SERVER_PORT) ->
            @created = @$filter("date")(new Date(), "dd.MM.yyyy H:mm")
            @description = "Room description"

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
