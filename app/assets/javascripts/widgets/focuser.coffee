class bud.widgets.Focuser extends bud.Widget
  @SELECTOR: '.Focuser'

  initialize: ->
    @$target = bud.get(@$container.data('target'))
    @$container.click @on_click
    
  on_click: =>
    @$target.focus()
    console.log @$container
    return false #!@$container.is('a')
