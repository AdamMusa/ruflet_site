# Getting Started

Create and run a Ruflet application:

```bash
gem install ruflet
ruflet new my_app
cd my_app
bundle install
ruflet run main.rb --web
```

Generated projects contain `main.rb`, `ruflet.yaml`, `services.yaml`, a
`Gemfile`, and starter assets.

## Development targets

```bash
ruflet run main.rb
ruflet run main.rb --web
ruflet run main.rb --desktop
```

The first command starts mobile development mode. The other commands launch a
managed local client.

## Core model

- Build controls with helpers such as `text`, `column`, `container`, and `filled_button`.
- Add controls with `page.add`.
- Update mounted controls with `page.update`.
- Navigate with `page.go` and `page.views`.
- Access client capabilities through page services.

Continue with [App Structure](/docs/app-structure), [CLI Workflow](/docs/cli-workflow),
and [Controls](/docs/component-reference).
