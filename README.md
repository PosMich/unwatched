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

    pip install Pygments

Install
=======

    git clone xxxxx <name>
    cd <name>
    npm install

Userconfig
==========

> A <b>*`userconfig.coffe`*</b> file must be created in the `modules` directory, because sensible data is stored here, it isn't checked in into the version control system.

    module.exports =
        port:    3000
        appName: "AppName"
        sessionSecret: "Seeecreet 64 chars long"



Take a look at the Gruntfile
============================


    grunt --help



Docs
====

> [groc](https://github.com/nevir/groc/) is used for generating the documentation.

> The files are moved to the <b>*`public`*</b> dir, you can access them via **`http://servername/docs`**.


TODO
====
> *XSS!!!* node-validator


> ## CI
>>Would be nice :)
