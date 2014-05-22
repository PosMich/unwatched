# Unwatched - Angular Controllers
# ===============================

"use strict"

app = angular.module "unwatched.controllers", []

app.controller "AppCtrl", [
    "$scope"
    ($scope) ->


]

app.controller "IndexCtrl", [
    "$scope", "RTC"
    ($scope, RTCProvider) ->
        # console.log RTCProvider
        # console.log "index ctrl here"

        # $scope.submitCreateRoom = ->
]

app.controller "SpacelabCtrl", ->
    console.log "spacelab ctrl here"


# ***
# ## Config
# > contains routing stuff only (atm)
# >
# > see
# > [angular docs](http://docs.angularjs.org/guide/dev_guide.services.$location)
# > for $locationProvider details

# ***
# * <h3>Member Controller</h3>
# >
app.controller "MembersCtrl", [
    "$scope", "ChatStateService"
    ($scope, ChatStateService) ->
        $scope.members = []

        $scope.$watch (->
            return ChatStateService.chat_state
        ), ((new_state, old_state) ->
            $scope.chat_state = new_state
        ), true

        membersAmount = Math.floor(Math.random() * 10 + 1) + 6
        while membersAmount -= 1
            $scope.members.push
                name: "Lorem Ipsum"
                avatar:
                    if Math.round(Math.random()) is 0 then "/images/avatar.png"
                    else "/images/avatar_inverted.png"
]

# ***
# * <h3>Share Controller</h3>
# >
app.controller "ShareCtrl", [
    "$scope", "ChatStateService"
    ($scope, ChatStateService) ->
        $scope.shared_items = []

        $scope.$watch (->
            return ChatStateService.chat_state
        ), ((new_state, old_state) ->
            $scope.chat_state = new_state
        ), true

        $scope.controls = {}
        $scope.controls.layout = "layout-icons"
        $scope.controls.sorting = {}
        $scope.controls.sorting.state = "name"
        $scope.controls.sorting.ascending = false

        $scope.shared_items = dummy_items

        $scope.setSortingState = (state) ->
            if $scope.controls.sorting.state is state
                scope.controls.sorting.ascending =
                    !$scope.controls.sorting.ascending
            else
                $scope.controls.sorting.ascending = false
                $scope.controls.sorting.state = state

        $scope.delete = (index) ->
            i = 0
            item = {}
            while i < $scope.shared_items.length
                item = $scope.shared_items[i]
                if item.id is index
                    $scope.shared_items.splice i, 1 
                    break
                i++

]

app.controller "ScreenshotCtrl", [
    "$scope", "$routeParams"
    ($scope, $routeParams) ->
        console.log $routeParams
        if $routeParams.id
            $scope.id = $routeParams.id

        else
            $scope.id = "No ID :("
]

app.controller "NoteCtrl", [
    "$scope", "$routeParams"
    ($scope, $routeParams) ->
        console.log $routeParams
        if $routeParams.id
            $scope.id = $routeParams.id

        else
            $scope.id = "No ID :("
]

app.controller "CodeCtrl", [
    "$scope", "$routeParams"
    ($scope, $routeParams) ->
        console.log $routeParams
        if $routeParams.id
            $scope.id = $routeParams.id

        else
            $scope.id = "No ID :("
]

app.controller "SharedScreenCtrl", [
    "$scope", "$routeParams"
    ($scope, $routeParams) ->
        console.log $routeParams
        if $routeParams.id
            $scope.id = $routeParams.id

        else
            $scope.id = "No ID :("
]

app.controller "SharedWebcamCtrl", [
    "$scope", "$routeParams"
    ($scope, $routeParams) ->
        console.log $routeParams
        if $routeParams.id
            $scope.id = $routeParams.id

        else
            $scope.id = "No ID :("
]

# ***
# * <h3>Chat Controller</h3>
# >
app.controller "ChatCtrl", [
    "$scope", "ChatStateService"
    ($scope, ChatStateService) ->

        $scope.chat = {}
        $scope.chat.state = ChatStateService.chat_state
        $scope.chat.state_history = ChatStateService.chat_state_history
        $scope.chat.messages = [
            # dummy entries
            {
                sender: "Lorem Ipsum",
                content: "Lorem ipsum dolor sit amet, consetetur sadipscing el"+
                "itr, sed diam nonumy eirmod tempor invidunt ut labore et dolo"+
                "re magna aliquyam erat, sed diam voluptua. At vero eos et acc"+
                "usam et justo duo dolores et ea rebum. Stet clita kasd guberg"+
                "ren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
            }
            {
                sender: "Lorem Ipsum",
                content: "Lorem ipsum dolor sit amet, consetetur sadipscing el"+
                "itr, sed diam nonumy eirmod tempor invidunt ut labore et dolo"+
                "re magna aliquyam erat, sed diam voluptua."
            }
            {
                sender: "Lorem Ipsum",
                content: "Lorem ipsum dolor sit amet, consetetur sadipscing el"+
                "itr, sed diam nonumy eirmod tempor invidunt ut labore et dolo"+
                "re magna aliquyam erat, sed diam voluptua. At vero eos et acc"+
                "usam et justo duo dolores et ea rebum."
            }

        ]

        $scope.submitChatMessage = ->
            $scope.chat.messages.push
                sender: "Lorem Ipsum"
                content: $scope.chat.message
            $scope.chat.message = ""

        $scope.chat.compress = ->
            $scope.chat.state = "compressed"
            ChatStateService.setChatState($scope.chat.state)

        $scope.chat.expand = ->
            $scope.chat.state = "expanded"
            ChatStateService.setChatState($scope.chat.state)

        $scope.chat.minimize = ->
            $scope.chat.state_history = $scope.chat.state
            ChatStateService.setChatStateHistory($scope.chat.state_history)
            $scope.chat.state = "minimized"
            ChatStateService.setChatState($scope.chat.state)

        $scope.chat.maximize = ->
            if $scope.chat.state is "minimized"
                $scope.chat.state = $scope.chat.state_history
                ChatStateService.setChatState($scope.chat.state_history)

]

