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
        bud.Widget.destroy(widget_container)
      catch error
        bud.Logger.error(error)

  __initialize: ->
    bud.Core.init_widgets()

    # BROWSER EVENTS
    $(window).on 'hashchange', -> bud.pub('window.hashchange')
    $(window).on 'popstate', -> bud.pub('window.locationchange')
    $(document).on 'touchstart', (e) ->
      bud.pub('document.touchstart', [$(e.currentTarget)])

    # KEYBINDINGS
    $(document).on 'keyup', (e) ->
      if e.keyCode == 27
        bud.pub('keyup.esc')

    @initialized = true
