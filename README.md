# SHRTNR: Ruby Full-Stack Implementation

This is the Client/Server implementation of SHRTNR on Ruby. As Ruby has been my
home language for a while, it made sense to use this as the reference
implementation of the core SHRTNR featureset before branching out into other
languages.

## Setup

```
bundle install
bin/rails db:setup
```

In development mode, this will seed the database with an admin account:

* email: `admin@example.com`
* password: `password`

## Testing

Single run: `bin/rails test`

Continuous testing: `bin/rerun`

## Running the server

```
bin/rails server
```

## API Features

Authenticate as an admin:

```
curl "http://localhost:3000/api/users/auth" \
  -X POST \
  -d "{\"email\":\"admin@example.com\",\"password\":\"password\"}" \
  -H "Content-Type: application/json" 
```

For most the API endpoints, that token will be required, assigning it to a
variable might be helpful...

```
TOKEN="eyJhbG..."
```

List shortcodes:

```
curl "http://localhost:3000/api/shortcodes" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}"
```

List users:

```
curl "http://localhost:3000/api/users" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}"
```

