#= require ./popup

class bud.widgets.RemotePopup extends bud.widgets.Popup
  @SELECTOR: '.RemotePopup'

  initialize: ->
    super
    bud.sub("remote_popup.show", @arise)

  destroy: ->
    bud.unsub("remote_popup.show", @arise)

  arise: (e, html) =>
    @show()
    bud.replace_html(@$container, html)
