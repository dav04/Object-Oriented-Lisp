;;;; -*- Mod: Lisp -*-
;;;; ool.lisp

;;;; Medina Davide 780851

;--------------------------------------------------------------------
;; Progetto Linguaggi di Programmazione:
;; Costruzione sistema OOL, Object-Oriented Lisp
;--------------------------------------------------------------------

; definizione e manipolazione hash table
(defparameter *classes-specs* (make-hash-table))

(defun add-class-spec (name class-spec)
  (setf (gethash name *classes-specs*) class-spec)
  )

(defun get-class-spec (name)
  (gethash name *classes-specs*)
  )

;; DEFINE-CLASS class-name parent (slot-value)*
; Crea la classe inserendola nella hash table usando come chiave 
; il nome della classe (class-name) e come valore una association list
; di tutti gli slot presenti (slot-value) con l'aggiunta del riferimento 
; dell'ereditarietà della classe (parent)
(defun define-class (class-name parent &rest slot-value)
  (cond ((not (symbolp class-name)) 
         (error "class-name is not a symbol")
         )
        ((not (symbolp parent)) 
         (error "parent is not a symbol")
         )
        ((eq class-name parent) 
         (error "class-name and parent can't be the same")
         )
        ((and (not (eq nil parent)) (not (get-class-spec parent)))
         (error "parent class doesn't exist")
         )
        (T (progn
             (remhash class-name *classes-specs*)
             (create-slot class-name slot-value)
             (add-class-spec class-name 
                             (acons 'parent parent (get-class-spec class-name))
                             )
             class-name)
           )
        )
  )

;; CREATE-SLOT class-name slot-value
; Riceve la lista di tutti i possibili slot di una classe (slot-value)
; e crea la association list usando lo slot-name come chiave e lo slot-value
; come valore; inoltre, in caso di presenza di un metodo, esegue la funzione
; process-method che definisce e crea il metodo vero e proprio
(defun create-slot (class-name slot-value)
  (if (not (symbolp (first slot-value)))
      (progn 
        (remhash class-name *classes-specs*)
        (error "slot-name is not a symbol")
        )
    (if (not (null slot-value))
        (if (not (assoc (first slot-value) (get-class-spec class-name)))
            (progn 
              (if (and (consp (second slot-value))
                       (eq 'method (first (second slot-value)))
                       )
                  (process-method (first slot-value))
                )
              (add-class-spec class-name 
                              (acons (first slot-value) 
                                     (second slot-value) 
                                     (get-class-spec class-name)
                                     )
                              )
              (create-slot class-name (rest (rest slot-value)))
              )
          (progn 
            (remhash class-name *classes-specs*)
            (error "two slots with the same name")
            )
          )
      )
    )
  )

;; NEW class-name (slot-value)*
; Crea l'istanza tramite la classe selezionata (class-name) con la
; possibilità di modificare gli slot già esistenti della classe (slot-value)
(defun new (class-name &rest slot-value)
  (cond ((not (symbolp class-name)) 
         (error "class-name is not a symbol")
         )
        ((and (null slot-value) 
              (null (cdr (assoc 'parent (get-class-spec class-name))))
              )
         (append (list 'ool-instance class-name)
                 (get-class-spec class-name)
                 )
         )
        ((null slot-value) 
         (append (list 'ool-instance class-name)
                 (check-parent class-name ())
                 )
         )
        ((null (cdr (assoc 'parent (get-class-spec class-name))))
         (create-instance class-name slot-value (get-class-spec class-name))
         )
        (T
         (create-instance class-name slot-value (check-parent class-name ()))
         )
        )
  )

;; CHECK-PARENT class-name list
; Dato che sono presenti "parenti" nella classe selezionata (class-name), viene
; creata la association list con tutti gli slot di tutte le classi antenate
(defun check-parent (class-name list)
  (if (not (null (cdr (assoc 'parent (get-class-spec class-name)))))
      (check-parent (cdr (assoc 'parent (get-class-spec class-name)))
                    (append list (get-class-spec class-name))
                    )
    (remove-duplicates (append list (get-class-spec class-name))
                       :from-end t :key #'car)
    )
  )

;; CREATE-INSTANCE class-name slot-value list
; Crea la association list con tutti gli slot che rappresenta l'istanza e,
; nel caso sia stato ridefinito un metodo, richiama process-method
(defun create-instance (class-name slot-value list)
  (if (not (null slot-value))
      (if (not (assoc (first slot-value) list)) 
          (error "unknown slot")
        (progn 
          (if (and (consp (second slot-value))
                   (eq 'method (first (second slot-value)))
                   )
              (process-method (first slot-value))
            )
          (create-instance class-name 
                           (rest (rest slot-value))
                           (acons (first slot-value) 
                                  (second slot-value) 
                                  list
                                  )
                           )
          )
        )
    (append (list 'ool-instance class-name)
            (remove-duplicates list :from-end t :key #'car)
            )
    )
  )

;; GET-SLOT instance slot-name
; Restituisce il valore dello slot richiesto (slot-name) preso dall'istanza
; indicata (instance)
(defun get-slot (instance slot-name)
  (cond ((not (consp (cddr instance)))
         (error "instance not correct")
         )
        ((not (symbolp slot-name)) 
         (error "slot-name is not a symbol")
         )
        ((not (assoc slot-name (cddr instance))) 
         (error "slot is not present in the instance")
         )
        (T 
         (cdr (assoc slot-name (cddr instance)))
         )
        )
  )

;; PROCESS-METHOD method-name
; Crea la funzione, chiamandola con il nome dello slot (method-name), definendo
; al suo interno una funzione lambda il cui corpo viene creato al momento
; della chiamata della funzione prendendolo direttamente all'interno dello slot
(defun process-method (method-name)
  (setf (fdefinition method-name)
        (lambda (this &rest args)
          (apply 
           (eval (append 
                  (list 'lambda)
                  (list (append (list 'this) 
                                (list* (second (get-slot this method-name)))
                                )
                        )
                  (cddr (get-slot this method-name))
                  )
                 )
           (append (list this) args)
           )
          )
        )
  )

;;;; -- end of file -- ool.lisp