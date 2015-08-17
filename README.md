# immigrate.js
## Automatize migrations for your Node.js packages

### Example
- `app.js`
- `package.json`
- `migrations/v1.2.0.js`
- `migrations/v1.3.0.js`
- `migrations/v1.4.0.js`
- `migrations/setup.js`

```js
// app.js
immigrate = require('immigrate')

immigrate(); // that's it
```

immigrate.js will record the version from the package.json file. If the package.json version increases from a previous run, intermediate migration files will be executed. A context can be passed to the migration files.

### Options

`immigrate({ ... })` can receive an optional options object.

parameter           | type                 | description
-----               | -----                | -----
currentVersion      | string \<optional\>  | Overwrites automatic version detection with custom version.
packageJsonFile     | string \<optional\>  | Declare custom path to package.json file.
migrateIfFresh      | boolean \<optional\> | Default: `false`. Execute all migrations the first time when immigrate.js is run. Otherwise, only `setup.js` will be executed.
migrationsDirectory | string \<optional\>  | Default: `./migrations/`. Path to the directory containing the version migration files.
immigrateJsonFile   | string \<optional\>  | Default: `./immigrate.json`. Path to the JSON file that should be used by immigrate.js to record the last version that has been migrated.
context             | object \<optional\>  | An object that will be passed as argument to the migration files (see below).


### Usage
The first time when immigrate.js is run, it will look for the `setup.js` file in the `migrationsDirectory`. The `setup.js` file is optional. At any other time, immigrate.js will check if the version of the main package increased since the last time it was run, and execute any intermediate immigration files from the `migrationsDirectory`.

If you would like to execute all migration files also the first time immigrate.js is called, up to the present version of the package, then set `migrateIfFresh` to `true`.

The CoffeeScript extension (`.coffee`) can also be used (for all files) instead of `.js`.

### Migration files
The files in the `migrationsDirectory` must follow a valid semver version format, such as `v1.2.3.js` or `1.2.3.js`. Those files will be `require`d and executed when a version update is detected, from lowest version to highest.

If the `module.exports` of any of those migration files returns a function, it will be executed.

If the `module.exports` of a migration file returns a promise, the promise will be resolved before the next migration will be called. `module.exports` may also return a function which returns a promise.

If the migration file `exports` a function, then the `context` option parameter will be passed as first argument. The `context` will also be the functions context (accessible through `this). E.g.

```js
module.exports = function(context) {...}
```

`immigrate()` returns a promise that will be resolved once all migrations have completed.

### Example with context and promises

```js
// app.js
immigrate = require('immigrate');

promise = immigrate({
	context: {
		database: app.database
	}
});

promise.then(function () { /* migrations have completed */ });
```

```js
// migrations/v1.23.45.js
module.exports = function (context) {
	// ...
	return context.database.updateSomething();
}

// or...
module.exports = function () {
	// ...
	return this.database.updateSomething();
}

```

Promise example:
```
// migrations/v1.12.13.js
Promise = require('promise');

module.exports = function () {
	return new Promise(function (resolve, reject) {
		updateSomethingAsync(function (err, res) {
			if (err) reject(err);
			else resolve(res);
		});
	});
}
```

### Details
By default, the module will look for the `package.json` file in the parent directories of the file which require()d immigrate.js.

The parent directory of the `package.json` file will be used as base directory for all other files by default if you supply relative paths (for `migrationsDirectory` and `immigrateJsonFile`).


