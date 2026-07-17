# Styling Native HTML

Native HTML screens are styled with a `class` attribute that reads like
Tailwind. Each utility maps to a real native prop, and a control only picks up
the utilities it actually supports — so you can drop any class on any tag
without breaking it.

```erb
<column class="p-6 gap-4 items-center">
  <text class="text-2xl font-bold text-slate-900">Welcome</text>
  <text class="text-sm text-slate-500">Styled with familiar classes.</text>
</column>
```

## Spacing and size

- padding: `p-4`, `px-6`, `py-2`, `pt-3`, `pr-1`, `pb-1`, `pl-1`
- margin: `m-4`, `mx-auto`-style edges (`mx-6`, `my-2`), and negatives (`-mt-2`)
- gaps between children: `gap-3`, `gap-x-4`, `gap-y-2`
- width and height: `w-64`, `h-32`, `size-12`, `min-h-screen`, `w-full`,
  `h-full`, `flex-1`
- aspect ratio: `aspect-square`, `aspect-video`, `aspect-[4/3]`

The spacing scale matches Tailwind (`4` = 16px). For an exact pixel value use the
arbitrary form: `w-[320px]`, `p-[10px]`.

## Color

- background: `bg-slate-100`, `bg-emerald-600`, `bg-[#123456]`
- text: `text-slate-900`, `text-emerald-600`
- theme tokens map to your app's color scheme: `bg-primary`, `text-on-surface`,
  `bg-surface-variant`
- gradients: `bg-gradient-to-r from-blue-500 via-sky-400 to-cyan-300`

The full Tailwind v3 palette is available (`slate`, `gray`, `red`, `emerald`,
`sky`, `violet`, …, in shades `50`–`900`).

## Typography

- size: `text-xs`…`text-9xl`, or `text-[42]`
- weight: `font-bold`, `font-semibold`, `font-medium`, `font-light`
- family: `font-mono`, `font-serif`
- style: `italic`, `underline`, `line-through`
- spacing: `tracking-wide`, `leading-relaxed`
- case: `uppercase`, `lowercase`, `capitalize`
- alignment and overflow: `text-center`, `truncate`, `line-clamp-2`,
  `whitespace-nowrap`, `text-ellipsis`

## Shape and effects

- corners: `rounded-2xl`, `rounded-t-lg`, `rounded-br-sm`, `rounded-full`
- borders: `border`, `border-2`, `border-t`, `border-red-500`
- shadow and opacity: `shadow`, `shadow-lg`, `opacity-75`
- blur: `blur`, `blur-md`

## Layout and display

- flex alignment: `items-center`, `items-start`, `justify-between`,
  `justify-center`, `place-center`
- wrapping and scrolling: `flex-wrap`, `scroll`, `overflow-hidden`
- image fit: `object-cover`, `object-contain`
- visibility: `hidden`, `invisible`

## Transforms, position, and motion

- transforms: `rotate-45`, `-rotate-12`, `scale-95`
- absolute position (inside a `<stack>`): `top-4`, `left-2`, `inset-0`,
  `inset-x-4`
- implicit animation: `transition`, `duration-300`, `ease-in-out` — property
  changes then animate

```erb
<container class="p-6 rounded-2xl bg-gradient-to-br from-indigo-500 to-pink-500
                  shadow-lg transition duration-300">
  <text class="text-white font-bold text-xl">Gradient card</text>
</container>
```

## Beyond the class list

The class vocabulary covers the common cases. Anything it does not map is always
reachable as an explicit attribute — the value passes straight through as the
native prop:

```erb
<container class="p-6 rounded-2xl" blur="8"
           gradient='{"_type":"linear","begin":{"x":-1,"y":0},"end":{"x":1,"y":0},"colors":["#4f46e5","#06b6d4"]}'>
  …
</container>
```

There are no responsive (`md:`) or state (`hover:`) variants — a server-rendered
native screen has no place for them. Use conditional ERB for responsive layouts.

## Related guides

- [Native HTML Apps](/docs/rails-native-html)
- [Components](/docs/rails-native-components)
- [Navigation and Forms](/docs/rails-native-interactivity)
