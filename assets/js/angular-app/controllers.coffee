# Unwatched - Angular Controllers
# ===============================

"use strict"

app = angular.module "unwatched.controllers", []

app.controller "AppCtrl", [
  "$scope"
  ($scope) ->

    if !$scope.chat_state?
      $scope.chat_state = "compressed"
    if !$scope.chat_state_history?
      $scope.chat_state_history = ""

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
    $scope.controls.layout = "layout-list"

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
      file.size = Math.floor(Math.random() * 1024 + 1)
      file.author = "Max Mustermann"
      file.created = "14.05.2014 - 15:10"

      if rand is 0
        file.category = "note"
        file.thumbnail = 
          title: "Lorem Ipsum"
          content: "<p>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, s"+
            "ed diam nonumy eirmod.</p><p>tempor invidunt ut labore et dolore magna a"+
            "liquyam erat, sed diam voluptua.</p>"
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
        file.thumbnail = "var dummy = function() {<br/>&nbsp&nbsp&nbsp&nbspconsole.log(\"Hello world\")<br/>}"
        file.extension = code_extensions[ Math.floor(Math.random() * 6) ]
      else if rand is 4
        file.category = "shared-screen"
        file.thumbnail = "screenshot-screen.png"
        file.size = 0
      else
        file.category = "shared-webcam"
        file.thumbnail = "screenshot-webcam.jpg"
        file.size = 0

      file.templateUrl = "/partials/items/" + file.category + ".jade"

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
    $scope.chat.state_history = $scope.$parent.$parent.chat_state_history || ""
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
      $scope.$parent.$parent.chat_state_history = $scope.chat.state
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
