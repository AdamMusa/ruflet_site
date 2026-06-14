# Scaffolding a CRUD Resource

`ruflet_rails` extends the standard Rails scaffold generator. When you generate
a Rails scaffold, it also creates a complete Ruflet CRUD component using the
same model name and attributes. The generated component is ordinary application
code that you own and can edit.

It includes the index table and compact list, detail screen, create/edit
dialog, delete confirmation, form controls, and the calls that save and delete
records.

## Generate

```bash
bin/rails generate scaffold Post title:string body:text published_on:date
```

This creates one component:

```
app/views/ruflet/components/posts/post_component.rb
```

The normal Rails scaffold generator creates its usual model, controller, views,
migration, and routes. Ruflet adds only the resource component shown above.

To generate a Rails scaffold without its Ruflet component:

```bash
bin/rails generate scaffold Post title:string --skip-ruflet
```

## Mount the component

Mount the generated component explicitly in `config/routes.rb`:

```ruby
mount Ruflet::Rails.web_app(view: "PostComponent"), at: "/posts"
```

The mount serves the Ruflet web client and connects it to `PostComponent`. The
model is inferred from the component class name: `PostComponent` uses `Post`.

## What the generated file contains

The generated file contains the complete resource UI and persistence behavior.
The version in `ruflet_demo` includes methods such as:

- `render` for the responsive index screen
- `show(record)` for the detail screen
- `record_table`, `table_columns`, and `table_row` for larger screens
- `record_list` and `record_tile` for compact screens
- `open_form(record)` for creating and editing records
- `open_delete(record)` for delete confirmation
- `field_row` and header helpers for the generated layout

The create/edit and delete operations are explicit inside the generated dialog
button handlers:

```ruby
filled_button(content: text("Save"), on_click: ->(_event) {
  if record.update(attributes.call)
    close_dialog(dialog)
    refresh
    show_snackbar("#{singular_title} saved")
  else
    show_errors(record)
  end
})

filled_button(content: text("Delete"), on_click: ->(_event) {
  record.destroy!
  close_dialog(dialog)
  refresh
  show_snackbar("#{singular_title} deleted")
})
```

Change these generated handlers when your application needs authorization,
service objects, custom validations, or different UI.

## What ResourceComponent provides

`PostComponent` inherits reusable helpers from
`Ruflet::Rails::ResourceComponent`:

- Model and title inference through `model_class`, `resource_title`, and `singular_title`
- Record loading through `records`
- Field inference and formatting through `resource_fields`, `display_fields`, and `display_value`
- Index/detail navigation through `render_index`, `render_show`, `show_record`, and `refresh`
- Responsive sizing, dialogs, snackbars, errors, and date/time picker helpers

The generated component uses these helpers, but does not normally redefine
them. Override a helper in your component only when its default behavior does
not fit your model.

For example, customize the table columns and displayed values like this:

```ruby
class PostComponent < Ruflet::Rails::ResourceComponent
  def display_fields
    %w[title published_on]
  end

  def display_value(record, field)
    return record.published_on&.to_fs(:long) if field == "published_on"

    super
  end
end
```

## Reading control values

Inside the generated form, read picker and field values using dot access:

```ruby
title_control.value
date_control.value
range_control.start_value
range_control.end_value
```

Controls also support `control.value = value` and `control[:value]`.

## Generated input types

The attribute type determines the generated form control:

- `string` and `text` use text fields
- `boolean` uses a checkbox
- `date` uses a date picker
- `datetime` and `time` use a time picker
- `daterange` uses a date range picker

Generated form inputs stretch to the dialog width. Date and time pickers opened
from the form are handled as nested dialogs and return to the form after
selection.
