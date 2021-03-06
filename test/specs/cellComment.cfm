<cfscript>
describe( "cellComment",function(){

	it( "Gets the comment from the specified cell",function() {
		workbook = s.new();
		s.addColumn( workbook,"1" );
		theComment = {
			author="cfsimplicity"
			,comment="This is the comment in row 1 column 1"
		};
		expected = Duplicate( theComment );
		expected.Append( { column=1, row=1 } );
		s.setCellComment( workbook,theComment,1,1 );
		actual = s.getCellComment( workbook,1,1 );
		expect( actual ).toBe( expected );
	});

	describe( "Throws an exception if",function(){

		it( "column specified but not row, or vice versa",function() {
			expect( function(){
				s.getCellComment( workbook=workbook,row=1 );
				s.getCellComment( workbook=workbook,column=1 );
			}).toThrow( regex="Invalid argument combination" );
		});

	});	

});	
</cfscript>