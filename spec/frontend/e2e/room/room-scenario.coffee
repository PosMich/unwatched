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
      expect(repeater(".client .client-header .controls i.minimize").count()).toBeGreaterThan 0
      expect(repeater(".client .client-header .controls i.maximize").count()).toBeGreaterThan 0
      expect(repeater(".client .client-header .controls i.remove").count()).toBeGreaterThan 0

    it "should contain the icons 'share screen to' and 'share webcam to' on mouseover for each client", ->
      # not yet implemented - how to simulate "hovers" in ng-scenario?
      # expect(repeater(".client .options i.share-screen-to")).toBeGreaterThan 4
      # expect(repeater(".client .options i.share-webcam-to")).toBeGreaterThan 4

    it "should contain the icons 'share screen to all' and 'share webcam to all'", ->
      # not yet implemented
      # expect(element("#clients i.share-screen-to-all").count()).toBe 1
      # expect(element("#clients i.share-webcam-to-all").count()).toBe 1

  describe "chat", ->

    it "should contain the container for 'chat-messages', an input field for 'chat-message' and a disabled 'submit-chat-message' button ", ->
      expect(element("#chat-messages").count()).toBe 1
      expect(element("#input-chat-message").count()).toBe 1
      expect(element("#submit-chat-message").count()).toBe 1
      expect(element("#submit-chat-message").attr("disabled")).toBe "disabled"

    it "should be able to submit a chat-message", ->
      input("chat.message").enter "Lorem Ipsum"
      expect(element("#submit-chat-message").attr("disabled")).toBe undefined
      element("#submit-chat-message").click()
      expect(repeater(".chat-message").count()).toBe 1

    it "should contain a 'chat-message-sender' and a 'chat-message-content' -field for each chat-message", ->
      
      browser().navigateTo "/room"

      input("chat.message").enter "Lorem Ipsum"
      element("#submit-chat-message").click()
      input("chat.message").enter "Lorem Ipsum"
      element("#submit-chat-message").click()
      input("chat.message").enter "Lorem Ipsum"
      element("#submit-chat-message").click()

      # why the hell does this test keep failing??
      expect(repeater(".chat-message").column("message.sender")).toEqual ["Lorem Ipsum", "Lorem Ipsum", "Lorem Ipsum"]
      expect(repeater(".chat-message").column("message.content")).toEqual ["Lorem Ipsum", "Ipsum Lorem", "Lorem Ipsum"]

  describe "notes", ->

    it "should contain an option icon to add a new note to the room", ->
      expect(element("#notes i#addNote").count()).toBe 1

    it "should be able to add notes", ->
      element("#notes i#addNote").click()
      element("#notes i#addNote").click()

      expect(repeater(".note").count()).toBe 2

    it "should contain the controls icons 'view-note', 'edit-note', 'download-note' and 'delete-note' for each note", ->
      element("#notes i#addNote").click()

      expect(repeater(".note i.view-note").count()).toBe 1
      expect(repeater(".note i.edit-note").count()).toBe 1
      expect(repeater(".note i.download-note").count()).toBe 1
      expect(repeater(".note i.delete-note").count()).toBe 1
