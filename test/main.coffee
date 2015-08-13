immigrate = require('../app/immigrate')
expect = require("chai").expect
resolve = require('path').resolve
fs = require('fs')

packageJsonFile = './test/package.json'
customImmigrateJsonFile = './test/custom-immigrate.json'
immigrateJsonFile = './test/immigrate.json'
resultJsonFile = './test/result.json'

requireResolvedPath = (modulePath) -> require(resolve(modulePath))

cleanUp = ->
	fs.writeFileSync(resultJsonFile, JSON.stringify({
		migrations: 0
	}))

	filesToRemove = [
		immigrateJsonFile
		customImmigrateJsonFile
		resultJsonFile
	]

	for fileName in filesToRemove
		if fs.existsSync(fileName)
			fs.unlinkSync(fileName)


before -> cleanUp()


afterEach -> cleanUp()


describe "Option Parameters", ->
	it "Detects version from package.json if no options supplied", () ->
		return immigrate().then (result) ->
			packageJson = requireResolvedPath(packageJsonFile)
			expect(result.version).to.equal(packageJson.version)


	it "Writes last version to immigrate.json", ->
		return immigrate().then ->
			packageJson = requireResolvedPath(packageJsonFile)
			immigrateJson = require(immigrateJsonFile)
			expect(packageJson.version).to.equal(immigrateJson.version)


	it "options.currentVersion overwrites default ./package.json version", ->
		promise = immigrate({
			currentVersion: '999.999.999'
		})

		return promise.then (result) ->
			expect(result.version).to.equal('999.999.999')
	

	it "options.currentVersion overwrites options.packageJsonFile", ->
		promise = immigrate({
			currentVersion: '999.999.999'
			packageJsonFile: './package.json'
		})

		return promise.then (result) ->
			expect(result.version).to.equal('999.999.999')
	

	it "custom options.immigrateJsonFile contains result", ->
		promise = immigrate({
			immigrateJsonFile: customImmigrateJsonFile
		})

		return promise.then ->
			packageJson = requireResolvedPath(packageJsonFile)
			immigrateJson = requireResolvedPath(customImmigrateJsonFile)
			expect(packageJson.version).to.equal(immigrateJson.version)


	it "Migrates initially if options.migrateIfFresh is true", ->
		promise = immigrate({
			migrateIfFresh: true
		})

		return promise.then (result) ->
			packageJson = requireResolvedPath(packageJsonFile)
			immigrateJson = requireResolvedPath(immigrateJsonFile)
			resultJson = requireResolvedPath(resultJsonFile)

			expect(packageJson.version).to.equal(immigrateJson.version)
			expect(resultJson.migrations).to.be.above(0)

	
