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
InventoryCollection = require './InventoryCollection'


### inventory Singleton ###
module.exports =
    collection: new InventoryCollection()

    exportItems: ->
        results = []
        for i in [0..localStorage.length]
            key = localStorage.key(i)
            if key and key.indexOf("InvMaterial-") == 0
                item = JSON.parse(localStorage.getItem(key))
                if item and item.quantity > 0
                    results.push item
        results

    reset: (data)->
        @collection.reset([])
        for item in data
            @collection.create(item)

    load: ()->
        @collection.fetch(reset: true, silent: true)

    getItem: (materialId)->
        @collection.getOrCreate(materialId)

    get: (materialId)->
        @getItem(materialId).get "quantity"
