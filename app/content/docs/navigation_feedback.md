# Navigation and Feedback

Ruflet already includes enough navigation and feedback primitives to build multi-screen apps, nested shells, and polished transient UI flows.

## Navigation primitives

Current navigation-oriented controls and patterns include:

- `view`
- `pagelet`
- `navigation_bar`
- `navigation_bar_destination`
- `navigation_rail`
- `navigation_rail_destination`
- `navigation_drawer`
- `navigation_drawer_destination`
- `tabs`
- `tab`
- `tab_bar`
- `tab_bar_view`
- `page_view`

In practice Ruflet apps combine these with:

- `page.route`
- `page.views`
- button click handlers that call navigation methods or swap views

## App shell surfaces

Ruflet supports the main shell building blocks you would expect:

- `app_bar`
- `cupertino_app_bar`
- `bottom_app_bar`
- `drawer`
- `end_drawer`
- `floating_action_button`

## Dialogs and sheets

The repo already uses both Material and Cupertino dialog patterns:

- `alert_dialog`
- `cupertino_alert_dialog`
- `bottom_sheet`
- `cupertino_bottom_sheet`
- `cupertino_action_sheet`

And the page API includes:

- `page.show_dialog(control)`
- `page.pop_dialog`

## Feedback controls

These are already part of the available surface:

- `snack_bar`
- `banner`
- `progress_bar`
- `progress_ring`
- `tooltip`
- `badge`

## Tabs example

The shipped `tabs.rb` example combines tabbed content and a bottom navigation bar:

```ruby
top_tabs = tabs(
  expand: 1,
  length: 3,
  selected_index: 0,
  content: column(
    expand: true,
    spacing: 0,
    children: [
      tab_bar(
        tabs: [
          tab(label: text("Home")),
          tab(label: text("Play")),
          tab(label: text("About"))
        ]
      ),
      tab_bar_view(
        expand: 1,
        children: [
          container(expand: true, content: text("Home tab")),
          container(expand: true, content: text("Play tab")),
          container(expand: true, content: text("About tab"))
        ]
      )
    ]
  )
)
```

## Where Ruflet Studio is especially useful

Ruflet Studio demonstrates:

- dialog presentation
- sheets and pickers
- top-level navigation
- bottom navigation
- route-aware detail pages

That makes it the best reference when you are building real app shells instead of isolated components.
