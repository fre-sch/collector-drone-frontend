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
utils = require './utils'
CodecV1 = require './CodecV1'


ImportDataView = Backbone.View.extend
    template: _.template $("#import-data-view").html()

    events:
        "click .btn.import": "import"

    render: ->
        @$el.html @template(items: @model)
        return this

    import: (event)->
        items = for input in @$el.find("input").get()
            id: parseInt $(input).data("id")
            quantity: parseInt $(input).val()
        @trigger "import-data", items


### SettingsView ###
module.exports = Backbone.View.extend
    el: 'section#settings'

    events:
        "click .export-file-btn": "exportFile"
        "change #import-file-input": "inventoryImportFile"

    initialize: (options)->
        {@router} = options
        @listenTo @router, "route:viewScreen", @show
        return this

    show: (screen, data)->
        @$el.find("#inventory-import").hide()
        if screen == "settings"
            exportData = @inventoryExport()
            l = window.location
            href = "#{l.protocol}//#{l.host}/#/settings/"
            href += encodeURIComponent(exportData)
            $("#inventory-export-link").attr("href", href).text(href)
            if data
                @inventoryImportResult data
        return this

    inventoryExport: ()->
        items = inventory.exportItems()
        CodecV1.encode items

    inventoryImportResult: (encodedData)->
        try
            items = CodecV1.decode encodedData
            materials = {}
            for material in CollectorDroneData.materials
                materials[material.id] = material.title
            for item in items
                item.title = materials[item.id]
            items.sort (a, b)-> utils.strcmp(a.title, b.title)

            view = new ImportDataView(model: items)
            @$el.find("#inventory-import").show()
            @$el.find(".import-result").html view.render().el
            @listenTo view, "import-data", (data)->
                inventory.reset data
                Backbone.trigger "action:inventory:restore"
        catch e
            @$el.find("#inventory-import").show()
            @$el.find(".import-result").html "<p>Failed to import data: #{e}</p>"

        return this

    # exportFile: ()->
    #     timestamp = utils.dateFormatted()
    #     fileName = "collector-drone.#{timestamp}.txt"
    #     saveTextAs @inventoryExport(), fileName
