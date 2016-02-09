#= require ./cleaner

class bud.widgets.SearchCleaner extends bud.widgets.Cleaner
  @SELECTOR: '.SearchCleaner'

  initialize: ->
    super
    @target = bud.get(@$container.data('target')).data('jsWidget')

  on_click: =>
    @target.input.val("")
    @target.form.submit()
    bud.pub('search.changed', [@target.input.val()])
    false
