# Testing on Mobile

Mobile is Ruflet's default target for local development.

## Install the Ruflet mobile client

Get the latest client from the [Ruflet releases page](https://github.com/AdamMusa/Ruflet/releases).

## Run your app

```bash
ruflet run main.rb
```

The terminal output includes:

- the local connection URL
- the WebSocket endpoint
- QR code guidance for quick connect

## Connect the client

You can connect in two ways:

- enter the shown URL manually
- use the mobile client's scan feature and scan the QR code or connect info shown by Ruflet

## Why this matters

Testing on a real phone or tablet helps you validate:

- spacing and touch targets
- scrolling behavior
- orientation and responsiveness
- device-aware features like camera, battery, connectivity, or file access

## When to move beyond the client

The mobile client is ideal for rapid iteration. When you are ready to package a product build, move to the publishing guides.
