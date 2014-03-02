class bud.widgets.PopupTrigger extends bud.Widget
  @SELECTOR: '.PopupTrigger'

  initialize: ->
    @identifier = @$container.data('identifier')
    @$container.click @on_click

  on_click: =>
    bud.pub("popup.toggle.#{@identifier}")
    false
