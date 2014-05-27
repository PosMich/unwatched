# Unwatched - Angular Services
# ============================

"use strict"
class RTCService
    @::listeners = []
    class Master
        @::signalServer     = "wss://localhost:3001"
        @::roomId           = null
        @::signallingClients = []
        @::listeners = []
        class SlaveRTC
            @::id = null
            @::connection = null
            @::signaller = null
            @::debug = false
            constructor: (@signaller, @id) ->
                @connection = new RTCPeerConnection(
                    iceServers: [
                        url: "stun:stun.l.google.com:19302"
                    ]
                ,
                    optional: [
                            DtlsSrtpKeyAgreement: true
                        ,
                            RtpDataChannels: true
                    ]
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
                    console.log "error creating Data Channel"
                    console.log error.message

                #@createOffer()
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
            handleAnswer: (answer) -> # recieved from client
                console.log "handle answer" if @debug
                console.log answer if @debug
                @connection.setRemoteDescription new RTCSessionDescription(
                    answer
                )
            handleIce: (ice) ->
                console.log "handleIce" if @debug
                @connection.addIceCandidate new RTCIceCandidate(
                    sdpMLineIndex: ice.label
                    candidate: ice.candidate
                )
            handleNegotiation: =>
                console.log "handleNegotiation" if @debug
                @createOffer()
            handleStateChange: ->
                console.log "handle state change" if @debug
            onAddStream: ->
                console.log "onAddStream" if @debug
            onRemoveStream: ->
                console.log "onRemoveStream" if @debug
            DChandleMessage: (msg) =>
                console.log "got a message from DC" if @debug
                console.log msg if @debug
                parsedMsg = JSON.parse(msg.data)

                switch parsedMsg.type
                    when "broadcast"
                        @handleBroadcastMessage( parsedMsg.message )
                    else
                        console.log "DChandle: unknown msg"

            DChandleError: (error) ->
                console.log "got an DC error!" if @debug
                console.log error if @debug
            DChandleOpen: ->
                console.log "DC is open!" if @debug
            DChandleClose: ->
                console.log "DC is closed!" if @debug
            DCsend: (message) ->
                @dataChannel.send JSON.stringify(message)
            sendBroadcastMessage: (message) ->
                @DCsend
                    type: "broadcast"
                    message: message
            handleBroadcastMessage: (message) ->
                @signaller.handleBroadcastMessage message, @id

        constructor: ->
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
            console.log "got message!" if @debug
            try
                parsedMsg = JSON.parse(event.data)

                if !parsedMsg.type
                    throw new Error("message Type not defined")

            catch e
                console.log "wasn't able to parse message"
                console.log e.message
                console.log event
                console.log event.data

            switch parsedMsg.type
                when "id" # room creation successful
                    console.log "got id: " + parsedMsg.roomId if @debug
                    @roomId = parsedMsg.roomId
                    console.log "created room: " + parsedMsg.roomId

                    @sendBroadcastMessage
                        type: 'room'
                        message: parsedMsg.roomId

                when "connect"  # new client
                    console.log "client want's to connect"  if @debug
                    @signallingClients.push new SlaveRTC(@, parsedMsg.clientId)

                when "answer"
                    for slave in @signallingClients
                        if slave.id is parsedMsg.clientId
                            slave.handleAnswer parsedMsg
                            console.log "answer" if @debug
                            return
                when "candidate"
                    for slave in @signallingClients
                        if slave.id is parsedMsg.clientId
                            slave.handleIce parsedMsg
                            console.log "candidate for client" if @debug
                            break
                else
                    console.log "other message"
                    console.log parsedMsg
        handleSignalError: (event) ->
            console.log "Signalling Channel Error"
            console.log event
        handleSignalClose: (event) ->
            console.log "Signalling Channel Closed"
        sendBroadcastMessage: (message) ->
            console.log "send broadcast message"
            console.log message
            for client in @signallingClients
                message.clientId = @roomId
                client.sendBroadcastMessage( message )
            for listener in @listeners
                if listener.type is message.type
                    message.clientId = @roomId
                    listener.onMessage message
        handleBroadcastMessage: (message, sender) ->
            # send to all, except sender!
            if @debug
                console.log "handle message"
                console.log message
                console.log "from sender: " + sender
            for client in @signallingClients
                continue if client.id is sender
                message.clientId = sender
                if @debug
                    console.log "should send"
                    console.log message
                client.sendBroadcastMessage( message )
            # send to listener
            for listener in @listeners
                if listener.type is message.type
                    message.clientId = @roomId
                    listener.onMessage message


    # only 1 pc to the server
    class Slave
        @::signalServer = "wss://localhost:3001"
        @::roomId       = null
        @::id           = null
        @::connection   = null
        @::listeners    = []
        @::debug        = false
        constructor: (@roomId) ->
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
                optional: [
                        DtlsSrtpKeyAgreement: true
                    ,
                        RtpDataChannels: true
                ]
            )
            @connection.onicecandidate = @handleOwnIce

            @connection.onnegotiationneeded = @handleNegotiation
            @connection.onsignalingstatechange = @handleStateChange

            @connection.onaddstream = @onAddStream
            @connection.onremovestream = @onRemoveStream

            @connection.ondatachannel = @gotDataChannel

            @signalSend
                type: "connect"
                roomId: @roomId

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
            if @debug
                console.log "got a message from DC"
                console.log msg
            parsedMsg = JSON.parse(msg.data)
            switch parsedMsg.type
                when "broadcast"
                    @handleBroadcastMessage( parsedMsg.message )
                else
                    console.log "DChandle: unknown msg"
        DChandleError: (error) ->
            console.log "got an DC error!"
            console.log error
        DChandleOpen: ->
            console.log "DC is open!"
        DChandleClose: ->
            console.log "DC is closed!"
        handleBroadcastMessage: (message) ->
            for listener in @listeners
                if listener.type is message.type
                    console.log "listener found"
                    listener.onMessage message
        sendBroadcastMessage: (message) ->
            @DCsend
                type: "broadcast"
                message: message
            for listener in @listeners
                if listener.type is message.type
                    listener.onMessage message
        DCsend: (message) ->
            @dataChannel.send JSON.stringify(message)

    constructor: ->

    setup: (@roomId) ->
        console.log "setup done"

        if !@roomId
            @handler = new Master()
            @handler.listeners = @listeners
        else
            @handler = new Slave(@roomId)
            @handler.listeners = @listeners
        #@handler.onChatMessage = @onChatMessage

    # type: "blubb", onMessage: function
    registerBroadcastListener: (listener) ->
        console.log "register new broadcast listener"
        if @handler
            @handler.listeners.push listener
        else
            @listeners.push listener
    sendBroadcastMessage: (message) ->
        console.log "send broadcast"
        console.log message
        @handler.sendBroadcastMessage message

