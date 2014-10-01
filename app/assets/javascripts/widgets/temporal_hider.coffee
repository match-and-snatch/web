#= require ./toggler

# Toggles target's visibility and set cookies for 24h.
class bud.widgets.TemporalHider extends bud.widgets.Toggler
  @SELECTOR: '.TemporalHider'

  on_click: =>
    @set_cookie()
    super

  set_cookie: ->
    now = new Date()
    time = now.getTime() + 86400000
    now.setTime(time)
    document.cookie = "promo_block_hidden=true;expires=#{now.toUTCString()};path=/"

  toggle: ->
    @$target.removeClass('slidedown').addClass('slideup')
