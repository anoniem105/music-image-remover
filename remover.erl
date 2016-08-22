-module(remover).

-export([parse/1]).

parse(Directory) ->
	{ok, Filenames} = file:list_dir(Directory),
	processFiles(Filenames).

processFiles([CurFile | Rest]) ->
	io:format(CurFile),
	Extension = filename:extension(CurFile),
	io:format(Extension),
	processFile(CurFile, Extension),
	processFiles(Rest);
processFiles([]) ->
	dfsfinished.

processFile(File, ".flac") ->
	{ok, Data} = file:read_file(File),
	Data;
processFile(_, _) ->
	unknownFileType.
