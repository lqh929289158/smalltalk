Error subclass: XPPStructureException [
    
    <category: 'XMLPullParser'>
    <comment: nil>

]



Stream subclass: XMLAbstractPullParser [
    <category: 'XMLPullParser'>
    <comment: 'This is based on Antony Blakey''s XMLPullParser.'>

    XMLAbstractPullParser class >> parse: source [
	<category: 'instance creation'>
	self subclassResponsibility
    ]

    at: attName [
	<category: 'delegating accessors'>
	^self current at: attName
    ]

    at: attName ifFound: aFoundBlock ifNone: aBlock [
	<category: 'delegating accessors'>
	^self current 
	    at: attName
	    ifFound: aFoundBlock
	    ifNone: aBlock
    ]

    at: attName ifNone: aBlock [
	<category: 'delegating accessors'>
	^self current at: attName ifNone: aBlock
    ]

    collect: tagName peek: aBlock [
	<category: 'tag-based api'>
	| result |
	result := OrderedCollection new.
	self while: tagName peek: [result add: (self matchAnyPeek: aBlock)].
	^result
    ]

    collect: tagName take: aBlock [
	<category: 'tag-based api'>
	| result |
	result := OrderedCollection new.
	self while: tagName peek: [result add: (self matchAnyTake: aBlock)].
	^result
    ]

    collectAnyPeek: aBlock [
	<category: 'tag-based api'>
	| result |
	result := OrderedCollection new.
	self whileAnyPeek: [result add: (self matchAnyPeek: aBlock)].
	^result
    ]

    collectAnyTake: aBlock [
	<category: 'tag-based api'>
	| result |
	result := OrderedCollection new.
	self whileAnyTake: [result add: (self matchAnyPeek: aBlock)].
	^result
    ]

    consumeEndTag [
	<category: 'consuming events'>
	self mustBeEndTag.
	self next
    ]

    consumeEndTag: tagName [
	<category: 'consuming events'>
	self mustBeEndTag: tagName.
	self next
    ]

    consumeStartDocument [
	<category: 'consuming events'>
	self mustBeStartDocument.
	self next
    ]

    consumeStartTag [
	<category: 'consuming events'>
	self mustBeStartTag.
	self next
    ]

    consumeStartTag: tagName [
	<category: 'consuming events'>
	self mustBeStartTag: tagName.
	self next
    ]

    consumeText [
	<category: 'consuming events'>
	| text |
	self isText 
	    ifTrue: 
		[self mustBeText.
		text := self current text.
		self next.
		^text]
	    ifFalse: [^'']
    ]

    current [
	<category: 'core api'>
	self subclassResponsibility
    ]

    if: tagName peek: aBlock [
	<category: 'tag-based api'>
	(self is: tagName) ifTrue: [self matchAnyPeek: aBlock]
    ]

    if: tagName peek: aBlock else: elseBlock [
	<category: 'tag-based api'>
	^(self is: tagName) 
	    ifTrue: [self matchAnyPeek: aBlock]
	    ifFalse: [elseBlock value]
    ]

    if: tagName take: aBlock [
	<category: 'tag-based api'>
	(self is: tagName) ifTrue: [self matchAnyTake: aBlock]
    ]

    if: tagName take: aBlock else: elseBlock [
	<category: 'tag-based api'>
	^(self is: tagName) 
	    ifTrue: [self matchAnyTake: aBlock]
	    ifFalse: [elseBlock value]
    ]

    ifAnyPeek: aBlock [
	<category: 'tag-based api'>
	self isStartTag ifTrue: [self matchAnyPeek: aBlock]
    ]

    ifAnyPeek: aBlock else: elseBlock [
	<category: 'tag-based api'>
	^self isStartTag 
	    ifTrue: [self matchAnyPeek: aBlock]
	    ifFalse: [elseBlock value]
    ]

    ifAnyTake: aBlock [
	<category: 'tag-based api'>
	self isStartTag ifTrue: [self matchAnyTake: aBlock]
    ]

    ifAnyTake: aBlock else: elseBlock [
	<category: 'tag-based api'>
	^self isStartTag 
	    ifTrue: [self matchAnyTake: aBlock]
	    ifFalse: [elseBlock value]
    ]

    is: tagName [
	<category: 'testing event types'>
	^self isStartTag: tagName
    ]

    isEndDocument [
	<category: 'testing event types'>
	^self current isEndDocument
    ]

    isEndTag [
	<category: 'testing event types'>
	^self current isEndTag
    ]

    isEndTag: aStringOrNodeTag [
	<category: 'testing event types'>
	^self current isEndTag: aStringOrNodeTag
    ]

    isStartDocument [
	<category: 'testing event types'>
	^self current isStartDocument
    ]

    isStartTag [
	<category: 'testing event types'>
	^self current isStartTag
    ]

    isStartTag: aStringOrNodeTag [
	<category: 'testing event types'>
	^self current isStartTag: aStringOrNodeTag
    ]

    isText [
	<category: 'testing event types'>
	^self current isText
    ]

    match: tagName peek: aBlock [
	<category: 'tag-based api'>
	self mustBeStartTag: tagName.
	^self matchAnyPeek: aBlock
    ]

    match: tagName take: aBlock [
	<category: 'tag-based api'>
	self mustBeStartTag: tagName.
	^self matchAnyTake: aBlock
    ]

    matchAnyPeek: aBlock [
	<category: 'tag-based api'>
	self mustBeStartTag.
	^aBlock numArgs = 1 
	    ifTrue: [aBlock value: self current]
	    ifFalse: [aBlock value]
    ]

    matchAnyTake: aBlock [
	<category: 'tag-based api'>
	| result |
	result := aBlock numArgs = 1 
		    ifTrue: 
			[| tag |
			tag := self current.
			self consumeStartTag.
			aBlock value: tag]
		    ifFalse: 
			[self consumeStartTag.
			aBlock value].
	self consumeEndTag.
	^result
    ]

    mustBeEndDocument [
	<category: 'asserting event types'>
	self isEndDocument 
	    ifFalse: [XPPStructureException signal: 'Expected end of document']
    ]

    mustBeEndTag [
	<category: 'asserting event types'>
	self isEndTag 
	    ifFalse: [XPPStructureException signal: 'Expected end tag']
    ]

    mustBeEndTag: tagName [
	<category: 'asserting event types'>
	(self isEndTag: tagName) 
	    ifFalse: [XPPStructureException signal: 'Expected end tag: ' , tagName]
    ]

    mustBeStartDocument [
	<category: 'asserting event types'>
	self isStartDocument 
	    ifFalse: [XPPStructureException signal: 'Expected start of document']
    ]

    mustBeStartTag [
	<category: 'asserting event types'>
	self isStartTag 
	    ifFalse: [XPPStructureException signal: 'Expected start tag']
    ]

    mustBeStartTag: tagName [
	<category: 'asserting event types'>
	(self isStartTag: tagName) 
	    ifFalse: [XPPStructureException signal: 'Expected start tag: ' , tagName]
    ]

    mustBeText [
	<category: 'asserting event types'>
	self isText ifFalse: [XPPStructureException signal: 'Expected text']
    ]

    serializeTagContentsTo: serializer [
	<category: 'serializing'>
	self consumeStartTag.
	self serializeUntilEndTagTo: serializer.
	self consumeEndTag
    ]

    serializeTagTo: serializer [
	<category: 'serializing'>
	self mustBeStartTag.
	self current serializeTo: serializer.
	self consumeStartTag.
	self serializeUntilEndTagTo: serializer.
	self current serializeTo: serializer.
	self consumeEndTag
    ]

    serializeUntilEndTagTo: serializer [
	<category: 'serializing'>
	[self isEndTag] whileFalse: 
		[| event |
		event := self current.
		event isText 
		    ifTrue: 
			[event serializeTo: serializer.
			self next]
		    ifFalse: 
			[event isStartTag 
			    ifTrue: [self serializeTagTo: serializer]
			    ifFalse: [XPPStructureException signal: 'Unexpected element']]]
    ]

    skip: tagName [
	<category: 'tag-based api'>
	self consumeStartTag: tagName.
	[self isEndTag] whileFalse: 
		[| event |
		event := self current.
		event isText 
		    ifTrue: [self next]
		    ifFalse: 
			[event isStartTag 
			    ifTrue: [self skipAny]
			    ifFalse: [XPPStructureException signal: 'Unexpected element']]].
	self consumeEndTag: tagName
    ]

    skipAny [
	<category: 'tag-based api'>
	self consumeStartTag.
	[self isEndTag] whileFalse: 
		[| event |
		event := self current.
		event isText 
		    ifTrue: [self next]
		    ifFalse: 
			[event isStartTag 
			    ifTrue: [self skipAny]
			    ifFalse: [XPPStructureException signal: 'Unexpected element']]].
	self consumeEndTag
    ]

    skipIf: tagName [
	<category: 'tag-based api'>
	(self is: tagName) ifTrue: [self skipAny]
    ]

    skipIfAny [
	<category: 'tag-based api'>
	self isStartTag ifTrue: [self skipAny]
    ]

    skipWhile: tagName [
	<category: 'tag-based api'>
	[self is: tagName] whileTrue: [self skipAny]
    ]

    skipWhileAny [
	<category: 'tag-based api'>
	[self isStartTag] whileTrue: [self skipAny]
    ]

    tag [
	<category: 'delegating accessors'>
	^self current tag
    ]

    text [
	<category: 'delegating accessors'>
	^self isText 
	    ifTrue: 
		[| text |
		text := self current text.
		self next.
		text]
	    ifFalse: ['']
    ]

    textIf: tagName [
	<category: 'tag-based api'>
	^self 
	    if: tagName
	    take: [self text]
	    else: ['']
    ]

    textIf: tagName else: aBlock [
	<category: 'tag-based api'>
	^self 
	    if: tagName
	    take: [self text]
	    else: [aBlock value]
    ]

    textIfAny [
	<category: 'tag-based api'>
	^self ifAnyTake: [self text] else: ['']
    ]

    textIfAnyElse: aBlock [
	<category: 'tag-based api'>
	^self ifAnyTake: [self text] else: [aBlock value]
    ]

    textOf: tagName [
	<category: 'tag-based api'>
	^self match: tagName take: [self text]
    ]

    textOfAny [
	<category: 'tag-based api'>
	^self matchAnyTake: [self text]
    ]

    while: tagName peek: aBlock [
	<category: 'tag-based api'>
	[self is: tagName] whileTrue: [self matchAnyPeek: aBlock]
    ]

    while: tagName peek: aBlock separatedBy: sepBlock [
	<category: 'tag-based api'>
	| doneFirst |
	doneFirst := false.
	[self is: tagName] whileTrue: 
		[doneFirst ifTrue: [sepBlock value] ifFalse: [doneFirst := true].
		self matchAnyPeek: aBlock]
    ]

    while: tagName take: aBlock [
	<category: 'tag-based api'>
	[self is: tagName] whileTrue: [self matchAnyTake: aBlock]
    ]

    while: tagName take: aBlock separatedBy: sepBlock [
	<category: 'tag-based api'>
	| doneFirst |
	doneFirst := false.
	[self is: tagName] whileTrue: 
		[| tag |
		tag := self current.
		self consumeStartTag.
		doneFirst ifTrue: [sepBlock value] ifFalse: [doneFirst := true].
		aBlock numArgs = 1 ifTrue: [aBlock value: tag] ifFalse: [aBlock value].
		self consumeEndTag]
    ]

    whileAnyPeek: aBlock [
	<category: 'tag-based api'>
	[self isStartTag] whileTrue: [self matchAnyPeek: aBlock]
    ]

    whileAnyPeek: aBlock separatedBy: sepBlock [
	<category: 'tag-based api'>
	| doneFirst |
	doneFirst := false.
	[self isStartTag] whileTrue: 
		[| tag |
		tag := self current.
		doneFirst ifTrue: [sepBlock value] ifFalse: [doneFirst := true].
		aBlock numArgs = 1 ifTrue: [aBlock value: tag] ifFalse: [aBlock value]]
    ]

    whileAnyTake: aBlock [
	<category: 'tag-based api'>
	[self isStartTag] whileTrue: [self matchAnyTake: aBlock]
    ]

    whileAnyTake: aBlock separatedBy: sepBlock [
	<category: 'tag-based api'>
	| doneFirst |
	doneFirst := false.
	[self isStartTag] whileTrue: 
		[| tag |
		tag := self current.
		self consumeStartTag.
		doneFirst ifTrue: [sepBlock value] ifFalse: [doneFirst := true].
		aBlock numArgs = 1 ifTrue: [aBlock value: tag] ifFalse: [aBlock value].
		self consumeEndTag]
    ]
]




