class bud.widgets.SearchTag extends bud.Widget
  @SELECTOR: '.SearchTag'

  initialize: ->
    @tag = @$container.data('tag')
    @target = bud.get(@$container.data('target')).data('jsWidget')
    @$container.click(@on_click)

  on_click: =>
    @target.input.val("##{@tag}")
    @target.form.submit()
    bud.pub('search.changed', [@target.input.val()])
    false
