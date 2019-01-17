Class {
	#name : #StInspectorNode,
	#superclass : #Object,
	#instVars : [
		'hostObject'
	],
	#category : #'NewTools-Inspector-Model'
}

{ #category : #'instance creation' }
StInspectorNode class >> hostObject: anObject [ 
	^ self new
		hostObject: anObject;
		yourself
]

{ #category : #accessing }
StInspectorNode >> children [

	^ #()
]

{ #category : #composition }
StInspectorNode >> childrenNodesFor: aVariablesBrowser [
	"Return a collection of subvariable nodes to be displayed in a given raw variables browser.
	Note: by default we dispatch to browser and let it perform collection"

	^ aVariablesBrowser childrenVariableNodesForNode: self
]

{ #category : #accessing }
StInspectorNode >> errorMessage [
	^ 'error obtaining value'
]

{ #category : #accessing }
StInspectorNode >> hostObject [
	^ hostObject
]

{ #category : #accessing }
StInspectorNode >> hostObject: anObject [

	"
	Allow nil objects for the moment. Normally the inspector should be able to inspect nil.
	self
		assert: [ anObject isNotNil ]
		description: [ 'Host object must not be nil' ]."

	self
		assert: [ hostObject isNil ]
		description: [ 'Host can be assigned only once' ].

	hostObject := anObject
]

{ #category : #accessing }
StInspectorNode >> icon [ 

	^ [ 
		(self value gtInspectorIcon) ifNil: [ 
			self value class systemIcon ] ]
	on: Error do: [ :error | 
		self iconError: error ]
]

{ #category : #private }
StInspectorNode >> iconError: error [
	
	^ self iconNamed: #smallWarningIcon
]

{ #category : #actions }
StInspectorNode >> inspectorActionsForNode [
	"Return a collection of available inspector actions associated with a variable node"

	^ #()
]

{ #category : #accessing }
StInspectorNode >> key [
	"Answer the key of this object variable (slot, indexed attribute, computed value)."
	^ self subclassResponsibility
]

{ #category : #accessing }
StInspectorNode >> label [
	"Answer the label of this object variable (slot, indexed attribute, computed value)."
	^ self key asString
]

{ #category : #accessing }
StInspectorNode >> rawValue [
	"Answer the object value of this object variable (slot, indexed attribute, computed value)."
	^ self subclassResponsibility
]

{ #category : #actions }
StInspectorNode >> save: aValue [
]

{ #category : #accessing }
StInspectorNode >> stringValue [

	^ self value gtDisplayString
	
]

{ #category : #accessing }
StInspectorNode >> value [
	"Answer the object value of this object variable (slot, indexed attribute, computed value).
	Return nil in case there is an error obtaining the value"
	^ [ self rawValue ] on: Error do: [ nil ]
]

{ #category : #accessing }
StInspectorNode >> variableTag [
	^ 'implicit'
]