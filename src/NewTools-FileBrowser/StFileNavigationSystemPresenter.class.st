"
I'm use by thez fileDialog

my job is to navigate across file 

I provide:
* an history of visited folder
* a textInput use to jump to the write path
* a dropList use to filter the content of the fileReferenceTable
* a TextPresenter to show the selectedFile 

CUSTOMIZATION
-------------

look at the protocol 'api-customization'

column: aCollectionOfColumn
===========================

	to use it you have to give a collection of son of FDAbstractFileReferenceColumn for more information on how to create see documentation of FDAbstractFileReferenceColumn

defaultFoler: aFileReference
============================

	nothing to say 

filtersCustomization: aCollectionOfFilter
=========================================

	more documentation see FDAbstractPredicate documentation

previewer: aPreviewer
=====================

	more documentation see FDAbstractPreviewer documentation
	
IV
--

currentPathTextInputPresenter : <SpTextInputFieldPresenter> It's use to display the current path and there are same feature like in window 
nameLabel : <SpLabelPresenter>
nameText: <SpTextInputFieldPresenter> , use to show the name of the selected item of fileReferenceTable
filtersDropList <SpDropList> , use to display all the filter
readPointerHistoryParcour <DoubleLink> , use for the navigationSystem
currentDirectory , <FileReference> into there is the currentDirectory 
hiddenFilter <FDAbstractPredicate> there is a NullFilter or an hiddenFilter
columns <FDAbstractFileReferenceColumn> it's a collection of Column use by FileReferenceTable
previewer <FDAbstractPreviewer> 
nextButton <SpButton> use for the navigationSystem 
previousButton <SpButton> use for the navigationSystem
notebookPreviewer <SpNoteBook> use by the preview system
fileReferenceTable <SpTablePresenter> it's display children of the current directory
"
Class {
	#name : 'StFileNavigationSystemPresenter',
	#superclass : 'StFileBrowserAbstractPresenter',
	#instVars : [
		'currentPathTextInputPresenter',
		'nameText',
		'filtersDropList',
		'filter',
		'previewer',
		'nextButton',
		'previousButton',
		'notebookPreviewer',
		'fileReferenceTable',
		'configButton'
	],
	#classVars : [
		'Previewer'
	],
	#category : 'NewTools-FileBrowser-UI',
	#package : 'NewTools-FileBrowser',
	#tag : 'UI'
}

