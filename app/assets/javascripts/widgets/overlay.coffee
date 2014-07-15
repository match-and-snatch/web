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
    @$container.click @on_click

  destroy: ->
    bud.unsub('popup.show.overlay', @show)
    bud.unsub('popup.hide.overlay', @hide)

  on_click: =>
    bud.pub("popup.show")
    @hide()

  show: =>
    $('body').css('overflow', 'hidden')
    @$container.show()

  hide: =>
    $('body').css('overflow', 'visible')
    @$container.hide()
