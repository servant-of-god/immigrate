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


	it "Writes last version to immigrate.json", (done) ->
		cleanUp()

		packageJson = require('../package.json')
		promise = immigrate()

		promise.then ->
			immigrateJson = require('../immigrate.json')
			expect(packageJson.version).to.equal(immigrateJson.version)
			done()

		promise.catch (error) ->
			throw error
			done()


	it "options.currentVersion overwrites ./package.json version", (done) ->
		cleanUp()

		promise = immigrate({
			currentVersion: '999.999.999'
		})

		promise.then (result) ->
			expect(result.version).to.equal('999.999.999')
			done()
	

		promise.catch (error) ->
			throw error
			done()