# ***
# * <h3>Notes Controller</h3>
# > Contains the logic to add/remove notes - the title of a note is the key
# > of the note-model-object - the path to the note is the corresponding value.
app.controller "NotesCtrl", [
    "$scope"
    ($scope) ->
        $scope.room.notes = []

        $scope.tinymceOptions =
            menubar: false

        $scope.addNote = ->
            $scope.room.notes.push
                "title": "Untitled Document"
                "content": "Click to edit"
                "path": "future/path/to/note"
            

        $scope.removeNote = (index) ->
            $scope.room.notes.splice index, 1

]


dummy_items = [
    {
        id: 1
        category: "screenshot"
        name: "Sophia"
        size: 1036463
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        thumbnail: "screenshot.png"
        templateUrl: "/partials/items/thumbnails/screenshot.html"
    }
    {
        id: 2,
        name: "Steffen"
        size: 43696
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "file"
        thumbnail: "icon"
        extension: ".pdf"
        templateUrl: "/partials/items/thumbnails/file.html"
    }
    {
        id: 3,
        name: "style"
        size: 876432
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "code"
        thumbnail: "vardummy=function() {<br/>&nbsp&nbsp&nbsp&nbspconsole.log"+
            "(\"Helloworld\")<br/>}"
        extension: "css"
        templateUrl: "/partials/items/thumbnails/code.html"
    }
    {
        id: 4,
        name: "index"
        size: 346432
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "code"
        thumbnail: "vardummy=function() {<br/>&nbsp&nbsp&nbsp&nbspconsole.log"+
            "(\"Helloworld\")<br/>}"
        extension: "html"
        templateUrl: "/partials/items/thumbnails/code.html"
    }
    {
        id: 5,
        name: "main"
        size: 832
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "code"
        thumbnail: "vardummy=function() {<br/>&nbsp&nbsp&nbsp&nbspconsole.log"+
            "(\"Helloworld\")<br/>}"
        extension: "js"
        templateUrl: "/partials/items/thumbnails/code.html"
    }
    {
        id: 6,
        name: "HelloWorld"
        size: 876432
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "code"
        thumbnail: "vardummy=function() {<br/>&nbsp&nbsp&nbsp&nbspconsole.log"+
            "(\"Helloworld\")<br/>}"
        extension: "java"
        templateUrl: "/partials/items/thumbnails/code.html"
    }
    {
        id: 7,
        name: "script"
        size: 1024
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "code"
        thumbnail: "vardummy=function() {<br/>&nbsp&nbsp&nbsp&nbspconsole.log"+
            "(\"Helloworld\")<br/>}"
        extension: "py"
        templateUrl: "/partials/items/thumbnails/code.html"
    }
    {
        id: 8,
        name: "spec"
        size: 90123
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "code"
        thumbnail: "vardummy=function() {<br/>&nbsp&nbsp&nbsp&nbspconsole.log"+
            "(\"Helloworld\")<br/>}"
        extension: "rb"
        templateUrl: "/partials/items/thumbnails/code.html"
    }
    {
        id: 9,
        name: "Untitled"
        size: 90123
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "note"
        thumbnail:
            title: "Protocol",
            content: "<p>Loremipsumdolorsitamet, consetetursadipscingelitr, "+
                "seddiamnonumyeirmod.</p><p>temporinvidun tutlaboreet dolorem "+
                "agnaaliquy amerat, seddiamvoluptua.</p>"
        edited: "20.05.2014-20:25"
        templateUrl: "/partials/items/thumbnails/note.html"
    }
    {
        id: 10,
        name: "How to photoshop"
        size: 0
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "shared-screen"
        thumbnail: "screenshot-screen.png"
        templateUrl: "/partials/items/thumbnails/shared-screen.html"
    }
    {
        id: 11,
        name: "See me cooking"
        size: 0
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "shared-webcam"
        thumbnail: "screenshot-webcam.jpg"
        templateUrl: "/partials/items/thumbnails/shared-webcam.html"
    }

]