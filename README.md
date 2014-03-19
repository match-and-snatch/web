## Setup application

### On a virtual machine

- Install [Vagrant](http://www.vagrantup.com/)
- Install [VirtualBox](https://www.virtualbox.org/)
- Install [Ansible](http://www.ansible.com/)
- `git clone git@github.com:subscribebuddy/platform.git`.
- run `vagrant up`

### Or on your local box

- `git clone git@github.com:subscribebuddy/platform.git`.
- Checkout development branch `git checkout development`.
- Install [Ruby 2.0](http://rvm.io/).
- Setup [Postgres App](http://postgresapp.com/).
- Setup any ruby version management environment.
- Setup Guard (if you use it).
- Run `bundle install`.
- Create `config/database.yml` using [config/database.yml.example](config/database.yml.example) file.
- Setup foreman (if you are going to use it). Put into project root directory `.env` file containing:

```bash
RACK_ENV=development
PORT=3000
DATABASE_URL=postgres://postgres:password@localhost/buddy_platform_development
```

- Install [Toolbelt](https://devcenter.heroku.com/)

Add your SSH keys:

```bash
heroku keys:add ~/.ssh/id_rsa.pub
```

## Running

Default:
- `bundle install`
- `rake db:create`
- `rake db:migrate`
- `rails s`

Foreman:
- `bundle install`
- `foreman run rake db:create`
- `foreman run rake db:migrate`
- `foreman start`

## Basic workflow

```
> git remote add my git@github.com:mygithubname/platform.git
> git checkout development
> git pull origin development
> bundle install
> rake db:migrate
> git checkout -b my-new-feature
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

`bundle exec rspec spec`

Use Guard FTW!

`bundle exec guard start`

Or using Foreman: `foreman run -e .env_test bundle exec guard start`

### Deployment instructions

- `git remote add heroku git@heroku.com:subscribebuddy.git`
- `git push heroku master`
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
