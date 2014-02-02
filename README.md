## Setup application

- `git clone git@github.com:streamrush/platform.git`
- Install Ruby 2.0.
- Setup Postgres.
- Setup any ruby version management environment.
- Setup Guard (if you use it).
- Run `bundle install`.
- Setup your local environment. Put into project root directory `.env` file containing:

```bash
RACK_ENV=development
PORT=3000
DATABASE_URL=postgres://postgres:password@localhost/streamrush_platform_development
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

### Deployment instructions

- `git remote add heroku git@heroku.com:streamrush.git`
- `git push heroku master`
- `git push heroku your_feature_branch:master -f`

### Staging server access

Goto [http://streamrush.herokuapp.com/](http://streamrush.herokuapp.com/)

### Learn

- [https://devcenter.heroku.com/](https://devcenter.heroku.com/)
- [https://www.ruby-lang.org/en/](https://www.ruby-lang.org/en/)
- [http://slim-lang.com/](http://slim-lang.com/)
- [https://github.com/rails/sass-rails](https://github.com/rails/sass-rails)
- [http://coffeescript.org/](http://coffeescript.org/)
- [http://www.postgresql.org/](http://www.postgresql.org/)
- [https://github.com/guard/guard#readme](https://github.com/guard/guard#readme)
- [http://betterspecs.org/](http://betterspecs.org/)
- [http://rspec.info/](http://rspec.info/)
