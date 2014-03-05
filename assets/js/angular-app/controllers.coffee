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
    console.log RTCProvider.createHash()
    #RTCProvider.setName "Friedrich"
    RTCProvider.logName()

    RTCProvider.addClient "Herbert", "herbert@herbert.com"
    RTCProvider.addClient "Franz", "franz@franz.fr"
    RTCProvider.listClients()
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

    $scope.isCollapsed = true
    $scope.ok = ->
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
      activePanel: "clients-chat"

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
