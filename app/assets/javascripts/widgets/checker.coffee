class bud.widgets.Checker extends bud.Widget
  @SELECTOR: '.Checker'

  initialize: ->
    @checked_url   = @$container.data('checkedUrl')
    @unchecked_url = @$container.data('uncheckedUrl')
    @$container.change @on_change

  on_change: =>
    @$container.addClass('pending')
    url = if @$container.prop('checked') then @checked_url else @unchecked_url
    bud.Ajax.post(url, {_method: 'PUT'}, {success: @on_success})
    true

  on_success: =>
    @$container.removeClass('pending')
