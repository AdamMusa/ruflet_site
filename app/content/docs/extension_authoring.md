# Extension Authoring

Ruflet extensions follow Flet's user-extension architecture: a typed Ruby DSL
control and a Flutter package share one exact wire type. The Flutter package
exports `Extension`, subclasses `FletExtension`, and returns the widget from
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

The Flutter package exposes the normal Flet extension entrypoint:

```dart
library;

import "package:flet/flet.dart";
import "package:flutter/widgets.dart";

class Extension extends FletExtension {
  @override
  Widget? createWidget(Key? key, Control control) {
    if (control.type != "rating") return null;
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

## Client registration

A bundled extension needs four client declarations: its dependency in
`pubspec.yaml`, its Dart import, `Extension()` in the Flet extension list, and
its key in `ruflet.yaml`. Native capabilities also need permission mapping.
Changing an extension requires a rebuild or full Flutter restart.

Test the Ruby helper in every supported DSL context, rejected properties,
serialized event names, and invoke method names. On the Flutter side, test
configuration parsing, `createWidget` routing, events, methods, and lifecycle
behavior. The official [Flet user-extension guide](https://flet.dev/docs/extend/user-extensions/)
describes the underlying Flutter contract.
