# ToDo

The ToDo example is one of the best Ruflet tutorials because it looks like a real product feature.

Instead of reading the finished file as one block, build it in layers:

1. create the app and state
2. render the input
3. store tasks
4. render task rows
5. add filters
6. wire task actions

The production example lives here:

```text
examples/todo.rb
```

## Step 1: create the app and initial state

The real example uses a class-based app with a few instance variables.

```ruby
require "ruflet"

class TodoApp < Ruflet::App
  FILTERS = %w[all active completed].freeze

  def initialize
    super
    @tasks = []
    @next_id = 1
    @filter = "all"
    @draft = ""
  end
end
```

Why this structure is good:

- `@tasks` stores the list
- `@next_id` gives each task a stable identifier
- `@filter` controls which tasks are visible
- `@draft` mirrors the current input field value

## Step 2: build the page shell

Start with a simple centered card.

```ruby
def view(page)
  page.title = "Todo"
  page.vertical_alignment = "center"
  page.horizontal_alignment = "center"

  render(page)
end
```

Use a dedicated `render(page)` method just like the example does. That makes full rerenders easy after each action.

## Step 3: add the draft input

The real app keeps the text field controlled by `@draft`.

```ruby
input = text_field(
  value: @draft,
  hint_text: "What needs to be done?",
  on_change: ->(e) { @draft = e.data.to_s },
  on_submit: ->(e) { add_task(e.page) }
)
```

This is an important Ruflet pattern:

- state lives on the app object
- the field updates that state on change
- submit actions call a method that mutates state and rerenders

## Step 4: add the button row

Next, place the input beside an Add button.

```ruby
def add_row(page, input)
  add_button = elevated_button(
    content: text("Add"),
    on_click: ->(e) { add_task(e.page) }
  )

  row(spacing: 10, children: [input, add_button])
end
```

In the full example this becomes responsive, switching to a `column` on small screens. Start simple first, then add responsiveness after the behavior works.

## Step 5: create the add action

Now make the button do something.

```ruby
def add_task(page)
  task_text = @draft.to_s.strip
  return if task_text.empty?

  @tasks << { id: @next_id, text: task_text, done: false }
  @next_id += 1
  @draft = ""
  render(page)
end
```

This small method teaches a lot:

- validate first
- append a new task hash
- reset the draft
- rerender the screen

## Step 6: render the task list

The real example turns each task into its own row helper.

```ruby
def task_row(page, task)
  label = task[:done] ? "✓ #{task[:text]}" : task[:text]

  row(
    alignment: "spaceBetween",
    vertical_alignment: "center",
    children: [
      checkbox(
        value: task[:done],
        label: label,
        expand: true,
        on_change: ->(e) { toggle_task(task[:id], e.page) }
      ),
      text_button(
        content: text("Delete"),
        on_click: ->(e) { delete_task(task[:id], e.page) }
      )
    ]
  )
end
```

Then in `render(page)`:

```ruby
task_controls = if filtered_tasks.empty?
  [
    container(
      padding: 16,
      content: text("No tasks")
    )
  ]
else
  filtered_tasks.map { |task| task_row(page, task) }
end
```

This is a very Ruflet-friendly pattern:

- Ruby data in
- control list out

## Step 7: add filtering

The example supports `all`, `active`, and `completed`.

```ruby
def filtered_tasks
  case @filter
  when "active"
    @tasks.reject { |task| task[:done] }
  when "completed"
    @tasks.select { |task| task[:done] }
  else
    @tasks
  end
end
```

Now build the filter buttons:

```ruby
def filter_button(page, name)
  selected = (@filter == name)

  if selected
    filled_button(
      content: text(name.capitalize),
      on_click: ->(e) { set_filter(name, e.page) }
    )
  else
    text_button(
      content: text(name.capitalize),
      on_click: ->(e) { set_filter(name, e.page) }
    )
  end
end
```

This teaches a useful product pattern:

- the active filter changes both data and visual style

## Step 8: wire task actions

The rest of the example is a set of small mutations:

```ruby
def toggle_task(task_id, page)
  task = @tasks.find { |item| item[:id] == task_id }
  return unless task

  task[:done] = !task[:done]
  render(page)
end

def delete_task(task_id, page)
  @tasks.reject! { |task| task[:id] == task_id }
  render(page)
end

def set_filter(name, page)
  @filter = name
  render(page)
end

def clear_completed(page)
  @tasks.reject! { |task| task[:done] }
  render(page)
end
```

The key lesson here is consistency:

- every action changes Ruby state
- every action rerenders the page

That makes the whole app easy to reason about.

## Step 9: make the layout feel complete

The real example adds:

- a card container
- an app bar
- a floating action button
- a footer with counts and filters
- responsive sizing based on `page.client_details`

Those are polish layers you can add after the core flow works.

## Run the real example

```bash
cd examples
bundle install
ruflet run todo
```

## What you learned

- how to manage list state in Ruflet
- how to turn arrays into control trees
- how to build realistic add, toggle, delete, and filter flows
- how rerender-based UI can stay simple and productive
