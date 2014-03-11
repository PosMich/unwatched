"use strict"

describe "Unwatched Room Page - ", ->

  beforeEach ->
    browser().navigateTo "/room"

  it "should contain the elements 'clients', 'chat' and 'notes'", ->
    expect(element("#clients").count()).toBe 1
    expect(element("#chat").count()).toBe 1
    expect(element("#notes").count()).toBe 1

  describe "clients", ->

    it "should contain at least one client", ->
      expect(repeater(".client").count()).toBeGreaterThan 0

    it "should countain an avatar-name and -image", ->
      expect(repeater(".client .client-header .name").row(0)).toMatch /Lorem Ipsum/
      expect(element(".client .client-content").attr("style")).toContain "background-image:"

    it "should contain the icons 'minimize', 'maximize' and 'close' for each client", ->
      expect(repeater(".client .client-header .controls i.minimize").count()).not().toBe 0
      expect(repeater(".client .client-header .controls i.maximize").count()).not().toBe 0
      expect(repeater(".client .client-header .controls i.remove").count()).not().toBe 0

    it "should contain the icons 'share screen to' and 'share webcam to' on mouseover for each client", ->

      expect(repeater(".client .client-options span.share-screen-to").count()).not().toBe 0
      expect(repeater(".client .client-options span.share-webcam-to").count()).not().toBe 0

      appElement ".client .client-options span.share-screen-to", (elem) ->
        elem.trigger "mouseover"
        expect(element(".client .client-options span.share-screen-to.showOption").count()).not().toBe 0
        return

      appElement ".client .client-options span.share-webcam-to", (elem) ->
        elem.trigger "mouseover"
        expect(element(".client .client-options span.share-webcam-to.showOption").count()).not().toBe 0
        return


    it "should contain the icons 'share screen to all' and 'share webcam to all'", ->
      # not yet implemented
      expect(element("#clients button.share-screen-to-all").count()).toBe 1
      expect(element("#clients button.share-webcam-to-all").count()).toBe 1

  describe "chat", ->

    it "should be a tab", ->
      expect(element(".tab-content #chat").count()).toBe 1

    it "should contain the container for 'chat-messages', an input field for 'chat-message' and a disabled 'submit-chat-message' button ", ->
      element("li#chat-tab a").click()
      expect(element("#chat-messages").count()).toBe 1
      expect(element("#input-chat-message").count()).toBe 1
      expect(element("#submit-chat-message").count()).toBe 1
      expect(element("#submit-chat-message").attr("disabled")).toBe "disabled"

    it "should be able to submit a chat-message", ->
      element("li#chat-tab a").click()
      input("chat.message").enter "Lorem Ipsum"
      expect(element("#submit-chat-message").attr("disabled")).toBe undefined
      element("#submit-chat-message").click()
      expect(repeater(".chat-message").count()).toBe 1

    it "should contain a 'chat-message-sender' and a 'chat-message-content' -field for each chat-message", ->
      
      browser().navigateTo "/room"
      element("li#chat-tab a").click()

      input("chat.message").enter "Lorem Ipsum"
      element("#submit-chat-message").click()
      input("chat.message").enter "Lorem Ipsum"
      element("#submit-chat-message").click()
      input("chat.message").enter "Lorem Ipsum"
      element("#submit-chat-message").click()

      expect(repeater(".chat-message").column("message.sender")).toEqual ["Lorem Ipsum", "Lorem Ipsum", "Lorem Ipsum"]
      expect(repeater(".chat-message").column("message.content")).toEqual ["Lorem Ipsum", "Lorem Ipsum", "Lorem Ipsum"]

  describe "notes", ->

    it "should contain an option icon to add a new note to the room", ->
      expect(element("#notes p#add-note").count()).toBe 1

    it "should be able to add notes", ->
      element("#notes p#add-note").click()
      element("#notes p#add-note").click()

      expect(repeater(".note").count()).toBe 2

    it "should contain the controls icons 'view-note', 'edit-note', 'download-note' and 'delete-note' for each note", ->
      element("#notes p#add-note").click()
      element("#notes p#add-note").click()

      expect(repeater(".note").count()).toBe 2
      expect(repeater(".note i.download-note").count()).toBe 2
      expect(repeater(".note i.delete-note").count()).toBe 2


angular.scenario.dsl "appElement", ->
  (selector, fn) ->
    @addFutureAction "element " + selector, ($window, $document, done) ->
      fn.call this, $window.angular.element(selector)
      done()
      return

