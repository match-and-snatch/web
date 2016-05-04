bud.widgets or= {}

class bud.Widget
  @instances: []
  @SELECTOR: null

  @init: (parent_container = $('body')) ->
    return unless @SELECTOR

    widget_class = @
    parent_container.find(widget_class.SELECTOR).not('.js-widget').each (index, container) ->
      new widget_class($(container), widget_class)

  @destroy: (widget_container) ->
    $widget_container = $(widget_container)
    widget = $widget_container.data('js-widget')
    return unless widget

    window.bud.Widget.instances = _.without(window.bud.Widget.instances, widget)
    $widget_container.removeClass('js-widget')
    widget.destroy()
    delete $widget_container.data('js-widget')
    $widget_container.data('js-widget', null)

  @highlight_all:   -> $('.js-widget').addClass('js-highlight')
  @dehighlight_all: -> $('.js-widget').removeClass('js-highlight')

  constructor: (container, klass) ->
    @klass = klass
    if container.hasClass('js-widget')
      bud.Logger.error("Widget: #{@class_name()} already initialized")
      return

    @$container = container

    @initialize()

    @$container.addClass('js-widget').data('js-widget', @)
    # bud.Logger.message("Widget: #{@class_name()} initialized")

    bud.Widget.instances.push(@)

  class_name: -> @klass

  initialize: ->
    # To be redeclared in inherited classes

  data: ->
    @$container.data.apply(@$container, arguments)

  get_target: (data_target_field = 'target') ->
    bud.get(@data(data_target_field))

  destroy: ->
    @$container.unbind()
    @$container.removeClass('js-widget')
    bud.Logger.message("Widget: #{@class_name()} destroying")

  # Optimizes jquery.getScript performance
  load_once: (src, callback) ->
    @klass.__ext_scripts or= {}
    return callback() if @klass.__ext_scripts[src]

    bud.Ajax.getScript(src).done =>
      (@klass.__ext_scripts[src] = callback)()

