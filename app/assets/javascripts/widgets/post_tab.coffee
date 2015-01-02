class bud.widgets.PostTab extends bud.Widget
  @SELECTOR: '.PostTab'

  initialize: ->
    if $(bud.widgets.PostTab.SELECTOR).filter('.active').length < 1
      @$container.addClass('active')

    @$container.click @on_click
    bud.sub('attachment.uploading', @halt)
    bud.sub('attachment.uploaded', @restore)

  destroy: ->
    bud.unsub('attachment.uploading', @halt)
    bud.unsub('attachment.uploaded', @restore)

  restore: =>
    @uploading = false

  halt: =>
    @uploading = true

  on_click: =>
    if @uploading
      bud.confirm 'Are you sure you want to change the tab? It will stop uploading process.', @change_tab
    else
      @change_tab()

  change_tab: =>
    $(bud.widgets.PostTab.SELECTOR).removeClass('active')
    @$container.addClass('active')
    bud.pub('PostTab.changed', [@$container])
