#= require ./toggler

# Toggles target's visibility and sets cookies for 24h.
class bud.widgets.MemoToggler extends bud.widgets.Toggler
  @SELECTOR: '.MemoToggler'

  on_click: =>
    @set_cookie()
    super

  set_cookie: ->
    cookie_name = @$target.data('storage_key')
    visible_state = !@$target.is(':visible')
    document.cookie = "#{cookie_name}=#{visible_state};expires=#{@cookie_expire_time()};path=/"

  toggle: ->
    @$target.toggleClass('slidedown').toggleClass('slideup')

  cookie_expire_time: ->
    now = new Date()
    time = now.getTime() + 86400000
    now.setTime(time)
    return now.toUTCString()
