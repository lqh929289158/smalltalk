"======================================================================
|
|   CairoContext wrapper class for libcairo
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Tony Garnock-Jones
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: CairoSurface [
    | surface |

    rawSurface [ ^surface ]

    update: aspect [
	aspect == #returnFromSnapshot ifTrue: [
	    ^ self rebuildSurface].
    ]

    buildSurface [
	self subclassResponsibility.
    ]

    rebuildSurface [
	surface := self buildSurface.
	self addToBeFinalized.
	self changed: #returnFromSnapshot.
    ]

    finalize [
	surface ifNil: [ ^self ].
	Cairo surfaceDestroy: surface.
	surface := nil.
    ]

    context [
	^CairoContext on: self
    ]
].

CairoSurface subclass: CairoPngSurface [
    | filename |

    filename [ filename ]

    filename: aString [
	self finalize.
	filename := aString.
	self rebuildSurface.
    ]

    buildSurface [
	^ Cairo imageSurfaceCreateFromPng: filename.
    ]
].

BlockClosure extend [
    maskOn: context [
	| pattern |
	[
	    Cairo.Cairo pushGroup: context.
	    self ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo mask: context pattern: pattern
	] ensure: [
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]

    on: context withSourceDo: paintBlock [
	| pattern source |
	source := Cairo.Cairo getSource: context.
	Cairo.Cairo patternReference: source.
	[
	    Cairo.Cairo pushGroup: context.
	    self ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo setSource: context source: pattern.
	    paintBlock value
	] ensure: [
	    source isNil ifFalse: [
		Cairo.Cairo
		    setSource: context source: source;
		    patternDestroy: source ].
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]

    setSourceOn: context [
	| pattern |
	[
	    Cairo.Cairo pushGroup: context.
	    self ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo setSource: context source: pattern.
	] ensure: [
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]
]

Object subclass: CairoPattern [
    | pattern canonical |

    Patterns := nil.
    CairoPattern class >> initialize [
	Patterns := WeakKeyDictionary new.
	ObjectMemory addDependent: self.
    ]

    CairoPattern class >> update: aspect [
	"Clear our cache."
	aspect == #returnFromSnapshot ifTrue: [
	    Patterns do: [ :each | each finalize ]].
    ]

    pattern [ ^pattern ]

    cachedPattern [
	[canonical isNil] whileTrue: [
	    Patterns
		at: self
		ifAbsentPut: [
		    self addToBeFinalized.
		    pattern := self createCachedPattern.
		    canonical := self ].
	    "Keep the canonical object alive so we don't need to
	     reference count its pattern.  The #at:ifAbsent: call
	     makes the code resistant to finalization races."
	    canonical := pattern isNil
	        ifTrue: [Patterns at: self ifAbsent: [nil]]
		ifFalse: [self]].

	^canonical pattern
    ]

    createCachedPattern [
	self subclassResponsibility.
    ]

    postCopy [
	"Reference the same canonical object, but not the pattern."
	pattern := nil.
    ]

    finalize [
	pattern ifNotNil: [ :p | Cairo patternDestroy: p ].
	pattern := nil.
    ]

    maskOn: context [
	Cairo.Cairo mask: context pattern: self cachedPattern
    ]

    setSourceOn: context [
	Cairo setSource: context source: self cachedPattern
    ]

    on: context withSourceDo: paintBlock [
	| pattern source |
	source := Cairo getSource: context.
	Cairo patternReference: source.
	[
	    self setSourceOn: context.
	    paintBlock value
	] ensure: [
	    source isNil ifFalse: [
		Cairo
		    setSource: context source: source;
		    patternDestroy: source ].
	].
    ]
].

CairoPattern subclass: CairoPatternDecorator [
    | wrappedPattern |
    CairoPatternDecorator class >> on: aPattern [
	^self new wrappedPattern: aPattern; yourself
    ]

    = anObject [
	^self class == anObject class and: [
	    self wrappedPattern = anObject wrappedPattern ]
    ]

    hash [
	^self class hash bitXor: self wrappedPattern hash
    ]

    wrappedPattern [ ^wrappedPattern ]
    wrappedPattern: aPattern [ wrappedPattern := aPattern ]
]

CairoPatternDecorator subclass: ReflectedPattern [
    createCachedPattern [
	| result |
	result := self wrappedPattern createCachedPattern.
	Cairo patternSetExtend: result extend: Cairo extendReflect.
	^result
    ]
]

CairoPatternDecorator subclass: RepeatedPattern [
    createCachedPattern [
	| result |
	result := self wrappedPattern createCachedPattern.
	Cairo patternSetExtend: result extend: Cairo extendRepeat.
	^result
    ]
]

CairoPatternDecorator subclass: PaddedPattern [
    createCachedPattern [
	| result |
	result := self wrappedPattern createCachedPattern.
	Cairo patternSetExtend: result extend: Cairo extendPad.
	^result
    ]
]

CairoPattern subclass: SurfacePattern [
    | surface |

    surface [ ^ surface ]
    surface: aCairoSurface [ surface := aCairoSurface ]

    = anObject [
	^self class == anObject class and: [
	    self surface = anObject surface ]
    ]

    hash [
	^self class hash bitXor: self surface hash
    ]

    createCachedPattern [
	^ Cairo patternCreateForSurface: surface rawSurface
    ]
].

CairoPattern subclass: GradientPattern [
    | colorStops |

    GradientPattern class >> new [
	^super new initialize
    ]

    colorStops [
	^colorStops
    ]

    initialize [
	colorStops := OrderedCollection new.
    ]

    = anObject [
	^self class == anObject class and: [
	    self colorStops = anObject colorStops ]
    ]

    hash [
	^self class hash bitXor: self colorStops hash
    ]

    addStopAt: aNumber color: aColor [
	colorStops add: aNumber -> aColor.
    ]

    addStopAt: aNumber red: r green: g blue: b alpha: a [
	colorStops add: aNumber -> (Color r: r g: g blue: b a: a).
    ]

    initializeCachedPattern: p [
	| c |
	colorStops do: [ :stop |
	    c := stop value.
	    Cairo patternAddColorStopRgba: p
		  offset: stop key asCNumber
		  red: c red asCNumber
		  green: c green asCNumber
		  blue: c blue asCNumber
		  alpha: c alpha asCNumber ].
    ]
].

GradientPattern subclass: LinearGradient [
    | point0 point1 |

    LinearGradient class >> from: point0 to: point1 [
	^ self new
	    from: point0 to: point1;
	    yourself
    ]

    from [
	^point0
    ]

    to [
	^point1
    ]

    from: aPoint0 to: aPoint1 [
	point0 := aPoint0.
	point1 := aPoint1.
    ]

    = anObject [
	^super = anObject and: [
	    point0 = anObject from and: [
	    point1 = anObject to ]]
    ]

    hash [
	^(super hash bitXor: point0 hash) bitXor: point1 hash
    ]

    createCachedPattern [
	| p c |
	p := Cairo patternCreateLinear: point0 x asCNumber
		   y0: point0 y asCNumber
		   x1: point1 x asCNumber
		   y1: point1 y asCNumber.
	self initializeCachedPattern: p.
	^ p
    ]
].

GradientPattern subclass: RadialGradient [
    | point0 r0 point1 r1 |

    RadialGradient class >> from: point0 radius: r0 to: point1 radius: r1 [
	^ self new
	    from: point0 radius: r0 to: point1 radius: r1;
	    yourself
    ]

    from [
	^point0
    ]

    fromRadius [
	^r0
    ]

    to [
	^point1
    ]

    toRadius [
	^r1
    ]

    from: aPoint0 radius: aR0 to: aPoint1 radius: aR1 [
	point0 := aPoint0.
	r0 := aR0.
	point1 := aPoint1.
	r1 := aR1.
    ]

    = anObject [
	^super = anObject and: [
	    point0 = anObject from and: [
	    r0 = anObject fromRadius and: [
	    point0 = anObject to and: [
	    r1 = anObject toRadius ]]]]
    ]

    hash [
	^(((super hash bitXor: point0 hash) bitXor: point1 hash)
	     bitXor: r0 hash) bitXor: r1 hash
    ]

    createCachedPattern [
	| p c |
	p := Cairo patternCreateRadial: point0 x asCNumber
		   cy0: point0 y asCNumber
		   radius0: r0 asCNumber
		   cx1: point1 x asCNumber
		   cy1: point1 y asCNumber
		   radius1: r1 asCNumber.
	self initializeCachedPattern: p.
	^ p
    ]
].

CairoPattern subclass: Color [
    | red green blue alpha |

    Color >> new [
	^self new r: 0 g: 0 b: 0 a: 1.
    ]

    Color class >> r: r g: g b: b [
	^ self basicNew r: r g: g b: b a: 1.0.
    ]

    Color class >> r: r g: g b: b a: a [
	^ self basicNew r: r g: g b: b a: a.
    ]

    Color class >> black [^ self r: 0 g: 0 b: 0.]
    Color class >> white [^ self r: 1 g: 1 b: 1.]
    Color class >> red [^ self r: 1 g: 0 b: 0.]
    Color class >> green [^ self r: 0 g: 1 b: 0.]
    Color class >> blue [^ self r: 0 g: 0 b: 1.]
    Color class >> cyan [^ self r: 0 g: 1 b: 1.]
    Color class >> magenta [^ self r: 1 g: 0 b: 1.]
    Color class >> yellow [^ self r: 1 g: 1 b: 0.]

    = anObject [
	^self class == anObject class and: [
	    red = anObject red and: [
	    green = anObject green and: [
	    blue = anObject blue and: [
	    alpha = anObject alpha]]]]
    ]

    hash [
	^(red * 255) truncated +
	 ((green * 255) truncated * 256) +
	 ((blue * 255) truncated * 65536) +
	 ((alpha * 63) truncated * 16777216)
    ]
	 
    red [ ^red ]
    green [ ^green ]
    blue [ ^blue ]
    alpha [ ^alpha ]

    r: r g: g b: b a: a [
	red := r.
	green := g.
	blue := b.
	alpha := a.
    ]

    withRed: aNumber [ ^ Color r: aNumber g: green b: blue a: alpha ]
    withGreen: aNumber [ ^ Color r: red g: aNumber b: blue a: alpha ]
    withBlue: aNumber [ ^ Color r: red g: green b: aNumber a: alpha ]
    withAlpha: aNumber [ ^ Color r: red g: green b: blue a: aNumber ]

    mix: aColor ratio: aScale [
	^Color r: ((red * aScale) + (aColor red * (1 - aScale)))
		g: ((green * aScale) + (aColor green * (1 - aScale)))
		b: ((blue * aScale) + (aColor blue * (1 - aScale)))
		a: ((alpha * aScale) + (aColor alpha * (1 - aScale)))
    ]

    * aScale [
	aScale isNumber ifTrue: [
	    ^ Color r: ((red * aScale) min: 1)
		    g: ((green * aScale) min: 1)
		    b: ((blue * aScale) min: 1)
		    a: alpha ].
	^ Color r: red * aScale red
		g: green * aScale green
		b: blue * aScale blue
		a: alpha * aScale alpha
    ]

    createCachedPattern [
	"Should never be reached."
	self halt.
	^ Cairo patternCreateRgba: red asCNumber
		green: green asCNumber
		blue: blue asCNumber
		alpha: alpha asCNumber.
    ]

    printOn: st [
	st << 'Color r: ' << red << ' g: ' << green << ' b: ' << blue << ' a: ' << alpha.
    ]

    storeOn: st [
	st << $(.
	self printOn: st.
	st << $)
    ]

    setSourceOn: context [
	Cairo
	    setSourceRgba: context
	    red: red asCNumber
	    green: green asCNumber
	    blue: blue asCNumber
	    alpha: alpha asCNumber.
    ]
].

Object subclass: TextExtents [
    | bearing extent advance |

    bearing [ ^bearing ]
    extent [ ^extent ]
    advance [ ^advance ]

    TextExtents class >> from: aCairoTextExtents [
	^ self new initializeFrom: aCairoTextExtents
    ]

    initializeFrom: aCairoTextExtents [
	bearing := aCairoTextExtents xBearing value @ aCairoTextExtents yBearing value.
	extent := aCairoTextExtents width value @ aCairoTextExtents height value.
	advance := aCairoTextExtents xAdvance value @ aCairoTextExtents yAdvance value.
    ]
].

Object subclass: CairoContext [
    | surface context depth |

    CairoContext class >> on: aCairoSurface [
	^ self new initialize: aCairoSurface
    ]

    initialize: aCairoSurface [
	surface := aCairoSurface.
	depth := 0.
	surface addDependent: self.
	self update: #returnFromSnapshot.
    ]

    update: aspect [
	aspect == #returnFromSnapshot ifTrue: [
	    context := Cairo create: surface rawSurface.
	    self addToBeFinalized.
	    ^self].
    ]

    finalize [
	context ifNil: [ ^self ].
	Cairo destroy: context.
	context := nil.
	surface removeDependent: self.
	surface := nil.
    ]

    saveWhile: aBlock [
	Cairo save: context.
	^ aBlock ensure: [ Cairo restore: context ].
    ]

    withSource: aPatternOrBlock do: paintBlock [
	aPatternOrBlock on: context withSourceDo: paintBlock
    ]

    source: aPatternOrBlock [
	aPatternOrBlock setSourceOn: context
    ]

    sourceRed: r green: g blue: b [
	Cairo setSourceRgb: context red: r asCNumber green: g asCNumber blue: b asCNumber.
    ]

    sourceRed: r green: g blue: b alpha: a [
	Cairo setSourceRgba: context red: r asCNumber green: g asCNumber blue: b asCNumber alpha: a asCNumber.
    ]

    closePath [
	Cairo closePath: context.
    ]

    withClosedPath: aBlock do: opsBlock [
	self withPath: [ aBlock value. self closePath ] do: opsBlock
    ]

    addClosedSubPath: aBlock [
	self newSubPath.
	aBlock value.
	self closePath
    ]

    addSubPath: aBlock [
	self newSubPath.
	aBlock value
    ]

    withPath: aBlock do: opsBlock [
	"Cannot yet save a path and go back to it later."
	depth >= 1 ifTrue: [ self notYetImplemented ].
	depth := depth + 1.
	[aBlock value. opsBlock value] ensure: [
	    depth := depth - 1. self newPath]
    ]

    newSubPath [
	Cairo newSubPath: context.
    ]

    newPath [
	Cairo newPath: context.
    ]

    moveTo: aPoint [
	Cairo moveTo: context x: aPoint x asCNumber y: aPoint y asCNumber.
    ]

    relMoveTo: aPoint [
	Cairo relMoveTo: context dx: aPoint x asCNumber dy: aPoint y asCNumber.
    ]

    lineTo: aPoint [
	Cairo lineTo: context x: aPoint x asCNumber y: aPoint y asCNumber.
    ]

    relLineTo: aPoint [
	Cairo relLineTo: context dx: aPoint x asCNumber dy: aPoint y asCNumber.
    ]

    curveTo: aPoint3 via: aPoint1 via: aPoint2 [
	Cairo curveTo: context
	      x1: aPoint1 x asCNumber y1: aPoint1 y asCNumber
	      x2: aPoint2 x asCNumber y2: aPoint2 y asCNumber
	      x3: aPoint3 x asCNumber y3: aPoint3 y asCNumber.
    ]

    curveVia: aPoint1 via: aPoint2 to: aPoint3 [
	Cairo curveTo: context
	      x1: aPoint1 x asCNumber y1: aPoint1 y asCNumber
	      x2: aPoint2 x asCNumber y2: aPoint2 y asCNumber
	      x3: aPoint3 x asCNumber y3: aPoint3 y asCNumber.
    ]

    arc: aPoint radius: r from: angle1 to: angle2 [
	Cairo arc: context
	      xc: aPoint x asCNumber yc: aPoint y asCNumber
	      radius: r asCNumber
	      angle1: angle1 asCNumber angle2: angle2 asCNumber.
    ]

    arcNegative: aPoint radius: r from: angle1 to: angle2 [
	Cairo arcNegative: context
	      xc: aPoint x asCNumber yc: aPoint y asCNumber
	      radius: r asCNumber
	      angle1: angle1 asCNumber angle2: angle2 asCNumber.
    ]

    rectangle: aRect [
	Cairo rectangle: context
	      x: aRect left asCNumber y: aRect top asCNumber
	      width: aRect width asCNumber height: aRect height asCNumber.
    ]

    roundedRectangle: b radius: cornerRadius [
	| hr vr h2 v2 |
	hr := cornerRadius@0.
	vr := 0@cornerRadius.
	h2 := hr * (1 - 0.55228475).
	v2 := vr * (1 - 0.55228475).
	self
	    moveTo: b topLeft + hr;
	    lineTo: b topRight - hr;
	    curveTo: b topRight + vr via: b topRight - h2 via: b topRight + v2;
	    lineTo: b bottomRight - vr;
	    curveTo: b bottomRight - hr via: b bottomRight - v2 via: b bottomRight - h2;
	    lineTo: b bottomLeft + hr;
	    curveTo: b bottomLeft - vr via: b bottomLeft + h2 via: b bottomLeft - v2;
	    lineTo: b topLeft + vr;
	    curveTo: b topLeft + hr via: b topLeft + v2 via: b topLeft + h2.
    ]

    groupWhile: aBlock [
	| pattern |
	[
	    Cairo.Cairo pushGroup: context.
	    aBlock ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo setSource: context source: pattern.
	] ensure: [
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]

    clipPreserve [
	Cairo clipPreserve: context
    ]

    clip [
	depth > 0
	    ifTrue: [Cairo clipPreserve: context]
	    ifFalse: [Cairo clip: context]
    ]

    clip: aBlock [
	self withPath: aBlock do: [ self clip ]
    ]

    resetClip [
        Cairo resetClip: context.
    ]

    mask: aPatternOrBlock [
        aPatternOrBlock maskOn: context
    ]

    paint [
        Cairo paint: context.
    ]

    paintWith: aPatternOrBlock [
	self withSource: aPatternOrBlock do: [ self paint ]
    ]

    paintWithAlpha: a [
        Cairo paintWithAlpha: context alpha: a asCNumber.
    ]

    paint: aPatternOrBlock withAlpha: a [
	self withSource: aPatternOrBlock do: [ self paintWithAlpha: a ]
    ]

    fillPreserve [
	Cairo fillPreserve: context
    ]

    fill [
	depth > 0
	    ifTrue: [Cairo fillPreserve: context]
	    ifFalse: [Cairo fill: context]
    ]

    fill: aBlock [
	self withPath: aBlock do: [ self fill ]
    ]

    fill: pathBlock with: aPatternOrBlock [
	self withSource: aPatternOrBlock do: [ self fill: pathBlock ]
    ]

    fillWith: aPatternOrBlock [
	self withSource: aPatternOrBlock do: [ self fill ]
    ]

    strokePreserve [
	Cairo strokePreserve: context
    ]

    stroke [
	depth > 0
	    ifTrue: [Cairo strokePreserve: context]
	    ifFalse: [Cairo stroke: context]
    ]

    stroke: aBlock [
	self withPath: aBlock do: [ self stroke ]
    ]

    stroke: pathBlock with: aPatternOrBlock [
	self withSource: aPatternOrBlock do: [ self stroke: pathBlock ]
    ]

    strokeWith: aPatternOrBlock [
	self withSource: aPatternOrBlock do: [ self stroke ]
    ]

    identityMatrix [
        Cairo identityMatrix: context.
    ]

    translateBy: aPoint [
	Cairo translate: context tx: aPoint x asCNumber ty: aPoint y asCNumber.
    ]

    scaleBy: aPoint [
	| p |
	p := aPoint asPoint.
        Cairo scale: context sx: p x asCNumber sy: p y asCNumber.
    ]

    rotateBy: rads [
        Cairo rotate: context angle: rads asCNumber.
    ]

    nullTransform [
    ]

    transformBy: aTransform [
        Cairo transform: context matrix: aTransform toLocal.
    ]

    CairoContext class >> lookupLineCapValue: anInteger [
	anInteger == Cairo lineCapSquare ifTrue: [ ^#square ].
	anInteger == Cairo lineCapRound ifTrue: [ ^#round ].
	anInteger == Cairo lineCapButt ifTrue: [ ^#butt ].
	self error: 'Unsupported line cap value ', anInteger
    ]

    CairoContext class >> lookupLineJoinValue: anInteger [
	anInteger == Cairo lineJoinBevel ifTrue: [ ^#bevel ].
	anInteger == Cairo lineJoinRound ifTrue: [ ^#round ].
	anInteger == Cairo lineJoinMiter ifTrue: [ ^#miter ].
	self error: 'Unsupported line join value ', anInteger
    ]

    CairoContext class >> lookupFillRuleValue: anInteger [
	anInteger == Cairo fillRuleEvenOdd ifTrue: [ ^#evenOdd ].
	anInteger == Cairo fillRuleWinding ifTrue: [ ^#winding ].
	self error: 'Unsupported fill rule value ', anInteger
    ]

    CairoContext class >> lookupSlantValue: anInteger [
	anInteger == Cairo fontSlantNormal ifTrue: [ ^#normal ].
	anInteger == Cairo fontSlantItalic ifTrue: [ ^#italic ].
	anInteger == Cairo fontSlantOblique ifTrue: [ ^#oblique ].
	self error: 'Unsupported slant value ', anInteger
    ]

    CairoContext class >> lookupLineCap: aSymbol [
	aSymbol == #square ifTrue: [ ^Cairo lineCapSquare ].
	aSymbol == #round ifTrue: [ ^Cairo lineCapRound ].
	aSymbol == #butt ifTrue: [ ^Cairo lineCapButt ].
	self error: 'Unsupported line cap symbol ', aSymbol
    ]

    CairoContext class >> lookupLineJoin: aSymbol [
	aSymbol == #bevel ifTrue: [ ^Cairo lineJoinBevel ].
	aSymbol == #round ifTrue: [ ^Cairo lineJoinRound ].
	aSymbol == #miter ifTrue: [ ^Cairo lineJoinMiter ].
	self error: 'Unsupported line join symbol ', aSymbol
    ]

    CairoContext class >> lookupFillRule: aSymbol [
	aSymbol == #evenOdd ifTrue: [ ^Cairo fillRuleEvenOdd ].
	aSymbol == #winding ifTrue: [ ^Cairo fillRuleWinding ].
	self error: 'Unsupported fill rule symbol ', aSymbol
    ]

    CairoContext class >> lookupSlant: aSymbol [
	aSymbol == #normal ifTrue: [ ^Cairo fontSlantNormal ].
	aSymbol == #italic ifTrue: [ ^Cairo fontSlantItalic ].
	aSymbol == #oblique ifTrue: [ ^Cairo fontSlantOblique ].
	self error: 'Unsupported slant symbol ', aSymbol
    ]

    CairoContext class >> lookupWeight: aSymbol [
	aSymbol == #normal ifTrue: [ ^Cairo fontWeightNormal ].
	aSymbol == #bold ifTrue: [ ^Cairo fontWeightBold ].
	self error: 'Unsupported weight symbol ', aSymbol
    ]

    selectFontFamily: aString slant: slantSymbol weight: weightSymbol [
	Cairo selectFontFace: context
	      family: aString
	      slant: (self class lookupSlant: slantSymbol)
	      weight: (self class lookupWeight: weightSymbol).
    ]

    lineWidth [
	^Cairo getLineWidth: context.
    ]

    lineCap [
	^self class lookupLineCapValue: (Cairo getLineCap: context).
    ]

    fillRule [
	^self class lookupFillRuleValue: (Cairo getFillRule: context).
    ]

    lineJoin [
	^self class lookupLineJoinValue: (Cairo getLineJoin: context).
    ]

    miterLimit [
	^Cairo getMiterLimit: context.
    ]

    lineWidth: w [
	Cairo setLineWidth: context width: w asCNumber.
    ]

    lineCap: aNumber [
	Cairo setLineCap: context lineCap: (self class lookupLineCap: aNumber).
    ]

    fillRule: aNumber [
	Cairo setFillRule: context fillRule: (self class lookupFillRule: aNumber).
    ]

    lineJoin: aNumber [
	Cairo setLineJoin: context lineJoin: (self class lookupLineJoin: aNumber).
    ]

    miterLimit: aNumber [
	Cairo setMiterLimit: context miterLimit: aNumber asCNumber.
    ]

    fontSize: aNumber [
	Cairo setFontSize: context size: aNumber.
    ]

    showText: aString [
	Cairo showText: context utf8: aString.
    ]

    textPath: aString [
	Cairo textPath: context utf8: aString.
    ]

    textExtents: aString [
	| ext |
	ext := CairoTextExtents new.
	[
	    Cairo textExtents: context utf8: aString extents: ext.
	    ^ TextExtents from: ext
	] ensure: [ ext free ]
    ]
].

CStruct subclass: #CairoTextExtents
    declaration: #(
        (#xBearing #double)
        (#yBearing #double)
        (#width #double)
        (#height #double)
        (#xAdvance #double)
        (#yAdvance #double))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'CairoTextExtents Wrapper'
!

Eval [
    CairoPattern initialize
]