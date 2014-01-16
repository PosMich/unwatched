fs            = require "fs"
wrench        = require "wrench"
{print}       = require "util"
which         = require "which"
{spawn, exec} = require "child_process"
pty           = require "pty.js"
linter        = require "coffeelint"
lintConfig    =
  "coffeescript_error":
    "level": "error"
  "arrow_spacing":
    "name": "arrow_spacing",
    "level": "warn"
  "no_tabs":
    "name": "no_tabs",
    "level": "error"
  "no_trailing_whitespace":
    "name": "no_trailing_whitespace",
    "level": "warn",
    "allowed_in_comments": false,
    "allowed_in_empty_lines": true
  "max_line_length":
    "name": "max_line_length",
    "value": 80,
    "level": "warn",
    "limitComments": true
  "line_endings":
    "name": "line_endings",
    "level": "ignore",
    "value": "unix"
  "no_trailing_semicolons":
    "name": "no_trailing_semicolons",
    "level": "error"
  "indentation":
    "name": "indentation",
    "value": 2,
    "level": "error"
  "camel_case_classes":
    "name": "camel_case_classes",
    "level": "error"
  "colon_assignment_spacing":
    "name": "colon_assignment_spacing",
    "level": "warn",
    "spacing":
      "left": 0,
      "right": 1
  "no_implicit_braces":
    "name": "no_implicit_braces",
    "level": "ignore",
    "strict": true
  "no_plusplus":
    "name": "no_plusplus",
    "level": "ignore"
  "no_throwing_strings":
    "name": "no_throwing_strings",
    "level": "error"
  "no_backticks":
    "name": "no_backticks",
    "level": "error"
  "no_implicit_parens":
    "name": "no_implicit_parens",
    "level": "ignore"
  "no_empty_param_list":
    "name": "no_empty_param_list",
    "level": "warn"
  "no_stand_alone_at":
    "name": "no_stand_alone_at",
    "level": "ignore"
  "space_operators":
    "name": "space_operators",
    "level": "warn"
  "duplicate_key":
    "name": "duplicate_key",
    "level": "error"
  "empty_constructor_needs_parens":
    "name": "empty_constructor_needs_parens",
    "level": "ignore"
  "cyclomatic_complexity":
    "name": "cyclomatic_complexity",
    "value": 10,
    "level": "ignore"
  "newlines_after_classes":
    "name": "newlines_after_classes",
    "value": 3,
    "level": "ignore"
  "no_unnecessary_fat_arrows":
    "name": "no_unnecessary_fat_arrows",
    "level": "warn"
  "missing_fat_arrows":
    "name": "missing_fat_arrows",
    "level": "ignore"
  "non_empty_constructor_needs_parens":
    "name": "non_empty_constructor_needs_parens",
    "level": "ignore"



{error, warn, info, infoSuccess, infoFail} = require "./modules/debug"

debug_port    = 8989

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

# ---
# print unused exceptions
process.on "uncaughtException", (err) ->
  console.log "OMG :-S"
  console.log "caught 'uncaught' exception: " + err


pkg = JSON.parse fs.readFileSync("./package.json")
startCmd = pkg.scripts.start


log = (message, color, explanation) ->
  console.log color + message + reset + " " + (explanation or "")


build = (successCallback, failCallback) ->
  log "cooking coffee ...", blue
  options = ["-c","-b", "-o", ".app", "modules"]
  cmd = which.sync "coffee"
  coffee = spawn cmd, options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  coffee.on "exit", (status) ->
    if status is 0
      log "Coffee is ready, enjoy it!", green
      successCallback()
    else
      log "Wasn't able to cook coffee: ", red
      failCallback?( status)

lint = (source, successCallback, failCallback) ->
  log "linting files ...", magenta
  result = linter.lint " asdf = -> a+a", lintConfig
  console.log result


  successCallback()

#
# Compiles app.coffee and src directory to the .app directory
#
task "build"
, "compiles coffeescript files to javascript into the .app directory", ->
  build(
    # build was successful
    -> log ":)", green
  ,
    # build failed
    (err) -> log err + " :(", red
  )

task "t", ->
  lint "'./modules/debug.coffee'", ->
    console.log "finished"

task "lint", "lints all coffeescript files", ->
  try
    cmd = which.sync "coffeelint"

    files = [
      "./modules/"
      "./assets/js"
    ]

    linter = spawn cmd, files
    linter.stdout.pipe process.stdout
    linter.stderr.pipe process.stderr

    linter.on "exit", (status) -> callback?() if status is 0
  catch err
    log err.message, red
    log "coffeelint is not installed - try npm install -g coffeelint", red
#
# generates annotated source code with Docco and move it to public dir
#
task "docs"
, "generates annotated source code with Docco and move it to public dir", ->
  build(
    ->

      # build was successful
      log ":)", green


      # read in all coffee files from the "modules" directory
      moduleFiles = wrench.readdirSyncRecursive "modules"
      moduleFiles = (
        "modules/#{file}" for file in moduleFiles when /\.coffee$/.test file
      )

      appFiles = wrench.readdirSyncRecursive "assets/js"
      appFiles = (
        "assets/js/#{file}" for file in appFiles when /\.coffee$/.test file
      )

      log "Module Files: ", blue
      log "\t" + file, green for file in moduleFiles
      log "Asset Files: ", bright_blue
      log "\t" + file, bright_green for file in appFiles

      files = moduleFiles.concat appFiles

      files.push "README.md"
      files.push "--out"
      files.push "./docs"

      # generate docs
      try
        cmd = which.sync "groc"
        groc = spawn cmd, files

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
task "dev", "run 'build' task, start dev env", (options, cb) ->
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
task "debug", "run 'build' task, start debug env", (options, cb) ->
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
task "run", "run 'build' task, start production env", (options, cb) ->
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
