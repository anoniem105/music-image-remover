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
	{ok, <<SMarker:32, Data/binary>>} = file:read_file(File),
	file:write_file("foo", <<SMarker:32>>),
	file:write_file("foo", parseContent(Data), [append]);
processFile(_, _) ->
	unknownFileType.

parseContent(<<IsLastBlock, Rest/binary>>) when IsLastBlock =:= 0 ->
	<<IsLastBlock, Rest/binary>>;
parseContent(<<IsLastBlock, Rest/binary>>) when IsLastBlock =:= 1 ->
	<<IsLastBlock, Rest/binary>>.
