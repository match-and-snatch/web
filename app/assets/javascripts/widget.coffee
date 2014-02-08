bud.widgets or= {}

class bud.Widget
  @instances: []
  @SELECTOR: null

  @init: (parent_container = $('body')) ->
    widget_class = @

    parent_container.find(widget_class.SELECTOR).not('.js-widget').each (index, container) ->
      new widget_class($(container))

  @highlight_all:   -> $('.js-widget').addClass('js-highlight')
  @dehighlight_all: -> $('.js-widget').removeClass('js-highlight')

  constructor: (container) ->
    if container.hasClass('js-widget')
      bud.Logger.error("Widget: #{@class_name()} already initialized")
      return

    @container = container

    @initialize()

    @container.addClass('js-widget')
    bud.Logger.message("Widget: #{@class_name()} initialized")

    bud.Widget.instances.push(@)

  class_name: -> @.__proto__.constructor.name

  initialize: ->
    # To be redeclared in inherited classes
