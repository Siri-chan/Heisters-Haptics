# Heister's Haptics
## About
### What is Heister's Haptics?
Heister's Haptics is a fast, scriptable, and highly customizable haptics and vibration engine for Payday 2, with a wide range of device support.

### How does it work?
Heister's Haptics requires:
- SuperBLT - Hooks and Lua
- Beardlib - Settings in the `Mod Menu` entry 
- [Intiface Central](https://intiface.com/central/)(available separately) \[[source](https://github.com/intiface/intiface-central)\]  - To connect to Haptic devices

Intiface Central interfaces with many different haptic devices, including but not limited to XInput devices (on Windows). It can therefore connect to most, if not all, of your game controllers to let you control them via in-game events.

For this you can write you own rules with the inbuilt `haptics-modes` feature.
We provide a default mode that sets the haptic strength based on the current assault state.
#### Technical Details
We created a SuperBLT Native Plugin to talk to Intiface asynchronously since Lua has a few issues with that. This Plugin will keep the connection to Intiface open in a separate thread, while the game is running, and simply receive events from the Lua part of the mod.

More developer documentation, as well as documentation on the `haptics-modes` feature will be available on the Mod's GitHub once released.
### What can I use this for?
An Example usage (and also our test case) would be to make your VR Controllers, like the Valve Index Controllers, vibrate based on the current assault state. In the provided `haptics-mode` "Default", *Captain Winters* as well as *Point of no return* cause the haptics motors to run on 100% strength for the entire duration. This can and **will** mess up your aim, amping the difficulty just a little more.

I'm sure you can think of many other use-cases, as well as different rules for when the strength should change (maybe HP%?) in which case you can just write your own `haptics-mode` for it.

### What Languages are available?
Currently only English, however we *are* using the localization feature and might be adding German and Japanese down the line.

### Is this done?
While everything so far works and we're confident about this release, there's no doubt that different configurations might cause unforeseen consequences. We will be actively working on this mod for the foreseeable future, fixing issues, as well as potentially adding features if requested often/we see it fit.

### Disclaimer
We currently only ship the `.dll` version of the plugin and XInput only works on Windows, however we have tested this mod via proton on Linux and have found it to be connecting to and communication with Intiface just fine.

## TODO: Add step by step usage instructions
### How to set up Intiface Central
### How to enable/adjust `haptics-modes`
