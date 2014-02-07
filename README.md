## Setup application

- `git clone git@github.com:subscribebuddy/platform.git`.
- Checkout development branch `git checkout development`.
- Install Ruby 2.0.
- Setup Postgres.
- Setup any ruby version management environment.
- Setup Guard (if you use it).
- Run `bundle install`.
- Create `config/database.yml` using `config/database.yml.example` file.
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

- `bundle install`
- `foreman run rake db:create`
- `foreman start`

## How to run the test suite

`bundle exec rspec spec`

Use Guard FTW!

`bundle exec guard start`

Or using Foreman: `foreman run -e .env_test bundle exec guard start`

### Deployment instructions

- `git remote add heroku git@heroku.com:streamrush.git`
- `git push heroku master`
- `git push heroku your_feature_branch:master -f`

### Staging server access

Goto [http://streamrush.herokuapp.com/](http://streamrush.herokuapp.com/)

### Frontend framework

- [http://slim-lang.com/](http://slim-lang.com/)
- [https://github.com/rails/sass-rails](https://github.com/rails/sass-rails)
- [http://coffeescript.org/](http://coffeescript.org/)

Only *SASS* for CSS. Only *coffee* for JS. Only *Slim* for HTML.
All CSS we do include in 1 file. Every single file created under `app/assets/stylesheets/pages` and `app/assets/stylesheets/mixins` will be included in application css file.
Same rule for Javascript.

In order to build mockup:

- Create file `app/views/mockups/whatever_you_want.html.slim`
- Navigate to `http://localhost:3000/whatever_you_want` and see your mockup

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
