-module(remover).

-export([parse/1]).

parse(Directory) ->
	{ok, Filenames} = file:list_dir(Directory),
	processFiles(Filenames).

processFiles([CurFile | Rest]) ->
	Extension = filename:extension(CurFile),
	processFile(CurFile, Extension),
	processFiles(Rest);
processFiles([]) ->
	finished.

processFile(File, ".flac") ->
	{ok, <<SMarker:32, Data/binary>>} = file:read_file(File),
	NewName = "new-" ++ File,
	file:write_file(NewName, <<SMarker:32>>),
	file:write_file(NewName, parseContent(Data), [append]);
processFile(_, _) ->
	unknownFileType.

parseContent(<<IsLastBlock, Rest/binary>>) when IsLastBlock =:= 0 ->
	<<IsLastBlock, Rest/binary>>;
parseContent(<<IsLastBlock, Rest/binary>>) when IsLastBlock =:= 1 ->
	<<IsLastBlock, Rest/binary>>.
