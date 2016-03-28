#= require ./ajax_form_link

class bud.widgets.SiblingCommentsToggler extends bud.widgets.AjaxFormLink
  @SELECTOR: '.SiblingCommentsToggler'

  render_link: (response) =>
    @$container.removeClass('pending')
    @$container.addClass('active')

    $comment_row = @target().parent()
    $visibility_toggler = @target().find('li.visibility_toggler')
    $edit_container = @target().children('.edit_container')

    @target().children('.edit_container:visible').toggle()

    bud.Core.destroy_widgets($edit_container)

    if response.visible
      $comment_row.css('opacity',  1)
      $visibility_toggler.text('Hide')
      $visibility_toggler.parent('a').attr 'href', (i, href) -> href.replace /make_visible/, 'hide'
    else
      $comment_row.css('opacity',  0.5)
      $visibility_toggler.text('Show')
      $visibility_toggler.parent('a').attr 'href', (i, href) -> href.replace /hide/, 'make_visible'

    bud.Core.init_widgets($edit_container)
