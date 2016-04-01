#= require ./toggler

class bud.widgets.EditMenu extends bud.widgets.Toggler
  @SELECTOR: '.EditMenu'

  initialize: ->
    super
    bud.sub('menu.opened', @close_menu)

  destroy: ->
    bud.unsub('menu.opened', @close_menu)

  on_click: =>
    @toggle()

    if @$target.is(':visible')
      bud.pub('menu.opened', [@$target])

    return false if @$container.is('a')
    return true

  close_menu: (e, menu) =>
    if menu.selector != @$target.selector
      @$target.hide()
