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
tracking = require './tracking'


### TrackBlueprintview ###
module.exports = Backbone.View.extend
    template: _.template $("#track-blueprint-tpl").html()
    className: "col-sm-6 track-blueprint"

    events:
        "click .panel-body.toggle": "toggleNextBody"
        "click .btn.track": "track"
        "click .btn.remove": "untrack"
        "click .btn.craft": "craft"

    itemTpl: _.template("""
        <tr class="<%=itemClass%>">
          <td><%= title %></td>
          <td>
            <span class="inventory"><%= inventory %></span>
            / <small class="quantity"><%= quantity %></small>
          </td>
        </tr>""")

    initialize: (options) ->
        for ingredient in @model.blueprint.get("ingredients")
            inventoryItem = inventory.getItem ingredient.material.id
            @listenTo inventoryItem, "change", @update
        @listenTo @model.trackBlueprint, 'change', @update
        @listenTo @model.trackBlueprint, 'destroy', @remove
        return this

    render: ->
        data = _.extend(
            @model.trackBlueprint.toJSON(),
            @model.blueprint.toJSON()
        )
        data.completion = @completion()
        $html = $(@template(data))
        for ingredient in data.ingredients
            quantity = ingredient.quantity * @model.trackBlueprint.get("quantity")
            inventoryQuantity = inventory.get ingredient.material.id
            textClass = if quantity > inventoryQuantity then "text-danger" else ""
            itemView = @itemTpl
                itemClass: "ingredient-#{ingredient.material.id} #{textClass}"
                title: ingredient.material.title
                quantity: quantity
                inventory: inventoryQuantity

            $html.find(".ingredients table").append(itemView)

        @$el.html $html
        return this

    update: ->
        trackedQuantity = @model.trackBlueprint.get "quantity"
        @$el.find("span.quantity").html trackedQuantity
        @$el.find(".drone-blueprint-completion").css(width: @completion() + "%")

        for ingredient in @model.blueprint.get "ingredients"
            quantity = ingredient.quantity * trackedQuantity
            inventoryQuantity = inventory.get ingredient.material.id

            if quantity > inventoryQuantity
                @$el.find(".ingredient-#{ingredient.material.id}"
                ).addClass("text-danger")
            else
                @$el.find(".ingredient-#{ingredient.material.id}"
                ).removeClass("text-danger")

            @$el.find(".ingredient-#{ingredient.material.id} .quantity"
            ).html quantity
            @$el.find(".ingredient-#{ingredient.material.id} .inventory"
            ).html inventoryQuantity

        return this

    completion: ()->
        trackedQuantity = @model.trackBlueprint.get "quantity"
        total = 0
        complete = 0
        for ingredient in @model.blueprint.get "ingredients"
            required = ingredient.quantity * trackedQuantity
            total += required
            complete += Math.min(required, inventory.get ingredient.material.id)
        parseInt Math.min(100, (complete / total) * 100)

    track: (event)->
        tracking.trackBlueprint(@model.blueprint)
        event?.preventDefault()
        return this

    untrack: (event)->
        tracking.untrackBlueprint(@model.blueprint)
        event?.preventDefault()
        return this

    craft: (event)->
        @model.trackBlueprint.quantityPlus -1

        for ingredient in @model.blueprint.get("ingredients")
            inventoryItem = inventory.getItem ingredient.material.id
            amount = Math.min(ingredient.quantity, inventoryItem.get("quantity"))
            inventoryItem.quantityPlus(-amount)
            tracking.untrackMaterial(ingredient.material, ingredient.quantity)

        if @model.trackBlueprint.get("quantity") <= 0
            @untrack()

        Backbone.trigger "action:blueprint:craft"
        event?.preventDefault()
        return this

    toggleNextBody: (e)->
        $(e.currentTarget).next().slideToggle(80)
        $(e.currentTarget).find(".glyphicon")
            .toggleClass("glyphicon-triangle-bottom")
            .toggleClass("glyphicon-triangle-top")
        this
