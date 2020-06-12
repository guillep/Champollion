Class {
	#name : #CHInterpreterTest,
	#superclass : #TestCase,
	#instVars : [
		'interpreter',
		'receiver',
		'collaborator'
	],
	#category : #'Champollion-Core'
}

{ #category : #helpers }
CHInterpreterTest >> executeSelector: aSymbol [

	| ast |
	ast := (CInterpretable lookupSelector: aSymbol) ast.
	^ self interpreter executeMethod: ast withReceiver: receiver
]

{ #category : #hooks }
CHInterpreterTest >> interpreter [

	^ interpreter
]

{ #category : #hooks }
CHInterpreterTest >> interpreterClass [ 

	^ CHInterpreter
]

{ #category : #hooks }
CHInterpreterTest >> setUp [

	interpreter := self interpreterClass new.
	receiver := CInterpretable new.
	collaborator := CInterpretable new.
	receiver collaborator: collaborator 
]

{ #category : #'chapter two' }
CHInterpreterTest >> testArgumentAccess [
	"
	changeCollaboratorWithArgument
		collaborator x: 500
	"

	receiver x: 200.
	collaborator x: 300.
	self executeSelector: #changeCollaboratorWithArgument.
	self assert: receiver x equals: 200.
	self assert: collaborator x equals: 500
]

{ #category : #'chapter two' }
CHInterpreterTest >> testArgumentAccessDoesNotEscapeItsDefinition [
	"
	changeCollaboratorXWithConflictingArgumentNAmes
		collaborator collaboratorXIgnoringArgumentWithSameName: 1987
	"

	receiver x: 200.
	collaborator x: 300.

	"Test precondition. Both methods have arguments with the same name.
	Otherwise this test could be green but false."
	self
		assert: (CInterpretable >> #collaboratorXIgnoringArgumentWithSameName:) argumentNames
		equals: (CInterpretable >> #x:) argumentNames.
	
	self executeSelector: #changeCollaboratorXWithConflictingArgumentNAmes.

	self assert: receiver x equals: 200.
	self assert: collaborator x equals: 100
]

{ #category : #'chapter two' }
CHInterpreterTest >> testInstanceVariableAccessInMethodActivationDoesNotEscape [
	"
	collaboratorX

		^ collaborator x
	"

	receiver x: 100.
	collaborator x: 200.
	self assert: (self executeSelector: #collaboratorX) equals: 200
]

{ #category : #'chapter two' }
CHInterpreterTest >> testInstanceVariableStoreInMethodActivationDoesNotChangeSender [
	"
	changeCollaboratorX
 		collaborator store100IntoX
	"

	receiver x: 200.
	collaborator x: 300.
	self executeSelector: #changeCollaboratorX.
	self assert: receiver x equals: 200.
	self assert: collaborator x equals: 100
]

{ #category : #'chapter two' }
CHInterpreterTest >> testLookupMessageInSuperclass [
	"
	Subclass>>sendMessageInSuperclass

	^ self methodNotInSubclass
	
	Superclass>>methodNotInSubclass
		^ 5
	"

	self assert: (self executeSelector: #sendMessageInSuperclass) equals: 5
]

{ #category : #'chapter two' }
CHInterpreterTest >> testLookupRedefinedMethod [
	"
	Subclass>>redefinedMethod

	^ super redefinedMethod
	
	Superclass>>redefinedMethod
		^ 5
	"

	self assert: (self executeSelector: #redefinedMethod) equals: 5
]

{ #category : #'chapter two' }
CHInterpreterTest >> testLookupSuperMessage [
	"
	Subclass>>superMessageSend

	^ super methodNotInSubclass
	
	Superclass>>methodNotInSubclass
		^ 5
	"

	self assert: (self executeSelector: #superMessageSend) equals: 5
]

{ #category : #'chapter two' }
CHInterpreterTest >> testLookupSuperMessageNotInReceiverSuperclass [
	"
	This tests tests that it does not loop\
	
	MiddleSuperclass>>redefinedMethodAtThreeLevels

	^ super redefinedMethodAtThreeLevels

	Superclass>>redefinedMethodAtThreeLevels
		^ 5
	"

	self assert: (self executeSelector: #redefinedMethodAtThreeLevels) equals: 5
]

{ #category : #'chapter two' }
CHInterpreterTest >> testReadArgumentVariableAfterMessageSend [
	"
	readArgumentVariableAfterMessageSend
		^ self readArgumentVariableAfterMessageSend: 17
	
	readArgumentVariableAfterMessageSend: arg
		collaborator returnUnassignedTemp.
		^ arg
	
	returnUnassignedTemp
		| temp |
		^ temp
	"
	receiver x: 1.
	collaborator x: 2.
	self assert: (self executeSelector: #readArgumentVariableAfterMessageSend) equals: 17
]

{ #category : #'chapter two' }
CHInterpreterTest >> testReadInstanceVariableAfterMessageSend [
	"
	readInstanceVariableAfterMessageSend
		collaborator returnUnassignedTemp.
		^ x
	
	returnUnassignedTemp
		| temp |
		^ temp
	"
	receiver x: 1.
	collaborator x: 2.
	self assert: (self executeSelector: #readInstanceVariableAfterMessageSend) equals: 1
]

{ #category : #'chapter two' }
CHInterpreterTest >> testReadTemporaryVariableAfterMessageSend [
	"
	readTemporaryVariableAfterMessageSend
		| temp |
		temp := 17.
		collaborator returnUnassignedTemp.
		^ temp
	
	returnUnassignedTemp
		| temp |
		^ temp
	"
	self assert: (self executeSelector: #readTemporaryVariableAfterMessageSend) equals: 17
]

{ #category : #'chapter two' }
CHInterpreterTest >> testReadTemporaryVariableDoesNotEscapeItsDefinition [
	"
	readCollaboratorTemporaryVariable
		| temp |
		temp := 17.
		^ collaborator returnUnassignedTemp
	
	returnUnassignedTemp
		| temp |
		^ temp
	"
	self assert: (self executeSelector: #readCollaboratorTemporaryVariable) equals: nil
]

{ #category : #'chapter one' }
CHInterpreterTest >> testReturnAccessInstanceVariable [

	receiver x: 100.
	self assert: (self executeSelector: #returnX) equals: 100
]

{ #category : #'chapter one' }
CHInterpreterTest >> testReturnBoolean [

	self assert: (self executeSelector: #returnBoolean) equals: false
]

{ #category : #'chapter one' }
CHInterpreterTest >> testReturnEmptyArray [

	self assert: (self executeSelector: #returnEmptyArray) equals: #() 
]

{ #category : #'chapter one' }
CHInterpreterTest >> testReturnFloat [

	self assert: (self executeSelector: #returnFloat) equals: 3.14 
]

{ #category : #'chapter one' }
CHInterpreterTest >> testReturnGlobal [

	| globalObject |
	globalObject := Object new.
	interpreter globalEnvironmentAt: #Global put: globalObject. 
	self assert: (self executeSelector: #returnGlobal) equals: globalObject  
]

{ #category : #'chapter one' }
CHInterpreterTest >> testReturnInteger [

	self assert: (self executeSelector: #returnInteger) equals: 5
]

{ #category : #'chapter one' }
CHInterpreterTest >> testReturnLiteralArray [

	self assert: (self executeSelector: #returnLiteralArray) equals: #(true 1 'ahah')
]

{ #category : #'chapter one' }
CHInterpreterTest >> testReturnSelf [

	self assert: (self executeSelector: #returnSelf) equals: receiver
]

{ #category : #'chapter one' }
CHInterpreterTest >> testReturnSuper [

	self assert: (self executeSelector: #returnSuper) equals: receiver
]

{ #category : #'chapter two' }
CHInterpreterTest >> testSelfSend [
	"
	sendMessageReturnX

		^ self returnX
	"

	receiver x: 100.
	self assert: (self executeSelector: #sendMessageReturnX) equals: 100
]

{ #category : #'chapter one' }
CHInterpreterTest >> testStoreInstanceVariable [

	receiver x: 17.
	self executeSelector: #store100IntoX.
	self assert: receiver x equals: 100
]

{ #category : #'chapter two' }
CHInterpreterTest >> testUnassignedTempHasNilValue [
	"
	creturnUnassignedTemp
		| temp |
		^ temp
	"

	self assert: (self executeSelector: #returnUnassignedTemp) equals: nil
]

{ #category : #'chapter two' }
CHInterpreterTest >> testWriteTemporaryVariableDoesNotEscapeItsDefinition [
	"writeCollaboratorTemporaryVariable

		| temp |
		temp := 17.
		collaborator writeTemporaryVariable.
		^ temp
	
	writeTemporaryVariable

		| temp |
		temp := 100.
		^ temp
	"
	self assert: (self executeSelector: #writeCollaboratorTemporaryVariable) equals: 17
]