# Toggles target's visibility.
class bud.widgets.TemporalHider extends bud.Widget
  @SELECTOR: '.TemporalHider'

  initialize: ->
    @$target = bud.get(@$container.data('target')) || @$container
    @$container.click @on_click

  on_click: =>
    @$target.removeClass('slidedown').addClass('slideup')
    @set_cookie()

  set_cookie: ->
    now = new Date()
    time = now.getTime() + 86400000
    now.setTime(time)

    document.cookie = "promo_block_hidden=true;expires=#{now.toUTCString()};path=/"
