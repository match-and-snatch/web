# Submits form while user inputs text in the form input
# Must be initialized on an input element inside a form
class bud.widgets.Autocomplete extends bud.Widget
  @SELECTOR: '.Autocomplete'

  initialize: ->
    @form  = @$container.parents('form')
    @input = @$container
    @input.val('')

    @input.on 'keyup', (e) =>
      if e.which == 27
        @input.val('')
        @submit()
        bud.pub('search.changed', [@input.val()])

    @input.on 'input', =>
      @submit()
      bud.pub('search.changed', [@input.val()])

  submit: =>
    if @form_widget()
      @submitted_value = @input.val() unless @form_widget().requesting

      @form_widget().safe_submit(=>
        @submit() if @input.val() != @submitted_value)
    else
      @form.submit()

  form_widget: ->
    @_form_widget or= @form.data('js-widget')
