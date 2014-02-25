"use strict"

describe "Unwatched App Index Page - ", ->

  describe "Unwatched Index Page Header", ->
    it "should contain Unwatched", ->
      browser().navigateTo "/"
      expect(element(".navbar-brand").text()).toEqual "Unwatched"

  describe "Login Modal - ", ->

    beforeEach ->
      browser().navigateTo "/"

    it "should open as modal view", ->
      expect(element("body").attr("class")).toBe undefined
      element("#open-login").click()
      expect(element("body").attr("class")).toBe "modal-open"

    it "should disappear on a click on cancel", ->
      element("#open-login").click()
      expect(element("body").attr("class")).toBe "modal-open"
      element("#close-login").click()
      expect(element("body").attr("class")).toBe ""

    describe "Login Form - ", ->

      beforeEach ->
        browser().navigateTo "/"
        element("#open-login").click()

      it "should contain the empty input-fields 'user.email', 'user.password' 
            and 'user.passwordConfirm'", ->
        expect(input("user.email").val()).toBe ""
        expect(input("user.password").val()).toBe ""
        expect(input("user.passwordConfirm").val()).toBe ""

      it "should contain a disabled submit button", ->
        expect(element("#submit-login").attr("disabled")).toBe "disabled"

      describe "invalid input recognition - ", ->

        beforeEach ->
          input("user.email").enter ""
          input("user.password").enter ""
          input("user.passwordConfirm").enter ""

        it "should recognize an invalid email adress", ->
          input("user.email").enter "invalid-email-adress"
          expect(element("#inputEmail.ng-invalid-email").count()).toBe 1

        it "should recognize invalid/too short password - min 5 chars", ->
          input("user.password").enter "lore"
          expect(element("#inputPassword.ng-invalid-minlength").count()).toBe 1

        it "should recognize invalid/too short password confirmation - min 5 chars", ->
          input("user.passwordConfirm").enter "lore"
          expect(element("#inputPasswordConfirm.ng-invalid-minlength").count()).toBe 1

        it "should recognize a wrong password confirmation", ->
          input("user.password").enter "lorem"
          input("user.passwordConfirm").enter "ipsum"
          expect(element("#inputPasswordConfirm.ng-invalid-input-match").count()).toBe 1

      it "should recognize valid input and enable the submit button", ->
        input("user.email").enter "lorem@ipsum.org"
        input("user.password").enter "lorem"
        input("user.passwordConfirm").enter "lorem"
        expect(element("#submit-login").attr("disabled")).toBe undefined


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