{ #category : 'commands' }
StFileNavigationSystemPresenter class >> buildCommandsGroupWith: presenter forRoot: rootCommandGroup [
	rootCommandGroup
		register:
			((CmCommandGroup named: 'StFBNavigationMenu') asSpecGroup
				register: StFileBrowserNewDirectoryCommand forSpec;
				register: StFileBrowserCopyBasenameCommand forSpec;
				register: StFileBrowserCopyFullnameCommand forSpec;				
				
				register: StFileBrowserRenameCommand forSpec;
				register: StFileBrowserRemoveCommand forSpec;
				register: StFileBrowserInspectCommand forSpec;
				register: StFileBrowserCompressCommand forSpec;
				register: StFileBrowserFileInCommand forSpec;
				register: StFileBrowserChangeListCommand forSpec;
				register: StFileBrowserOpenTerminalCommand forSpec;

				register:
					((CmCommandGroup named: 'Bookmarks') asSpecGroup
						register: StFileBrowserAddBookmarkCommand forSpec;
						yourself);
				yourself)
]

{ #category : 'defaults' }
StFileNavigationSystemPresenter class >> defaultPreviewer [
	^ StFileBrowserContentPreviewer new
]

{ #category : 'examples' }
StFileNavigationSystemPresenter class >> example [
	<example>
	| presenter |
	presenter := self new.
	
	presenter previewer: StFileBrowserPNGPreviewer new.
	presenter open.
	presenter inspect.
	^ presenter
]

{ #category : 'class initialization' }
StFileNavigationSystemPresenter class >> initialize [

	self initializeBookmarks.
	Previewer := self defaultPreviewer
]

{ #category : 'api - customization' }
StFileNavigationSystemPresenter >> columns: aCollectionOfColumns [
	| tmpColumn |
	tmpColumn := aCollectionOfColumns asSet.
	tmpColumn
		addAll:
			({StFileBrowserIconColumn.
			StFileBrowserNameColumn} ).
	fileReferenceTable
		columns: ((tmpColumn asOrderedCollection sort: #priority ascending) collect: #column)
]

{ #category : 'initialization' }
StFileNavigationSystemPresenter >> configButtonAction [

	configButton action: [
		SettingBrowser new
			rootNodes: (SettingBrowser currentTree nodeNamed: #fileBrowser) allChildren;
			open ].
]

{ #category : 'initialization' }
StFileNavigationSystemPresenter >> connectPresenters [

	self filesListAction.
	self nameTextAction.
	self filtersDropListAction.
	self previousBeforeButtonAction.
	self nextButtonAction.
	self configButtonAction.
]

{ #category : 'accessing' }
StFileNavigationSystemPresenter >> currentPathTextInputPresenter [
	^ currentPathTextInputPresenter
]

{ #category : 'api - customization' }
StFileNavigationSystemPresenter >> defaultFolder: aFileReference [
	self updateWidgetWithFileReference: aFileReference.
	self initializeHistoryIteratorWith: aFileReference
]

{ #category : 'layout' }
StFileNavigationSystemPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		add: (SpBoxLayout newLeftToRight
				vAlignCenter;
				add: previousButton expand: false;
				add: nextButton expand: false;
				add: currentPathTextInputPresenter;
			   addLast: configButton;				
				yourself)
			 expand: false;
		add: (SpPanedLayout newTopToBottom
				add: fileReferenceTable;
				add: notebookPreviewer;
				yourself);
		add: (SpBoxLayout newLeftToRight
				vAlignCenter;
				add: nameText;
				add: filtersDropList expand: false;
				yourself)
			 expand: false;
		yourself
]

{ #category : 'accessing' }
StFileNavigationSystemPresenter >> fileReferenceTable [
	^ fileReferenceTable
]

{ #category : 'actions' }
StFileNavigationSystemPresenter >> filesListAction [

	| previewProcess |

	fileReferenceTable
		transmitTo: nameText
		transform: [ :selectedItem | 
			selectedItem ifNotNil: [ selectedItem basename ] ifNil: [ '' ] ].

	fileReferenceTable whenActivatedDo: [ :selectedItem | 
		previewProcess ifNotNil: [ 
			previewProcess isTerminated ifFalse: [ previewProcess terminate ] ].
		selectedItem selectedItem isDirectory
			ifTrue: [ self openFolder: selectedItem selectedItem ]
			ifFalse: [ self owner confirm ] ].

	fileReferenceTable whenSelectedDo: [ :aFileReference | 
		previewProcess ifNotNil: [ 
			previewProcess isTerminated ifFalse: [ previewProcess terminate ] ].
		previewProcess := [ 
		                  notebookPreviewer pageContent:
			                  (previewer previewOn: aFileReference) ]
			                  forkAt: Processor userBackgroundPriority
			                  named: 'File Browser preview loader' ]
]

{ #category : 'accessing' }
StFileNavigationSystemPresenter >> filter: aFilter [

	filter := aFilter.
	filtersDropList ifNotNil: [ 
		filtersDropList listSize isZero ifFalse: [ 
			self initializeFiltersDropList ] ]
]

{ #category : 'api - customization' }
StFileNavigationSystemPresenter >> filtersCustomization: aCollectionOfFilter [
	"i always add the filter 'no filter'"

	filtersDropList
		items:
			(aCollectionOfFilter asOrderedCollection
				add: StAllFilter new;
				yourself) asSet asOrderedCollection.
	filtersDropList
		selectIndex:
			((filtersDropList listItems collect: #name)
				indexOf: StAllFilter new name)
]

{ #category : 'accessing' }
StFileNavigationSystemPresenter >> filtersDropList [
	^ filtersDropList
]

{ #category : 'actions' }
StFileNavigationSystemPresenter >> filtersDropListAction [
	filtersDropList whenSelectionChangedDo: [ self updateFileSystemContents ]
]

{ #category : 'initialization' }
StFileNavigationSystemPresenter >> initialize [

	filter := StVisibleFilter new.
	previewer := Previewer.
	super initialize
]

{ #category : 'initialization' }
StFileNavigationSystemPresenter >> initializeFilesTable [

	fileReferenceTable
		beResizable;
		columns: StFileBrowserAbstractColumn columns;
		sortingBlock: [ :a :b | 
			a isDirectory & b isDirectory not or: [ 
					a isDirectory = b isDirectory and: [ 
							a basename asLowercase < b basename asLowercase ] ] ];
		contextMenuFromCommandsGroup: [ self rootCommandsGroup / 'StFBNavigationMenu' ]
]

{ #category : 'initialization' }
StFileNavigationSystemPresenter >> initializeFiltersDropList [

	filtersDropList
		items: (StFileBrowserAbstractFilter defaultFiltersWith: filter);
		display: [ :item | item name ];
		selectItem: filter
]

{ #category : 'initialization' }
StFileNavigationSystemPresenter >> initializeNavigationPresenters [

	previousButton := self newButton.
	nextButton := self newButton.

	nextButton
		icon: (self application iconNamed: #forward);
		addStyle: 'small'.
	previousButton
		icon: (self application iconNamed: #back);
		addStyle: 'small'.

]

{ #category : 'initialization' }
StFileNavigationSystemPresenter >> initializePresenters [

	super initializePresenters.
	notebookPreviewer := self instantiate: StNoteBookPreviewerPresenter.
	fileReferenceTable := self newTable.
	currentPathTextInputPresenter := self instantiate: StPathBreadcrumbPresenter on: self model.
	nameText := self newTextInput.
	filtersDropList := self newDropList.
	configButton := self newButton
			addStyle: 'small';
			icon: (self iconNamed: #config);
			yourself.
	
	self initializeNavigationPresenters.
	self initializeFilesTable.
	self initializeFiltersDropList.
	self openOnLastDirectory 
		ifTrue: [ self updateWidgetWithFileReference: self lastVisitedDirectory ]
		ifFalse: [ self updateWidgetWithFileReference: self defaultDirectory ].
	self initializeHistoryIteratorWith: self currentDirectory
]

{ #category : 'accessing' }
StFileNavigationSystemPresenter >> nameText [
	^ nameText
]

{ #category : 'actions' }
StFileNavigationSystemPresenter >> nameTextAction [

	nameText whenTextChangedDo: [ :newText | 
		self nameTextChanged: newText ]
]

{ #category : 'actions' }
StFileNavigationSystemPresenter >> nameTextChanged: aText [

	fileReferenceTable selectedItem ifNotNil: [ :item | 
		(item basename = aText or: [ item basenameWithoutExtension = aText ]) 
			ifTrue: [ ^ self ] ].
	fileReferenceTable items
		detect: [ :item | 
			item basename = aText or: [ item basenameWithoutExtension = aText ] ]
		ifFound: [ :item | fileReferenceTable selectItem: item ]
		ifNone: [ fileReferenceTable unselectAll ]
]

{ #category : 'accessing' }
StFileNavigationSystemPresenter >> nextButton [
	^ nextButton
]

{ #category : 'accessing' }
StFileNavigationSystemPresenter >> nextButtonAction [
	nextButton action: [ self history redoIfEmpty: [ self inform: 'Nothing to redo.' ] ]
]

{ #category : 'accessing' }
StFileNavigationSystemPresenter >> notebookPreviewer [
	^ notebookPreviewer
]

{ #category : 'utilities' }
StFileNavigationSystemPresenter >> openFolder: aFileReference [ 

	self updateWidgetWithFileReference: aFileReference.
	model openFolder: aFileReference.

]

{ #category : 'accessing' }
StFileNavigationSystemPresenter >> previewer [
	^ previewer
]

{ #category : 'api - customization' }
StFileNavigationSystemPresenter >> previewer: aPreviewer [ 
	previewer := aPreviewer 
]

{ #category : 'actions' }
StFileNavigationSystemPresenter >> previousBeforeButtonAction [
	previousButton action: [ self history undoIfEmpty: [ self inform: 'Nothing to undo' ] ]
]

{ #category : 'accessing' }
StFileNavigationSystemPresenter >> previousButton [
	^ previousButton
]

{ #category : 'accessing' }
StFileNavigationSystemPresenter >> selectedEntry [

	^ fileReferenceTable selection selectedItem ifNil: [ 
		  self nameText text trimmed
			  ifEmpty: [ self currentDirectory ]
			  ifNotEmpty: [ :text | self currentDirectory / text ] ]
]

{ #category : 'asserting' }
StFileNavigationSystemPresenter >> shouldReparent [
	"Since a removal was requested from the navigation table, is not necessary to move to the parent directory"

	^ false
]

{ #category : 'utilities' }
StFileNavigationSystemPresenter >> updateFileSystemContents [

	fileReferenceTable items:
		((filtersDropList selectedItem ifNil: [ filter ]) applyOn:
			 (self currentDirectory children select: #exists)).
]

{ #category : 'utilities' }
StFileNavigationSystemPresenter >> updateWidgetWithFileReference: aFileReference [

	self currentDirectory: aFileReference.
	self updateFileSystemContents.
	currentPathTextInputPresenter currentDirectory: self currentDirectory
]