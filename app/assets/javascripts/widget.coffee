bud.widgets or= {}

class bud.Widget
  @instances: []
  @SELECTOR: null

  @init: ->
    widget_class = @
    $(widget_class.SELECTOR).each (index, container) ->
      new widget_class($(container))

  constructor: (container) ->
    @container = container
    @data = @container.data()
    bud.Widget.instances.push(@)
    @.__proto__.constructor.instances.push(@)
    @initialize()
    bud.Logger.message("Widget: #{@.__proto__.constructor.name} initialized")

  initialize: ->
    # To be redeclared in inherited classes
