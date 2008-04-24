Gtk class extend [

    mainIteration [
	<category: 'C call-outs'>
	<asyncCCall: 'gstGtkMainIteration' args: #()>
	
    ]

    mainIterationDo: blocking [
	<category: 'C call-outs'>
	<asyncCCall: 'gstGtkMainIterationDo' args: #(#boolean )>
	
    ]

    main: aSemaphore [
	<category: 'C call-outs'>
	<asyncCCall: 'gstGtkMain' args: #(#smalltalk )>
	
    ]

    shouldQuit [
	<category: 'C call-outs'>
	<cCall: 'gstGtkShouldQuit' returning: #boolean args: #()>
	
    ]

    gstGtkInit [
	<category: 'C call-outs'>
	<cCall: 'gstGtkInit' returning: #void args: #()>
	
    ]

]



GLib class extend [

    register: anObject forType: gType [
	<category: 'C call-outs'>
	<cCall: 'gstGtkRegisterForType' returning: #void
	args: #(#smalltalk #unknown )>
	
    ]

]



GObject extend [

    connectSignal: name to: handler selector: sel userData: userData [
	<category: 'C call-outs'>
	<cCall: 'gstGtkConnectSignal' returning: #void
	args: #(#selfSmalltalk #string #smalltalk #smalltalk #smalltalk )>
	
    ]

    narrow [
	<category: 'C call-outs'>
	<cCall: 'gstGtkNarrowGObjectOOP' returning: #smalltalk
	args: #(#self #selfSmalltalk )>
	
    ]

    free [
	<category: 'C call-outs'>
	<cCall: 'gstGtkFreeGObjectOOP' returning: #void args: #(#self )>
	
    ]

    propertiesAt: name [
	<category: 'C call-outs'>
	<cCall: 'gstGtkGetProperty' returning: #smalltalk args: #(#self #string )>
	
    ]

    propertiesAt: name put: anObject [
	<category: 'C call-outs'>
	<cCall: 'gstGtkSetProperty' returning: #void
	args: #(#self #string #smalltalk )>
	
    ]

]



GtkWidget extend [

    getAllocation [
	<category: 'C call-outs'>
	<cCall: 'gstGtkWidgetGetAllocation' returning: #{GtkAllocation}
	args: #(#self )>
	
    ]

    getWindow [
	<category: 'C call-outs'>
	<cCall: 'gstGtkGetWindow' returning: #{GdkWindow} args: #(#self )>
	
    ]

    getState [
	<category: 'C call-outs'>
	<cCall: 'gstGtkGetState' returning: #int args: #(#self )>
	
    ]

    getFlags [
	<category: 'C call-outs'>
	<cCall: 'gstGtkGetFlags' returning: #int args: #(#self )>
	
    ]

    setFlags: flags [
	<category: 'C call-outs'>
	<cCall: 'gstGtkSetFlags' returning: #void args: #(#self #int )>
	
    ]

    unsetFlags: flags [
	<category: 'C call-outs'>
	<cCall: 'gstGtkUnsetFlags' returning: #void args: #(#self #int )>
	
    ]

]



GtkContainer extend [

    child: widget propertiesAt: name [
	<category: 'C call-outs'>
	<cCall: 'gstGtkGetChildProperty' returning: #smalltalk
	args: #(#self #cObject #string )>
	
    ]

    child: widget propertiesAt: name put: anObject [
	<category: 'C call-outs'>
	<cCall: 'gstGtkSetChildProperty' returning: #void
	args: #(#self #cObject #string #smalltalk )>
	
    ]

]



GValue class extend [

    typeFromName: aName [
	<category: 'C call-outs'>
	<cCall: 'g_type_from_name' returning: #int args: #(#string )>
	
    ]

]



GtkTreeModel extend [

    getOop: iter column: aColumn [
	<category: 'C call-outs'>
	<cCall: 'gstGtkTreeModelGetOOP' returning: #smalltalk
	args: #(#self #cObject #int )>
	
    ]

]



GtkTreeStore extend [

    setOop: iter column: aColumn value: aValue [
	<category: 'C call-outs'>
	<cCall: 'gstGtkTreeStoreSetOOP' returning: #void
	args: #(#self #cObject #int #smalltalk )>
	
    ]

]



GtkListStore extend [

    setOop: iter column: aColumn value: aValue [
	<category: 'C call-outs'>
	<cCall: 'gstGtkListStoreSetOOP' returning: #void
	args: #(#self #cObject #int #smalltalk )>
	
    ]

]



GtkDialog extend [

    getVBox [
	<category: 'C call-outs'>
	<cCall: 'gstGtkDialogGetVBox' returning: #{GtkWidget} args: #(#self )>
	
    ]

    getActionArea [
	<category: 'C call-outs'>
	<cCall: 'gstGtkDialogGetActionArea' returning: #{GtkWidget}
	args: #(#self )>
	
    ]

]



GtkScrolledWindow extend [

    getHscrollbarVisible [
	<category: 'C call-outs'>
	<cCall: 'gstGtkGetHscrollbarVisible' returning: #boolean args: #(#self )>
	
    ]

    getVscrollbarVisible [
	<category: 'C call-outs'>
	<cCall: 'gstGtkGetVscrollbarVisible' returning: #boolean args: #(#self )>
	
    ]

]



GtkAdjustment extend [

    getLower [
	<category: 'C call-outs'>
	<cCall: 'gstGtkAdjustmentGetLower' returning: #int args: #(#self )>
	
    ]

    getUpper [
	<category: 'C call-outs'>
	<cCall: 'gstGtkAdjustmentGetUpper' returning: #int args: #(#self )>
	
    ]

    getPageSize [
	<category: 'C call-outs'>
	<cCall: 'gstGtkAdjustmentGetPageSize' returning: #int args: #(#self )>
	
    ]

]



GdkPixbufLoader extend [

    write: buf count: count error: error [
	"FIXME: funcs.awk is broken for this."

	<category: 'C call-outs'>
	<cCall: 'gdk_pixbuf_loader_write' returning: #boolean
	args: #(#self #byteArray #int #cObject )>
	
    ]

]



Eval [
    GtkTreeStore superclass: GtkTreeModel.
    GtkListStore superclass: GtkTreeModel
]
