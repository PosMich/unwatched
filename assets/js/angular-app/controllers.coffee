# Angular Controllers
# =======================================================

"use strict"

app = angular.module "unwatched.controllers", []

app.controller "IndexCtrl", ->
  console.log "index ctrl here"

app.controller "CyborgCtrl",  ->
  console.log "cyborg ctrl here"

app.controller "NavCtrl", [
  "$scope"
  "$modal"
  ($scope, $modal) ->

    $scope.open = ->
      modalInstance = $modal.open(
        templateUrl: "/partials/loginForm.jade"
        controller: "SignupCtrl"
      )

]

app.controller "SignupCtrl", [
  "$scope"
  "$modalInstance"
  ($scope, $modalInstance) ->
    $scope.ok = ->
      $modalInstance.close

    $scope.cancel = ->
      $modalInstance.dismiss "cancel"
]
