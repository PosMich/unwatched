# Unwatched - RTC Service
# ============================

"use strict"

app = angular.module "unwatched.services"

app.service "FileService", [
    "$rootScope"
    "RoomService"
    "SharesService"
    ($rootScope, RoomService, SharesService) ->

        console.log "file"

        @fileSystem = undefined
        @root = undefined
        @roomDir = undefined

        @initFs = ->
            window.requestFileSystem = window.requestFileSystem ||
                window.webkitRequestFileSystem

            navigator.webkitPersistentStorage.requestQuota(
                1024 * 1024 * 1024 * 5
                (grantedBytes) =>
                    window.requestFileSystem(
                        window.PERSISTENT
                        grantedBytes
                        @onInitFs
                        @onErrorFs
                    )
                (e) ->
                    console.log 'Error', e
            )

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


        @createDirectory = (baseDir, name, callback) ->
            baseDir.getDirectory(
                name
                { create: true }
                (dir) ->
                    console.log "successfully created directory '" + baseDir +
                        "/" + name + "'"
                    callback(dir)
                (error) ->
                    console.log "failed to created directory", error
                    callback(false)
            )


        @createFile = (baseDir, name, callback) ->
            baseDir.getFile(
                name
                { create: true }
                (fileEntry) ->
                    console.log "successfully created fileEntry '" + baseDir +
                        "/" + name + "'"
                    callback(fileEntry)
                (error) ->
                    console.log "failed to created directory", error
                    callback(false)
            )

        @saveFile = (id, file) ->

            reader = new FileReader()
            item = SharesService.get(id)

            name = item.originalName
            size = item.size

            console.log "item size " + size
            console.log "file size " + file.size

            updateProgress = (currentSize) ->

                item.progress = Math.round( currentSize / size * 100 )

                if item.progress >= 100
                    item.progress = 100

                console.log "updated progress to " + item.progress

                $rootScope.$apply() if !$rootScope.$$phase

            writer = (fileEntry) =>
                console.log "WRITER :: fileEntry", fileEntry
                fileEntry.createWriter(
                    (fileWriter) =>

                        CHUNK_SIZE = 1024 * 1024 * 5
                        i = 0
                        start = i * CHUNK_SIZE

                        console.log "trying to write data"

                        reader.readAsArrayBuffer file.slice( start,
                            start + CHUNK_SIZE )

                        reader.onload = (e) ->

                            fileWriter.seek( fileWriter.length )
                            fileWriter.write(new Blob(
                                [e.target.result]
                            ))

                        fileWriter.onwritestart = (e) ->
                            console.log "started writing", e

                        fileWriter.onwriteend = (e) =>
                            console.log "finished writing, next " +
                                "step = " + (i * CHUNK_SIZE)
                            i++
                            start = i * CHUNK_SIZE

                            updateProgress(start)

                            if start < file.size
                                reader.readAsArrayBuffer file.slice(
                                    start, start + CHUNK_SIZE )
                            else
                                console.log "finished writing 100% :D"
                                @setURL(id)


                        fileWriter.onerror = (error) ->
                            console.log "filewriter error", error
                            console.log "error was" + fileWriter.error.message

                    (error) ->
                        console.log "error on create writer", error
                )

            @createDirectory(
                @roomDir
                id.toString()
                (dir) =>
                    if !dir
                        return
                    @createFile(
                        dir
                        name
                        (fileEntry) =>
                            if !fileEntry
                                return
                            console.log "created fileEntry", fileEntry
                            writer(fileEntry)

                    )
            )

        @setURL = (id) ->
            item = SharesService.get( id )
            room = RoomService.id.toString() + "/" + id
            filename = room + "/" + item.originalName

            @root.getFile(
                filename
                {}
                (file) ->
                    item.content = file.toURL()
                    console.log "changed item content to url: " + item.content
            )

        @deleteFile = (id) ->
            item = SharesService.get( id )
            room = RoomService.id.toString() + "/" + id
            filename = room + "/" + item.originalName

            @root.getFile(
                filename
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
