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

Keep Ruby and Dart property names and defaults identical. Flutter events check
the matching `on_<event>` flag and call `control.triggerEvent` with JSON-safe
data. Mounted Ruby methods call `runtime_page.invoke` and should accept
`timeout:` and `on_result:`.

## Use the extension

Add the extension under `extensions:` in `ruflet.yaml`, then rebuild your app.

For an extension Ruflet does not include, follow [Use an extension Ruflet does
not bundle](/docs/extensions#use-an-extension-ruflet-does-not-bundle).
