# ii-widgets

Registry for widgets of [dots-hyprland/extensions](https://github.com/Berupor/dots-hyprland).
One file, `index.json`: what the Widgets page lists so you can install a widget without
knowing its url.

A widget itself lives in its own repository. This is only the listing.

## Adding yours

Open a PR that appends an entry. Keep the list sorted by `id`.

```json
{
  "id": "hello",
  "name": "Hello",
  "description": "Template widget: copy this repo to start your own",
  "icon": "waving_hand",
  "author": "Berupor",
  "url": "https://github.com/Berupor/ii-widget-hello",
  "minShellVersion": "1.0",
  "dependencies": [],
  "tags": ["template"]
}
```

- `id` must match `widgetId` in your `Manifest.qml`. It also names the install directory
- `icon` is a Material Symbols name, same as the manifest's
- `minShellVersion` is the widget contract you built against. The page hides entries it
  cannot run, so a wrong one here makes your widget invisible or broken
- `dependencies` are binaries the widget needs, shown before install
- `name` and `description` are listed as written, no translation

No `version` field: the installed `Manifest.qml` is the one that reports it, and a copy
here would go stale on every release.

Start from [ii-widget-hello](https://github.com/Berupor/ii-widget-hello), it is the
template and carries the contract in its README.

## Checking

`./validate.sh` runs what CI runs: parse, required fields, unique ids, reachable urls.
