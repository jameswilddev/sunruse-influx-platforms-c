describe "platforms", ->
	describe "javascript", ->
		describe "resultGenerator", ->
			resultGenerator = options = undefined
			beforeEach ->
				resultGenerator = require "./resultGenerator"
				options = 
					outputTypeName: "testOutputTypeName"
			describe "imports", ->
				it "codeCache", ->
					expect(resultGenerator.codeCache).toBe require "./codeCache"
			describe "on calling", ->
				it "returns an anonymous object given properties", ->
					codeCache = resultGenerator.codeCache
					resultGenerator.codeCache = (platform, cache, input) ->
						expect(platform).toEqual "Test Platform"
						expect(cache).toEqual "Test Cache"
						switch input
							when "Test Property AA" then return "Test Code AA"
							when "Test Property ABA" then return "Test Code ABA"
							when "Test Property B" then return "Test Code B"
							else expect(false).toBeTruthy()
					
					output = 
						properties:
							propertyA:
								properties:
									propertyAA: "Test Property AA"
									propertyAB: 
										properties:
											propertyABA: "Test Property ABA"
							propertyB: "Test Property B"
							
					result = resultGenerator "Test Platform", "Test Cache", output, options
					resultGenerator.codeCache = codeCache
									
					expect(result).toEqual 	"""
						\treturn (testOutputTypeName) {
						\t	.propertyA = {
						\t		.propertyAA = Test Code AA,
						\t		.propertyAB = {
						\t			.propertyABA = Test Code ABA
						\t		}
						\t	},
						\t	.propertyB = Test Code B
						\t};
											"""
				it "returns the generated code given non-properties", ->
					codeCache = resultGenerator.codeCache
					resultGenerator.codeCache = (platform, cache, input) ->
						expect(platform).toEqual "Test Platform"
						expect(cache).toEqual "Test Cache"
						expect(input).toBe output
						"Test Code"
					
					output = {}
							
					result = resultGenerator "Test Platform", "Test Cache", output, options
					resultGenerator.codeCache = codeCache
									
					expect(result).toEqual 	"""
						\treturn (testOutputTypeName) Test Code;
											"""					