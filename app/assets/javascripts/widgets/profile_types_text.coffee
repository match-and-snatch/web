class bud.widgets.ProfileTypesText extends bud.Widget
  @SELECTOR: '.ProfileTypesText'

  initialize: ->
    bud.sub('profile_types.changed', @on_change)

  destroy: ->
    bud.unsub('profile_types.changed', @on_change)

  on_change: (e, text) =>
    bud.replace_html(@$container, text)
