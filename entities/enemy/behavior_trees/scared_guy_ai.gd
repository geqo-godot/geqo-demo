@tool
extends BeehaveTree

func setup(...args: Array):
	%ExecuteQueryAction.environment_query = args[0]
