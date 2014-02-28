class bud.widgets.PopupTrigger extends bud.Widget
  @SELECTOR: '.PopupTrigger'

  initialize: ->
    @target_id = @$container.data('target')
    @$container.click @on_click

  on_click: =>
    $.publish("popup.toggle.#{@target_id}")
    false
