(script-fu-register
    "script-fu-habitat"                        ;func name
    "Habitat 1 - Setup"                                  ;menu label
    "Blocks out all of image except habitat"              ;description
    "Steffi"                             ;author
    "CP"
    "Jul 4 2013"
    ""                     ;image type that the script works on
    SF-IMAGE "Input Image" 0
    SF-DRAWABLE "Input Drawable" 0
    )

(define (morph-filename orig-name new-extension)
  (let ((buffer (vector #f #f #f)))
    (if (re-match "^(.*)[.]([^.]+)$" orig-name buffer)
        (string-append (re-match-nth orig-name buffer 1) new-extension)
        (string-append orig-name new-extension))))

(script-fu-menu-register "script-fu-habitat" "<Image>/Filters")
(define (script-fu-habitat image drawable)
  (let* (;; define our local variables
	 (height_image (car (gimp-image-height image)))
	 (width_image (car (gimp-image-width image)))
	 (territory (car (gimp-layer-new image width_image height_image 1 "territory" 100 0)))
	 (water (car (gimp-layer-new image width_image height_image 1 "water" 100 0)))
	 (grass (car (gimp-layer-new image width_image height_image 1 "grass" 100 0)))
         (naturalgrass (car (gimp-layer-new image width_image height_image 1 "naturalgrass" 100 0)))
	 (trees (car (gimp-layer-new image width_image height_image 1 "trees" 100 0)))
	 (dirt (car (gimp-layer-new image width_image height_image 1 "dirt" 100 0)))
	 (pavement (car (gimp-layer-new image width_image height_image 1 "pavement" 100 0)))
	 (bushes (car (gimp-layer-new image width_image height_image 1 "bushes" 100 0)))
	 (buildings (car (gimp-layer-new image width_image height_image 1 "buildings" 100 0)))
	 (input (car (gimp-image-get-filename image)))
	 (output 0)
	 (temp 0)
	 )

    (gimp-context-set-background '(255 255 255) )
    (gimp-context-set-foreground '(0 0 0) )  
    (gimp-image-undo-group-start image) ;; start undo

    (gimp-image-insert-layer image water 0 -1) ;; Create new layer    
    (gimp-image-insert-layer image grass 0 -1) ;; Create new layer
    (gimp-image-insert-layer image naturalgrass 0 -1) ;; Create new layer
    (gimp-image-insert-layer image trees 0 -1) ;; Create new layer
    (gimp-image-insert-layer image dirt 0 -1) ;; Create new layer
    (gimp-image-insert-layer image pavement 0 -1) ;; Create new layer
    (gimp-image-insert-layer image bushes 0 -1) ;; Create new layer
    (gimp-image-insert-layer image buildings 0 -1) ;; Create new layer

    (gimp-drawable-fill water TRANSPARENT-FILL)
    (gimp-drawable-fill grass TRANSPARENT-FILL)
    (gimp-drawable-fill naturalgrass TRANSPARENT-FILL)
    (gimp-drawable-fill trees TRANSPARENT-FILL)
    (gimp-drawable-fill dirt TRANSPARENT-FILL)
    (gimp-drawable-fill pavement TRANSPARENT-FILL)
    (gimp-drawable-fill bushes TRANSPARENT-FILL)
    (gimp-drawable-fill buildings TRANSPARENT-FILL)

    ;;Get territory layer to specify the ring
    (gimp-image-insert-layer image territory 0 -1) ;; Create new layer
    (gimp-selection-all image) ;; Select everything
    (gimp-image-select-ellipse image CHANNEL-OP-SUBTRACT 356 30 948 948)  ;; Substract circle from centre
    (gimp-edit-bucket-fill territory 1 0 100 0 FALSE 0 0) 

    (gimp-selection-all image) ;; Select everything
    (gimp-image-undo-group-end image)  ;; end undo

    ;; Select default brush and colour
    (gimp-context-set-foreground '(0 0 0))
    (gimp-context-set-brush "2. Hardness 100")
    (gimp-context-set-brush-size 100)
    
    (gimp-image-set-active-layer image buildings) ;; Set the buildings layer as the active layer

    ;; Change from jpg to project files: Named as IDname_a.xcf
    (while (not (string=? (substring input (- (string-length input) 1)) "."))
	   (set! input (substring input 0 (- (string-length input) 1)))
	   )
    (set! input (substring input 0 (- (string-length input) 1)))
    (set! output (string-append input "_a.xcf"))

    ;Save project file
    (gimp-xcf-save 1 image drawable output output)

    ;reload the xcf to get the proper name
    (set! temp (car (gimp-file-load RUN-NONINTERACTIVE output output)))
    (gimp-displays-reconnect image temp)
    (gimp-image-clean-all temp)
    
    (gimp-displays-flush)
    )    
  )
