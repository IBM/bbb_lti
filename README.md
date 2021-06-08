# Big Blue Button LTI

This tool allows Big Blue Button meetings to be scheduled by instructors. Meetings are created with simple CRUD operations and launched using the Big Blue Button API.

## To start your Phoenix server:

  * Create and fill a `.env` file based on `.env.example`
  * `source .env`
  * Setup the project with `mix setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000/meetings`](http://localhost:4000/meetings) from your browser.

## Testing with Skills Network Portals

  * Pick a development portal
  * Find your portal's LTI Credentials in `{slug}.skillsnetwork.site/admin/advanced/edit`
  * Make a `POST` request to `http://localhost:4000/api/lti/clients` with the following body
    ```JSON
    {
      "clientId": "{LTI Client Key}",
      "clientSecret": "{LTI Client Secret}"
    }
    ```
    This will authenticate your portal with your local instance of VC LTI
  * Follow [this guide](https://support.skillsnetwork.site/knowledgebase/articles/1940794-how-do-i-setup-virtual-classroom-for-a-course)

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
