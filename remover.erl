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

% parse the content of the file. In this case, the next block is not the last
% of the file
parseContent(<<IsLastBlock:1, Rest/bitstring>>) when IsLastBlock =:= 0 ->
	{<<Block/binary>>, <<NewRest/binary>>} = processMetaDataBlock(
		<<IsLastBlock:1, Rest/bitstring>>
	),
	Content = parseContent(NewRest),
	<<Block/binary, Content/binary>>;
% In this case, this block is the last before the file content
parseContent(<<IsLastBlock:1, Rest/bitstring>>) when IsLastBlock =:= 1 ->
	{<<Block/binary>>, <<RestNew/binary>>} = processMetaDataBlock(
		<<IsLastBlock:1, Rest/bitstring>>
	),
	<<Block/binary, RestNew/binary>>.

% Block of type picture, must be ignored, only the next block will be returned
processMetaDataBlock(<<_:1, 6:7, Length:24, Data/binary>>) ->
	BitLength = Length * 8,
	<<_:BitLength, NextData/binary>> = Data,
	{<<>>, NextData};
% Any other kind of block, must be returned with the rest of the data
processMetaDataBlock(<<IsLastBlock:1, Type:7, Length:24, Data/binary>>) ->
	BitLength = Length * 8,
	<<BlockData:BitLength, NextData/binary>> = Data,
	<<Block/binary>> = <<IsLastBlock:1, Type:7, Length:24, BlockData:BitLength>>,
	{<<Block/binary>>, <<NextData/binary>>}.
