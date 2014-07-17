# Once clicked, changes hash in url instead of navigating to link
class bud.widgets.HashLink extends bud.Widget
  @SELECTOR: '.HashLink'

  initialize: ->
    @href = @$container.attr('href')
    @hash = @href
    @default = @data('default')

    @location_changed()
    bud.sub('window.hashchange', @location_changed)

    @$container.click @link_clicked

  destroy: ->
    bud.unsub('window.hashchange', @location_changed)

  location_changed: =>
    if window.location.hash.match("##{@hash}")
      @$container.addClass('active')
    else if _.isEmpty(window.location.hash) && @default
      window.location.hash = @hash
    else
      @$container.removeClass('active pending')

  link_clicked: =>
    if "##{@hash}" != window.location.hash
      $(bud.widgets.HashLink.SELECTOR).removeClass('active pending')
      window.location.hash = @hash

    return false

