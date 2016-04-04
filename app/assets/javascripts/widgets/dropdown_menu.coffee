#= require ./toggler

class bud.widgets.DropdownMenu extends bud.widgets.Toggler
  @SELECTOR: '.DropdownMenu'

  initialize: ->
    super
    bud.sub('menu.opened', @close_menu)

  destroy: ->
    bud.unsub('menu.opened', @close_menu)

  on_click: =>
    @toggle()

    if @$target.is(':visible')
      bud.pub('menu.opened', [@$target])

    return !@$container.is('a')
    return true

  close_menu: (e, menu) =>
    if menu.selector != @$target.selector
      @$target.hide()
