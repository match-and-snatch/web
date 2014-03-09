class (window.bud or= {}).Core
  initialized: false

  @instance: ->
    @__instance or= new Core()

  @initialize: ->
    if @instance().initialized
      bud.Logger.error('Core already initialized')
      return

    @instance().__initialize()
    bud.pub('bud.Core.initialized')

  @init_widgets: (parent_container) ->
    _.each window.bud.widgets, (widget_class) ->
      try
        widget_class.init(parent_container)
      catch error
        bud.Logger.error(error)

  __initialize: ->
    bud.Core.init_widgets()
    @initialized = true
