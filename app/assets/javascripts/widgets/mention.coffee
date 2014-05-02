class bud.widgets.Mention extends bud.Widget
  @SELECTOR: '.Mention'

  initialize: ->
    @$container.click(@on_click)

  on_click: =>
    bud.pub('mention.clicked', [@$container.data()])