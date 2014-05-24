# Unwatched - Angular Services
# ============================

"use strict"

class Client
    name: null
    eMail: null
    id: null
    connections: []
    constructor: (@name, @email) ->
    get: ->

class Signaler 
    @channel = null
    constructor: (@channel) ->
    createNew: (type) ->
        type: "new"
        newType: "share"
        id: ""


class RTConnection
    @id = null
    @isInitiator = false
    @isStarted = false
    @pcConfig =
        iceServers: [
            url: "stun:stun.l.google.com:19302"
        ]
    @pcConstraints = 
        optional: [
            { DtlsSrtpKeyAgreement: true }
            { RtpDataChannels: true }
        ]
    @sdpConstraints = 
        mandatory:
            OfferToReceiveAudio: true
            OfferToReceiveVideo: true
    @dataChannelOptions = 
        ordered: false
        maxRetransmitTime: 3000
        #maxRetransmits: 
        #protocol:
        #negotiated:
        #id:
    @peerConnection = null
    @dataChannel = null
    @signalChannel = null
    constructor: (@signalChannel, @id = null, @type = "share") -> 
        console.log "id: "+@id
        console.log "type: "+@type
        @signalChannel.onmessage = @handleSignalChannelMessage
        if !@id 
            console.log "id is undefined"
            @delayedSignalChannelSend()
        console.log "RTConnection constructor"
    delayedSignalChannelSend: =>
        console.log "deeelaayyyyeeed"
        console.log @signalChannel
        if @signalChannel.readyState is 1

            @signalChannel.send JSON.stringify( 
                type: "new"
                newType: "share"
            )
        else
            setTimeout @delayedSignalChannelSend, 100
    startConnection: ->
        console.log "RTConnection startConnection"
        try 
            @peerConnection = new window.RTCPeerConnection(@pcConfig, @pcConstraints)
            @peerConnection.onicecandidate = @handleIceCandidate
        catch error
            console.log "error creating peerConnection"
            console.log error.message

        @peerConnection.onaddstream = @remoteStreamAdded
        @peerConnection.onremovestream = @remoteStreamRemoved
        
        if @isInitiator
            @addDataChannel
        else
            @peerConnection.ondatachannel = @gotDataChannel

        @isStarted = true
        return
    addDataChannel: ->
        console.log "RTConnection addDataChannel"
        try
            @dataChannel = @peerConnection.createDataChannel("testLabel", @dataChannelOptions)
            @dataChannel.onmessage = @DChandleMessage
            @dataChannel.onerror   = @DChandleError
            @dataChannel.onopen    = @DChandleOpen
            @dataChannel.onclose   = @DChandleClose
        catch error
            console.log "error creating Data Channel"
            console.log error.message
    gotDataChannel: (event) ->
        console.log "RTConnection gotDataChannel"
        @dataChannel = event.channel
        @dataChannel.onmessage = @handleMessage
        @dataChannel.onerror   = @handleError
        @dataChannel.onopen    = @handleOpen
        @dataChannel.onclose   = @handleClose
    DChandleMessage: (msg)->
        console.log "DataChannel message"
        console.log JSON.parse(msg)
    DCHandleError: (error)->
        console.log "DataChannel Error"
        console.log error
    DChandleOpen: ->
        console.log "DataChannel opened"
    DChandleClose: ->
        console.log "DataChannel closed"
    handleIceCandidate: (event) ->
        console.log "RTConnection handleIceCandidate"
        if event.candidate
            @signalChannel.send
                type: "candidate"
                label: event.candidate.sdpMLineIndex
                id: event.candidate.sdpMid
                candidate: event.candidate.candidate
        else
            console.log "end of candidates"
    doOffer: ->
        console.log "RTConnection startCall"
        @peerConnection.createOffer @setLocalSdpSend, null, @sdpConstraints
    doAnswer: ->
        console.log "RTConnection doAnswer"
        @peerConnection.createAnswer setLocalAndSendMessage, null, @sdpConstraints
    setLocalSdpSendBack: (sessionDescription)->
        console.log "RTConnection setLocalSdpSendBack"
        @peerConnection.setLocalDescription sessionDescription
        @signalChannel.send sessionDescription
    handleSignalChannelMessage: (message)->
        console.log "RTConnection handleSignalChannelMessage"
        console.log "Received message:", message
        
        if message.type is "offer"
            @startConnection() if not @isInitiator and not @isStarted
            @peerConnection.setRemoteDescription new RTCSessionDescription(message)
            @doAnswer()
        else if message.type is "answer" and @isStarted
            @peerConnection.setRemoteDescription new RTCSessionDescription(message)
        else if message.type is "candidate" and @isStarted
            candidate = new RTCIceCandidate(
                sdpMLineIndex: message.label
                candidate: message.candidate
            )
            @peerConnection.addIceCandidate candidate
        #else handleRemoteHangup()  if message is "bye" and @isStarted
        else 
            console.log "got unknown msg"
            console.log message

