class bud.widgets.Autofocus extends bud.Widget
  @SELECTOR: '.Autofocus'

  initialize: ->
    if @$container.is('input,textarea,select')
      @$container.focus()
    else
      @$container.find('input,textarea,select:first').focus()