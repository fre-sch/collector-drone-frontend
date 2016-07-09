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

AppView = require "./AppView"
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
fix_removed_blueprints = (blueprints)->
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

localDataVersion = ()->
    localStorage.getItem("dataVersion") ? "beta"


data_migrate = ()->
    fix_removed_blueprints()
    fix_stuck_materials()
    prevVersion = localDataVersion()
    if prevVersion != CollectorDroneData.version
        console.info "update found, migrate #{prevVersion} -> #{CollectorDroneData.version}"
        localStorage.setItem "dataVersion", CollectorDroneData.version
        Backbone.trigger "action:migrate", prevVersion, CollectorDroneData.version

    $("#drone-data-version").html(localDataVersion())


### App.js ###
App = ->
    $.ajaxSetup(contentType: "application/json")

    data_migrate()

    blueprintsFilter = new BlueprintsFilter
    blueprintsFiltered = FilteredCollection(
        new BlueprintCollection, blueprintsFilter)

    materialsFilter = new MaterialsFilter
    materialsFiltered = FilteredCollection(
        new MaterialCollection, materialsFilter)

    @blueprintsCollectionView = new BlueprintsCollectionView
        model: blueprintsFiltered
        filter: blueprintsFilter
        pager: new PagerModel(collection: blueprintsFiltered)

    @materialsCollectionView = new MaterialsCollectionView
        model: materialsFiltered
        filter: materialsFilter
        pager: new PagerModel(collection: materialsFiltered)

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

    @view = new AppView
        blueprints: blueprintsFiltered
        materials: materialsFiltered

    inventory.fetch(reset: true)
    blueprintsFiltered._source.reset(CollectorDroneData.blueprints)
    materialsFiltered._source.reset(CollectorDroneData.materials)
    tracking.materials.fetch(reset: true)
    tracking.blueprints.fetch(reset: true)

    @router = new AppRouter()
    Backbone.history.start()
    new Ga(Backbone)

    return this

window.app = new App()
