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
inventory = require './inventory'
tracking = require "./tracking"


### MaterialView ###
module.exports = Backbone.View.extend
    template: _.template $("#material-tpl").html()

    className: ->
        rarity = @model.get("rarity").replace(/\W+/, "-")
        "col-sm-6 material rarity-#{rarity}"

    events:
        "click .panel-body.toggle": "toggleNextBody"
        "click .btn.inventory-minus": "inventoryMinus"
        "click .btn.inventory-plus": "inventoryPlus"
        "click .btn.track": "track"

    initialize: (options) ->
        @inventoryItem = inventory.getItem @model.id
        @listenTo @inventoryItem, "change", @update
        # @listenTo @model, "change", @render
        @listenTo @model, "destroy", @remove
        this

    render: ->
        data = @model.toJSON()
        data.typeLabel = @model.typeLabel()
        data.inventory = @inventoryItem.get("quantity")
        if not data.inventory
            data.inventory = ""
        @$el.html @template(data)
        this

    update: (inventoryItem)->
        inventoryQuantity = inventoryItem.get("quantity")
        if not inventoryQuantity
            inventoryQuantity = ""
        @$el.find(".inventory").html(inventoryQuantity)
        return this

    inventoryPlus: (event)->
        quantity = if event.shiftKey then 5 else 1
        @inventoryItem.quantityPlus quantity
        Backbone.trigger("action:inventory:plus")
        event.preventDefault()
        this

    inventoryMinus: (event)->
        quantity = if event.shiftKey then 5 else 1
        @inventoryItem.quantityPlus -quantity
        Backbone.trigger("action:inventory:minus")
        event.preventDefault()
        this

    track: (event)->
        tracking.trackMaterial @model
        Backbone.trigger("action:material:track")
        event.preventDefault()
        this

    toggleNextBody: (e)->
        $(e.currentTarget).next().slideToggle(80)
        $(e.currentTarget).find(".glyphicon")
            .toggleClass("glyphicon-triangle-bottom")
            .toggleClass("glyphicon-triangle-top")
        this