window.RTConnection = RTConnection
#(new WebSocket("wss://localhost:3001"))

class RTCProvider
    @::isMaster   = true
    @::name       = ""
    @::clients    = []
    @::moderators = []
    @::signalServer = "wss://localhost:3001" 
    
    @::wss          = null
    @::room         = null
    # exposed to .config
    constructor: ->

    setSignalServer: (@signalServer)->
        console.log "set Signal Server: "+signalServer
        console.log "RTCPeerConnection:"
        console.log window.RTCPeerConnection
        console.log "getUserMedia:" 
        console.log window.getUserMedia
        console.log "attachMediaStraem:" 
        console.log window.attachMediaStream
        console.log "reattachMediaStream" 
        console.log window.reattachMediaStream
        console.log "webrtcDetectedBrowser" 
        console.log window.webrtcDetectedBrowser
        console.log "webrtcDetectedVersion" 
        console.log window.webrtcDetectedVersion
        console.log "isWebrtcAble" 
        console.log window.isWebrtcAble
        return
    connect: ->
        wss = new WebSocket @signalServer
        wss.onopen = ->
            console.log "wss open"
        
        wss.onerror = (error) ->
            console.log "wss error"
            console.log error
        wss.onmessage = (msg) ->
            console.log "wss msg received"
            console.log JSON.parse(msg)

        wss.onclose = ->
        
    newRoom: (name) ->
    newShare: (type) ->

    connectToRoom: ->

    connectToShare: ->
    
    setName: (@name) ->
        console.log "inner set Name: " + name
    addClients: (name, eMail) ->
        console.log "+++ addClients"
        console.log @clients
        console.log @name
        @clients.push new Client(name, eMail)
        console.log "--- addClients"
    getClients: ->
        console.log "+++ getClients"
        console.log @clients
        console.log "--- getClients"
    # exposed to everyone
    $get: ->
        logName: ->
            console.log "+++ logName"
            console.log "Hello " + @name
            console.log "--- logName"
        createHash: ->
            return "HAAASh"
        setName: (@name) ->
            console.log "set name to: " + name
        addClient: (name, eMail) =>
            console.log "+++ addClient"
            @addClients name, eMail
            console.log "--- addClient"
        listClients: ->
            console.log "+++ listClients"
            console.log @
            console.log @name
            console.log @clients
            console.log "--- listClients"
            #@getClients()
            #console.log @asdf
            #console.log "bluuuuuu"
            #console.log @clients


app = angular.module "unwatched.services", []

app.provider "RTC", RTCProvider

app.value "version", "0.1"

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
    "item_template_code", "dummy_authors", "$filter", "dummy_code_names"
    (item_template_code, dummy_authors, $filter, dummy_code_names) ->

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


        @create = ->
            item = item_template_code
            item.id = getFirstFreeId()

            name_id = Math.floor(Math.random() * dummy_code_names.length)
            item.name = dummy_code_names[name_id]

            author_id = Math.floor(Math.random() * dummy_authors.length)
            item.author = dummy_authors[author_id]

            item.created = $filter("date")(new Date(), "dd.MM.yyyy hh:mm")

            @items.push item

            return item

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

app.constant "dummy_code_names", [
    "main"
    "script"
    "style"
    "index"
    "spec"
    "template"
    "code"
]

app.constant "item_template_code", {
    id: 0
    name: ""
    size: Math.floor((Math.random()*1024*1024)+400)
    author: ""
    created: ""
    category: "code"
    thumbnail: ""
    content: ""
    path: ""
    extension: ""
    templateUrl: "/partials/items/thumbnails/code.html"
}
