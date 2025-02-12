Class {
	#name : 'StRewriterAbstractToolTest',
	#superclass : 'TestCase',
	#category : 'NewTools-RewriterTools-Tests-AbstractTestClass',
	#package : 'NewTools-RewriterTools-Tests',
	#tag : 'AbstractTestClass'
}

{ #category : 'testing' }
StRewriterAbstractToolTest class >> isAbstract [

	^ self = StRewriterAbstractToolTest
]

{ #category : 'tests' }
StRewriterAbstractToolTest >> testDescriptionText [

	self assert: self toolClass descriptionText isString.
	self assert: self toolClass descriptionText isNotEmpty
]

{ #category : 'tests' }
StRewriterAbstractToolTest >> testIcon [

	self assert: self toolClass icon isForm
]

{ #category : 'tests' }
StRewriterAbstractToolTest >> testIconName [

	self assert: self toolClass iconName isSymbol
]

{ #category : 'accessing' }
StRewriterAbstractToolTest >> toolClass [

	^ self subclassResponsibility
]
