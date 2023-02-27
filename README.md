# Gidk Engine

This is the repository for Gidk Engine, an engine created for making and playing mods for Friday Night Funkin'.

# To Do

- Custom Events
- Custom Shaders
- Custom Dialogue
- Custom Note Skin
- Custom Note Type

## Credits
* [Gidk](https://github.com/Gidk-g) - Programmer of Gidk Engine
* [Teotm](https://github.com/teotm) - Assistant Programmer of Gidk Engine

### Special Thanks
* [Leather128](https://github.com/Leather128) - Programmer of [Funkin Multikey](https://github.com/Leather128/Funkin-Multikey)

# Compiling The Game
1. [Install git-scm](https://git-scm.com/downloads) if you don't have it already.
2. [Install Haxe](https://haxe.org/download/)
3. Open up your Command Prompt/PowerShell or Terminal and type in these following commands in order to install the Haxelibs needed specifically for *Gidk Engine*:
```
haxelib install hmm
haxelib run hmm install
```
4. If you run on Windows, install [Visual Studio Community 2019](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=community&rel=16&utm_medium=microsoft&utm_source=docs.microsoft.com&utm_campaign=download+from+relnotes&utm_content=vs2019ga+button) using these specific components in `Individual Components` instead of selecting the normal options:
```
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)
```
5. Run `lime test <windows/linux/mac>`, choosing your OS. (Ex. `lime test windows`)
