"use strict"

describe "Unwatched App Intro Page", ->
  it "should contain Unwatched", ->
    browser().navigateTo "/"
    expect(element("#navbar-brand").text()).toEqual "Unwatched"