###
window.Master = Master
window.Slave = Slave
###
#console.log RTCProvider

window.rtcService = RTCService


app = angular.module "unwatched.services", []


app.value "version", "0.1"

app.service "UserService", class Users
    constructor: ->


app.service "RTCService", RTCService

app.service "SharesService", class Shares
    @::shares = []
    class Item
        id: 0
        name: ""
        size: 0
        author: ""
        created: ""
        category: ""
        thumbnail: ""
        content: ""
        path: ""
        extension: ""
        templateUrl: ""


app.service "UserService", class Users
    @::users = []
    class User
        @signallingId
        @name
        @email
        @profilePic

    constructor: ->



app.service "ChatService", [
    "RTCService",
    "$rootScope",
    class Messages
        @::messages = []
        class Message
            constructor: (@sender, @message) ->

        constructor: (@RTCService, @$rootScope) ->
            console.log @RTCService
            @RTCService.registerBroadcastListener
                type: "chat"
                onMessage: @onMessage

        onMessage: (message) =>
            console.log "ChatService: got message"
            console.log message
            @messages.push new Message(message.clientId, message.message)
            @$rootScope.$apply()


        sendMessage: (message) ->
            #@messages.push new Message("me", message)
            @RTCService.sendBroadcastMessage
                type: "chat"
                message: message
]

app.service "RoomService", [
    "RTCService",
    "$filter",
    class Room
        @id
        @name
        @created

        constructor: (@RTCService, @$filter, @id, @name) ->
            @created = @$filter("date")(new Date(), "dd.MM.yyyy H:mm")

            @RTCService.registerBroadcastListener
                type: "room"
                onMessage: @onMessage

        onMessage: (message) =>
            console.log "RoomService: got message"
            console.log message

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

        @font_size = font_sizes[0]
        @theme = ace_themes[0]

        @setFontSize = (font_size) ->
            @font_size = font_size

        @setTheme = (theme) ->
            @theme = theme


        return
]

app.service "SharedItemsService", [
    "item_template", "dummy_authors", "$filter"
    (item_template, dummy_authors, $filter) ->

        @items = []

        getItemIndex = (id) =>
            item = {}
            for i of @items
                item = @items[i]
                if item.id is parseInt(id)
                    return i

        getFirstFreeId = =>
            ids = []
            freeId = 0
            for i of @items
                ids.push @items[i].id

            while true
                if ids.indexOf(freeId) isnt -1
                    freeId++
                else
                    return freeId

        @initItems = (items_arr) ->
            @items = items_arr

        @getItems = ->
            @items

        @get = (id) ->
            @items[ getItemIndex(id) ]

        @delete = (id) ->
            @items.splice( getItemIndex(id), 1 )


        @create = (category) ->
            item = {}
            angular.copy item_template, item
            # item = new
            item.id = getFirstFreeId()

            item.name = "Untitled " + category + " item"

            author_id = Math.floor(Math.random() * dummy_authors.length)
            item.author = dummy_authors[author_id]

            item.created = $filter("date")(new Date(), "dd.MM.yyyy H:mm")
            item.category = category
            item.templateUrl = "/partials/items/thumbnails/" +
                category + ".html"

            @items.push item


            return item

        return

]

app.service "StreamService", [
    "$rootScope", "SharedItemsService"
    ($rootScope, SharedItemsService) ->

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
                    SharedItemsService.delete(@screen_item_id)

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
                    SharedItemsService.delete(@webcam_item_id)

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

app.constant "dummy_authors", [
    "Antoinette Dean"
    "Rex Vargas"
    "Pearl Carr"
    "Clark Miller"
    "Clinton Richardson"
    "Donna Norman"
    "Laurie Bowen"
    "Kristi Saunders"
    "Amanda Swanson"
    "Brandy Glover"
]

app.constant "item_template", {
    id: 0
    name: ""
    size: 0
    author: ""
    created: ""
    category: ""
    thumbnail: ""
    content: ""
    path: ""
    extension: ""
    templateUrl: ""
}
