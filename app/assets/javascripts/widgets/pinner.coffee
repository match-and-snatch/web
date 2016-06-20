#= require ./ajax_form_link

class bud.widgets.Pinner extends bud.widgets.AjaxFormLink
  @SELECTOR: '.Pinner'

  render_link: (response) =>
    @$container.removeClass('pending')
    @$container.addClass('active')
    bud.pub('post.toggle.pinned')
