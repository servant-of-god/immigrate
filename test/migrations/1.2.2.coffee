module.exports = (context)->
	require('../helpers').recordVersion('argument-found') if context?.foo
	require('../helpers').recordVersion('1.2.2')
	return undefined
