Slim::Engine.set_options pretty: false, sort_attrs: false

if Rails.env.production?
  Slim::Engine.set_options shortcut: {'@' => {attr: false},
                                      '#' => {attr: 'id'},
                                      '.' => {attr: 'class'}}
else
  Slim::Engine.set_options shortcut: {'@' => {attr: 'qid'},
                                      '#' => {attr: 'id'},
                                      '.' => {attr: 'class'}}
end
