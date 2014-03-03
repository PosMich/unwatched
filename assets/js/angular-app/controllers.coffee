# Unwatched - Angular Controllers
# ===============================

"use strict"

app = angular.module "unwatched.controllers", []

app.controller "IndexCtrl", [
  "$scope"
  ($scope) ->
    console.log "index ctrl here"

    $scope.submitCreateRoom = ->
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
app.controller "NavCtrl", [
  "$scope"
  "$modal"
  "RTC"
  ($scope, $modal, RTCProvider) ->
    console.log RTCProvider
    RTCProvider.logName()
    RTCProvider.setName "Friedrich"
    RTCProvider.logName()

    $scope.open = ->
      modalInstance = $modal.open(
        templateUrl: "/partials/loginForm.jade"
        controller: "SignupCtrl"
      )

]

# ***
# * <h3>Signup Controller</h3>
# >
app.controller "SignupCtrl", [
  "$scope"
  "$modalInstance"
  "RTC"
  ($scope, $modalInstance, RTCProvider) ->

    $scope.user = {}

    RTCProvider.logName()
    $scope.hideSignUp = true

    $scope.submit = ->
      console.log $scope.user
      $modalInstance.close

    $scope.cancel = ->
      $modalInstance.dismiss "cancel"
]

# ***
# * <h3>Room Controller</h3>
# >
app.controller "RoomCtrl", [
  "$scope"
  ($scope) ->
    $scope.room =
      name: "Untitled Room"
      activePanel: "clients"

    $scope.setActivePanel = (panelId) ->
      $scope.room.activePanel = panelId

    $scope.getActivePanel = (panelId) ->
      if $scope.room.activePanel is panelId
        return "panel-primary"
      else
        return "panel-default"
]

# ***
# * <h3>Clients Controller</h3>
# >
app.controller "ClientsCtrl", [
  "$scope"
  ($scope) ->
    $scope.clients = []
    
    clientsAmount = Math.floor(Math.random() * 10 + 1) + 1
    while clientsAmount -= 1
      $scope.clients.push
        name: "Lorem Ipsum"
        avatar: if Math.round(Math.random()) is 0 then "/images/avatar.png"
        else "/images/avatar_inverted.png"
]

# ***
# * <h3>Chat Controller</h3>
# >
app.controller "ChatCtrl", [
  "$scope"
  ($scope) ->
    $scope.chat = {}
    $scope.chat.messages = []

    $scope.submitChatMessage = ->
      $scope.chat.messages.push
        sender: "Lorem Ipsum"
        content: $scope.chat.message
      $scope.chat.message = ""

]

# ***
# * <h3>Notes Controller</h3>
# > Contains the logic to add/remove notes - the title of a note is the key
# > of the note-model-object - the path to the note is the corresponding value.
app.controller "NotesCtrl", [
  "$scope"
  ($scope) ->
    $scope.room.notes = {}

    $scope.addNote = ->
      occupied = false
      if $scope.room.notes["Untitled Document"] is undefined
        $scope.room.notes["Untitled Document"] = "future/path/to/note"
      else
        occupied = true
        index = 1
        while occupied
          if $scope.room.notes["Untitled Document(" + index + ")"] is undefined
            $scope.room.notes["Untitled Document(" + index + ")"] =
              "future/path/to/note"
            occupied = false
          else index++

    $scope.removeNote = (key) ->
      delete $scope.room.notes[key]

]