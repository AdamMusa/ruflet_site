# Calculator

This tutorial turns the calculator example into a learn-by-building exercise.

Instead of jumping straight to the finished code, we will build the app in layers:

1. create the app shell
2. add a calculator display
3. render keypad rows
4. store calculator state
5. handle digits and decimal input
6. add operators, equals, and utility actions

## Before you start

The production calculator logic in this repo lives in Ruflet Studio under:

```text
ruflet_studio/sections_controls/calculator.rb
```

This tutorial teaches the same ideas in a smaller step-by-step flow.

## Step 1: create the app shell

Start with a class-based app so the calculator state can live on the object.

```ruby
require "ruflet"

class CalculatorApp < Ruflet::App
  def view(page)
    page.title = "Calculator"

    page.add(
      container(
        width: 420,
        padding: 16,
        border_radius: 16,
        content: text("Calculator coming next...")
      )
    )
  end
end

CalculatorApp.new.run
```

What this step teaches:

- `Ruflet::App` is a good fit when the screen has internal state
- `page.add(...)` mounts your main UI
- `container` gives the tutorial a card-like surface to grow inside

## Step 2: add calculator state

We need somewhere to keep the current display value and the pending operation.

```ruby
class CalculatorApp < Ruflet::App
  def initialize
    super
    @state = {
      display: "0",
      operand: nil,
      operator: nil,
      start_new_value: false
    }
  end
end
```

What each field means:

- `display`: the text currently shown on screen
- `operand`: the previous number waiting for an operation
- `operator`: `+`, `-`, `x`, or `/`
- `start_new_value`: whether the next digit should replace the display

## Step 3: render the display

Now replace the placeholder text with a real calculator display.

```ruby
def build_display
  @display_control = text(
    value: @state[:display],
    text_align: "right",
    style: { size: 72 }
  )
end

def view(page)
  page.title = "Calculator"

  page.add(
    container(
      width: 420,
      padding: 16,
      border_radius: 16,
      content: column(
        spacing: 16,
        children: [
          row(alignment: "end", children: [build_display])
        ]
      )
    )
  )
end
```

What this step teaches:

- a text control can behave like a digital display
- keeping a reference in `@display_control` makes updates easy later
- `row(alignment: "end")` pushes the display to the right

## Step 4: build keypad rows

The real calculator example builds keys row by row. That is a good Ruflet pattern because it keeps repetitive UI tidy.

```ruby
def keypad_row(page, *labels)
  row(
    alignment: "center",
    spacing: 6,
    children: labels.map do |label|
      elevated_button(
        content: text(label),
        width: 78,
        height: 65,
        on_click: ->(e) { handle_input(label, e.page) }
      )
    end
  )
end
```

Now mount a few rows:

```ruby
content: column(
  spacing: 12,
  children: [
    row(alignment: "end", children: [build_display]),
    keypad_row(page, "7", "8", "9", "/"),
    keypad_row(page, "4", "5", "6", "x"),
    keypad_row(page, "1", "2", "3", "-"),
    keypad_row(page, "+/-", "0", ".", "+")
  ]
)
```

What this step teaches:

- one helper method can generate a whole keypad
- Ruby arrays map nicely into Ruflet control lists
- each button can send its label into one shared event handler

## Step 5: handle digit input

Start with the simplest input: numbers.

```ruby
DIGITS = %w[0 1 2 3 4 5 6 7 8 9].freeze

def handle_input(label, page)
  if DIGITS.include?(label)
    on_digit(label)
  elsif label == "."
    on_decimal
  end

  page.update(@display_control, value: @state[:display])
end

def on_digit(digit)
  if @state[:start_new_value] || @state[:display] == "Error"
    @state[:display] = digit
    @state[:start_new_value] = false
    return
  end

  @state[:display] = (@state[:display] == "0" ? digit : "#{@state[:display]}#{digit}")
end

def on_decimal
  if @state[:start_new_value] || @state[:display] == "Error"
    @state[:display] = "0."
    @state[:start_new_value] = false
    return
  end

  @state[:display] += "." unless @state[:display].include?(".")
end
```

Why this works well:

- one handler routes all key presses
- each behavior stays in a small method
- `page.update(...)` refreshes only the control that changed

## Step 6: add operators

Now teach the calculator how to remember the left-hand number and wait for the next value.

```ruby
def handle_input(label, page)
  if DIGITS.include?(label)
    on_digit(label)
  elsif label == "."
    on_decimal
  elsif %w[x / - +].include?(label)
    on_operator(label)
  elsif label == "="
    on_equals
  end

  page.update(@display_control, value: @state[:display])
end

def on_operator(next_operator)
  if @state[:operator] && !@state[:start_new_value]
    apply_calculation
    return if @state[:display] == "Error"
  else
    @state[:operand] = to_number(@state[:display])
  end

  @state[:operator] = next_operator
  @state[:start_new_value] = true
end
```

Add the equals behavior:

```ruby
def on_equals
  return unless @state[:operator]

  apply_calculation
  @state[:operator] = nil if @state[:display] != "Error"
end
```

## Step 7: calculate results

This is the core math step from the real example.

```ruby
def apply_calculation
  right = to_number(@state[:display])

  result = case @state[:operator]
           when "+"
             @state[:operand] + right
           when "-"
             @state[:operand] - right
           when "x"
             @state[:operand] * right
           when "/"
             return show_error if right.zero?

             @state[:operand] / right
           end

  @state[:display] = format_number(result)
  @state[:operand] = to_number(@state[:display])
  @state[:start_new_value] = true
end

def to_number(value)
  Float(value)
rescue StandardError
  0.0
end

def format_number(value)
  number = value.to_f
  return number.to_i.to_s if number == number.to_i

  number.to_s.sub(/\.?0+\z/, "")
end
```

## Step 8: add utility keys

The real calculator includes useful extra keys:

- `AC` resets the calculator
- `BS` removes the last character
- `+/-` toggles sign
- `%` converts the display to a percentage

Those are great examples of small, focused state methods:

```ruby
def reset
  @state[:display] = "0"
  @state[:operand] = nil
  @state[:operator] = nil
  @state[:start_new_value] = false
end
```

The pattern is the important part:

- keep each action tiny
- change only the state you need
- update the display after the action runs

## Final keypad layout

The full keypad from the real example is:

```ruby
keypad_row(page, "BS", "AC", "%", "/")
keypad_row(page, "7", "8", "9", "x")
keypad_row(page, "4", "5", "6", "-")
keypad_row(page, "1", "2", "3", "+")
keypad_row(page, "+/-", "0", ".", "=")
```

## Run your version

```bash
ruflet run main
```

## What you learned

- how to keep state inside a `Ruflet::App`
- how to generate repeated controls with Ruby helpers
- how to route events through one shared handler
- how `page.update(...)` keeps the UI in sync

## Compare with the repo implementation

After finishing your version, compare it with the real calculator logic in:

```text
ruflet_studio/sections_controls/calculator.rb
```

That comparison is useful because you will see the same structure at a slightly more polished level.
