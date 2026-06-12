# Scaffolding a CRUD Resource

`ruflet_rails` generates a full CRUD screen for an existing model as **one
mountable component**. Routing, model lookup, record loading, and persistence
all live in the base class — the generated file holds only the UI and the field
configuration you actually customize.

## Generate

```bash
bin/rails generate ruflet:scaffold Product name:string price:decimal published_on:date
```

This creates a single file:

```
app/views/ruflet/components/products/product_component.rb
```

There is **no separate view/controller file** — the framework plumbing is
inherited from `Ruflet::Rails::ResourceComponent`.

## Mount it

A resource component is mounted by class name. The route comes from
`routes.rb`, not from the component:

```ruby
mount Ruflet::Rails.web_app(view: "ProductComponent"), at: "/products"
```

The model is inferred from the class name (`ProductComponent` → `Product`).

## What's generated vs. inherited

The generated `ProductComponent` contains only the customizable surface:

```ruby
class ProductComponent < Ruflet::Rails::ResourceComponent
  def render(...)      # the index UI (table / list)
  def show(record)     # the detail UI

  # The fields you tune:
  def resource_fields  = ["name", "price", "published_on"]
  def display_fields   = ["name", "price"]
  def display_value(record, field)
    # custom formatting per field
  end

  def open_form(record) # the create/edit dialog, one input per attribute
end
```

Everything else is inherited from `ResourceComponent` and never appears in your
file:

- `model_class`, `resource_title`, `singular_title` (inferred from the name)
- `records` (loads up to 50)
- `render_index`, `render_show`, `show_record`
- `save_record`, `destroy_record`
- dialog management and the date/time picker helpers

## Reading control values

Inside the generated form, picker and field values use clean dot access:

```ruby
title_control.value            # instead of title_control.props["value"]
range_control.start_value
range_control.end_value
```

Any control supports `control.value`, `control.value = x`, and
`control[:value]` — typos still raise `NoMethodError`, so they stay safe.

## Generated input types

The attribute type picks the form input:

- `string`, `text` → text field
- `boolean` → checkbox
- `date` → date picker
- `datetime`, `time` → time picker
- `daterange` → date range picker

Form inputs stretch to the dialog width, and nested pickers (a date picker
opened from inside the form dialog) close correctly without breaking the form's
Save/Cancel.
