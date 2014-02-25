# Unwatched - Angular Directives
# ==============================

"use strict"

app = angular.module "unwatched.directives", []

app.directive "appVersion", [
  "version"
  (version) ->
    (scope, elem, attrs) ->
      elem.text version
]

app.directive "inputMatch", [->
  require: "ngModel"
  link: (scope, elem, attrs, ctrl) ->
    originInput = "#" + attrs.inputMatch
    elem.add(originInput).on "keyup", ->
      scope.$apply ->
        v = elem.val() is $(originInput).val()
        ctrl.$setValidity "inputMatch", v
        return
      return
    return
]