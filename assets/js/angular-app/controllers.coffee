# Angular Controllers
# =======================================================

"use strict"

UnwatchedCtrl = angular.module("unwatched.controllers", [])
UnwatchedCtrl.controller "IndexCtrl", [ ->
  console.log "index ctrl here"
]
UnwatchedCtrl.controller "CyborgCtrl", [ ->
  
]

UnwatchedCtrl.controller "ModalInstanceCtrl",
["$scope", "$modalInstance", "items", ($scope, $modalInstance, items) ->
  console.log "ModalInstanceCtrl here"
  
  $scope.items = items
  $scope.selected =
    item: $scope.items[0]

  $scope.ok = ->
    $modalInstance.close $scope.selected.item

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"

]

UnwatchedCtrl.controller "NavCtrl", [ "$scope", "$modal", ($scope, $modal) ->
  console.log "NavCtrl here"

  $scope.items = ['item 1', 'item 2', 'item 3']

  $scope.open = ->
    
    modalInstance = $modal.open(
      templateUrl: "/partials/loginForm.jade"
      controller: "ModalInstanceCtrl"
      resolve:
        items: ->
          $scope.items
    )

    modalInstance.result.then ((selectedItem) ->
      $scope.selected = selectedItem
    ), ->
      console.log "Modal dismissed at: " + new Date()

]

