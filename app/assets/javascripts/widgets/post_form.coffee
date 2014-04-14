class bud.widgets.PostForm extends bud.Widget
  @SELECTOR: '.PostForm'

  initialize: ->
    @$target = bud.get(@$container.data('target'))
    bud.sub('PostTab.changed', @on_tab_changed)

  on_tab_changed: (e, $tab_element) =>
    if @$current_tab != $($tab_element)
      @$current_tab = $($tab_element)
      bud.Ajax.get(@$current_tab.data('url'), {}, replace: @on_render_form)

  on_render_form: (response) =>
    bud.replace_html(@$target, response['html'])

