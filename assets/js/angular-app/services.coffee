# Unwatched - Angular Services
# ============================

"use strict"


# class RTCProvider
#     @::isMaster      = true
#     @::signalServer  = "wss://localhost:3001" 
#     @::roomId        = null
#     @::peerConnections = []
#     @::signalClients   = []
#     @::masterPC    
#     setup: ->
#         @isMaster = false if @roomId is not null
#         @setupSignalServer()

#     setupSignalServer: ->
#         @signalConnection = new WebSocket(@signalServer)
#         @signalConnection.onopen    @handleSignalOpen
#         @signalConnection.onmessage @handleSignalMessge
#         @signalConnection.onerror   @handleSignalError
#         @signalConnection.onclose   @handleSignalClose
#         if @isMaster
#             @signalSend type: "new"
#         else
#             @signalSend 
#                 type: "connect"
#                 roomId: @roomId
#     signalSend: (msg) ->
#         if @signalConnection.readyState is 1
#             @signalConnection.send JSON.stringify(msg)
#         else
#             console.log "Signalling Channel isn't ready"
#     handleSignalOpen: (event) =>
#         console.log "Signalling Channel Opened"
#     handleSignalMessage: (message) =>
#         try 
#             parsedMsg = JSON.parse(message)

#             if parsedMsg.type?
#                 throw new Error("message Type not defined")

#             switch parsedMsg.type
#                 when "id" # room creation successful
#                     @roomId = parsedMsg.roomId
#                     console.log "created room"
#                 when "connect"  # new client
#                     console.log "client want's to connect"
#                     signallingId = parsedMsg.clientId
#                     # create new PeerConnection, assign internal ClientId
#                 when "answer"
#                     console.log "answer"
#                     # traverse peerconnections, send to corresponding peerconnection
#                 when "candidate"
#                     console.log "candidate"
#                     # traverse peerconnections, send to corresponding peerconnection
#         catch e
#             console.log "wasn't able to parse message"

#     handleSignalError: (event) =>
#         console.log "Signalling Channel Error"
#         console.log event
#     handleSignalClose: (event) =>
#         console.log "Signalling Channel Closed"

# window.rtc = RTCProvider

app = angular.module "unwatched.services", []

# app.provider "RTC", RTCProvider

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
