# Extension Authoring

A Ruflet extension pairs a typed Ruby DSL control with a Flutter package that
renders its wire type. The Flutter package exports `Extension`, which extends
`RufletExtension` from `package:ruflet/ruflet.dart` and returns the widget from
`createWidget`. Ruflet does not require a separate client adapter.

## Package shape

The Ruby side defines a `Ruflet::Control` subclass with an explicit `TYPE`,
accepted `KEYWORDS`, event properties, and any mounted-control methods. Register
it with `Ruflet::Extensions.register_control` so the helper is available in the
bare DSL, `Ruflet`, `Ruflet::UI`, and widget builders:

```ruby
module MyExtension
  class RatingControl < Ruflet::Control
    TYPE = "rating"
    KEYWORDS = %i[value maximum on_change width height].freeze

    def initialize(id: nil, **props)
      super(type: TYPE, id: id, **props)
    end
  end
end

Ruflet::Extensions.register_control(
  :rating,
  control_class: MyExtension::RatingControl,
  flutter: {
    package: "ruflet_rating",
    import: "package:ruflet_rating/ruflet_rating.dart",
    alias: "ruflet_rating",
    constructor: "Extension"
  }
)
```

The Flutter package exports the `Extension` entrypoint. Ruflet sends the
control type in CamelCase, so `TYPE = "rating"` arrives as `Rating`:

```dart
library;

import "package:flutter/widgets.dart";
import "package:ruflet/ruflet.dart";

class Extension extends RufletExtension {
  @override
  Widget? createWidget(Key? key, Control control) {
    if (control.type != "Rating") return null;
    return LayoutControl(
      control: control,
      child: RatingWidget(key: key),
    );
  }
}
```

To pick the wire type yourself, set a `WIRE` constant on the control class,
for example `WIRE = "Rating"`; the client then receives exactly that name.
`register_control` also takes `helpers:` when the DSL helper names differ from
the registered name, for example `helpers: %i[rating star_rating]`.

### Extension hooks

`RufletExtension` has four methods; override the ones your package needs:

- `createWidget(key, control)` returns the widget for a visual control, or
  `null` for types the extension does not handle.
- `createService(control)` returns a `RufletService` for a control that draws
  nothing, such as an audio player. The service's `init`, `update` and
  `dispose` run when Ruby registers it, changes its properties and removes it.
  In Ruby, register such a control with `page.add_service(control)` instead of
  `page.add`.
- `ensureInitialized()` runs once when the client starts, for SDK setup.
- `createIconData(iconCode)` maps icon codes to an icon font the package
  ships.

To run a method on a mounted control from Ruby, register a listener in Dart
with `control.addInvokeMethodListener` and return the result from it; the Ruby
side calls `runtime_page.invoke(self, "method_name", args: { ... }, timeout:, on_result:)`.

Keep Ruby and Dart property names and defaults identical. Flutter events check
the matching `on_<event>` flag and call `control.triggerEvent` with JSON-safe
data. Mounted Ruby methods call `runtime_page.invoke` and should accept
`timeout:` and `on_result:`.

## Use the extension

Add the extension under `extensions:` in `ruflet.yaml`, then rebuild your app.

For an extension Ruflet does not include, follow [Use an extension Ruflet does
not bundle](/docs/extensions#use-an-extension-ruflet-does-not-bundle).
