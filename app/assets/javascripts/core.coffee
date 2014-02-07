class (window.bud or= {}).Core
  initialized: false

  @instance: ->
    @__instance or= new Core()

  @initialize: ->
    if @instance().initialized
      bud.Logger.error('Core already initialized')
      return

    @instance().__initialize()

  __initialize: ->
    @__init_widgets()
    @initialized = true

  __init_widgets: ->
    _.each window.bud.widgets, (widget_class) ->
      try
        widget_class.init()
      catch error
        bud.Logger.error(error)
