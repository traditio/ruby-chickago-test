#SimAccordion plugin
#Author: Dmitri Patrakov <traditio@gmail.com>
#
#Usage:
#
#    $('div').accordion([options])
#
#    Options:
#        accordionHeader: selector for all accordion headers
#        accordionContents: selector for all accordion contents
#        slideDuration: duration of slide effect ("normal", "fast", "slow" or in ms)
#        events: type of event or array of events

$.fn.accordion = (opts) ->

    element = this #to use in inner functions

    #defaults options
    defaults =
        accordionHeader: '.accordion.header'
        accordionContents: '.accordion.contents'
        slideDuration: 'normal'
        events: ['click', 'dblclick']

    options = $.extend defaults, opts

    #if event is a string, put it to array to use in bind function
    if typeof options.events == 'string'
        options.events = [options.events ]

    #hides all contents except first
    contents = this.find(options.accordionContents)
    first = contents.first()
    contents.not(first).hide()

    #show selected content
    show = (ev) ->
        content = $(ev.target).next(options.accordionContents)
        if content.is(':hidden')
            element.find(options.accordionContents).not(content).slideUp(options.slideDuration)
            console.log 'options.slideDuration', options.slideDuration
            content.slideToggle(options.slideDuration)

    #bind events
    eventsMap = {}
    for e in options.events
        eventsMap[e] = show
    this.find(options.accordionHeader).bind eventsMap

$ () ->
    #attach to body of test.html because accrdion's block in this file are not wrapped in separate div
    $('body').accordion({slideDuration: 'fast'})