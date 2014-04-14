class bud.widgets.PostTab extends bud.Widget
  @SELECTOR: '.PostTab'

  initialize: ->
    if $(bud.widgets.PostTab.SELECTOR).filter('.active').length < 1
      @$container.addClass('active')

    @$container.click @on_click

  on_click: =>
    $(bud.widgets.PostTab.SELECTOR).removeClass('active')
    @$container.addClass('active')
    bud.pub('PostTab.changed', [@$container])
