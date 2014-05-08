Unwatched - Playground
======================



Repository
==========

xxxx


> ## Branches & CI

>> ### dev

>> > Here's where the developers are circling around, doing random stuff (on their local environments ;)).

>> > Here the development and debug environments are used.


>> ### test

>> > If there's a ne plus ultra (or not) feature, the developer merges it into the *`test`* branch and runs tests (atm. manually). Usually the CI server watches the test brunch and runs the tests automatically when something has changed.

>> > Here's debug land.


>> ### master

>> > If all tests are passed successfully, the CI server (or some human like individual) merges the test branch into the master and deploys the code to the production server.


Prerequisites
=============

> ## Node.js

>> ### NVM

>>>[Go there](https://github.com/creationix/nvm)

>> ### Windows

>>> [Try this](http://www.ubuntu.com/download/desktop), [this](http://wiki.centos.org/Download), or [this](http://fedoraproject.org/get-fedora).

> ## coffee-script, grunt

    npm install -g coffee-script
    npm install -g grunt-cli

> ## Pygments

>> needed to generate documentation
>> 
>> `pip install Pygments`

Install
=======

    git clone xxxxx <name>
    cd <name>
    npm install

Userconfig
==========

> A <b>*`userconfig.coffe`*</b> file must be created, because sensible data is stored here, it isn't checked in into the version control system.

    module.exports =
        appName: "AppName"
        sessionSecret: "Seeecreet 64 chars long"



Run
===

> Run <b>*`cake`*</b> to see all available commands:

    [ubuser@ubuthink playground]$ cake
    Cakefile defines the following tasks:<br>

    cake docs                 # Generate annotated source code with Docco and move it to public dir
    cake build                # compiles coffeescript files to javascript into the .app directory
    cake dev                  # run 'build' task, start dev env
    cake debug                # run 'build' task, start debug env
    cake run                  # run 'build' task, start production env


Docs
===

> [Docco](http://jashkenas.github.io/docco/) is used for generating the documentation.

> The files are moved to the <b>*`public`*</b> dir, you can access them via **`http://servername/docs`**.


Build
=====

> The cake task <b>*`cake build`*</b> compiles the *`.coffeescript`* files to plain js for easier debugging.

> ##Environments

>> Before starting each environment, the <b>*`build`*</b> task is invoked to generate the js files.

>> ### Start Development Environment

    cake dev

>>> In Development mode [node-supervisor](https://npmjs.org/package/supervisor) is used to watch several folders for file changes (atm the file extensions `js` and `html` in the folders `.app` and `views`).

>>> If one of the these files change (or the server crashes) the node inspector automatically restarts the app.

>> ### Start Debug Environment

    cake debug

>>> In Debug Environment, all coffee files are watched and the server is started in debug mode.

>>> The [node-inspector](https://npmjs.org/package/node-inspector) is used as debugging interface.

>>> After invoking the node-inspector, google-chrome will open a new window with the debug interface (usually http://localhost:8989/debug?port=5858).
>>> If something strange happens, take a look at the used ports.

>> ### Start Production Environment

    cake run

>>> In Production Environment, all files located in *`assets/`* are compiled, concenated and moved to *`buildAssets`*. These files are served with an MD5 hash suffix and use a far-future expires header. These files are not stored in the repository.


Debugging
=========
    cake debug

> See *`Debug Environment`*, [node-inspector](https://npmjs.org/package/node-inspector).

TODO
====
> *XSS!!!* node-validator

Future?
=======
> ## Mocha-Testing

> [http://visionmedia.github.io/mocha/](http://visionmedia.github.io/mocha/)


> ## yeoman

> [http://yeoman.io/](http://yeoman.io/):
>> Yeoman 1.0 is more than just a tool. It's a workflow; a collection of tools and best practices working in harmony to make developing for the web even better.
>> ### yo
>>> *`yo`* is used to scaffold out a application. This means that you can make (or use existing templates) several templates (Hale specific node.js with express, node.js with angular, angular.js projects, rails projects, whatever...) and reuse them.

>> ### grunt
>>> [Grunt](http://gruntjs.com/) runs several tasks, like to build, preview and test your project.

>> ### bower
>>> [Bower](http://bower.io/) is used for dependency management, so that you don't need to manually download and manage your scripts (like jquery, jquery UI, angular, ....). Beside the official packages you can add:

>>> * a remote Git Endpoint (private or public)
>>> * a Github shorthand `someone/some-package` (is resolved to: `http://github.com/someone/some-package`)
>>> * a local endpoint (i.e. a folder containing a local Git repository)
>>> * a URL to a file (zip and tar will automatically be extracted)


> ## CI
>>Would be nice :)
