"use strict"

describe "Unwatched App Index Page", ->

  describe "Unwatched Index Page Header", ->
    it "should contain Unwatched", ->
      browser().navigateTo "/"
      expect(element(".navbar-brand").text()).toEqual "Unwatched"

  describe "Unwatched 'createRoom' form", ->

    it "should contain the form 'createRoom' with the input fields 'room-name' 
          and 'room-password'", ->
      expect(element("form#createRoom").count()).toBe 1
      expect(input("room.name").val()).toBe ""
      expect(input("room.password").val()).toBe ""

    it "should contain an invisible submit button", ->
      expect(element("#submitCreateRoom").attr("disabled")).toBe "disabled"

    it "should contain an enabled button when the right input is given", ->
      input("room.name").enter "a"
      input("room.password").enter "a"
      expect(element("#submitCreateRoom").attr("disabled")).toBe undefined