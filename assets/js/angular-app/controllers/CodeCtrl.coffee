# Unwatched - Code Controller
# ===============================

"use strict"

app = angular.module "unwatched.controllers"

app.controller "CodeCtrl", [
    "$scope", "$routeParams", "SharesService", "ChatStateService",
    "available_extensions", "font_sizes", "ace_themes", "$location",
    "AceSettingsService", "$modal", "UserService", "RTCService",
    "$rootScope", "$timeout"
    ($scope, $routeParams, SharesService, ChatStateService,
        available_extensions, font_sizes, ace_themes, $location,
        AceSettingsService, $modal, UserService, RTCService,
        $rootScope, $timeout) ->

        # init ace editor
        $scope.editor = ace.edit("editor")
        $scope.copiedCode = false

        # testing

        $scope.editor.getSession().setUseWorker(false)
        $scope.editor.session.setNewLineMode("unix")

        # init settings for ace editor
        $scope.settings = {}

        # get available setting options (constants)
        $scope.settings.available_extensions = available_extensions
        $scope.settings.available_font_sizes = font_sizes
        $scope.settings.available_themes = ace_themes

        # dataUrl to download code file
        $scope.dataUrl = ""

        # helper functions
        $scope.containerResize = ->
            $scope.editor.resize()

        $scope.setEditorExtension = (extension) ->
            return if extension is ""
            ace_ext = extension
            ace_ext = "javascript" if extension is "js"
            ace_ext = "ruby" if extension is "rb"
            ace_ext = "python" if extension is "py"
            $scope.editor.getSession().setMode("ace/mode/" + ace_ext)

        $scope.setEditorFontSize = (font_size) ->
            $scope.editor.setFontSize(font_size)
            return

        $scope.setEditorTheme = (theme) ->
            $scope.editor.setTheme("ace/theme/" + theme)
            return

        $scope.getExtensionId = (value) ->
            extension = {}
            for i of $scope.settings.available_extensions
                extension = $scope.settings.available_extensions[i]
                if value is extension.value
                    return i

        $scope.updateThumbnail = ->
            lines = $scope.editor.session.doc.getLines(0, 4)
            i = 0
            thumbnail = ""
            while i < lines.length
                thumbnail += lines[i] + "\n"
                i++

            $scope.item.thumbnail = thumbnail


        $scope.delete = ->
            modalInstance = $modal.open(
                templateUrl: "/partials/deleteModal.html"
                controller: "DeleteModalInstanceCtrl"
                size: "lg"
                resolve: {
                    item: ->
                        $scope.item
                }
            )

            modalInstance.result.then( ->
                RTCService.sendItemDeleted( $scope.user, $scope.item.id )
                SharesService.delete $scope.item.id
                $location.path "/share"
            )

        $scope.getClipText = ->
            $scope.copiedCode = true
            $scope.$apply() if !$scope.$$phase
            $timeout(
                ->
                    $scope.copiedCode = false
                2500
            )
            return $scope.item.content

        $scope.users = UserService.users
        $scope.user = $scope.users[$rootScope.userId]

        if !$routeParams.id?
            # create new code item
            sharedItemId = SharesService.create( $rootScope.userId, "code" )
            $scope.item = SharesService.get( sharedItemId )

            RTCService.sendNewCodeItem $scope.item, $scope.user.isMaster

            contributor = SharesService.getContributor(
                $scope.item.id, $scope.user.id )

        else
            # get shared item by given id
            $scope.item = SharesService.get($routeParams.id)
            $location.path "/404" if !$scope.item?

            contributor = SharesService.getContributor(
                $scope.item.id, $scope.user.id )

            if !contributor
                $scope.item.contributors.push
                    id: $scope.user.id
                    active: true


        contributor.active = true

        change =
            contributors: $scope.item.contributors
        RTCService.sendCodeItemHasChanged(
            change, $scope.item.id, $scope.user.isMaster )


        Range = ace.require("ace/range").Range
        $rootScope.markers = []

        for contributor in $scope.item.contributors
            if contributor.active
                if contributor.id isnt $scope.user.id
                    $rootScope.markers.push
                        contributorId: contributor.id
                        marker: $scope.editor.session.addMarker(
                            new Range(), "marker" + contributor.id, "text", true
                        )
                        cursor:
                            row: 0
                            col: 0
                    console.log "pushed marker"

        # set init value of code and clear predefined selection
        $scope.editor.setValue($scope.item.content)
        $scope.editor.clearSelection()


        # for inline editing
        $scope.disabled = true

        # set init coding language, font size and theme
        extension_id = $scope.getExtensionId( $scope.item.extension )

        $scope.settings.extension =
            $scope.settings.available_extensions[extension_id]
        $scope.settings.font_size = AceSettingsService.font_size
        $scope.settings.theme = AceSettingsService.theme

        $scope.setEditorExtension( $scope.settings.extension.value )
        $scope.setEditorFontSize( $scope.settings.font_size.value )
        $scope.setEditorTheme( $scope.settings.theme.value )

        # observe 'change' event
        $scope.editor.session.doc.on 'change', (e) ->
            if !$scope.block

                RTCService.broadcastCodeDocumentHasChanged(
                    e.data,
                    $scope.item.id,
                    $scope.user
                )

            $scope.block = false

            # update model
            $scope.item.content = $scope.editor.getValue()
            $scope.item.size = $scope.editor.session.getLength()
            $scope.$apply() if !$scope.$$phase
            $scope.item.last_edited = new Date()

            # console.log $scope.item.content
            # $scope.dataUrl = window.btoa $scope.item.content

            if e.data.range.start.row <= 5 or e.data.range.end.row <= 5
                $scope.updateThumbnail()
                change =
                    thumbnail: $scope.item.thumbnail
                    content: $scope.item.content
                RTCService.sendCodeItemHasChanged(
                    change, $scope.item.id, $scope.user.isMaster )

        $scope.editor.selection.on "changeCursor", ->
            RTCService.broadcastCursorHasChanged(
                $scope.editor.selection.getCursor(), $scope.user, $scope.item.id
            )


        # watch changes on coding language and update editor
        $scope.$watch "settings.extension", (option, old_option) ->
            if option.value is ""
                $scope.settings.extension = old_option
                return
            $scope.setEditorExtension( option.value )
            $scope.item.extension = option.extension
            change =
                extension: option.extension
            RTCService.sendCodeItemHasChanged(
                change, $scope.item.id, $scope.user.isMaster )
            return

        # watch changes on font size and update editor
        $scope.$watch "settings.font_size", (option) ->
            AceSettingsService.setFontSize(option)
            $scope.setEditorFontSize(option.value)

        # watch changes on theme and update editor
        $scope.$watch "settings.theme", (option) ->
            AceSettingsService.setTheme(option)
            $scope.setEditorTheme(option.value)

        $scope.$watch (->
            return $scope.item.name
        ), ((name) ->
            change =
                name: name
            RTCService.sendCodeItemHasChanged(
                change, $scope.item.id, $scope.user.isMaster )
        ), true

        $scope.$watch (->
            return $scope.item.extension
        ), ((extension) ->
            if $scope.item.extension is $scope.settings.extension.value
                return
            if extension? and extension.length isnt 0
                extension_id = $scope.getExtensionId( $scope.item.extension )

                $scope.settings.extension =
                    $scope.settings.available_extensions[extension_id]
        ), true

        $scope.$watch (->
            return $scope.item.contributors
        ), ((contributors) ->
            for contributor in contributors
                continue if contributor.id is $scope.user.id
                found = false
                for marker, index in $rootScope.markers
                    if marker.contributorId is contributor.id
                        console.log "FOUND"
                        found = true
                        if !contributor.active
                            $scope.editor.session.removeMarker marker.marker
                            $rootScope.markers.splice(index, 1) # remove inactive marker

                if !found and contributor.active
                    $rootScope.markers.push
                        contributorId: contributor.id
                        marker: $scope.editor.session.addMarker(
                            new Range(), "marker" + contributor.id, "text", true
                        )
                        cursor:
                            row: 0
                            col: 0
                    console.log "pushed marker"
                    console.log "MARKERS", $rootScope.markers


        )

        $scope.$watch (->
            return AceSettingsService.font_size
        ), ((font_size) ->
            $scope.settings.font_size = font_size
        ), true

        $scope.$watch (->
            return AceSettingsService.theme
        ), ((theme) ->
            $scope.settings.theme = theme
        ), true

        $scope.$watch (->
            return $scope.item.deltas
        ), ((deltas) ->
            console.log "got new deltas, apply: ", deltas
            if deltas? and deltas.length isnt 0
                $scope.block = true
                $scope.editor.session.doc.applyDeltas [deltas]
                $scope.item.deltas = ""
        ), true

        $rootScope.markersChanged = false

        $scope.$watch (->
            return $rootScope.markers
        ), ((markers) ->
            if $rootScope.markersChanged
                for marker in markers
                    $scope.editor.session.removeMarker( marker.marker )

                    row = marker.cursor.row
                    col = marker.cursor.column
                    marker.marker = $scope.editor.session.addMarker(
                        new Range(row, col, row, col + 1),
                        "marker" + marker.contributorId, "text", true
                    )
                $rootScope.markersChanged = false
        ), true

        # set contributor to false
        $scope.$on "$routeChangeStart", (scope, next, current) ->

            $rootScope.markers = []
            if current.scope.item.id?
                SharesService.setContributorInactive(current.scope.item.id,
                    current.scope.user.id)
                change =
                    contributors: current.scope.item.contributors

                RTCService.sendCodeItemHasChanged(
                    change, current.scope.item.id, current.scope.user.isMaster )

]
