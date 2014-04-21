class bud.widgets.AutocompleteField extends bud.Widget
  @SELECTOR: '.AutocompleteField'

  initialize: ->
    @url = @$container.data('url')
    @$target = bud.get(@$container.data('target'))
    @$container.val('')

    @$container.on 'keyup', (e) =>
      if e.which == 27
        @$container.val('')
        bud.replace_html(@$target, '')

    @$container.on 'input', @perform_request

  perform_request: =>
    bud.Ajax.get(@url, {q: @query()}, {replace: @on_replace})

  query: ->
    @$container.val()

  on_replace: (response) =>
    bud.replace_html(@$target, response['html'])
