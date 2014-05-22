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

app.controller "ViewInstanceCtrl", [
    "$scope"
    ($scope, viewInstance) ->
        
        $scope.ok = ->
            viewInstance.close()

        $scope.cancel = ->
            viewInstance.dismiss()
]

# ***
# * <h3>Share Controller</h3>
# >
app.controller "ShareCtrl", [
    "$scope", "$modal", "ChatStateService"
    ($scope, $modal, ChatStateService) ->
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

        $scope.openView = (item_category) ->
            viewInstance = $modal.open(
                templateUrl: "/partials/items/" + item_category + ".html"
                controller: "ViewInstanceCtrl"
                size: "lg"
            )

        shared_items_amount = Math.floor(Math.random() * 20 + 1) + 10

        file_names = [
            'Lothar',
            'Rafael',
            'Angelika',
            'Wolfram',
            'Lisa',
            'Sophia',
            'David',
            'Andrea',
            'Hermine',
            'Rudolf',
            'Steffen',
            'Johanna'
        ]

        code_extensions = [
            "html"
            "css"
            "js"
            "py"
            "java"
            "rb"
        ]
    
        while shared_items_amount -= 1

            rand = Math.round(Math.random() * 6)

            file = {}
            file.name = file_names[ Math.floor(Math.random() * 12) ]
            file.size = Math.floor(Math.random() * 1024 * 1024) + 100
            file.author = "Max Mustermann"
            file.created = "14.05.2014 - 15:10"

            if rand is 0
                file.category = "note"
                file.thumbnail =
                    title: "Lorem Ipsum"
                    content: "<p>Lorem ipsum dolor sit amet, consetetur sadips"+
                        "cing elitr, sed diam nonumy eirmod.</p><p>tempor invi"+
                        "dunt ut labore et dolore magna aliquyam erat, sed dia"+
                        "m voluptua.</p>"
                file.edited = "20.05.2014 - 20:25"
            else if rand is 1
                file.category = "screenshot"
                file.thumbnail = "screenshot.png"
            else if rand is 2
                file.category = "file"
                file.thumbnail = "icon"
                file.extension = ".pdf"
            else if rand is 3
                file.category = "code"
                file.thumbnail = "var dummy = function() {<br/>&nbsp&nbsp&nbsp"+
                    "&nbspconsole.log(\"Hello world\")<br/>}"
                file.extension = code_extensions[Math.floor(Math.random() * 6)]
            else if rand is 4
                file.category = "shared-screen"
                file.thumbnail = "screenshot-screen.png"
                file.size = 0
            else
                file.category = "shared-webcam"
                file.thumbnail = "screenshot-webcam.jpg"
                file.size = 0


            file.templateUrl = "/partials/items/" + file.category + ".html"

            $scope.shared_items.push file

        $scope.setSortingState = (state) ->
            if $scope.controls.sorting.state is state
                scope.controls.sorting.ascending =
                    !$scope.controls.sorting.ascending
            else
                $scope.controls.sorting.ascending = false
                $scope.controls.sorting.state = state

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
