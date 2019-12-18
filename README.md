# MetaHCR v2.0 - An Implementation of MetaHCR in Elm and Phoenix

MetaHCR v2.0 is a reimplementation of the original application [MetaHCR](https://github.com/metahcr/metahcr_v1.0) - Metagenomics on Hydrocarbon Resources - from JavaScript/Django/Python to Elm/Phoenix/Elixir. Currently [W3.CSS](https://www.w3schools.com/w3css/) is used for all web page styling and behavior - no JavaScript (so far). Subsequent stages may use one of the CSS Elm packages to define CSS in Elm - the Styles module only defines strings.

A brief overview of the data: Investigations collect one or more Samples; Samples have one or more Analyses performed; and an Analysis contain one or more Organisms. Organisms of concern are primarily from the domains  [Bacteria](https://en.wikipedia.org/wiki/Bacteria) and [Archaea](https://en.wikipedia.org/wiki/Archaea). As an example of one of its functions, MetaHCR allows one to determine all the Samples of an Investigation that contain a particular organism.


As of 1 May 2018: all inter-relationships between entities, with the exception of Organisms, can be explored in the Browse page. If you are interested, the v1.0 version of MetaHCR contains instructions for creating the database. Once that is done, you'll find instructions for installing the rest of the application's tools and languages below.

## Installation
Elixir, Phoenix, and Elm need to be installed first. Phoenix/Elixir installation instructions can be found [in the Phoenix documentation](https://hexdocs.pm/phoenix/installation.html#content). An Elm installation guide can be found at the [Elm website](https://guide.elm-lang.org/install.html). W3CSS styling can be downloaded, however, this application accesses the style sheets via a CDN.

### Phoenix
With this repository:
1. `$ cd <installation directory>`
2. `$ mix deps.get`
3. `$ cd apps/metahcr_web/assets`
4. `$ npm install`

### Elm

This step will download all the required Elm packages and compile the Elm code.
1. `$ cd <installation directory>`
2. `$ cd apps/metahcr_web/assets/elm`
3. `$ elm-compile.cmd or ./elm-compile.sh`

**A note on Elm recompilation** Phoenix uses [Brunch](http://brunch.io/) to monitor changes in the Elixir files and provide automatic recompilation. There is a Brunch plugin - [elm-brunch](https://www.npmjs.com/package/elm-brunch) - that can monitor changes to Elm files. However, I had trouble with the proper recompilation of multiple, interdependent Elm source files. Hence this Phoenix project does not rely on automatic recompilation of the Elm code. You can use one of the elm-compile scripts to recompile manually or some editors can be configured to execute commands upon the saving of files. Atom, for instance, has a save-commands plugin that will execute elm-make of the Main.elm file anytime an Elm file is saved. An Atom `save_commands.json` file is included.

### Running the Phoenix Server
Start the Phoenix web server:
1. `$ cd <installation directory>`
2. `$ mix phx.server`

You can begin using the application by pointing your browser at [localhost:4000](localhost:4000).