XMLAbstractPullParser subclass: XMLPullParser [
    | stream current nestedStreams entities externalEntities parameterEntities parsingMarkup peekChar nameBuffer attributeBuffer eventQueue |
    
    <category: 'XMLPullParser'>
    <comment: 'This is based on Antony Blakey''s XMLPullParser.'>

    NameDelimiters := nil.
    DigitTable := nil.
    CharEscapes := nil.
    SeparatorTable := nil.
    LiteralChars := nil.

    XMLPullParser class >> initialize [
	"XMLPullParser initialize"

	<category: 'instance creation'>
	| nameDelimiters |
	CharEscapes := #($& $" $' $> $<) asSet.
	SeparatorTable := Array new: 256.
	SeparatorTable atAllPut: true.
	#(9 10 12 13 32) do: [:each | SeparatorTable at: each + 1 put: false].
	LiteralChars := Array new: 256.
	LiteralChars atAllPut: false.
	':-_.' do: [:each | LiteralChars at: each asciiValue put: true].
	1 to: 256
	    do: 
		[:i | 
		((Character value: i - 1) isDigit or: [(Character value: i - 1) isLetter]) 
		    ifTrue: [LiteralChars at: i put: true]].
	nameDelimiters := #(9 10 12 13 32 61 62 47).	"$= asInteger 61"	"$> asInteger"	"$/ asInteger"
	NameDelimiters := Array new: 256.
	NameDelimiters atAllPut: false.
	nameDelimiters do: [:each | NameDelimiters at: each put: true].
	DigitTable := Array new: 256.
	DigitTable atAllPut: -1.
	0 to: 15
	    do: [:each | DigitTable at: (Character digitValue: each) asciiValue put: each].
    ]

    XMLPullParser class >> isCharEscape: aChar [
	<category: 'accessing'>
	^CharEscapes includes: aChar
    ]

    XMLPullParser class >> on: source [
	<category: 'instance creation'>
	^self new initialize: source
    ]

    atEnd [
	<category: 'streaming'>
	nestedStreams == nil ifTrue: [^peekChar == nil and: [stream atEnd]].
	^stream atEnd 
	    ifTrue: 
		[self popNestingLevel.
		self atEnd]
	    ifFalse: [false]
    ]

    current [
	<category: 'core api'>
	^current
    ]

    entities [
	<category: 'entities'>
	entities ifNil: [entities := self initEntities].
	^entities
    ]

    entity: refName [
	<category: 'entities'>
	^self entities at: refName
	    ifAbsentPut: [self parseError: 'XML undefined entity ' , refName printString]
    ]

    fastStreamStringContents: writeStream [
	<category: 'private'>
	^writeStream contents
    ]


    initEntities [
	<category: 'entities'>
	| ents |
	ents := Dictionary new.
	ents
	    at: 'amp' put: $&;
	    at: 'quot' put: $";
	    at: 'apos' put: $';
	    at: 'gt' put: $>;
	    at: 'lt' put: $<.
	^ents
    ]

    initialize: source [
	<category: 'initialize-release'>
	parsingMarkup := false.
	attributeBuffer := WriteStream on: (String new: 128).
	nameBuffer := WriteStream on: (String new: 128).
	eventQueue := OrderedCollection new.
	stream := source readStream.
	current := XPPStartDocument new
    ]

    next [
	<category: 'core api'>
	eventQueue isEmpty ifFalse: [^current := eventQueue removeFirst].
	self nextWhitespace.
	self atEnd ifTrue: [^current := XPPEndDocument new].
	self peek = $< ifTrue: [self nextNode] ifFalse: [self nextPCData].
	^current := eventQueue isEmpty 
		    ifTrue: [self next]
		    ifFalse: [eventQueue removeFirst]
    ]

    nextAttributeInto: attributes namespaces: namespaces [
	<category: 'streaming'>
	| attrName attrValue |
	attrName := self nextName.
	self skipSeparators.
	self nextChar == $= ifFalse: [self errorExpected: '='].
	self skipSeparators.
	attrValue := self nextAttributeValue.
	(self usesNamespaces and: [attrName startsWith: 'xmlns']) 
	    ifTrue: 
		[attrName size > 6 
		    ifTrue: 
			[namespaces at: (attrName copyFrom: 7 to: attrName size) put: attrValue]
		    ifFalse: [namespaces at: attrName put: attrValue]]
	    ifFalse: [attributes at: attrName put: attrValue]
    ]

    nextAttributeValue [
	<category: 'streaming'>
	| delimiterChar attributeValueStream nextChar nextPeek referenceString entityValue |
	delimiterChar := self nextChar.
	(delimiterChar == $" or: [delimiterChar == $']) 
	    ifFalse: [self errorExpected: 'Attribute value delimiter expected.'].
	attributeValueStream := attributeBuffer reset.
	
	[nextPeek := nextChar := self nextChar.
	nextChar ifNil: [self errorExpected: 'Character expected.'].
	nextChar == $& 
	    ifTrue: 
		[self peek == $# 
		    ifTrue: 
			[nextPeek := nil.
			nextChar := self nextCharReference]
		    ifFalse: 
			[referenceString := self nextLiteral.
			self nextChar == $; ifFalse: [self errorExpected: ';'].
			entityValue := self entity: referenceString.
			(self class isCharEscape: entityValue) 
			    ifTrue: 
				[nextPeek := nil.
				nextChar := entityValue]
			    ifFalse: 
				[entityValue := entityValue asString.
				entityValue isEmpty 
				    ifTrue: [nextPeek := nextChar := nil]
				    ifFalse: 
					[self pushStream: (ReadStream on: entityValue asString).
					nextPeek := nextChar := self nextChar]]]].
	nextPeek == delimiterChar] 
		whileFalse: [nextChar ifNotNil: [attributeValueStream nextPut: nextChar]].
	^self fastStreamStringContents: attributeValueStream
    ]

    nextCDataContent [
	"Skip $["

	<category: 'tokenizing'>
	| cdata |
	self nextChar.
	cdata := self nextUpToAll: ']]>'.
	eventQueue addLast: (XPPText new text: cdata)
    ]

    nextCDataOrConditional [
	<category: 'tokenizing'>
	"Skip ["

	| nextChar conditionalKeyword |
	self nextChar.
	self skipSeparators.
	nextChar := self peek.
	nextChar == $% 
	    ifTrue: 
		[self checkAndExpandReference: (self parsingMarkup 
			    ifTrue: [#dtd]
			    ifFalse: [#content]).
		conditionalKeyword := self nextLiteral.
		self skipSeparators.
		^self nextChar == $[ 
		    ifTrue: 
			[self skipSeparators.
			self nextIncludeSection: (self conditionalInclude: conditionalKeyword)]
		    ifFalse: [self errorExpected: '[']].
	nextChar == $C 
	    ifTrue: 
		[^self nextLiteral = 'CDATA' 
		    ifTrue: 
			[self peek == $[ 
			    ifTrue: [self nextCDataContent]
			    ifFalse: [self errorExpected: '[']]
		    ifFalse: [self errorExpected: 'CData']].
	self errorExpected: 'CData or declaration'
    ]

    nextChar [
	"Return the next character from the current input stream. If the current stream is at end pop to next nesting level if there is one.
	 Due to the potential nesting of original document, included documents and replacment texts the streams are held in a stack representing the nested streams. The current stream is the top one."

	<category: 'streaming'>
	| nextChar |
	peekChar ifNil: 
		[nestedStreams ifNotNil: [self checkNestedStream].
		^nextChar := stream next]
	    ifNotNil: 
		[nextChar := peekChar.
		peekChar := nil.
		^nextChar]
    ]

    nextCharReference [
	<category: 'tokenizing'>
	| base charValue |
	self nextChar == $# ifFalse: [self errorExpected: 'character reference'].
	base := self peek == $x 
		    ifTrue: 
			[self nextChar.
			16]
		    ifFalse: [10].
	charValue := [self readNumberBase: base] on: Error
		    do: [:ex | self errorExpected: 'Number.'].
	self nextChar == $; ifFalse: [self errorExpected: '";"'].
	^Character value: charValue
    ]

    nextComment [
	"Skip first -"

	<category: 'tokenizing'>
	self nextChar.
	self nextChar == $- ifFalse: [self errorExpected: 'second comment $-'].
	self nextUpToAll: '-->'
    ]

    nextEndTag [
	<category: 'tokenizing'>
	"Skip /"

	| string |
	self nextChar.
	string := self nextTrimmedBlanksUpTo: $>.
	eventQueue addLast: (XPPEndTag new tag: (NodeTag new type: string))
    ]

    nextLiteral [
	<category: 'tokenizing'>
	| resultStream nextChar resultString |
	resultStream := (String new: 10) writeStream.
	((nextChar := self peek) isLetter or: [nextChar == $_]) 
	    ifFalse: [self errorExpected: 'Name literal.'].
	
	[nextChar := self peek.
	(LiteralChars at: nextChar asciiValue + 1) 
	    ifTrue: 
		[nextChar == $& 
		    ifTrue: 
			[nextChar := self nextChar.
			resultStream nextPut: (self peek == $# 
				    ifTrue: [self nextCharReference]
				    ifFalse: [^resultStream contents])]
		    ifFalse: [resultStream nextPut: self nextChar]]
	    ifFalse: 
		[resultString := resultStream contents.
		resultString isEmpty 
		    ifTrue: [self errorExpected: 'Name literal']
		    ifFalse: [^resultString]]] 
		repeat
    ]

    nextName [
	<category: 'tokenizing'>
	| nextChar |
	nameBuffer reset.
	self peek == $. ifTrue: [self malformedError: 'Character expected.'].
	
	[(nextChar := self peek) ifNil: [self errorExpected: 'Character expected.'].
	NameDelimiters at: nextChar asciiValue] 
		whileFalse: [nameBuffer nextPut: self nextChar].
	^self fastStreamStringContents: nameBuffer
    ]

    nextNode [
	<category: 'tokenizing'>
	"Skip <"

	| nextChar |
	self nextChar.
	nextChar := self peek.
	nextChar == $! 
	    ifTrue: 
		["Skip !!"

		self nextChar.
		nextChar := self peek.
		nextChar == $- ifTrue: [^self nextComment].
		nextChar == $[ ifTrue: [^self nextCDataOrConditional].
		^self parsingMarkup 
		    ifTrue: [self nextMarkupDeclaration]
		    ifFalse: [self nextDocType]].
	nextChar == $? ifTrue: [^self nextPI].
	^self nextTag
    ]

    nextPCData [
	<category: 'tokenizing'>
	| resultStream nextPeek nextChar referenceString entityValue |
	resultStream := (String new: 10) writeStream.
	
	[nextPeek := nextChar := self peek.
	nextChar ifNil: [self errorExpected: 'Character expected.'].
	nextChar == $& 
	    ifTrue: 
		[self nextChar.
		self peek == $# 
		    ifTrue: 
			[nextPeek := nil.
			nextChar := self nextCharReference]
		    ifFalse: 
			[referenceString := self nextLiteral.
			self nextChar == $; ifFalse: [self errorExpected: ';'].
			entityValue := self entity: referenceString.
			(self class isCharEscape: entityValue) 
			    ifTrue: 
				[nextPeek := nil.
				nextChar := entityValue]
			    ifFalse: 
				[entityValue := entityValue asString.
				entityValue isEmpty 
				    ifTrue: [nextPeek := nextChar := nil]
				    ifFalse: 
					[self pushStream: (ReadStream on: entityValue asString).
					nextPeek := nextChar := self peek]]]]
	    ifFalse: [nextPeek == $< ifFalse: [self nextChar]].
	nextPeek == $<] 
		whileFalse: [nextChar ifNotNil: [resultStream nextPut: nextChar]].
	eventQueue addLast: (XPPText new text: resultStream contents)
    ]

    nextPI [
	<category: 'tokenizing'>
	"Skip ?"

	| piTarget piData |
	self nextChar.
	piTarget := self nextLiteral.
	piTarget asUppercase = 'XML' ifTrue: [^self nextXMLDecl].
	self skipSeparators.
	piData := self nextUpToAll: '?>'
	"self handlePI: piTarget data: piData"
    ]

    nextTag [
	<category: 'tokenizing'>
	| tagName attributes nextChar namespaces |
	self peek = $/ ifTrue: [^self nextEndTag].
	tagName := self nextName.
	self skipSeparators.
	attributes := Dictionary new: 33.
	namespaces := Dictionary new: 5.
	[(nextChar := self peek) == $> or: [nextChar == $/]] whileFalse: 
		[self nextAttributeInto: attributes namespaces: namespaces.
		self skipSeparators].
	eventQueue addLast: ((XPPStartTag new)
		    tag: (NodeTag new type: tagName);
		    attributes: attributes).
	self nextChar == $/ 
	    ifTrue: 
		[eventQueue addLast: (XPPEndTag new tag: (NodeTag new type: tagName)).
		self nextChar]
    ]

    nextTrimmedBlanksUpTo: delimiter [
	<category: 'streaming'>
	| resultStream nextChar |
	resultStream := WriteStream on: (String new: 10).
	nextChar := nil.
	[(nextChar := self nextChar) == delimiter] 
	    whileFalse: [nextChar == $  ifFalse: [resultStream nextPut: nextChar]].
	nextChar == delimiter 
	    ifFalse: 
		[self parseError: 'XML no delimiting ' , delimiter printString , ' found'].
	^resultStream contents
    ]

    nextUpToAll: delimitingString [
	<category: 'streaming'>
	| string |
	self unpeek.
	string := stream upToAll: delimitingString.
	stream skip: delimitingString size negated.
	(stream next: delimitingString size) = delimitingString 
	    ifFalse: 
		[self 
		    parseError: 'XML no delimiting ' , delimitingString printString , ' found'].
	^string
    ]

    nextWhitespace [
	<category: 'tokenizing'>
	| nextChar |
	
	[(nextChar := self peek) == nil 
	    or: [SeparatorTable at: nextChar asciiValue + 1 ifAbsent: [true]]] 
		whileFalse: [self nextChar].
	(nestedStreams == nil or: [self atEnd not]) 
	    ifFalse: 
		[self checkNestedStream.
		self nextWhitespace]
    ]

    nextXMLDecl [
	<category: 'tokenizing'>
	| attributes nextChar namespaces |
	self skipSeparators.
	attributes := Dictionary new.
	namespaces := Dictionary new.
	[(nextChar := self peek) == $?] whileFalse: 
		[self nextAttributeInto: attributes namespaces: namespaces.
		self skipSeparators].
	self nextChar.
	self nextChar == $> ifFalse: [self errorExpected: '> expected.'].
	(attributes includesKey: 'encoding') 
	    ifTrue: [self streamEncoding: (attributes at: 'encoding')]
	"self handleXMLDecl: attributes namespaces: namespaces"
    ]

    parsingMarkup [
	<category: 'private'>
	^parsingMarkup
    ]

    peek [
	"Return the next character from the current input stream. If the current stream poop to next nesting level if there is one.
	 Due to the potential nesting of original document, included documents and replacment texts the streams are held in a stack representing the nested streams. The current stream is the top one."

	<category: 'streaming'>
	peekChar ifNil: 
		[nestedStreams ifNotNil: [self checkNestedStream].
		^peekChar := stream atEnd ifTrue: [nil] ifFalse: [stream next]]
	    ifNotNil: [^peekChar]
    ]

    readNumberBase: base [
	"Read a hex number from stream until encountering $;"

	<category: 'private'>
	| value digit |
	base = 10 
	    ifFalse: 
		[| numberString |
		numberString := self nextUpTo: $;.
		self stream skip: -1.
		^Integer readFrom: numberString asUppercase readStream base: base].
	value := 0.
	digit := DigitTable at: self peek asciiValue.
	digit < 0 ifTrue: [self error: 'At least one digit expected here'].
	self nextChar.
	value := digit.
	
	[digit := DigitTable at: self peek asciiValue.
	digit < 0 
	    ifTrue: [^value]
	    ifFalse: 
		[self nextChar.
		value := value * base + digit]] 
		repeat.
	^value
    ]

    skipSeparators [
	<category: 'streaming'>
	| nextChar |
	
	[(nextChar := self peek) == nil 
	    or: [SeparatorTable at: nextChar asciiValue + 1]] 
		whileFalse: [self nextChar].
	(nestedStreams == nil or: [self atEnd not]) 
	    ifFalse: 
		[self checkNestedStream.
		self skipSeparators]
    ]

    skipUpTo: delimiter [
	<category: 'tokenizing'>
	| nextChar |
	self unpeek.
	[self atEnd or: [(nextChar := self nextChar) == delimiter]] whileFalse: [].
	nextChar == delimiter 
	    ifFalse: 
		[self parseError: 'XML no delimiting ' , delimiter printString , ' found']
    ]

    streamEncoding: encodingString [
	<category: 'streaming'>
	| converterClass |
	Smalltalk at: #TextConverter
	    ifPresent: 
		[:tc | 
		(stream respondsTo: #converter:) 
		    ifTrue: 
			[converterClass := tc 
				    defaultConverterClassForEncoding: encodingString asLowercase.
			converterClass ifNotNil: [stream converter: converterClass new]]]
    ]

    unpeek [
	<category: 'streaming'>
	peekChar ifNotNil: 
		[stream pushBack: (String with: peekChar).
		peekChar := nil]
    ]

    usesNamespaces [
	<category: 'private'>
	^true
    ]
]



NodeTag extend [
    type: typeStr [
	<category: 'initialize'>
	namespace := ''.
	type := typeStr.
	qualifier := ''
    ]
]


Eval [
    XMLPullParser initialize
]
