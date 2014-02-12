# Unwatched - Angular Controllers
# ===============================

"use strict"

app = angular.module "unwatched.controllers", []

app.controller "IndexCtrl", ->
  console.log "index ctrl here"

app.controller "SpacelabCtrl",  ->
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

app.controller "SignupCtrl", [
  "$scope"
  "$modalInstance"
  "RTC"
  ($scope, $modalInstance, RTCProvider) ->
    RTCProvider.logName()
    $scope.ok = ->
      $modalInstance.close

    $scope.cancel = ->
      $modalInstance.dismiss "cancel"
]
