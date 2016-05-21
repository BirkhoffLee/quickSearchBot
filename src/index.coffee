Bot      = require 'telegram-bot-api'
token    = "YOUR_TOKEN_HERE"
username = ""

#
# Modules
#
searchModules = {}
searchModules.wiki   = require "./modules/wiki.coffee"
searchModules.google = require "./modules/google.coffee"

bot = new Bot
    token: token
    updates:
        enabled: true

bot.getMe()
    .then (data) ->

        username = data.username
        console.log "Successfully conencted to Telegram API Server."

    .catch (err) ->
        if err.name == "RequestError"
            console.error "Unable to connect to Telegram API Server."
        else
            console.error "Unable to get the bot's username."

        process.exit -1

sendMessageErrorHandler = (err) ->
    console.error err

sendResult = (message, text) ->
    bot.sendMessage
        chat_id: message.chat.id
        reply_to_message_id: message.message_id
        disable_web_page_preview: "true"
        parse_mode: "html"
        text: text
    .catch sendMessageErrorHandler

bot.on 'message', (message) ->
    if !message.text?
        return

    console.log "@#{message.from.username}: #{message.text}"

    firstPiece = message.text.split(" ")[0]
    quiet      = null

    switch firstPiece.replace(new RegExp("@#{username}", "i"), "").slice 1
        when "wiki", "wikipedia"

            result = null
            search = message.text.slice(firstPiece.length + 1).trim()

            if search == ""
                sendResult message, "You have to provide the keyword for me!"
                return

            searchModules.wiki search
                .then (result) ->

                    if !result
                        sendResult message, "Sorry, I found nothing about that on Wikipedia."
                    else
                        sendResult message, result

                .catch (err) ->
                    console.error err
                    if err == 0
                        sendResult message, "Sorry, I found nothing about that on Wikipedia."
                    else
                        console.error "Error occurred in Wikipedia searching module, code: #{err.toString()}"
                        sendResult message, "Sorry, I ran into an error while searching."

        when "google"

            result = null
            keyword = message.text.slice(firstPiece.length + 1).trim()

            if keyword == ""
                sendResult message, "You have to provide the keyword for me!"
                return

            searchModules.google keyword
                .then (results) ->

                    if results.length == 0
                        sendResult message, "Sorry, I found nothing about that on Google."
                    else
                        sendResult message, results.join("\n\n").trim()

                .catch (err) ->
                    console.error "Error occurred in Google searching module, code: #{err.toString()}"
                    sendResult message, "Sorry, I ran into an error while searching."

        when "start", "help"
            sendResult message, "Available commands:\n/wiki: Search something on Wikipedia.\n/wikipedia: Alias of /wiki.\n/google: Search something on Google."
        else
            return