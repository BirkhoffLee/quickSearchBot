Q      = require 'q'
google = require 'google'
url    = require 'url'

module.exports = (keyword) ->
    deferred = Q.defer()
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

            if counter < 3
                counter++

                domain      = url.parse(single.link).hostname
                link        = single.link.replace(/\n/g, " ").trim()
                title       = single.title.replace(/\n/g, " ").trim()
                description = single.description.slice(0, 150).replace(/\n/g, " ").trim() + "..."
                results.push "<a href=\"#{link}\">[#{title}]</a> @ <b>#{domain}</b>\n<i>#{description}</i>"

        deferred.resolve results

    return deferred.promise