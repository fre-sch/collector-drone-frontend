###
# Unofficial companion web-app for Elite: Dangerous (property of Frontier
# Developments). Collector-Drone lets you manage blueprints and material
# inventory for crafting engineer upgrades.
# Copyright (C) 2016  Frederik Schumacher
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
###


module.exports = Backbone.Router.extend
    routes:
        "tracker(/:view)": "trackerView"
        "library(/:view)": "libraryView"
        ":section": "viewScreen"

    viewScreen: (section)->
        $section = $("#" + section)
        if $section.get()
            $section.addClass("active").siblings().removeClass("active")
            $("#main-navbar li").removeClass("active")
            $("#view-" + section).addClass("active")
        return this

    trackerView: (view="blueprints")->
        @viewScreen "tracker"
        $view  = $("#tracker-" + view)
        if $view.get()
            $view.addClass("active").siblings().removeClass("active")
            $("#view-tracker-" + view).addClass("active").siblings().removeClass("active")
            Backbone.trigger("action:section", "tracker:" + view)
        return this

    libraryView: (view="blueprints")->
        @viewScreen "library"
        $view  = $("#library-" + view)
        if $view.get()
            $view.addClass("active").siblings().removeClass("active")
            $("#view-library-" + view).addClass("active").siblings().removeClass("active")
            $("#library-#{view}-filter").addClass("active").siblings().removeClass("active")
            Backbone.trigger("action:section", "library:" + view)
        return this
