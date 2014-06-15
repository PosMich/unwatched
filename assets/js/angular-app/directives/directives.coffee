# Unwatched - Angular Directives
# ==============================

"use strict"

app = angular.module "unwatched.directives"

# ***
# * <h3>inputMatch</h3>
# > Directive to validate wheter two inputs are equal <br/>
# > Frontend-usage: input(input-match="origin-input-field-id")

app.directive "inputMatch", [ ->
    require: "ngModel"
    link: (scope, elem, attrs, ctrl) ->
        originInput = "#" + attrs.inputMatch
        elem.add(originInput).on "input", ->
            scope.$apply ->
                v = elem.val() is $(originInput).val()
                ctrl.$setValidity "inputMatch", v
                return
            return
        return
]

app.directive "centerVertical", [
    "$window", "RoomService"
    ($window, RoomService) ->
        link: (scope, elem, attrs) ->

            centerVertical = (elem, attrs) ->
                marginTop = ( $($window).height() - $(elem).height() ) / 2
                $(elem).css "margin-top", marginTop
                return

            scope.$watch attrs.adjustWidth, ->
                window.setTimeout( (->
                    centerVertical(elem, attrs)
                ), 1)

            scope.$watch ->
                RoomService.id
            , ->
                window.setTimeout( (->
                    centerVertical(elem, attrs)
                ), 1)
            , true

            angular.element($window).bind "resize", ->
                centerVertical(elem, attrs)
                return
]

app.directive "resizeModal", [
    "ChatStateService"
    (ChatStateService) ->
        link: (scope, element, attrs) ->

            resize = ->
                width = "100%"
                width = "50%" if ChatStateService.chat_state is 'expanded'
                element.parent().parent().parent().width width

            scope.$watch ->
                ChatStateService.chat_state
            , ->
                resize()

]

app.directive "editInPlace", ->
    restrict: "E"
    scope:
        value: "="
    link: (scope, element, attrs) ->

        inputRepresentation = angular.element element.children()[0]
        inputElement = angular.element element.children()[1]

        inputElement.css("font-size", inputRepresentation.css("font-size"))
        inputElement.css("height", "auto")

        element.addClass 'edit-in-place'
        scope.editing = false

        inputRepresentation.on "click", ->
            inputRepresentation.addClass 'representation-inactive'
            scope.old_value = scope.value
            scope.editing = true
            element.addClass "active"
            inputElement[0].focus()

        inputElement.on "blur", ->
            inputRepresentation.removeClass 'representation-active'
            scope.editing = false
            element.removeClass "active"

            if !scope.value? || scope.value.length is 0 || scope.value is null
                scope.value = scope.old_value
                scope.$apply()

app.directive "myClip", ->
    link: (scope, element, attrs) ->

        clip = new ZeroClipboard angular.element("#test")[0],
            moviePath: "/swf/ZeroClipboard.swf"

        element.on "click", ->
            console.log "clicked"
            angular.element("#test").click()
