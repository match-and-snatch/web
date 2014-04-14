class bud.widgets.PostForm extends bud.Widget
  @SELECTOR: '.PostForm'

  initialize: ->
    @pending_post_url = @$container.data('url')
    @$target = bud.get(@$container.data('target'))
    bud.sub('PostTab.changed', @on_tab_changed)

  on_tab_changed: (e, $tab_element) =>
    if @$current_tab != $($tab_element)
      @$current_tab = $($tab_element)
      @save_post_data()

  save_post_data: ->
    params = {'_method': 'PUT'}

    title_container = @$container.find('input[name=title]')
    if title_container.length > 0
      params['title'] = title_container.val()

    keywords_container = @$container.find('input[name=keywords]')
    if keywords_container.length > 0
      params['keywords'] = keywords_container.val()

    message_container = @$container.find('textarea[name=message]')
    if message_container.length > 0
      params['message'] = message_container.val()

    bud.Ajax.post @pending_post_url, params, success: =>
      bud.Ajax.get(@$current_tab.data('url'), {}, replace: @on_render_form)

  on_render_form: (response) =>
    bud.replace_html(@$target, response['html'])
