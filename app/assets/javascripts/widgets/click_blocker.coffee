class bud.widgets.ClickBlocker extends bud.Widget
  @SELECTOR: '#ClickBlocker'

  initialize: ->
    bud.sub('bud.Core.initialized', @disable)

  disable: =>
    @$container.hide()

  enable: =>
    @$container.show()
