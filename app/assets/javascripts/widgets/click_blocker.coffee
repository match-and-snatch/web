# Prevents a page from any clicks before core is initialized
class bud.widgets.ClickBlocker extends bud.Widget
  @SELECTOR: '#ClickBlocker'

  initialize: ->
    bud.sub('bud.Core.initialized', @disable)

  destroy: ->
    bud.unsub('bud.Core.initialized', @disable)

  disable: =>
    @$container.hide()

  enable: =>
    @$container.show()
