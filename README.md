🛑 This is a deprecated and unsupported gamemode. We are releasing this for learning purposes, and it may or may not work on the current version of RedM. No support is given, but you may join [our Discord](https://discord.gg/XAQ34Td) to chat with us. 🛑

Example videos of the gamemode [here](https://www.youtube.com/watch?v=Z7-73l9gT_g) and [here](https://www.youtube.com/watch?v=X_PU0VhRDhk).


# Usage
You may use any part of this gamemode as you like, but you need to give credit. See the LICENSE for information on how to give credit. You are free to host servers with this, use the code for your own gamemodes and learning, etc. Just please don't take credit for it.

You may credit "Paradigm" as the author.

# Support
No support is given for this, but you may join [our Discord](https://discord.gg/XAQ34Td) and we might be able to help you with questions if you have any.

# Notes

Much of this code was written in June/July of 2019, with the intention of creating a wave survival gamemode for FiveM.

However, with the release and announcement of RedM later that year, we quickly turned our efforts to creating a wave survival gamemode for RedM and using our framework (OOF, formerly NAPI) to enable developers to create cross-game gamemodes.

The original release of this wave survival gamemode was on December 22, 2019 and there were many updates in the next 6 months that improved stability and added new features.

The wave survival gamemode uses a much, much earlier and outdated version of OOF. It probably still works, but you should use the newer version of OOF that is open source.

Old README below (NAPI is an earlier version of [OOF](https://github.com/Paradigm-MP/oof)):

# RedM Wave Survival Gamemode
Repository for all gamemode code for the Wave Survival Gamemode on [RedM](https://redm.net/). Also includes NAPI, which is our abstraction layer for natives. 

## NAPI (Native Abstraction Programming Interface)
All gamemode code uses a class system, provided by NAPI. A class system allows for far better code organization and module interaction than a non-class approach. Keep in mind that because NAPI uses classes, its features cannot be used with existing scripts unless they are integrated with it. NAPI requires that you use a **single-resource gamemode**, meaning that all of your gameplay logic, data persistence, networking, UI, and everything else must be inside of one resource. This is due to a limitation within the CFX export system because it does not support our class system.

# Credits
The `mysql-async` module was created by [brouznouf](https://github.com/brouznouf/fivem-mysql-async/tree/2.0).

[system] resources are from the default RedM server data.