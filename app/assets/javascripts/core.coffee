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

  @destroy_widgets: (parent_container) ->
    _.each parent_container.find('.js-widget'), (widget_container) ->
      try
        $widget_container = $(widget_container)
        widget = $widget_container.data('js-widget')
        window.bud.Widget.instances = _.without(window.bud.Widget.instances, widget)

        widget.destroy()
        delete $widget_container.data('js-widget')
        $widget_container.data('js-widget', null)
      catch error
        bud.Logger.error(error)

  __initialize: ->
    bud.Core.init_widgets()
    @initialized = true
