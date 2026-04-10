# Solitaire

The solitaire example is where Ruflet starts to feel like a serious app framework instead of a small demo toolkit.

This tutorial does not ask you to memorize the whole file at once. Instead, use the example as a study path:

1. understand the data model
2. understand slots
3. understand cards
4. understand layout and dealing
5. understand drag and drop
6. understand game rules

The full example lives here:

```text
examples/solitaire.rb
```

## Step 1: model the game data

The example starts with plain Ruby structures:

```ruby
Suite = Struct.new(:name, :color)
Rank = Struct.new(:name, :value)
```

This is a great reminder that Ruflet does not replace Ruby. You still model your domain with normal Ruby objects first.

## Step 2: build slot objects

Slots represent places where cards can live:

- stock
- waste
- foundation piles
- tableau columns

The `Slot` class stores:

- position
- size
- type
- pile contents

That means the UI is backed by a clean game model instead of random visual state.

## Step 3: build the card object

The `Card` class is where game data and interactive UI meet.

It stores:

- suit and rank
- left and top position
- current slot
- whether the card is face up
- whether the card is visible
- the Ruflet control reference used for updates

This is a very important Ruflet lesson:

- app state and control references can live together when needed
- `page.update(...)` can then patch position or image state without rebuilding everything

## Step 4: render a card as a control

Each card becomes a gesture-aware control:

```ruby
@control ||= gesture_detector(
  left: left,
  top: top,
  visible: visible,
  on_pan_start: ->(_e) { @game.start_drag(self) },
  on_pan_update: ->(e) { @game.drag(self, e) },
  on_pan_end: ->(_e) { @game.drop(self) },
  on_tap: ->(_e) { @game.card_tap(self) },
  on_double_tap: ->(_e) { @game.card_double_tap(self) },
  content: image(image_url, width: @w, height: @h)
)
```

This step alone teaches a lot:

- Ruflet can attach drag gestures directly to controls
- the game object handles the rules
- the card object knows how to represent itself visually

## Step 5: compute the board layout

The `setup_layout` method is worth studying carefully.

It calculates:

- viewport-aware widths
- card size
- gaps between columns
- tableau offsets
- drop proximity thresholds

This is one of the best parts of the example because it shows how Ruflet apps can adapt layout using live client details rather than fixed assumptions.

## Step 6: create slots and deck

The example then separates setup into small steps:

- `create_slots`
- `create_deck`
- `deal`

That separation is excellent practice for any larger Ruflet app:

- layout first
- model objects second
- initial state third

## Step 7: understand dealing

The `deal` method teaches a useful pattern for many stateful apps:

1. clear old state
2. reset model objects
3. place objects into their starting containers
4. reveal only the parts that should be visible

Even if you are not building a card game, this reset-and-rebuild pattern is useful for dashboards, workflows, editors, and board-style apps.

## Step 8: understand drag and drop

The drag flow is split into three methods:

- `start_drag`
- `drag`
- `drop`

This is the right way to study the example.

### `start_drag`

This decides whether the selected card can move and remembers its original position.

### `drag`

This updates the dragged card group as the pointer moves.

### `drop`

This finds a valid destination and either places the cards or sends them back.

That separation keeps the interactive logic understandable even though the app is much larger than the earlier tutorials.

## Step 9: understand the rules

Rule methods are intentionally small:

- `valid_foundation?`
- `valid_tableau?`
- `candidate_slots`

This is a strong design choice. The UI code is complicated enough already, so the game rules stay isolated and readable.

## Step 10: understand rendering

The board is finally mounted like this:

```ruby
board = container(width: @board_w, height: @board_h, content: stack(children: controls))
body = container(
  expand: true,
  padding: @outer,
  content: column(
    expand: true,
    spacing: 10,
    children: [@status_control, board]
  )
)

@page.add(body, appbar: app_bar(...))
```

That is the architectural payoff:

- a normal app bar
- a board container
- a `stack` for absolute-positioned card controls
- page updates for card movement and flip state

## How to study this example productively

Do not try to rewrite the whole file in one pass.

Use this order:

1. read `Suite`, `Rank`, `Slot`, and `Card`
2. read `setup_layout`, `create_slots`, `create_deck`, and `deal`
3. read `start_drag`, `drag`, and `drop`
4. read `valid_foundation?` and `valid_tableau?`
5. read `render`

That order makes the example far easier to absorb.

## Run the example

```bash
cd examples
bundle install
bundle exec ruflet run solitaire
```

## What you learned

- how larger Ruflet apps can still stay organized
- how to combine Ruby domain models with interactive controls
- how gesture handling works in practice
- how `stack`, `container`, and targeted updates support game-like interfaces
