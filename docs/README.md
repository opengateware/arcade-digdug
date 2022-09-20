[![Dig Dug Logo](digdug-logo.png)](#)

---

[![Active Development](https://img.shields.io/badge/Maintenance%20Level-Actively%20Developed-brightgreen.svg)](#status-of-features)
[![Build](https://github.com/opengateware/arcade-digdug/actions/workflows/build-pocket.yml/badge.svg?branch=master&event=push)](https://github.com/opengateware/arcade-digdug/actions/workflows/build-pocket.yml)
[![release](https://img.shields.io/github/release/opengateware/arcade-digdug.svg)](https://github.com/opengateware/arcade-digdug/releases)
[![license](https://img.shields.io/github/license/opengateware/arcade-digdug.svg?label=License&color=yellow)](#legal-notices)
[![issues](https://img.shields.io/github/issues/opengateware/arcade-digdug.svg?label=Issues&color=red)](https://github.com/opengateware/arcade-digdug/issues)
[![stars](https://img.shields.io/github/stars/opengateware/arcade-digdug.svg?label=Project%20Stars)](https://github.com/opengateware/arcade-digdug/stargazers)
[![discord](https://img.shields.io/discord/676418475635507210.svg?logo=discord&logoColor=white&label=Discord&color=5865F2)](https://chat.raetro.org)
[![Twitter Follow](https://img.shields.io/twitter/follow/marcusjordan?style=social)](https://twitter.com/marcusjordan)

## Namco [Dig Dug] Compatible Gateware IP Core

This Implementation of a compatible Dig Dug arcade hardware in HDL is the work of [MiSTer-X].

## Overview

Dig Dug is single screen action game in which the player must dig horizontal and vertical tunnels to reach and eliminate the underground-dwelling monsters living there. This is achieved by either inflating them with an air pump until they explode, or by dropping rocks onto them.

## Technical specifications

- **Main CPU:**     Zilog Z80 @ 3.072 MHz
- **Graphics CPU:** Zilog Z80 @ 3.072 MHz
- **Sound CPU:**    Zilog Z80 @ 3.072 MHz
- **Sound Chip:**   Namco 3-channel WSG
- **Resolution:**   288×224, 16 colors
- **Display Box:**  384×264 @ 6.144 MHz
- **Aspect Ratio:** 9:7
- **Orientation:**  Vertical (90º)

## Compatible Platforms

- Analogue Pocket

## Compatible Games

> **ROMs NOT INCLUDED:** By using this gateware you agree to provide your own roms.

| **Game**                        | Region | Status |
| :------------------------------ | :----: | :----: |
| Dig Dug (Rev 2)                 |  JPN   |   ✅   |
| **Alternatives**                |        |        |
| Dig Dug (Rev 1)                 |  JPN   |   ✅   |
| Dig Dug (Atari, Rev 1)          |  USA   |   ✅   |
| Dig Dug (Atari, Rev 2)          |  USA   |   ✅   |
| Dig Dug (Manufactured by Sidam) |  ITA   |   ✅   |

### ROM Instructions

1. Download and Install [ORCA](https://github.com/opengateware/tools-orca/releases/latest) (Open ROM Conversion Assistant)
2. Download the [ROM Recipes](https://github.com/opengateware/arcade-digdug/releases/latest) and extract to your computer.
3. Copy the required MAME `.zip` file(s) into the `roms` folder.
4. Inside the `tools` folder execute the script related to your system.
   1. **Windows:** right click `make_roms.ps1` and select `Run with Powershell`.
   2. **Linux and MacOS:** run script `make_roms.sh`.
5. After the conversion is completed, copy the `Assets` folder to the Root of your SD Card.
6. **Optional:** an `.md5` file is included to verify if the hash of the ROMs are valid. (eg: `md5sum -c checklist.md5`)

> **Note:** Make sure your `.rom` files are in the `Assets/digdug/common` directory.

## Status of Features

> **WARNING**: This repository is in active development. There are no guarantees about stability. Breaking changes might occur until a stable release is made and announced.

- [ ] Dip Switches
  - [x] Reset Core
  - [x] Enter Service Mode
  - [ ] Change Difficulty
  - [ ] Change Number of Lives
  - [ ] Change Score for Bonus Life
- [ ] Pause
- [ ] Hi-Score Save


## Credits and acknowledgment

- [Alan Steremberg]
- [Jim Gregory]
- [Matt McConnell]
- [MiSTer-X]

## Powered by Open-Source Software

This project borrowed and use code from several other projects. A great thanks to their efforts!

| Modules                        | Copyright/Developer     |
| :----------------------------- | :---------------------- |
| [Data Loader]                  | 2022 (c) Adam Gastineau |
| [Dig Dug RTL]                  | 2017 (c) MiSTer-X       |
| [Generic Dual-Port RAM module] | 2021 (c) Jim Gregory    |
| [Pause Handler]                | 2021 (c) Jim Gregory    |
| [TV80]                         | 2004 (c) Guy Hutchison  |

## Legal Notices

Dig Dug © 1982 NAMCO LTD. All rights reserved. Dig Dug is a trademark of BANDAI NAMCO ENTERTAINMENT INC.
All other trademarks, logos, and copyrights are property of their respective owners.

The authors and contributors or any of its maintainers are in no way associated with or endorsed by Bandai Namco Entertainment Inc.

[Data Loader]: https://github.com/agg23/analogue-pocket-utils
[Dig Dug RTL]: https://github.com/MiSTer-devel/Arcade-DigDug_MiSTer/tree/master/rtl
[TV80]: https://github.com/hutch31/tv80
[Pause Handler]: https://github.com/JimmyStones/Pause_MiSTer
[Dig Dug]: https://en.wikipedia.org/wiki/Dig_Dug
[Generic Dual-Port RAM module]: https://github.com/JimmyStones

[Alan Steremberg]: https://github.com/alanswx
[Jim Gregory]: https://github.com/JimmyStones
[Matt McConnell]: https://github.com/mattmcwru
[MiSTer-X]: https://github.com/MrX-8B
