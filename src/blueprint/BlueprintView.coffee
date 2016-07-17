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
tracking = require './tracking'
inventory = require './inventory'


### BlueprintView ###
module.exports = Backbone.View.extend
    template: _.template $("#blueprint-tpl").html()
    className: "col-sm-6 blueprint"

    events:
        "click a.track": "track"
        "click .panel-body.toggle": "toggleNextBody"

    initialize: (options) ->
        @listenTo @model, "destroy", @remove

    render: ->
        data = @model.toJSON()
        for ingredient in data.ingredients
            ingredient.inventory = inventory.get ingredient.material.id
        data.completion = @model.completion()
        @$el.html @template(data)
        return this

    toggleNextBody: (e)->
        $(e.currentTarget).next().slideToggle(80)
        $(e.currentTarget).find(".glyphicon")
            .toggleClass("glyphicon-triangle-bottom")
            .toggleClass("glyphicon-triangle-top")
        this

    track: (event)->
        tracking.trackBlueprint(@model)
        @$el.find(".drone-flash")
            .fadeToggle("fast")
            .delay(400)
            .fadeToggle("fast")
        event.preventDefault()
        return this
