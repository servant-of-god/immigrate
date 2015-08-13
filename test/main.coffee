immigrate = require('../app/immigrate')
expect = require("chai").expect
resolve = require('path').resolve
fs = require('fs')

packageJsonFile = './package.json'
customImmigrateJsonFile = './custom-immigrate.json'
immigrateJsonFile = './immigrate.json'
resultJsonFile = './test/result.json'

requireResolvedPath = (modulePath) -> require(resolve(modulePath))

cleanUp = ->
	fs.writeFileSync(resultJsonFile, JSON.stringify({
		migrations: 0
	}))

	filesToRemove = [
		immigrateJsonFile
		customImmigrateJsonFile
	]

	for fileName in filesToRemove
		if fs.existsSync(fileName)
			fs.unlinkSync(fileName)


before -> cleanUp()


afterEach -> cleanUp()


describe "Option Parameters", ->
	it "Detects version from package.json if no options supplied", (done) ->
		promise = immigrate()

		promise.then (result) ->
			packageJson = requireResolvedPath(packageJsonFile)
			expect(result.version).to.equal(packageJson.version)
			done()

		promise.catch (error) ->
			throw error
			done()


	it "Writes last version to immigrate.json", (done) ->
		promise = immigrate()

		promise.then ->
			packageJson = requireResolvedPath(packageJsonFile)
			immigrateJson = require('../immigrate.json')
			expect(packageJson.version).to.equal(immigrateJson.version)
			done()

		promise.catch (error) ->
			throw error
			done()


	it "options.currentVersion overwrites default ./package.json version", (done) ->
		promise = immigrate({
			currentVersion: '999.999.999'
		})

		promise.then (result) ->
			expect(result.version).to.equal('999.999.999')
			done()
	
		promise.catch (error) ->
			throw error
			done()
	
	it "options.currentVersion overwrites options.packageJsonFile", (done) ->
		promise = immigrate({
			currentVersion: '999.999.999'
			packageJsonFile: './package.json'
		})

		promise.then (result) ->
			expect(result.version).to.equal('999.999.999')
			done()
	
		promise.catch (error) ->
			throw error
			done()
	

	it "custom options.immigrateJsonFile contains result", (done) ->
		promise = immigrate({
			immigrateJsonFile: customImmigrateJsonFile
		})

		promise.then ->
			packageJson = requireResolvedPath(packageJsonFile)
			immigrateJson = require(resolve(customImmigrateJsonFile))
			expect(packageJson.version).to.equal(immigrateJson.version)
			done()

		promise.catch (error) ->
			throw error
			done()


	it "Migrates initially if options.migrateIfFresh is true", (done) ->
		promise = immigrate({
			migrateIfFresh: true
		})

		promise.then (result) ->
			packageJson = requireResolvedPath(packageJsonFile)
			immigrateJson = require(resolve(immigrateJsonFile))
			resultJson = require(resolve(resultJsonFile))

			expect(packageJson.version).to.equal(immigrateJson.version)
			expect(resultJson.migrations).to.be.above(0)

			done()

		promise.catch (error) ->
			throw error
			done()

	
