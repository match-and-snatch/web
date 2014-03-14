# Generally used for popups
class bud.widgets.Overlay extends bud.Widget
  @SELECTOR: '.Overlay'

  @instance: ->
    bud.widgets.Overlay.__instance ?= new bud.widgets.Overlay($(@SELECTOR))

  initialize: ->
    unless bud.widgets.Overlay.__instance
      bud.widgets.Overlay.__instance = @
      bud.sub('popup.show.overlay', @show)
      bud.sub('popup.hide.overlay', @hide)

  show: => @$container.show()
  hide: => @$container.hide()
