# immigrate.js
## Automatize migrations for your Node.js packages

### API
```
immigrate = require('immigrate');

immigrate({
	currentVersion: "1.2.3", // or "v1.2.3"
	// OR
	packageJsonFile: "./package.json" // default
	
	migrateIfFresh: true,

	migrationsDirectory: "./migrations/",

	context: { /* ... */ }

	immigrateJsonFile: "./immigrate.json"
})
```

All options are optional

The `migrationsDirectory` (default: `./migrations/`) must contain files with the file name format of
- `v1.0.1.js`
- `v1.2.0.js`
- `v1.12.13.js`
- ...
- `setup.js`

or
- `1.0.1.js`
- `1.2.0.js`
- `1.12.13.js`
- ...
- `setup.js`

The `.coffee` extension for CoffeeScript instead of `.js` is also allowed. E.g. `1.12.13.coffee`

The versions will be parsed with the npm semver parser for node. https://github.com/npm/node-semver

The `currentVersion` can be defined either as an option, or automatically parsed from the `packageJsonFile` (default: `./package.json`). If no option is set, the `package.json` file is used.

If the `currentVersion` increased since the last time immigrate.js was executed, then all intermediate version scripts from the `migrationsDirectory` will be run. The most recent version to which has been migrated will be recorded in the `immigrateJsonFile` (default: `/.immigrate.json`).

The file `setup.js` is an optional script file. If present, it will be executed instead of the `vX.X.X.js` scripts when immigrate.js called for the first time in a project directory.

If either the `setup.js` file is present, or `migrateIfFresh` is set to `false`, then the `vX.X.X.js` files will not be executed at the first time when immigrate.js is called. Instead migration starts at the version at which immigrate.js is first called.

The files in the `migrationsDirectory` can return a function through `module.exports`. If so, the `context` option will be passed as the first argument. The `context` option will also be the context of the module.exports function.

Context example:

```
// index.js
immigrate = require('immigrate');

immigrate({
	context: {
		database: app.database
	}
})
```

```
// migrations/v1.12.13.js
module.exports = function (context) {
	context.database.updateSomething();
}

// -- OR --
module.exports = function () {
	this.database.updateSomething();
}

```


