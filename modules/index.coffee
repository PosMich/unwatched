# The whole Project is compiled into the `.app` Folder.

# Due to we export the start method from the server module,
# a simple call to `require("./.app")()` starts the server.
module.exports = require("./server").start