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

    describe "Login/Signup Form - ", ->

      beforeEach ->
        browser().navigateTo "/"
        element("#open-login").click()

      it "should contain the empty input-fields 'user.email' and 'user.password'", ->
        expect(input("user.email").val()).toBe ""
        expect(input("user.password").val()).toBe ""

      it "should contain a disabled submit button", ->
        expect(element("#submit-login").attr("disabled")).toBe "disabled"

      describe "invalid input recognition - ", ->

        beforeEach ->
          input("user.email").enter ""
          input("user.password").enter ""

        it "should recognize an invalid email address", ->
          input("user.email").enter "invalid-email-address"
          expect(element("#inputEmail.ng-invalid-email").count()).toBe 1

        it "should recognize invalid/too short password - min 5 chars", ->
          input("user.password").enter "lore"
          expect(element("#inputPassword.ng-invalid-minlength").count()).toBe 1

      it "should recognize valid input and enable the submit button", ->
        input("user.email").enter "lorem@ipsum.org"
        input("user.password").enter "lorem"
        expect(element("#submit-login").attr("disabled")).toBe undefined

      it "should toggle sign up fields on 'Not yet/Allready registered?'", ->
        element("#toggle-signup-form").click()
        expect(element("#signup-fields-container.collapsing").count()).toBe 1
        element("#toggle-signup-form").click()
        expect(element("#signup-fields-container.collapse.in").count()).toBe 0

      it "should accept correct input after toggling", ->
        input("user.email").enter "lorem@ipsum.org"
        input("user.password").enter "lorem"
        expect(element("#submit-login").attr("disabled")).toBe undefined
        element("#toggle-signup-form").click()
        expect(element("#submit-login").attr("disabled")).toBe "disabled"
        element("#toggle-signup-form").click()
        expect(element("#submit-login").attr("disabled")).toBe undefined

      describe "Signup Fields - ", ->

        beforeEach ->
          browser().navigateTo "/"
          element("#open-login").click()
          element("#toggle-signup-form").click()

        it "should contain the empty input fields 'user.confirmEmail', 'user.disblayName' and 'user.confirmPassword'", ->
          expect(input("user.confirmPassword").val()).toBe ""
          expect(input("user.confirmEmail").val()).toBe ""
          expect(input("user.displayName").val()).toBe ""

        it "should contain a disabled submit button", ->
          expect(element("#submit-login").attr("disabled")).toBe "disabled"

        describe "invalid input recognition - ", ->

          beforeEach ->
            input("user.email").enter ""
            input("user.password").enter ""
            input("user.confirmEmail").enter ""
            input("user.confirmPassword").enter ""
            input("user.displayName").enter ""

          it "should recognize invalid/too short display name - min 5 chars", ->
            input("user.displayName").enter "lore"
            expect(element("#inputDisplayName.ng-invalid-minlength").count()).toBe 1

          it "should recognize invalid/too short password confirmation - min 5 chars", ->
            input("user.confirmPassword").enter "lore"
            expect(element("#inputConfirmPassword.ng-invalid-minlength").count()).toBe 1

          it "should recognize a wrong password confirmation", ->
            input("user.password").enter "lorem"
            input("user.confirmPassword").enter "ipsum"
            expect(element("#inputConfirmPassword.ng-invalid-input-match").count()).toBe 1

          it "should recognize a wrong email confirmation", ->
            input("user.email").enter "lorem@ipsum.org"
            input("user.confirmEmail").enter "ipsum@lorem.org"
            expect(element("#inputConfirmEmail.ng-invalid-input-match").count()).toBe 1

        it "should recognize valid input and enable the submit button", ->
          input("user.email").enter "lorem@ipsum.org"
          input("user.password").enter "lorem"
          input("user.confirmEmail").enter "lorem@ipsum.org"
          input("user.confirmPassword").enter "lorem"
          input("user.displayName").enter "Lorem Ipsum"


  describe "Unwatched 'createRoom' form", ->
    it "should contain the form 'createRoom' with the input fields 'room-name' and 'room-password'", ->
      expect(element("form#createRoom").count()).toBe 1
      expect(input("room.name").val()).toBe ""
      expect(input("room.password").val()).toBe ""

    it "should contain an invisible submit button", ->
      expect(element("#submitCreateRoom").attr("disabled")).toBe "disabled"


    it "should validate too short inputs - min 5 chars", ->
      input("room.name").enter "lore"
      input("room.password").enter "ipsu"
      expect(element("#inputRoomName.ng-invalid-minlength").count()).toBe 1
      expect(element("#inputRoomPassword.ng-invalid-minlength").count()).toBe 1
      
    it "should contain an enabled button when the right input is given", ->
      input("room.name").enter "lorem"
      input("room.password").enter "ipsum"
      expect(element("#submitCreateRoom").attr("disabled")).toBe undefined
