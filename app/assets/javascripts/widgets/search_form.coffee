#= require ./form

class bud.widgets.SearchForm extends bud.widgets.Form
  @SELECTOR: '.SearchForm'

  on_replace: (response) =>
    super
    bud.pub('search.finished')
