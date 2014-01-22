fs            = require "fs"
wrench        = require "wrench"
{print}       = require "util"
which         = require "which"
{spawn, exec} = require "child_process"
pty           = require "pty.js"
linter        = require "coffeelint"
async         = require "async"

lintConfig    = require "./coffeelint.json"


{error, warn, info, infoSuccess, infoFail} = require "./modules/debug"

debug_port    = 8989
dirs          =
  "coffee": [
    "./modules"
    "./assets/js"
  ],
  "styl": [
    "./assets/css"
  ],
  "views": [
    "./views"
  ]



# ANSI Terminal Colors
bold           = "\x1B[0;1m"
reset          = "\x1B[0;m"

red            = "\x1B[0;31m"
bright_red     = "\x1B[0;1;31m"

green          = "\x1B[0;32m"
bright_green   = "\x1B[0;1;32m"

blue           = "\x1b[0;34m"
bright_blue    = "\x1B[0;1;34m"

brown          = "\x1B[0;33m"
bright_brown   = "\x1B[0;1;33m"

magenta        = "\x1B[0;35m"
bright_magenta = "\x1B[0;1;35m"

cyan           = "\x1B[0;36m"
bright_cyan    = "\x1B[0;1;36m"

gray           = "\x1B[1;30m"
bright_gray    = "\x1B[0;0;37m"

good = "✓"
warning = "⚡"
bad = "✗"


# ---
# print unused exceptions
process.on "uncaughtException", ( err ) ->
  error "OMG :-S"
  error "caught 'uncaught' exception: " + err


# ---
# simple log function
log = ( message, color, explanation ) ->
  console.log color + message + reset + " " + (explanation or "")

# ---
# #getCoffeeFiles()
# >get all CoffeeScript Files
getCoffeeFiles = ->
  coffeeFiles = []

  for dir in dirs.coffee
    for file in wrench.readdirSyncRecursive dir when /\.coffee$/.test file
      coffeeFiles.push "#{dir}/#{file}"

  return coffeeFiles


# ---
# #build( successCallback, failCallback )
# >build CoffeeScript Files into .app directory
build = ( callback ) ->
  log "cooking coffee ...", blue

  options = ["-c","-b", "-o", ".app"].concat dirs.coffee

  cmd = which.sync "coffee"

  coffee = spawn cmd, options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr

  coffee.on "exit", ( status ) ->
    if status is 0
      log "Coffee is ready, enjoy it!", green
      callback null
    else
      log "Wasn't able to cook coffee: ", red
      callback status


# ---
# #lintSingleFile( data, config, callback )
# >lint a single File, return result
lintSingleFile = ( data, config, callback ) ->
  results = linter.lint data, config

  if results.length > 0
    for result in results
      if result.level is "warn"
        console.log """
          \t#{magenta}#{result.lineNumber}:#{reset} #{cyan}#{result.message}#{reset}
        """
      else if result.level is "error"
        console.log """
          \t#{magenta}#{result.lineNumber}:#{reset} #{red}#{result.message}#{reset}
        """
    callback results
  else
    callback null



# ---
# #lint( callback )
# >lint all coffee files
lint = ( callback ) ->
  coffeeFiles = getCoffeeFiles()

  lintFuncs = []

  for file in coffeeFiles
    do (file) ->
      lintFuncs.push (cbInner) ->
        console.log """
          #{cyan}linting... #{reset}#{gray}#{file}
        """
        fs.readFile file, (err, data) ->
          cbInner(err) if err
          lintSingleFile data.toString(), lintConfig, (result) ->
            cbInner null, result


  #then lint each file
  async.series lintFuncs, (err, result) ->
    # warnings, errors
    warnings = 0
    errors   = 0
    for lint_result in result
      continue if lint_result is undefined or lint_result is null
      for single_result in lint_result
        warnings +=1 if single_result.level is "warn"
        errors   +=1 if single_result.level is "error"
    callback
      "warnings": warnings
      "errors":   errors


