# Milestone Viewer

This Sinatra app uses sinatra_auth_github and backbone to take Github Milestones and view them in a timeline. This app works with Github organizations. Making it work with a repository belonging to an individual shouldn't be too hard.

## Setup

Download this repository and run

```ruby
bundle install
gem install foreman
```

Then open up `app.rb` and set the following values to reflect your organization and repository:

```ruby
repo_name = 'oreillymedia/orm-atlas'
github_organization_authenticate!('oreillymedia')
```

Next you must create a Github Application belonging to an organization. Visit a url such as:

```
https://github.com/organizations/<ORGNAME>/settings/applications/new
```

Where `<ORGNAME>` is replaced with the name of your organization. In filling out the form, if your app is to be hosted on `localhost:5000` the **Authorization callback URL** would be `http://localhost:5000/auth/github/callback`.

Once you have registered the application, create a file named `.env` and copy and paste in the Github application Client ID and Client secret, after the equals signs in the below text:

```
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=
```

You're all set to launch the app. Run: `foreman start` to see your application running on http://localhost:5000

## Setting a Future Start Date for a Milestone

Github's Milestones don't have a field for "start date," so all milestones will appear to have started on the day they were created. If you want to create a milestone for the future you can do so by using some YAML frontmatter.

When creating or editing a milestone, add the following as the first lines of the description:

```
---
start: YYYY-MM-DD
---

description of what this milestone is about
```

Now that milestone will appear to begin at the date of `YYYY-MM-DD`.