immigrate = require('../app/immigrate')
expect = require("chai").expect
resolve = require('path').resolve
fs = require('fs')


cleanUp = ->
	filesToRemove = [
		'./immigrate.json'
	]

	for fileName in filesToRemove
		if fs.existsSync(fileName)
			fs.unlinkSync(fileName)


describe "Option Parameters", ->
	it "Detects version from package.json if no options supplied", (done) ->
		cleanUp()

		packageJson = require('../package.json')
		promise = immigrate()

		promise.then (result) ->
			expect(result.version).to.equal(packageJson.version)
			done()

		promise.catch (error) ->
			throw error
			done()
