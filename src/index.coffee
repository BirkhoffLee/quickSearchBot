Bot      = require 'telegram-bot-api'
token    = "221954642:AAHPt8u4tKb4Kb7jhkUHkxcN7C0Qi93VULg"
username = ""

#
# Modules
#
searchModules = {}
searchModules.wiki = require "./modules/wiki.coffee"

bot = new Bot
    token: token
    updates:
        enabled: true

bot.getMe()
    .then (data) ->
        username = data.username
    .catch (err) ->
        console.error "Unable to get the bot's username."
        process.exit -1

sendMessageErrorHandler = (err) ->
    console.error err

sendResult = (message, text) ->
    bot.sendMessage
        chat_id: message.chat.id
        reply_to_message_id: message.message_id
        disable_web_page_preview: "true"
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
                        return
                    else
                        console.log result
                        sendResult message, result
                        return
                .catch (err) ->
                    console.error "Error occurred on Wikipedia searching module, code: #{err.toString()}"
                    sendResult message, "Sorry, I ran into an error while searching."

        when "google"
            sendResult message, "google"
        when "wolframalpha"
            sendResult message, "wolframalpha"
        when "start", "help"
            sendResult message, "Currently available commands:\n/wiki: Search something on Wikipedia.\n/wikipedia: Alias of /wiki.\n/google: Search something on Google.\n/wolframalpha"
        else
            return

console.log username