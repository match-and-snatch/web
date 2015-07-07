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
      bud.sub('keyup.esc', @on_esc)

      if bud.is_mobile.any()
        @$container.on 'touchstart', @on_click
      else
        @$container.click @on_click

  destroy: ->
    bud.unsub('popup.show.overlay', @show)
    bud.unsub('popup.hide.overlay', @hide)

  on_esc: =>
    if @$container.is(':visible')
      @on_click()

  on_click: (e) =>
    if bud.is_mobile.any()
      e.stopPropagation()
      e.preventDefault()
    bud.pub("popup.show")
    @hide()

  show: =>
    $('body').css('overflow', 'hidden') unless bud.is_mobile.any()
    @$container.show()

  hide: =>
    $('body').css('overflow', 'visible')
    @$container.hide()
