# Unwatched - Angular Controllers
# ===============================

"use strict"

app = angular.module "unwatched.controllers", []

app.controller "AppCtrl", [
  "$scope"
  ($scope) ->

    if !$scope.chat_state?
      console.log "changing state"
      $scope.chat_state = "expanded"

]

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
  # "RTC"
  ($scope, $modal) ->
    # console.log RTCProvider
    # RTCProvider.logName()
    # console.log RTCProvider.createHash()
    #RTCProvider.setName "Friedrich"
    # RTCProvider.logName()

    # RTCProvider.addClient "Herbert", "herbert@herbert.com"
    # RTCProvider.addClient "Franz", "franz@franz.fr"
    # RTCProvider.listClients()
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
  #"RTC"
  ($scope, $modalInstance) ->
    $scope.user = {}

    # RTCProvider.logName()
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
# * <h3>Member Controller</h3>
# >
app.controller "MembersCtrl", [
  "$scope"
  ($scope) ->
    $scope.members = []

    membersAmount = Math.floor(Math.random() * 10 + 1) + 6
    while membersAmount -= 1
      $scope.members.push
        name: "Lorem Ipsum"
        avatar: if Math.round(Math.random()) is 0 then "/images/avatar.png"
        else "/images/avatar_inverted.png"
]

# ***
# * <h3>Share Controller</h3>
# >
app.controller "ShareCtrl", [
  "$scope"
  ($scope) ->
    $scope.shared_items = []

    $scope.controls = {}
    $scope.controls.layout = "icons"

    shared_items_amount = Math.floor(Math.random() * 20 + 1) + 50

    file_names = [
      'Lothar',
      'Rafael',
      'Angelika',
      'Wolfram',
      'Gisa',
      'Sophie',
      'David',
      'Andrea',
      'Hermine',
      'Rudolf',
      'Steffen',
      'Johanna'
    ]
    
    while shared_items_amount -= 1

      rand = Math.round(Math.random() * 4)

      file = {}
      file.name = file_names[ Math.floor(Math.random() * 12) ]
      file.size = Math.floor(Math.random() * 1024 + 1)
      file.author = "Max Mustermann"

      if rand is 0
        file.category = "note"
      else if rand is 1
        file.category = "screenshot"
      else if rand is 2
        file.category = "file"
      else
        file.category = "shared_screen"
        file.size = 0


      $scope.shared_items.push file

]

# ***
# * <h3>Chat Controller</h3>
# >
app.controller "ChatCtrl", [
  "$scope"
  ($scope) ->

    $scope.chat = {}
    $scope.chat.state = $scope.$parent.$parent.chat_state || "minimized"
    console.log $scope.chat.state
    $scope.chat.state_history = ""
    $scope.chat.messages = [
      # dummy entries
      {
        sender: "Lorem Ipsum",
        content: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed"+
        " diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquya"+
        "m erat, sed diam voluptua. At vero eos et accusam et justo duo dolore"+
        "s et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est"+
        " Lorem ipsum dolor sit amet."
      }
      {
        sender: "Lorem Ipsum",
        content: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed"+
        " diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquya"+
        "m erat, sed diam voluptua."
      }
      {
        sender: "Lorem Ipsum",
        content: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed"+
        " diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquya"+
        "m erat, sed diam voluptua. At vero eos et accusam et justo duo dolore"+
        "s et ea rebum."
      }

    ]

    $scope.submitChatMessage = ->
      $scope.chat.messages.push
        sender: "Lorem Ipsum"
        content: $scope.chat.message
      $scope.chat.message = ""

    $scope.chat.compress = ->
      $scope.chat.state = "compressed"
      $scope.$parent.$parent.chat_state = $scope.chat.state

    $scope.chat.expand = ->
      $scope.chat.state = "expanded"
      $scope.$parent.$parent.chat_state = $scope.chat.state

    $scope.chat.minimize = ->
      $scope.chat.state_history = $scope.chat.state
      $scope.chat.state = "minimized"
      $scope.$parent.$parent.chat_state = $scope.chat.state

    $scope.chat.maximize = ->
      if $scope.chat.state is "minimized"
        $scope.chat.state = $scope.chat.state_history
        $scope.$parent.$parent.chat_state = $scope.chat.state

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
