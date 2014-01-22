# ### User Config
# The userconfig file *must not be in your repository* cause it contains
# sensible data like database login data or user specific settings
# (e.g. local databse).
userconfig = require "../userconfig"

config = {}

config.sessionSecret = userconfig.sessionSecret
config.appName       = userconfig.appName

config.DEBUG_LOG = true
config.DEBUG_WARN = true
config.DEBUG_ERROR = true

# ### Config file
# Sets application config parameters depending on `env` name
config.setEnvironment = (env) ->
  console.log "set app environment: #{env}"

  switch(env)
    when "development"
      config.DEBUG_LOG = true
      config.DEBUG_WARN = true
      config.DEBUG_ERROR = true

    when "testing"
      config.DEBUG_LOG = true
      config.DEBUG_WARN = true
      config.DEBUG_ERROR = true

    when "production"
      config.DEBUG_LOG = false
      config.DEBUG_WARN = false
      config.DEBUG_ERROR = true

    else
      console.log "environment #{env} not found"

module.exports = config
