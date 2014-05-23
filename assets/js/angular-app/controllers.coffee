# Unwatched - Angular Controllers
# ===============================

"use strict"

app = angular.module "unwatched.controllers", []

app.controller "AppCtrl", [
    "$scope", "SharedItemsService"
    ($scope, SharedItemsService) ->


        SharedItemsService.initItems( dummy_items )

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
    "$scope", "ChatStateService", "SharedItemsService"
    ($scope, ChatStateService, SharedItemsService) ->
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

        $scope.shared_items = SharedItemsService.getItems()

        $scope.setSortingState = (state) ->
            if $scope.controls.sorting.state is state
                scope.controls.sorting.ascending =
                    !$scope.controls.sorting.ascending
            else
                $scope.controls.sorting.ascending = false
                $scope.controls.sorting.state = state

        $scope.delete = (item_id) ->
            SharedItemsService.deleteItem(item_id)

]

app.controller "ScreenshotCtrl", [
    "$scope", "$routeParams", "SharedItemsService"
    ($scope, $routeParams, SharedItemsService) ->
        
        $scope.item = {}

        if $routeParams.id
            $scope.item = SharedItemsService.getItem($routeParams.id)
        else
            $scope.error = "No such item is shared in your current room."
]

app.controller "NoteCtrl", [
    "$scope", "$routeParams"
    ($scope, $routeParams) ->
        if typeof $routeParams.id is "undefined"
            $scope.item_error = "No such item is shared in your current room."
        else
            $scope.item = dummy_items[$routeParams.id]
]

app.controller "CodeCtrl", [
    "$scope", "$routeParams", "SharedItemsService", "ChatStateService"
    ($scope, $routeParams, SharedItemsService, ChatStateService) ->

        if $routeParams.id

            $scope.containerResize = ->
                $scope.editor.resize()

            $scope.setEditorExtension = (value) ->
                ace_ext = value
                ace_ext = "javascript" if value is "js"
                ace_ext = "ruby" if value is "rb"
                ace_ext = "python" if value is "py"
                $scope.editor.getSession().setMode("ace/mode/" + ace_ext)

            $scope.setEditorFontSize = (value) ->
                $scope.editor.setFontSize(value)
                return

            getExtensionId = (value) ->
                extension = {}
                for i of $scope.settings.available_extensions
                    extension = $scope.settings.available_extensions[i]
                    if value is extension.value
                        return i

            $scope.settings = {}

            $scope.settings.available_extensions = [
                { value: "", name: "Choose language" }
                { value: "html", name: "HTML" }
                { value: "css", name: "CSS" }
                { value: "js", name: "JavaScript" }
                { value: "java", name: "Java" }
                { value: "rb", name: "Ruby" }
                { value: "py", name: "Python" }
            ]

            $scope.settings.available_font_sizes = [
                { value: 12, name: "12px"}
                { value: 14, name: "14px"}
                { value: 16, name: "16px"}
                { value: 18, name: "18px"}
                { value: 20, name: "20px"}
            ]

            $scope.item = SharedItemsService.getItem($routeParams.id)

            $scope.editor = ace.edit("editor")
            $scope.editor.getSession().setUseWorker(false)
            $scope.editor.setTheme("ace/theme/monokai")
            $scope.editor.setValue($scope.item.content)

            extension_id = getExtensionId( $scope.item.extension )
            $scope.settings.extension = 
                $scope.settings.available_extensions[extension_id]
            $scope.settings.font_size = $scope.settings.available_font_sizes[0]

            $scope.setEditorExtension( $scope.settings.extension.value )
            $scope.setEditorFontSize( $scope.settings.font_size.value )

            $scope.$watch "settings.extension", (option, old_option) ->
                if option.value is ""
                    $scope.settings.extension = old_option
                    return
                $scope.setEditorExtension( option.value )    


            $scope.$watch "settings.font_size", (option) ->
                $scope.setEditorFontSize(option.value)
                
        else
            $scope.id = "No ID :("


]

app.controller "SharedScreenCtrl", [
    "$scope", "$routeParams"
    ($scope, $routeParams) ->
        if $routeParams.id
            $scope.id = $routeParams.id

        else
            $scope.id = "No ID :("
]

app.controller "SharedWebcamCtrl", [
    "$scope", "$routeParams"
    ($scope, $routeParams) ->
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
        path: "/images/screenshot.png"
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
        path: "/future/path/to/file"
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
        path: "/future/path/to/file"
        extension: "css"
        templateUrl: "/partials/items/thumbnails/code.html"
    }
    {
        id: 4,
        name: "HelloWorld"
        size: 346432
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "code"
        thumbnail: "vardummy=function() {<br/>&nbsp&nbsp&nbsp&nbspconsole.log"+
            "(\"Helloworld\")<br/>}"
        path: "/future/path/to/file"
        extension: "java"
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
        path: "/future/path/to/file"
        extension: "js"
        templateUrl: "/partials/items/thumbnails/code.html"
    }
    {
        id: 6,
        name: "index"
        size: 876432
        author: "Max Mustermann"
        created: "14.05.2014-15:10"
        category: "code"
        thumbnail: "var dummy = function() {<br/>&nbsp&nbsp&nbsp&nbspconsole.l"+
            "og(\"Helloworld\")<br/>}"
        content: 
            '<!doctype html>\n' +
                '<html lang="en">\n' +
                    '\t<head>\n' +
                        '\t\t<meta charset="utf-8">\n' +
                        '\t\t<title>The HTML5 Herald</title>\n' +
                        '\t\t<meta name="description" content="The HTML5 Heral'+
                            'd">\n' +
                        '\t\t<meta name="author" content="SitePoint">\n' +
                        '\t\t<link rel="stylesheet" href="css/styles.css?v=1.0'+
                            '">\n' +
                    '\t</head>\n' +
                    '\t<body>\n' +
                        '\t\t<script src="js/scripts.js"></script>\n' +
                    '\t</body>\n' +
                '</html>\n'
        path: "/future/path/to/file"
        extension: "html"
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
        path: "/future/path/to/file"
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
        path: "/future/path/to/file"
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
        path: "/future/path/to/file"
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
