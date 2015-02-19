#Spreadsheet library for Lucee

Adapted from the https://github.com/teamcfadvance/cfspreadsheet-railo extension, this is a standalone library for reading, creating and formatting spreadsheets in [Lucee Server](http://lucee.org/) which does not require installation into each web context.

##Rationale

I was dissatisfied with the official Railo (now Lucee) spreadsheet extension for two main reasons:

1. It was designed for an older version of Railo (Lucee) and (at the time of writing) installation as an extension fails in the current version
2. It can be installed manually, but this needs doing in each web context, followed by a server restart

##Benefits over the official extension

- No installation/restart required, either at the server or individual web context level.
- `read()` method offers some of the features of the `<cfspreadsheet action="read">` tag in script over in addition to the basic options of `SpreadsheetRead()`.
- Invoking the library doesn't create a workbook instance (a.k.a *Spreadsheet Object*), meaning:
 - a blank workbook isn't created unnecessarily when reading an existing spreadsheet
 - the library can be stored as a singleton in application scope
 - the functions work more like those in ACF: you pass in an existing workbook explicitly as the first argument.
- Offers additional convenience methods, e.g. `downloadFileFromQuery()`.
- Uses a newer version of the java POI library (3.11).
- Written entirely in Lucee script.

##Downsides

- Not all spreadsheet functions implemented
- Existing code needs adapting to invoke the library. Existing CFML spreadsheet functions and the `<cfspreadsheet>` tag won't work with it.

##Currently supported Adobe ColdFusion functions

- `addColumn`
- `addRow`
- `addRows`
- `createSheet`
- `deleteRow`
- `formatCell`
- `formatRow`
- `formatRows`
- `new`
- `read`
- `readBinary`
- `removeSheet`
- `setActiveSheet`
- `setActiveSheetNumber`
- `shiftRows`
- `write`

##Usage

Note that this is not a Lucee extension, so **does not need to be installed**. To use it, simply copy the files/folders to a location where `Spreadsheet.cfc` can be called by your application code.

The following examples assume the file containing the script is in the same location as the spreadsheet.cfc.

You will probably want to place the spreadsheet library files in a central location with an application mapping, and instantiate the component using its dot path (e.g. `New myLibrary.spreadsheet.spreadsheet();`). [How to create mappings](http://stackoverflow.com/questions/12073714/components-mapping-in-railo).

```
spreadsheet	=	New spreadsheet();
data = QueryNew( "First,Last","VarChar,VarChar",[ [ "Susi","Sorglos" ],[ "Julian","Halliwell" ] ] );
workbook = spreadsheet.new();
spreadsheet.addRows( workbook,data );
```

###Enhanced Read() method

In Adobe ColdFusion, the `SpreadsheetRead()` script function is limited to just returning a spreadsheet object, whereas the `<cfspreadsheet action="read">` tag has a range of options for reading and returning data from a spreadsheet file. 

Not all of these options are available yet, but with the `read()` method in this library you can currently read a spreadsheet file into a query and return that instead of a spreadsheet object.

```
myQuery = spreadsheet.read( src=mypath,format="query" );
```
#####Required arguments
- `src` string: full path to the file to read

#####Optional arguments
- `format` string: currently only "query" supported
- `headerRow` numeric: specify which row is the header to be used for the query column names
- `sheetName` string: name of the sheet to read
 OR
- `sheetNumber` numeric default=1: number of the sheet to read (1 based, not zero-based)
- `includeHeaderRow` boolean default=false: whether to include the header row from the spreadsheet (NB: the default is the opposite to Adobe ColdFusion 9, which is `excludeHeaderRow=false`). 
- `includeBlankRows` boolean default=false: whether to include blank rows from the spreadsheet in the query data set. By default blank rows are suppressed.

###Additional/convenience methods

####deleteSheet()

Same as `removeSheet` but also allows sheets to be removed by their number.

```
spreadsheet.deleteSheet( workbook,"sheet2" );
spreadsheet.deleteSheet( workbook=workbook,sheetNumber=2 );
```

#####Required arguments
 - `workbook` object: the spreadsheet object
 - `sheetNumber` numeric: the number of the sheet to delete

####deleteSheetNumber()

Easier to type synonym when you want to delete by sheet number:
```
spreadsheet.deleteSheet( workbook=workbook,sheetNumber=2 );
spreadsheet.deleteSheetNumber( workbook,2 );// the same effect
```

#####Required arguments
 - `workbook` object: the spreadsheet object
 - EITHER
 	`sheetName` string: the name of the sheet to delete
 	OR
 	`sheetNumber` numeric: the number of the sheet to delete

####downloadFileFromQuery()

Provides a quick way of downloading a spreadsheet to the browser by passing a query and a filename. The query column names are included by default as a bold header row.

```
spreadsheet	=	New spreadsheet();
data = QueryNew( "First,Last","VarChar,VarChar",[ [ "Susi","Sorglos" ],[ "Julian","Halliwell" ] ] );
filename = "report";
spreadsheet.downloadFileFromQuery( data,filename );
```

#####Required arguments
- `data` query: the data you want to download
- `filename` string: name of the file to download, without the file extension

#####Optional arguments
- `addHeaderRow` boolean default=true: whether to include the query column names as a header row
- `boldHeaderRow` boolean default=true: whether to make the header row bold
- `xmlformat` boolean default=false: whether to create an XML spreadsheet (.xlsx)
- `contentType` string: specify if you wish, otherwise an appropriate MIME type for the spreadsheet will be used

####binaryFromQuery()
Similar to `downloadFileFromQuery`, but without downloading the file.

```
data = QueryNew( "First,Last","VarChar,VarChar",[ [ "Susi","Sorglos" ],[ "Julian","Halliwell" ] ] );
spreadsheet	=	New spreadsheet();
binary = spreadsheet.binaryFromQuery( data );
```
#####Required arguments
- `data` query: the data you want to download

#####Optional arguments
- `addHeaderRow` boolean default=true: whether to include the query column names as a header row
- `boldHeaderRow` boolean default=true: whether to make the header row bold
- `xmlformat` boolean default=false: whether to create an XML spreadsheet (.xlsx)

####writeFileFromQuery()
Similar to `downloadFileFromQuery` but writes the spreadsheet to a file.

```
spreadsheet	=	New spreadsheet();
data = QueryNew( "First,Last","VarChar,VarChar",[ [ "Susi","Sorglos" ],[ "Julian","Halliwell" ] ] );
filepath = ExpandPath( "report.xls" );
spreadsheet.writeFileFromQuery( data,filepath,true );
```
#####Required arguments
- `data` query: the data you want to download
- `filepath` string: full path of the file to be written, including filename and extension

#####Optional arguments
- `overwrite` boolean default=false: whether or not to overwrite an existing file
- `addHeaderRow` boolean default=true: whether to include the query column names as a header row
- `boldHeaderRow` boolean default=true: whether to make the header row bold
- `xmlformat` boolean default=false: whether to create an XML spreadsheet (.xlsx)

##Test Suite
The automated tests require [TestBox 2.1](https://github.com/Ortus-Solutions/TestBox). You will need to create an application mapping for `/testbox`

##Credits

The code is very largely based on the work of [TeamCfAdvance](https://github.com/teamcfadvance/), to whom credit and thanks are due. Ben Nadel's [POI Utility](https://github.com/bennadel/POIUtility.cfc) was also used as a basis for parts of the `read` functionality.

[JavaLoader](https://github.com/markmandel/JavaLoader) is by Mark Mandel.

##Legal

###The MIT License (MIT)

Copyright (c) 2015 Julian Halliwell

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.