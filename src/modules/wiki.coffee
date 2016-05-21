Q = require "q"

module.exports = (search) ->
    deferred = Q.defer()
    rp       = require 'request-promise'
    title    = ""
    message  = ""
    options  =
        uri  : "http://en.wikipedia.org/w/api.php?format=json&action=query&list=search&srlimit=1&srprop&continue&srsearch=#{search}"
        json : 1

    rp options
        .then (jsonObject) ->

            if !jsonObject.query.search[0] || !jsonObject.query.search[0].title
                deferred.reject 0
                return 0

            title = jsonObject.query.search[0].title

            options =
                uri  : "http://en.wikipedia.org/w/api.php?format=json&utf8&action=query&prop=extracts&exintro&explaintext&exchars=500&redirects&titles=" + encodeURI title
                gzip : 1
                json : 1

            return rp options

        .then (jsonObject) ->

            if !jsonObject.query
                deferred.reject 1
                return 0

            try
                result = "<b>" + jsonObject.query.pages[Object.keys(jsonObject.query.pages)[0]].extract.replace /\n/g, " "
                result += "</b> [http://zh.wikipedia.org/wiki/" + title.replace(/\s/g, '_') + "]"
            catch err
                console.error err
                deferred.reject 2
                return 0

            deferred.resolve result

        .catch (err) ->
            console.error err
            deferred.reject 3
            return 0

    return deferred.promise