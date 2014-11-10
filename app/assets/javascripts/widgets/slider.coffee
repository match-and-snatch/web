class bud.widgets.Slider extends bud.Widget
  @SELECTOR: '.Slider'

  initialize: ->
    @$lis = @$container.find('li')
    @$lis.hide()
    @$current_li = $(@$lis[0])
    @$current_li.show()
    @interval = @data('interval') || 3000
    setTimeout(@iterate, 100)

  iterate: =>
    setInterval( =>
      @$current_li.hide()
      @$current_li = @$current_li.next('li')
      @$current_li = $(@$lis[0]) if @$current_li.length < 1
      @$current_li.show()
    , @interval)
