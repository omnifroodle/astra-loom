# Astra-loom

## Setup

You'll need:
* a google auth developer account
* an Astra database (Free tier should do it)

Copy `example.env` to `.env` and update it with your Astra and Google creds

### Add your tables to Astra

In the Astr CQL console:
```
create table messages (
    thread text,
    user text,
    id timeuuid,
    added timestamp,
    message text,
    picture text,
    primary key (thread, id, user)
);
```
## Start the server

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).