==========================
Collector-Drone (frontend)
==========================

Unofficial companion web-app for Elite: Dangerous (property of Frontier
Developments). Collector-Drone lets you manage blueprints and material inventory
for crafting engineer upgrades.

Data pulled from `Engineering Database & Calculator <https://forums.frontier.co.uk/showthread.php/248275>`_
gathered by `Qohen-Leth <https://forums.frontier.co.uk/member.php/118579-Qohen-Leth>`_.
Icons and colors by `edassets.org <http://www.edassets.org/>`_.

UI/UX Concept by Carina Lea Meyer
Programming by Frederik Schumacher
Copyright 2016  Frederik Schumacher, Carina Lea Meyer

`http://collector-drone.one/ <http://collector-drone.one/>`_

*****
Setup
*****

Create a python virtual env and install dependencies::

    > virtualenv env
    > source env/bin/active
    > pip install -r packages.txt

Building the frontend::

    > npm install
    > grunt

After the initial build you can use grunt-watch::

    > grunt watch

Now open ``build/static/index.html`` in a browser.
