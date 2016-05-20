Q = require "q"

module.exports = (keyword) ->
    deferred = Q.defer()
    google   = require 'google'
    results  = []
    message  = ""
    counter  = 0

    google keyword, (err, res) ->
        if err
            console.log err
            deferred.reject 0
            return

        res.links.forEach (single) ->
            if !single.title || !single.description || !single.link
                return

            if counter < 5
                counter++

                description = single.description.slice 0, 150
                results.push "[#{single.title}] #{description}... [#{single.link}]".replace(/\n/g, " ").trim()

        deferred.resolve results

    return deferred.promise