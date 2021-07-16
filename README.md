# Big Blue Button LTI

This tool allows BigBlueButton meetings to be scheduled by instructors. Meetings are created with simple CRUD operations and launched using the BigBlueButton API.

## Why?

BigBlueButton already has a capable [LTI plugin](https://github.com/bigbluebutton/bigbluebutton/tree/develop/bbb-lti) out of the box but it was missing some features that we needed to enable BigBlueButton as an LTI provider for our applications. We extended the functionality of the default LTI provider and added some of the features below:

- Schedule meetings inside the LTI service, this includes links to add to your calendar.
- Add settings (autostart recording, default presentation url, mute on start, etc) to each meeting when scheduling.
- Calendar view of past, present, and upcoming meetings.
- API and admin UI to dynamically create LTI consumer credentials. We don't know all of the consumers ahead of time and we don't want to share one set of credentials between consumers.

## Development

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
