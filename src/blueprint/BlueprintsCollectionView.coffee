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
PagerView = require './PagerView'
BlueprintView = require './BlueprintView'


### BlueprintsCollectionView ###
module.exports = Backbone.View.extend
    initialize: (options) ->
        {@filter, @pager} = options
        @pager.listenTo @filter, "change", @pager.reset

        new PagerView
            el: @$el.parent().find(".drone-pagination")
            model: @pager

        @listenTo @model, "reset", @render
        @listenTo @pager, "change:current", @render
        return this

    render: ()->
        begin = @pager.offset()
        end = @pager.offset() + @pager.get("limit")
        fragment = document.createDocumentFragment()
        for model, i in @model.slice begin, end
            view = new BlueprintView(model: model)
            fragment.appendChild(view.render().el)
        @$el.empty().append(fragment)
        return this
