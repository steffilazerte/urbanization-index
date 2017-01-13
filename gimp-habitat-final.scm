(script-fu-register
    "script-fu-habitat-final"                        ;func name
    "Habitat 2 - Save"                               ;menu label
    "Blocks out all of image except habitat"         ;description
    "Steffi LaZerte"                                         ;author
    "CP"                                             ;copyright
    "Jul 4 2013"                                     ;date
    ""                                               ;image type that the script works on
    SF-IMAGE "Input Image" 0
    SF-DRAWABLE "Input Drawable" 0
    )

;; Define a function to grab out the original picture name without loc or extension or _a or _b
(define (morph-filename orig-name new-extension)
 (let* ((buffer (vector "" "" "" "")))
  (if (re-match "^(.*)[.]([^.]+)$" orig-name buffer)
   (string-append (substring orig-name 0 (car (vector-ref buffer 2))) new-extension)
  )
 )
)

(define (base-name orig-name divider)
  (car (reverse (strbreakup (car (strbreakup orig-name "_a.xcf")) divider)))
)


(script-fu-menu-register "script-fu-habitat-final" "<Image>/Filters")

(define (script-fu-habitat-final image drawable)
  (let* (
	 ;; Guess host OS based on directory path separator (based on script from http://www.gimp.org/tutorials/AutomatedJpgToXcf/)

         

	 ;; Get directory location

         (local_dir (car (strbreakup (car (gimp-image-get-filename image)) "maps")))

	 (isLinux ( >  
            (length (strbreakup local_dir "/" ))
            (length (strbreakup local_dir "\\" ))))

	 (slashes (if isLinux
		      "/"
		      "\\"))


	 ;; Get file name without location or extension
	 (output (base-name (car (gimp-image-get-filename image)) slashes))

	 ;; Define new locations
	 ;(output_data (string-append local_dir "data"))
	 ;(output_gimp (string-append local_dir "gimp"))

	 (output2 (string-append local_dir "data" slashes output ".txt"))
	 (output3 (string-append local_dir "gimp" slashes output "_b.xcf"))
	 (output4 (string-append local_dir "gimp" slashes output "_a.xcf"))

	 ;; Define Layers
	 (territory (car (gimp-image-get-layer-by-name image "territory")))
	 (water (car (gimp-image-get-layer-by-name image "water")))
	 (grass (car (gimp-image-get-layer-by-name image "grass")))
	 (naturalgrass (car (gimp-image-get-layer-by-name image "naturalgrass")))
	 (trees (car (gimp-image-get-layer-by-name image "trees")))
	 (dirt (car (gimp-image-get-layer-by-name image "dirt")))
	 (pavement (car (gimp-image-get-layer-by-name image "pavement")))
	 (bushes (car (gimp-image-get-layer-by-name image "bushes")))
	 (buildings (car (gimp-image-get-layer-by-name image "buildings")))
	 
	 ;; Define values to create for the analysis
	 (histo_values)

	 (pixels-water)
	 (pixels-grass)
	 (pixels-naturalgrass)
	 (pixels-trees)
	 (pixels-dirt)
	 (pixels-pavement)
	 (pixels-bushes)
	 (pixels-buildings)

	 ;; For saving the file
	 (temp)

	 ;; Open the text file for writing
	 (p (open-output-file output2))

	 )

    (gimp-message-set-handler ERROR-CONSOLE)
    (gimp-message (string-append "local dir: " local_dir))

    ;Save hand drawn work as old file

    (gimp-message (string-append "output data file: " output2))
    (gimp-message (string-append "image filename: " (car(gimp-image-get-filename image))))

    (gimp-xcf-save 1 image drawable output4 output4)
    (gimp-message (string-append "Saved - Old file - " output4))

    (gimp-image-undo-group-start image) ;; start undo
    (gimp-context-set-background '(255 255 255) )

     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;If one thing overlaps with something else, remove those pixels it from the first layer and from ring around territory
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;BUILDINGS > BUSHES > PAVEMENT > DIRT > TREES > GRASS > WATER

    ;WATER
    (gimp-image-select-color image CHANNEL-OP-REPLACE territory '(255 255 255))
    (gimp-image-select-color image CHANNEL-OP-ADD grass '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD naturalgrass '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD trees '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD dirt '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD pavement '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD bushes '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD buildings '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-INTERSECT water '(0 0 0))
    (if (= (car (gimp-selection-is-empty image)) FALSE) (gimp-edit-clear water))

    ;GRASS
    ;If grass overlaps with something else, remove those pixels from the grass layer (no worries about water)
    (gimp-image-select-color image CHANNEL-OP-REPLACE territory '(255 255 255))
    (gimp-image-select-color image CHANNEL-OP-ADD naturalgrass '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD trees '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD dirt '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD pavement '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD bushes '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD buildings '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-INTERSECT grass '(0 0 0))
    (if (= (car (gimp-selection-is-empty image)) FALSE) (gimp-edit-clear grass))
    ;(if (= (car (gimp-selection-is-empty image)) FALSE) (gimp-edit-bucket-fill grass 0 23 100 0 FALSE 0 0))

    ;NATURALGRASS
    ;If grass overlaps with something else, remove those pixels from the grass layer (no worries about water)
    (gimp-image-select-color image CHANNEL-OP-REPLACE territory '(255 255 255))
    (gimp-image-select-color image CHANNEL-OP-ADD trees '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD dirt '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD pavement '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD bushes '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD buildings '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-INTERSECT naturalgrass '(0 0 0))
    (if (= (car (gimp-selection-is-empty image)) FALSE) (gimp-edit-clear naturalgrass))
    ;(if (= (car (gimp-selection-is-empty image)) FALSE) (gimp-edit-bucket-fill grass 0 23 100 0 FALSE 0 0))

    ;TREES
    ;If trees overlap with something else, remove those pixels from the trees layer
    (gimp-image-select-color image CHANNEL-OP-REPLACE territory '(255 255 255))
    (gimp-image-select-color image CHANNEL-OP-ADD dirt '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD pavement '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD bushes '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD buildings '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-INTERSECT trees '(0 0 0))
    (if (= (car (gimp-selection-is-empty image)) FALSE) (gimp-edit-clear trees))

    ;DIRT
    (gimp-image-select-color image CHANNEL-OP-REPLACE territory '(255 255 255))
    (gimp-image-select-color image CHANNEL-OP-ADD pavement '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD bushes '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD buildings '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-INTERSECT dirt '(0 0 0))
    (if (= (car (gimp-selection-is-empty image)) FALSE) (gimp-edit-clear dirt))

    ;PAVEMENT
    (gimp-image-select-color image CHANNEL-OP-REPLACE territory '(255 255 255))
    (gimp-image-select-color image CHANNEL-OP-ADD bushes '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-ADD buildings '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-INTERSECT pavement '(0 0 0))
    (if (= (car (gimp-selection-is-empty image)) FALSE) (gimp-edit-clear pavement))

    ;BUSHES
    (gimp-image-select-color image CHANNEL-OP-REPLACE territory '(255 255 255))
    (gimp-image-select-color image CHANNEL-OP-ADD buildings '(0 0 0))
    (gimp-image-select-color image CHANNEL-OP-INTERSECT bushes '(0 0 0))
    (if (= (car (gimp-selection-is-empty image)) FALSE) (gimp-edit-clear bushes))    

    ;BUILDINGS
    (gimp-image-select-color image CHANNEL-OP-REPLACE territory '(255 255 255))
    (gimp-image-select-color image CHANNEL-OP-INTERSECT buildings '(0 0 0))
    (if (= (car (gimp-selection-is-empty image)) FALSE) (gimp-edit-clear buildings))    

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;Colour in everything nicely now
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (gimp-context-set-foreground '(0 0 255) )   
    (gimp-image-select-color image CHANNEL-OP-REPLACE water '(0 0 0))
    (gimp-edit-bucket-fill water 0 0 100 0 FALSE 0 0) 

    (gimp-context-set-foreground '(0 255 0) )   
    (gimp-image-select-color image CHANNEL-OP-REPLACE grass '(0 0 0))
    (gimp-edit-bucket-fill grass 0 0 100 0 FALSE 0 0) 
 
    (gimp-context-set-foreground '(45 95 58) )   
    (gimp-image-select-color image CHANNEL-OP-REPLACE naturalgrass '(0 0 0))
    (gimp-edit-bucket-fill naturalgrass 0 0 100 0 FALSE 0 0) 

    (gimp-context-set-foreground '(0 71 0) )   
    (gimp-image-select-color image CHANNEL-OP-REPLACE trees '(0 0 0))
    (gimp-edit-bucket-fill trees 0 0 100 0 FALSE 0 0) 

    (gimp-context-set-foreground '(123 49 17) )   
    (gimp-image-select-color image CHANNEL-OP-REPLACE dirt '(0 0 0))
    (gimp-edit-bucket-fill dirt 0 0 100 0 FALSE 0 0) 

    (gimp-context-set-foreground '(108 114 108) )   
    (gimp-image-select-color image CHANNEL-OP-REPLACE pavement '(0 0 0))
    (gimp-edit-bucket-fill pavement 0 0 100 0 FALSE 0 0) 

    (gimp-context-set-foreground '(0 255 255) )   
    (gimp-image-select-color image CHANNEL-OP-REPLACE bushes '(0 0 0))
    (gimp-edit-bucket-fill bushes 0 0 100 0 FALSE 0 0) 

    (gimp-context-set-foreground '(255 0 0) )   
    (gimp-image-select-color image CHANNEL-OP-REPLACE buildings '(0 0 0))
    (gimp-edit-bucket-fill buildings 0 0 100 0 FALSE 0 0) 



    ;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; GET PIXEL DATA BY LAYER
    ;;;;;;;;;;;;;;;;;;;;;;;;;

    (gimp-selection-none image)
    (set! histo_values (gimp-histogram water HISTOGRAM-VALUE 0 255))
    (set! pixels-water (number->string (car (cdr (cdr (cdr histo_values))))))

    (set! histo_values (gimp-histogram trees HISTOGRAM-VALUE 0 255))
    (set! pixels-trees (number->string (car (cdr (cdr (cdr histo_values))))))
    
    (set! histo_values (gimp-histogram bushes HISTOGRAM-VALUE 0 255))
    (set! pixels-bushes (number->string (car (cdr (cdr (cdr histo_values))))))
    
    (set! histo_values (gimp-histogram grass HISTOGRAM-VALUE 0 255))
    (set! pixels-grass (number->string (car (cdr (cdr (cdr histo_values))))))
    
    (set! histo_values (gimp-histogram naturalgrass HISTOGRAM-VALUE 0 255))
    (set! pixels-naturalgrass (number->string (car (cdr (cdr (cdr histo_values))))))
    
    (set! histo_values (gimp-histogram pavement HISTOGRAM-VALUE 0 255))
    (set! pixels-pavement (number->string (car (cdr (cdr (cdr histo_values))))))
    
    (set! histo_values (gimp-histogram buildings HISTOGRAM-VALUE 0 255))
    (set! pixels-buildings (number->string (car (cdr (cdr (cdr histo_values))))))
    
    (set! histo_values (gimp-histogram dirt HISTOGRAM-VALUE 0 255))
    (set! pixels-dirt (number->string (car (cdr (cdr (cdr histo_values))))))

    (gimp-image-undo-group-end image)  ;; end undo

    (gimp-item-set-visible territory TRUE)
    (gimp-item-set-visible water TRUE)
    (gimp-item-set-visible grass TRUE)
    (gimp-item-set-visible naturalgrass TRUE)
    (gimp-item-set-visible trees TRUE)
    (gimp-item-set-visible bushes TRUE)
    (gimp-item-set-visible dirt TRUE)
    (gimp-item-set-visible pavement TRUE)
    (gimp-item-set-visible buildings TRUE)

    ;;Save Pixel Data to file
    (display (string-append "ID,water,grass,naturalgrass,trees,dirt,pavement,bushes,buildings\n" output "," pixels-water "," pixels-grass ","  pixels-naturalgrass "," pixels-trees "," pixels-dirt "," pixels-pavement "," pixels-bushes "," pixels-buildings "\n") p)
    (close-port p)

    ;Save Project to file
    (gimp-xcf-save 1 image drawable output3 output3)

    ;reload the xcf
    (set! temp (car (gimp-file-load RUN-NONINTERACTIVE output3 output3)))
    (gimp-displays-reconnect image temp)
    (gimp-image-clean-all temp)

    (gimp-message-set-handler ERROR-CONSOLE)
    (gimp-message "Saved")
    (gimp-displays-flush)

    )    
  )

