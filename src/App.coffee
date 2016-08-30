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

### App.js ###
AppRouter = require "./AppRouter"
FilteredCollection = require "./FilteredCollection"
PagerModel = require "./PagerModel"
BlueprintCollection = require "./BlueprintCollection"
BlueprintsCollectionView = require "./BlueprintsCollectionView"
BlueprintsFilter = require "./BlueprintsFilter"
BlueprintsFilterView = require './BlueprintsFilterView'
MaterialCollection = require "./MaterialCollection"
MaterialsCollectionView = require './MaterialsCollectionView'
MaterialsFilter = require "./MaterialsFilter"
MaterialsFilterView = require "./MaterialsFilterView"
ResourceTabView = require "./ResourceTabView"
tracking = require './tracking'
TrackBlueprintCollectionView = require './TrackBlueprintCollectionView'
TrackMaterialCollectionView = require './TrackMaterialCollectionView'
TrackingTabView = require './TrackingTabView'
SettingsView = require './SettingsView'
inventory = require './inventory'
Ga = require './Ga'


### 2016-07-04 ###
fix_stuck_materials = ()->
    trackBlueprint = localStorage.getItem "trackBlueprint"
    trackMaterial = localStorage.getItem "trackMaterial"
    if not trackBlueprint?.length and trackMaterial?.length
        for id in trackMaterial.split ","
            localStorage.removeItem "trackMaterial-#{id}"
        localStorage.removeItem "trackMaterial"
    return


### 2016-07-09 ###
fix_removed_blueprints = ()->
    trackBlueprint = localStorage.getItem("trackBlueprint")
    if trackBlueprint
        ids = trackBlueprint.split ","
        for id in trackBlueprint.split ","
            if not _.findWhere(CollectorDroneData.blueprints, id: parseInt(id))
                ids = _.without(ids, id)
                localStorage.removeItem "trackBlueprint-#{id}"
        if ids.length
            localStorage.setItem "trackBlueprint", ids.join(",")
        else
            localStorage.removeItem "trackBlueprint"
    return


### 2016-07-09 ###
fix_removed_materials = ()->
    trackMaterial = localStorage.getItem("trackMaterial")
    if trackMaterial
        ids = trackMaterial.split ","
        for id in trackMaterial.split ","
            if not _.findWhere(CollectorDroneData.materials, id: parseInt(id))
                ids = _.without(ids, id)
                localStorage.removeItem "trackMaterial-#{id}"
        if ids.length
            localStorage.setItem "trackMaterial", ids.join(",")
        else
            localStorage.removeItem "trackMaterial"
    return


localDataVersion = ()->
    localStorage.getItem("dataVersion") ? "beta"


data_migrate = ()->
    fix_removed_blueprints()
    fix_removed_materials()
    fix_stuck_materials()
    prevVersion = localDataVersion()
    if prevVersion != CollectorDroneData.version
        console.info "update found, migrate #{prevVersion} -> #{CollectorDroneData.version}"
        localStorage.setItem "dataVersion", CollectorDroneData.version
        Backbone.trigger "action:migrate", prevVersion, CollectorDroneData.version

    $("#drone-data-version").html(localDataVersion())


class App
    constructor: ->
        $.ajaxSetup(contentType: "application/json")

        data_migrate()

        blueprintsFilter = new BlueprintsFilter
        blueprintsFiltered = FilteredCollection(
            new BlueprintCollection, blueprintsFilter)

        materialsFilter = new MaterialsFilter
        materialsFiltered = FilteredCollection(
            new MaterialCollection, materialsFilter)

        blueprintsFilterView = new BlueprintsFilterView
            el: $("#library-blueprints-filter")
            model: blueprintsFilter

        materialsFilterView = new MaterialsFilterView
            el: $("#library-materials-filter")
            model: materialsFilter

        materialsFilterView.typeMenuModel.set
            items: CollectorDroneData.materialTypes

        blueprintsFilterView.typeMenuModel.set
            items: CollectorDroneData.blueprintTypes

        blueprintsFilterView.levelMenuModel.set items:
            for item in blueprintsFilter.loadLevels()
                label: item, value: item

        @resourceTabView = new ResourceTabView
            blueprintsCollection: blueprintsFiltered
            materialsCollection: materialsFiltered

        new TrackBlueprintCollectionView blueprints: blueprintsFiltered
        new TrackMaterialCollectionView materials: materialsFiltered
        new TrackingTabView(model: tracking)
        @router = new AppRouter({blueprintsFiltered, materialsFiltered})
        new SettingsView({@router})

        inventory.load()
        blueprintsFiltered.resetSource CollectorDroneData.blueprints
        materialsFiltered.resetSource CollectorDroneData.materials
        tracking.materials.fetch(reset: true)
        tracking.blueprints.fetch(reset: true)

        @blueprintsCollectionView = new BlueprintsCollectionView
            el: $("#library-blueprints .collection-items")
            model: blueprintsFiltered
            filter: blueprintsFilter
            pager: new PagerModel(collection: blueprintsFiltered)

        @materialsCollectionView = new MaterialsCollectionView
            el: $("#library-materials .collection-items")
            model: materialsFiltered
            filter: materialsFilter
            pager: new PagerModel(collection: materialsFiltered)

        Backbone.history.start()
        new Ga(Backbone)

        return this

    randomizeInventory: ->
        for k of localStorage
            if k.indexOf("InvMaterial-") == 0
                item = JSON.parse localStorage[k]
                item.quantity = parseInt Math.random() * 255
                localStorage[k] = JSON.stringify item
        this

window.app = new App()
