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


### TrackMaterialView ###
module.exports = Backbone.View.extend
    template: _.template $("#track-material-tpl").html()

    className: "col-sm-6 material"

    events:
        "click .panel-body.toggle": "toggleNextBody"
        "click .inventory-plus": "inventoryPlus"
        "click .inventory-minus": "inventoryMinus"
        "click .btn.remove": "removeTrack"
        "click .btn.track": "addTrack"

    initialize: (options) ->
        {@material, @inventory} = options
        @listenTo @inventory, 'change', @update
        @listenTo @model, "change", @update
        @listenTo @model, 'destroy', @remove

    render: ->
        data =
            quantity: @model.get("quantity")
            inventory: @inventory.get("quantity")
            material: @material.toJSON()
        data.material.typeLabel = @material.typeLabel()
        @$el.html @template(data)
        rarity = data.material.rarity.replace(/\W+/, "-")
        @$el.addClass "rarity-#{rarity}"
        return this

    update: ->
        @$el.find("span.inventory").html(@inventory.get("quantity"))
        @$el.find("span.quantity").html @model.get("quantity")

    inventoryPlus: (event)->
        quantity = if event.shiftKey then 5 else 1
        @inventory.quantityPlus quantity
        Backbone.trigger("action:inventory:plus")
        event.preventDefault()
        this

    inventoryMinus: (event)->
        quantity = if event.shiftKey then 5 else 1
        @inventory.quantityPlus -quantity
        Backbone.trigger("action:inventory:minus")
        event.preventDefault()
        this

    removeTrack: (event)->
        @model.quantityPlus -1
        @model.destroy() if @model.get("quantity") <= 0
        Backbone.trigger("action:material:untrack")
        event.preventDefault()
        this

    addTrack: (event)->
        @model.quantityPlus 1
        Backbone.trigger("action:material:track")
        event.preventDefault()
        this

    toggleNextBody: (e)->
        $(e.currentTarget).next().slideToggle(80)
        $(e.currentTarget).find(".glyphicon")
            .toggleClass("glyphicon-triangle-bottom")
            .toggleClass("glyphicon-triangle-top")
        this
