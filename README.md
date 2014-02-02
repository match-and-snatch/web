## Setup application

- Install Ruby 2.0.
- Setup Postgres.
- Setup any ruby version management environment.
- Setup Guard.
- Setup your local environment. Put into project root directory `.env` file containing:

```bash
RACK_ENV=development
PORT=3000
DATABASE_URL=postgres://postgres:password@localhost/streamrush_platform_development
```

## Running

- `bundle install`
- `foreman run rake db:create`
- `foreman start`

## How to run the test suite

`bundle exec rspec spec`

### Deployment instructions

- `git remote add heroku git@heroku.com:streamrush.git`
- `git push heroku master`

