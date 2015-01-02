class bud.widgets.StaticAutocomplete extends bud.Widget
  @SELECTOR: '.StaticAutocomplete'

  initialize: ->
    @$target        = @get_target()
    @$submit_button = @get_target('submit_button')
    @$dropdown      = @get_target('dropdown')
    @options        = @data('options')
    @url            = @data('url')

    @fill_options()
    @$dropdown.hide()
    @$submit_button.click @on_submit

    @$container.keyup @on_keyup
    @$container.keydown @on_keydown

  on_keydown: (e) =>
    if e.which == 13
      @on_submit()
      return false

  on_keyup: (e) =>
    if e.which == 13
      return false

    @$dropdown.show()
    regex = new RegExp(@val(), 'i')

    _.each @options, (option, index) =>
      li = $(@lis()[index])
      li.toggle(!!li.text().match(regex))

  on_submit: =>
    val = @val()
    @$container.attr('disabled', 'disabled')
    @$container.addClass('pending')
    bud.Ajax.post(@url, {type: val}, {replace: @on_response})
    @$dropdown.hide()
    @lis().show()

  on_response: (response) =>
    @$container.val('')
    @$container.removeAttr('disabled')
    @$container.removeClass('pending')
    bud.replace_html(@$target, response['html']) if response['html']

  val: -> @$container.val()

  fill_options: ->
    _.each @options, (option) =>
      @$dropdown.append("<li>#{option}</li>")

    @lis().click @on_select

  lis: -> @$dropdown.find('li')

  on_select: (e) =>
    li = $(e.currentTarget)
    text = li.text()
    @$container.val(text)
    @$dropdown.hide()
    @on_submit()

