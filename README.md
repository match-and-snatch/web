![Buddy Rocks](http://buddy-assets.s3.amazonaws.com/images/logo_github.png)
## Learn
### Frontend
- [Assets Pipeline](http://guides.rubyonrails.org/asset_pipeline.html)
- [CoffeeScript](http://coffeescript.org/)
- [Slim templates](http://slim-lang.com/)
- [SASS](https://github.com/rails/sass-rails)

### Backend
- [Ruby](https://www.ruby-lang.org/en/)
- [Rails](http://guides.rubyonrails.org/)
- [PostgreSQL](www.postgresql.org)
- [RSpec](http://rspec.info/)
- [Stripe](stripe.com)

## Setting up the application

### On a virtual machine (preferred way)

- Install [Vagrant](http://www.vagrantup.com/)
- Install [VirtualBox](https://www.virtualbox.org/)
- Install [Ansible](http://www.ansible.com/)
- `git clone git@github.com:subscribebuddy/platform.git`
- `git checkout development`
- run `vagrant up`

### Or directly on your local box (not preferred)

- `git clone git@github.com:subscribebuddy/platform.git`.
- Checkout development branch `git checkout development`.
- Install [Ruby 2.0](http://rvm.io/).
- Setup [Postgres App](http://postgresapp.com/).
- Setup Guard (if you use it).
- Run `bundle install`.
- Create `config/database.yml` using [config/database.yml.example](config/database.yml.example) file.


## Setting up heroku (not required)
- Install [Toolbelt](https://devcenter.heroku.com/)

Add your SSH keys:

```bash
heroku keys:add ~/.ssh/id_rsa.pub
```

## Running

#### Virtual Machine (preferred way):
- `cap buddy server:restart`
- enjoy it on [localhost:3001](http://localhost:3001)

You also have commands:
- `cap buddy server:stop` which stops your web server
- `cap buddy server:start` which starts server without running all the service jobs

#### Directly on your local box:
- `bundle install`
- `rake db:create`
- `rake db:migrate`
- `rails s`
- enjoy it on [localhost:3000](http://localhost:3000)

## Basic workflow

```
> git remote add my git@github.com:mygithubname/platform.git
> git checkout development
> git pull origin development
> git checkout -b my-new-feature
> cap buddy update
> git commit ...
> git push my my-new-feature

Create Pull Request on github.

> git checkout development
> git pull origin development
> git checkout my-new-feature
> git rebase development
> git push my my-new-feature -f
> git checkout development
> git merge my-new-feature --no-ff
> git push origin development
```

## How to run the test suite

`cap buddy specs:all`

Use Guard FTW!

`cap buddy specs:guard`

### Deployment instructions

- `git remote add heroku git@heroku.com:subscribebuddy.git`
- `rake assets:precompile`
- `git add . && git commit -am "Compressed assets to push" && git push origin your_feature_branch`
- upload files on S3
- `git push heroku your_feature_branch:master -f`

### Staging server access

Goto [http://subscribebuddy.herokuapp.com/](http://subscribebuddy.herokuapp.com/)
Login: `buddy`
Password: `staging`

### Frontend framework

- [http://slim-lang.com/](http://slim-lang.com/)
- [https://github.com/rails/sass-rails](https://github.com/rails/sass-rails)
- [http://coffeescript.org/](http://coffeescript.org/)

Only *SASS* for CSS. Only *coffee* for JS. Only *Slim* for HTML.
All CSS we do include in 1 file. Every single file created under `app/assets/stylesheets/pages` and `app/assets/stylesheets/mixins` will be included in application css file.
Same rule for Javascript.

In order to build mockup:

- Create file `app/views/mockups/whatever_you_want.html.slim`
- Navigate to `http://localhost:3000/mockups/whatever_you_want` and see your mockup

Javascript examples:

#### Widgets

```coffeescript
class bud.widgets.MWidget extends bud.Widget
  @SELECTOR: '.MWidget' # Selector is used to initialize widget on each element matching this selector

  initialize: ->
    @$container.html('I am here!')
```

#### Global events

```coffeescript
# Bind public events
bud.sub('popup.show', @callback)

# Notify other widgets
bud.pub('something happened', [@])
```

#### Dom manipulation

```coffeescript
# Initialize widgets on new dom elements at runtime
bud.replace_html $('.SomeContainer'), "<div class='MWidget'></div>"
```

Find more in [Bud Helpers](app/assets/javascripts/helpers.coffee#l11)

#### Async responses

Handle all ajax requests using [Bud Ajax](app/assets/javascripts/ajax.coffee).
List of all possible responses:

```ruby
{status: 'redirect', url: 'http://r0.ru'}
```

```ruby
{status: 'reload'}
```

```ruby
{status: 'success'}
```

```ruby
{status: 'success', html: 'posts list'}
```

```ruby
{status: 'success', message: 'it works'}
```

```ruby
{status: 'failed', errors: {login: 'invalid'}, message: 'fucked up'}
```

```ruby
{status: 'append', html: 'new comment'}
```

```ruby
{status: 'prepend', html: 'new post'}
```

```ruby
{status: 'replace', html: 'new profile picture'}
```

### Philosophy

- No tons of gems.
- No cancans.
- Less callbacks.
- No observers.
- Linear structure.
- ActiveRecord should be ActiveRecord. We do consider model as a structure, not a business logic performer.
- No factories in tests.
- No direct creation of records in tests.

### Learn more

- [https://devcenter.heroku.com/](https://devcenter.heroku.com/)
- [https://www.ruby-lang.org/en/](https://www.ruby-lang.org/en/)
- [http://www.postgresql.org/](http://www.postgresql.org/)
- [https://github.com/guard/guard#readme](https://github.com/guard/guard#readme)
- [http://betterspecs.org/](http://betterspecs.org/)
- [http://rspec.info/](http://rspec.info/)
