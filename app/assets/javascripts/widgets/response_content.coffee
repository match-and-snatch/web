class bud.widgets.ResponseContent extends bud.Widget
  @SELECTOR: '.ResponseContent'

  initialize: ->
    bud.sub("response_content.show", @arise)

  destroy: ->
    bud.unsub("response_content.show", @arise)

  arise: (e, html) =>
    bud.append_html(@$container, html) if @$container.is(':empty')
