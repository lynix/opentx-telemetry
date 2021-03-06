# opentx-telemetry
**[OpenTX](http://www.open-tx.org) Telemetry Script for Taranis X9D Plus with
X8R Receiver**

Based on [_olimetry.lua_](https://www.youtube.com/watch?v=dMNDhq2QJv4) by
Ollicious (bowdown@gmx.net)

## About
This is a simplified and stripped-down variant of the _olimetry.lua_ script by
Ollicious. I started working on this as some widgets of the original version did
not work on OpenTX 2.1.6.

It does not offer the same degree of customizability, as it only provides a
subset of the original widgets. Code clean-up brought a drop of ~4% CPU usage in
Companion 2.1 simulation.

![](https://github.com/lynix/opentx-telemetry/blob/master/screenshot.png)

## Usage
* copy _telemetry.lua_ and the _GFX_ folder to _/SCRIPTS/TELEMETRY/_ on the
  taranis sd card
* edit constants in the `settings` section to meet your needs
* for the flight mode widget to work, you almost certainly need to edit the code
  (`fmWidget()`) to fit your channel and mode bindings

## Contributing
I provide this _as-is_, in hope that it might be an inspiration or starting
vector for someone making his/her own telemetry script. I don't see it as
ready-to-use telemetry script but rather a template for one.

However, pull requests for improvements on this basic functionality are always
welcome.

## License
This work is published under the terms of the MIT License, see file `LICENSE`.
