#= require ./ajax_form_link

class bud.widgets.CommentsToggler extends bud.widgets.AjaxFormLink
  @SELECTOR: '.CommentsToggler'

  render_link: (response) =>
    @$container.removeClass('pending')
    @$container.addClass('active')

    _.each @target(), (comment, index, list) ->
      $(comment).data('js-widget').toggle(response.visible)
