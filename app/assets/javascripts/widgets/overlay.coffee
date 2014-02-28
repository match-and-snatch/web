class bud.widgets.Overlay extends bud.Widget
  @SELECTOR: '.Overlay'

  @instance: ->
    bud.widgets.Overlay.__instance ?= new bud.widgets.Overlay($(@SELECTOR))

  initialize: ->
    unless bud.widgets.Overlay.__instance
      bud.widgets.Overlay.__instance = @
      $.subscribe('popup.show.overlay', @show)
      $.subscribe('popup.hide.overlay', @hide)

  show: => @$container.show()
  hide: => @$container.hide()
