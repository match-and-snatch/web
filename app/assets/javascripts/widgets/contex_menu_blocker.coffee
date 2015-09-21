# prevent context menu on right click
class bud.widgets.ContextMenuBlocker extends bud.Widget
  @SELECTOR: '.ContextMenuBlocker'

  initialize: ->
    @$container.contextmenu @on_context_menu

  on_context_menu: (e) =>
    e.preventDefault()
