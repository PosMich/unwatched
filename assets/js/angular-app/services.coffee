# Unwatched - Angular Services
# ============================

"use strict"
class RTCService
    @::roomId = null
    
    class Master
        @::signalServer     = "wss://localhost:3001" 
        @::roomId           = null
        @::signallingClients = []
        class SlaveRTC
            @::id = null
            @connection = null
            @signaller
            constructor: (@signaller, @id)->
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
                
                @connection.onconnecting = @onConnecting
                @connection.onopen = -> 
                    console.log "aodsifhrüjgöowaijgraoiwhjü9gr8j" 
                #@onOpen

                @connection.onaddstream = @onAddStream
                @connection.onremovestream = @onRemoveStream


                try
                    @dataChannel = @connection.createDataChannel("control",  reliable: false)
                    @dataChannel.onmessage = @DChandleMessage
                    @dataChannel.onerror   = @DChandleError
                    @dataChannel.onopen    = @DChandleOpen
                    @dataChannel.onclose   = @DChandleClose
                catch error
                    console.log "error creating Data Channel"
                    console.log error.message

                @createOffer()
            handleOwnIce: (event) =>
                console.log "handleOwnIce"
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
                console.log "create offer"
                @connection.createOffer (description) =>
                    @connection.setLocalDescription description
                    description.clientId = @id
                    @signaller.signalSend description
            handleAnswer: (answer)-> # recieved from client
                console.log "handle answer"
                console.log answer
                @connection.setRemoteDescription new RTCSessionDescription(answer)
            handleIce: (ice) ->
                console.log "handleIce"
                @connection.addIceCandidate new RTCIceCandidate(
                    sdpMLineIndex: ice.label
                    candidate: ice.candidate
                )
            onConnecting: =>
                console.log "connecting"
            onOpen: =>
                console.log "open"
                try
                    @dataChannel = @peerConnection.createDataChannel("control",  reliable: false)
                    @dataChannel.onmessage = @DChandleMessage
                    @dataChannel.onerror   = @DChandleError
                    @dataChannel.onopen    = @DChandleOpen
                    @dataChannel.onclose   = @DChandleClose
                catch error
                    console.log "error creating Data Channel"
                    console.log error.message
            onAddStream: =>
                console.log "onAddStream"
            onRemoveStream: =>
                console.log "onRemoveStream"
            DChandleMessage: (msg) =>
                console.log "got a message from DC"
                console.log msg
            DChandleError: (error)=>
                console.log "got an DC error!"
                console.log error
            DChandleOpen: =>
                console.log "DC is open!"
            DChandleClose: =>
                console.log "DC is closed!"
        constructor: ->
            console.log "setup"
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
        handleSignalOpen: (event) =>
            console.log "Signalling Channel Opened"
        handleSignalMessage: (event) =>
            console.log "got message!"
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
                    console.log "got id: "+parsedMsg.roomId
                    @roomId = parsedMsg.roomId
                    console.log "created room"
                when "connect"  # new client
                    console.log "client want's to connect"
                    # create new peerconnection
                    #@peerConnections.push new RTConnection(@, parsedMsg.clientId, @isMaster)
                    @signallingClients.push new SlaveRTC(@, parsedMsg.clientId)

                when "answer"
                    for slave in @signallingClients
                        if slave.id is parsedMsg.clientId
                            slave.handleAnswer parsedMsg
                            console.log "answer"
                            return
                when "candidate"
                    for slave in @signallingClients
                        if slave.id is parsedMsg.clientId
                            slave.handleIce parsedMsg
                            console.log "candidate for client"
                            break
                else
                    console.log "other message"
                    console.log parsedMsg
        handleSignalError: (event) =>
            console.log "Signalling Channel Error"
            console.log event
        handleSignalClose: (event) =>
            console.log "Signalling Channel Closed"

    # only 1 pc to the server
    class Slave
        @::signalServer = "wss://localhost:3001" 
        @::roomId       = null
        @::id           = null
        @::connection   = null
        constructor: (@roomId)->
            console.log "setup"
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
            
            @connection.onconnecting = @onConnecting
            @connection.onopen = @onOpen

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
        handleSignalOpen: (event) =>
            console.log "Signalling Channel Opened"
        handleSignalMessage: (event) =>
            console.log "got message!"
            try 
                parsedMsg = JSON.parse(event.data)

                if !parsedMsg.type
                    throw new Error("message Type not defined")

                switch parsedMsg.type
                    when "id" # room creation successful
                        console.log "got id: "+parsedMsg.clientId
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
        handleSignalError: (event) =>
            console.log "Signalling Channel Error"
            console.log event
        handleSignalClose: (event) =>
            console.log "Signalling Channel Closed"
        handleOwnIce: (event) =>
            console.log "handleOwnIce"
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
            console.log "handleIce"
            @connection.addIceCandidate new RTCIceCandidate(
                sdpMLineIndex: ice.label
                candidate: ice.candidate
            )
        handleOffer: (offer) =>
            console.log "handle offer"
            @connection.setRemoteDescription new RTCSessionDescription(offer)
            @createAnswer()
        createAnswer: -> 
            console.log "create answer"
            @connection.createAnswer (description) =>
                @connection.setLocalDescription description
                description.clientId = @id
                console.log @id
                console.log "answer sent?"
                @signalSend description
        onConnecting: =>
            console.log "connecting"
        onOpen: =>
            console.log "opened"
        onAddStream: =>
            console.log "stream added"
        onRemoveStream: =>
            console.log "stream removed"
        gotDataChannel: (event) =>
            console.log "RTConnection gotDataChannel"
            @dataChannel = event.channel
            @dataChannel.onmessage = @DChandleMessage
            @dataChannel.onerror   = @DChandleError
            @dataChannel.onopen    = @DChandleOpen
            @dataChannel.onclose   = @DChandleClose

        DChandleMessage: (msg) =>
            console.log "got a message from DC"
            console.log msg
        DChandleError: (error)=>
            console.log "got an DC error!"
            console.log error
        DChandleOpen: =>
            console.log "DC is open!"
        DChandleClose: =>
            console.log "DC is closed!"
    constructor: (@ChatService) ->
    @setRoomId: (@roomId)->
    @setup: ->
        console.log "setup done"
        if @roomId is null
            @handler = new Master()
        else
            @handler = new Slave(@roomId)

###
window.Master = Master
window.Slave = Slave
###
#console.log RTCProvider



app = angular.module "unwatched.services", []


app.value "version", "0.1"


app.service "ChatService", ->
    class Message
        constructor: (@sender, @message) ->

    @messages = []

    @addMessage = (sender, message) ->
        @messages.push new Message(sender, message)

    return


app.service "RTC", ["ChatService", RTCService]


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
            item.templateUrl = "/partials/items/thumbnails/" + category + ".html"

            @items.push item


            return item

        return
        
]

app.service "StreamService", [
    "$rootScope", "SharedItemsService"
    ($rootScope, SharedItemsService) ->

        @stream = undefined
        @video = undefined
        @item_id = undefined

        @setStream = (stream) ->
            @stream = stream
            window.stream = @stream

            @stream.onended = @killStream

        @setVideo = (video) ->
            @video = video

        @setItemId = (item_id) ->
            @item_id = item_id

        @startVideo = ->
            @video.src = window.URL.createObjectURL @stream
            @video.play()
            $rootScope.showVideo = true
            $rootScope.$apply()

        @killStream = =>
            $rootScope.showVideo = false
            window.setTimeout((=>
                @video.pause()
                @video.src = null
                if @stream?
                    @stream.stop()
                    @stream = undefined
                    SharedItemsService.delete(@item_id)
                    
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
