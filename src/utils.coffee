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


### utils ###

hasFileDownload = try
     !!new Blob
catch
    false

hasFileReader = try
    !!new FileReader
catch
    false

strcmp = (a, b) ->
    a.localeCompare(b)


numcmp = (a, b) ->
    if a > b then 1 else -1


cmp = (a, b) ->
    if not a
        return 1
    else if not b
        return -1
    else if a.localeCompare
        strcmp(a, b)
    else
        numcmp(a, b)


dateFormatted = ()->
    now = new Date()
    y = now.getUTCFullYear()
    m = now.getUTCMonth() + 1
    m = "0#{m}".slice -2
    d = now.getUTCDate()
    d = "0#{d}".slice -2
    s = now.getUTCHours() * 60 * 60
    s += now.getUTCMinutes() * 60
    s += now.getUTCSeconds()
    "#{y}-#{m}-#{d}.#{s}"


module.exports = {strcmp, numcmp, cmp, dateFormatted, hasFileReader, hasFileDownload}
