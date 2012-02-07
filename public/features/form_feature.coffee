Feature "simple form", ->
  Given -> fillIn "firstName", with: "santa"
  Given -> fillIn "lastName", with: "claus"
  When -> click '#submitButton'
  Then -> findContent "Submitted!"