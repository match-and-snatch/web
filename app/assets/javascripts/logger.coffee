class bud.Logger
  @instance: ->
    @__instance or= new bud.Logger(window.bud.config.log_level)

  @error:   (text) -> @instance().error(text)
  @warning: (text) -> @instance().warning(text)
  @message: (text) -> @instance().message(text)

  constructor: (log_level) -> @log_level = log_level || 0

  error:   (text) -> console.error(text) if @log_level >= 1
  warning: (text) -> console.warn(text)  if @log_level >= 2
  message: (text) -> console.log(text)   if @log_level >= 3
