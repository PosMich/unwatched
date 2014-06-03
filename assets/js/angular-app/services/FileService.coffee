# Unwatched - RTC Service
# ============================

"use strict"

app = angular.module "unwatched.services"

app.service "FileService", [
    "$rootScope"
    "RoomService"
    ($rootScope, RoomService) ->

        @fileSystem = undefined
        @root = undefined
        @roomDir = undefined

        @initFs = ->
            window.requestFileSystem = window.requestFileSystem ||
                window.webkitRequestFileSystem

            window.requestFileSystem window.TEMPORARY,
                1024,
                @onInitFs,
                @onErrorFs

        @onInitFs = (fs) =>
            console.log "created file-system " + fs.name + ":"
            console.log fs
            @fileSystem = fs
            @root = @fileSystem.root
            @root.getDirectory(
                RoomService.id.toString()
                { create: true }
                (dir) =>
                    @roomDir = dir
                (error) ->
                    console.log "error on dir create", error
            )

        @onErrorFs = (error) ->
            if error.code is FileError.QUOTA_EXCEEDED_ERR
                console.log "quota exceeded"

        @getFile = (id) ->
            console.log "roomDir is " + @roomDir
            @roomDir.getFile(
                id.toString()
                {}
                (file) ->
                    console.log "got file ", file
                    file
            )

        @createFile = (id, file) ->
            @roomDir.getFile(
                id.toString()
                { create: true }
                (fileEntry) ->
                    console.log "created fileEntry", fileEntry
                    fileEntry.createWriter(
                        (fileWriter) ->
                            fileWriter.write(file)
                            fileWriter.onwriteend = (e) ->
                                console.log e.toString()
                            fileWriter.onerror = (error) ->
                                console.log error.toString()
                        (error) ->
                            console.log "error on create writer", error
                    )

                (error) ->
                    console.log "error creating fileEntry", error
            )

        @deleteFile = (id) ->
            @roomDir.getFile(
                id.toString()
                { create: false }
                (file) ->
                    file.remove(
                        ->
                            console.log "file successfully removed"
                        (error) ->
                            console.log "error on file remove", error
                    )
                (error) ->
                    console.log "was not able to get file due:", error
            )

        @suicide = ->
            @roomDir.removeRecursively(
                ->
                    console.log "successfully removed room dir"
                (error) ->
                    console.log "error on room dir removal", error
            )
            @roomDir = undefined

        return


]
