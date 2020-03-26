Class {
	#name : #BasicInterpreterTest,
	#superclass : #TestCase,
	#category : #Champollion
}

{ #category : #hooks }
BasicInterpreterTest >> interpreter [

	^ self interpreterClass new
]

{ #category : #hooks }
BasicInterpreterTest >> interpreterClass [ 

	^ BasicInterpreter
]

{ #category : #assignment }
BasicInterpreterTest >> testAccessXInInstance [

	| ast result |
	ast := (Interpretable >> #store100IntoX) ast.
	result := self interpreter execute: ast with: (Interpretable new x: 100).
	self assert: result equals: 100. 
	
]

{ #category : #'return constant' }
BasicInterpreterTest >> testReturnConstant [

	| ast result |
	ast := (Interpretable >> #returnFive) ast.
	result := self interpreter execute: ast. 
	self assert: result equals: 5
]

{ #category : #'return constant' }
BasicInterpreterTest >> testReturnFalse [

	| ast result |
	ast := (Interpretable >> #returnFalse) ast.
	result := self interpreter execute: ast. 
	self deny: result 
]

{ #category : #assignment }
BasicInterpreterTest >> testStore100IntoX [

	| ast result |
	ast := (Interpretable >> #store100IntoX) ast.
	result := self interpreter execute: ast with: Interpretable new. 
	
]