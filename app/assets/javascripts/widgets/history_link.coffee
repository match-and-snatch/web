class bud.widgets.HistoryLink extends bud.Widget
  @SELECTOR: '.HistoryLink'

  initialize: ->
    @href = @$container.attr('href')
    @default = @data('default')
    @initialized_default = !@default

    @location_changed()
    bud.sub('window.locationchange', @location_changed)

    @$container.click @link_clicked

  destroy: ->
    bud.unsub('window.locationchange', @location_changed)

  location_changed: =>
    if window.location.href.match(@href)
      @$container.addClass('active')
    else if @default && !@initialized_default
      @link_clicked()
      @initialized_default = true
    else
      @$container.removeClass('active pending')

  link_clicked: =>
    if @href != window.location.href
      $(bud.widgets.HistoryLink.SELECTOR).removeClass('active pending')

      if @default && !@initialized_default
        bud.replace_url(@href)
      else
        bud.goto(@href)

    return false
