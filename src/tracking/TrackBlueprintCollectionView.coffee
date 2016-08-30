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
tracking = require "./tracking"
TrackBlueprintView = require "./TrackBlueprintView"


### TrackBlueprintCollectionView ###
module.exports = Backbone.View.extend
    el: $("#tracker-blueprints")

    initialize: (options)->
        {@blueprints} = options
        @listenTo tracking.blueprints, "add", @onAddTrackBlueprint
        @listenTo tracking.blueprints, "remove", @onRemoveTrackBlueprint
        @listenTo tracking.blueprints, "reset", @onTrackBlueprintsReset
        return this

    onAddTrackBlueprint: (trackBlueprint) ->
        createViewAndAppend = _.bind((trackBlueprint, blueprint) ->
            view = new TrackBlueprintView
                model: {trackBlueprint, blueprint}
            $("#introduction").hide()
            @$el.append view.render().el
            return this
        , this, trackBlueprint)

        @blueprints.getOrFetch trackBlueprint.id,
            success: createViewAndAppend

        return this

    onRemoveTrackBlueprint: ->
        if not tracking.materials.length and not tracking.blueprints.length
            $("#introduction").show()
        return this

    onTrackBlueprintsReset: (collection, options) ->
        for model in collection.models
            @onAddTrackBlueprint(model)
        return this
