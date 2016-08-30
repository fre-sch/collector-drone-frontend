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
inventory = require "./inventory"
TrackMaterialView = require "./TrackMaterialView"


### TrackMaterialCollectionView ###
module.exports = Backbone.View.extend
    el: $("#tracker-materials")

    initialize: (options)->
        {@materials} = options
        @listenTo tracking.materials, "add", @addTrackMaterial
        @listenTo tracking.materials, "remove", @removeTrackMaterial
        @listenTo tracking.materials, "reset", @onTrackMaterialsReset
        return this

    removeTrackMaterial: ->
        if not tracking.materials.length and not tracking.blueprints.length
            $("#introduction").show()
        return this

    onTrackMaterialsReset: (collection, options) ->
        for model in collection.models
            @addTrackMaterial(model)
        return this

    addTrackMaterial: (trackMaterial) ->
        createViewAndAppend = _.bind((trackMaterial, material) ->
            view = new TrackMaterialView
                model: trackMaterial
                material: material
                inventory: inventory.getItem(trackMaterial.id)
            $("#introduction").hide()
            @$el.append(view.render().el)
            return
        , this, trackMaterial)

        @materials.getOrFetch trackMaterial.id,
            success: createViewAndAppend

        return this
