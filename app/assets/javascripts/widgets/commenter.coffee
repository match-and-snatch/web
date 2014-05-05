#= require ./form

# Appends HTML to a target container once form is posted
# @data target [String] Target identifier
class bud.widgets.Commenter extends bud.widgets.Form
  @SELECTOR: '.Commenter'

  initialize: ->
    super
    @$target      = bud.get(@$container.data('target'))
    @$highlighter = bud.get(@$container.data('highlighter'))
    @$textarea    = @$container.find('textarea')

    @$textarea.on 'keydown', @on_keyup

  on_submit: =>
    return false if _.isEmpty(@$textarea.val())
    super()

  on_after: =>
    super
    if @highlighter()
      @highlighter().cleanup()

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
    bud.pub('commenter.commented', [@])

  on_replace: (response) =>
    bud.replace_container(@$target, response['html'])

  params: ->
    result = super()
    if @highlighter()
      result['mentions'] = @highlighter().mentions_data
    result

  highlighter: ->
    @__highlighter ||= @$highlighter.data('jsWidget') if @$highlighter
