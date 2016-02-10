#= require ./ajax_form_link

class bud.widgets.DeleteProfileTypeButton extends bud.widgets.AjaxFormLink
  @SELECTOR: '.DeleteProfileTypeButton'

  on_replace: (response) =>
    super
    bud.pub('profile_types.changed', response['types_text']) if response['types_text']
