# Unwatched - RTC Service
# ============================

"use strict"

app = angular.module "unwatched.services"

app.service "FileService", [
    "$rootScope"
    "RoomService"
    ($rootScope, RoomService) ->

        console.log "file"

        @fileSystem = undefined
        @root = undefined
        @roomDir = undefined

        @initFs = ->
            window.requestFileSystem = window.requestFileSystem ||
                window.webkitRequestFileSystem

            navigator.webkitTemporaryStorage.requestQuota(
                1024 * 1024 * 1024 * 5
                (grantedBytes) =>
                    window.requestFileSystem(
                        window.TEMPORARY
                        grantedBytes
                        @onInitFs
                        @onErrorFs
                    )
                (e) ->
                    console.log 'Error', e
            )

            # window.requestFileSystem window.PERSISTENT,
            #     1024 * 1024 * 1024 * 10 * 5,
            #     @onInitFs,
            #     @onErrorFs


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


        @saveFile = (id, file) ->

            reader = new FileReader()

            @roomDir.getFile(
                id.toString()
                { create: true }
                (fileEntry) ->
                    console.log "created fileEntry", fileEntry
                    fileEntry.createWriter(
                        (fileWriter) ->
                            CHUNK_SIZE = 1024 * 1024
                            i = 0
                            start = i * CHUNK_SIZE

                            console.log "trying to write data"

                            reader.readAsArrayBuffer file.slice( start, start + CHUNK_SIZE )

                            reader.onload = (e) ->

                                fileWriter.seek( fileWriter.length )
                                fileWriter.write(new Blob(
                                    [e.target.result]
                                ))

                            fileWriter.onwritestart = (e) ->
                                console.log "started writing", e

                            fileWriter.onwriteend = (e) ->
                                console.log "finished writing, next step = " + (i * CHUNK_SIZE)
                                i++
                                start = i * CHUNK_SIZE

                                if start < file.size
                                    reader.readAsArrayBuffer file.slice(
                                        start, start + CHUNK_SIZE )
                                else
                                    console.log "finished writing 100% :D"


                            fileWriter.onerror = (error) ->
                                console.log "filewriter error", error
                        (error) ->
                            console.log "error on create writer", error
                    )

                (error) ->
                    console.log "error creating fileEntry", error
            )






        @getFile = (id, callback) ->
            console.log "roomDir is " + @roomDir
            @roomDir.getFile(
                id.toString()
                {}
                (file) ->
                    callback(file)
                ->
                    callback(false)
            )

        @createFile = (id, fileSource) ->
            console.log "fileSource"

            # fileSource = new Uint8Array( fileSource )

            # myblob = new Blob( fileSource )


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
