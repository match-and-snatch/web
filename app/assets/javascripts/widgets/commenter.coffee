#= require ./form

# Appends HTML to a target container once form is posted
# @data target [String] Target identifier
class bud.widgets.Commenter extends bud.widgets.Form
  @SELECTOR: '.Commenter'

  initialize: ->
    super
    @$target = bud.get(@$container.data('target'))
    @$container.find('textarea').on 'keydown', @on_keyup
    @$mentions_source = bud.get(@$container.data('mentions_source'))
    @highlighter = @$mentions_source.data('jsWidget')

  on_after: =>
    super
    @highlighter.$container.empty() if @highlighter

  on_keyup: (e) =>
    if e.which == 13 && !e.shiftKey
      @$container.submit()
      return false
    else
      return true

  on_success: (response) =>
    super
    bud.append_html(@$target, response['html'])
    @$container[0].reset()

  on_replace: (response) =>
    bud.replace_container(@$target, response['html'])

  params: ->
    result = super()
    if @$mentions_source
      result['mentions'] = @highlighter.mentions_data
    result
