class bud.widgets.Slider extends bud.Widget
  @SELECTOR: '.Slider'

  initialize: ->
    @$lis = @$container.children('li')
    @$lis.hide()
    @$current_li = $(@$lis[0])
    @$current_li.show()
    @interval = @data('interval') || 3000
    @$lis.on('toggle', @on_toggle)
    setTimeout(@iterate, @interval)

  on_toggle: (e) =>
    if $(e.currentTarget).is(':visible')
      clearTimeout(@timeout) if @timeout
      @timeout = setTimeout(@iterate, @interval)

  iterate: =>
    @$current_li.hide()
    @$current_li = @$current_li.next('li')
    @$current_li = $(@$lis[0]) if @$current_li.length < 1
    @blocked = false
    @$current_li.show()