# ---
# #Task _build_
# >Compiles app.coffee and src directory to the .app directory
task "build"
, "compiles coffeescript files to javascript into the .app directory", ->

  log "linting files ...", blue
  lint (result) ->
    if result.errors > 0 or result.warnings > 0
      console.log """
        \n\rresult:
        \t#{cyan}#{result.warnings} warnings#{reset}, #{red}
        \t#{result.errors} errors

      """
      log "the coffee beans look like mud :(\n\r", red
    else
      log "this coffee beans are high quality shit :)\n\r", green

      build(
        # build was successful
        ->
          log ":)", green
        ,
        # build failed
        (err) -> log err + " :(", red
      )

# ---
# #Task _lint_
# >lints all CoffeeScript files
task "lint", "lints all coffeescript files", ->
  log "linting files ...", blue
  lint (result)->
    console.log """
      \n\rresult:
      \t#{cyan}#{result.warnings} warnings#{reset},
      \t#{red}#{result.errors} errors
    """


# ---
# #Task _docs_
# >generates annotated source code with Docco and move it to public dir
task "docs"
, "generates annotated source code with Docco and move it to public dir", ->
  build(
    ->

      # build was successful
      log ":)", green

      coffeeFiles = getCoffeeFiles()

      log "Coffee Files: ", bright_blue
      log "\t" + file, bright_green for file in coffeeFiles

      coffeeFiles.push "README.md"
      coffeeFiles.push "--out"
      coffeeFiles.push "./docs"

      # generate docs
      try
        cmd = which.sync "groc"
        groc = spawn cmd, coffeeFiles

        # pipe stdout & stderr to process
        groc.stdout.pipe process.stdout
        groc.stderr.pipe process.stderr
        groc.on "exit", (status) -> callback?() if status is 0
      catch err
        log err.message, red
        log "Groc is not installed - try npm install -g groc", red
  ,
    #build failed
    (err) -> log err + " :(", red
  )


#
# watches coffee, js and html files
#
task "dev", "run 'build' task, start dev env", ( options ) ->
  build(
    ->
      # build was successful
      log ":)", green

      # watch coffee files, automatically compile them
      options = ["-c", "-b", "-w", "-o", ".app", "modules"]
      cmd = which.sync "coffee"
      coffee = spawn cmd, options
      coffee.stdout.pipe process.stdout
      coffee.stderr.pipe process.stderr

      log "Watching coffee files", green
      # watch js and html files and restart server if changes happend
      supervisor = spawn "node", [
        "./node_modules/supervisor/lib/cli-wrapper.js",
        "-w",
        ".app,views",
        "-e",
        "js|html",
        "app"
      ]
      supervisor.stdout.pipe process.stdout
      supervisor.stderr.pipe process.stderr
      log "Watching js files and running server", green
  ,
    # build failed
    (err) -> log err + " :(", red
  )


#
# watches coffee, js and html files and starts the node inspector
#
task "debug", "run 'build' task, start debug env", ( options ) ->
  build(
    ->
      # build was successful
      log ":)", green

      # watch coffee files, automatically compile them
      options = ["-c", "-b", "-w", "-o", ".app", "modules"]
      cmd = which.sync "coffee"
      coffee = spawn cmd, options
      coffee.stdout.pipe process.stdout
      coffee.stderr.pipe process.stderr
      log "Watching coffee files", green

      # run debug mode
      app = spawn "node", [
        "--debug",
        "app"
      ]
      app.stdout.pipe process.stdout
      app.stderr.pipe process.stderr

      # run node-inspector
      inspector = spawn "node-inspector", ["--web-port=" + debug_port]
      inspector.stdout.pipe process.stdout
      inspector.stderr.pipe process.stderr

      # run google chrome
      chrome = spawn "google-chrome"
      , ["http://localhost:" + debug_port + "/debug?port=5858"]

      chrome.stdout.pipe process.stdout
      chrome.stderr.pipe process.stderr
      log "Debugging server", green
  ,
    #build failed
    (err) -> log err + " :(", red
  )


#
# runs the production environment
#
task "run", "run 'build' task, start production env", ( options ) ->
  build(
    ->
      # build was successful
      log ":)", green

      # start app in production environment
      cmd = spawn "node", ["app"],
        env:
          NODE_ENV: "production"
      cmd.stdout.pipe process.stdout
      cmd.stderr.pipe process.stderr
      log "Running Server in production environment", green
  ,
    # build failed
    (err) -> log err + " :(", red
  )
