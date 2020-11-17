;;;===================================================
;;; OM2Csound
;;; Control of Csound sound synthesis from OpenMusic
;;;
;;; Preferences
;;; J. Bresson, IRCAM 2010
;;;===================================================

(in-package :om)

(defvar *CSOUND-PATH* "path to Csound folder")

(pushr 'csound *external-prefs*)

(defvar *csound-defflags* "-f -m7 -N -g -b8192 -B8192")  ;; "-m7 -A -e -b8192 -B8192 -V50 -P128"

(defmethod get-external-name ((module (eql 'csound))) "Csound")

(defmethod get-external-module-vals ((module (eql 'csound)) modulepref) (get-pref modulepref :csound-options))
(defmethod get-external-module-path ((module (eql 'csound)) modulepref) (get-pref modulepref :csound-path))
(defmethod set-external-module-vals ((module (eql 'csound)) modulepref vals) (set-pref modulepref :csound-options vals))
(defmethod set-external-module-path ((module (eql 'csound)) modulepref path) 
  (set-pref modulepref :csound-path path))


(defun def-csound-options () '("-f -m7 -A -N -g -b8192 -B8192"))

(defmethod get-external-def-vals ((module (eql 'csound))) 
  `(:csound-path ,(pathname "/usr/local/bin/csound")
    :csound-options ,(def-csound-options)))


(defmethod save-external-prefs ((module (eql 'csound))) 
  `(:csound-path ,(om-save-pathname *CSOUND-PATH*) 
    :csound-options (list ,*csound-defflags*)))


(defmethod put-external-preferences ((module (eql 'csound)) moduleprefs)
  (let ((list-prefs (get-pref moduleprefs :csound-options)))
    (when list-prefs 
      (setf *csound-defflags* (car list-prefs)))
    (when (get-pref moduleprefs :csound-path)
      (setf *CSOUND-PATH* (find-true-external (get-pref moduleprefs :csound-path))))
    t))
      

(put-external-preferences 'csound (find-pref-module :externals))


;;;===========================
;;; INTERFACE

(defmethod show-external-prefs-dialog ((module (eql 'csound)) prefvals)
  (let* ((rep-list (copy-list prefvals))
         ;(rep-list (copy-list prefs))
         (dialog (om-make-window 'om-dialog
                                 :window-title "Csound Options"
                                 :size (om-make-point 300 150)
                                 :position :centered
                                 :resizable nil :maximize nil :close nil))
         (pos 20)
         (flaglabel (om-make-dialog-item 'om-static-text  
                                         (om-make-point 20 pos)  (om-make-point 147 17) "Csound default Flags"
                                          ;:bg-color *om-window-def-color*
                                         :font *om-default-font2*))
         (pos (+ pos 30))
         (defflagsline (om-make-dialog-item 'om-editable-text
                                             (om-make-point 24 pos)
                                             (om-make-point 240 20) (nth 0 prefvals)  
                                         :font *om-default-font2*))
          (pos (+ pos 40))

#|       
         (tablelabel (om-make-dialog-item 'om-static-text  
                                          (om-make-point 20 pos) (om-make-point 147 17) "Default Table"
                                          :font *om-default-font2*))
         (pos (+ pos 20))
         (deftablestr (om-make-dialog-item 'om-editable-text  
                                            (om-make-point 28 pos)
                                            (om-make-point 240 20) (nth 1 prefvals)  
                                           :font *om-default-font2*))
         (pos (+ pos 40))
         (startlabel (om-make-dialog-item 'om-static-text  
                                          (om-make-point 20 pos) (om-make-point 174 18) "Max GEN arguments"
                                   
                                          :font *om-default-font2*))

         (tablestart (om-make-dialog-item 'om-editable-text  
                                           (om-make-point 200 (- pos 5))
                                           (om-make-point 37 20)
                                          (format nil "~D" (nth 2 prefvals)) 
                                          :font *om-default-font2*))
         (pos (+ pos 40))
         (sizelabel (om-make-dialog-item 'om-static-text  
                                          (om-make-point 20 pos) (om-make-point 133 19) "Default table size"
                                          :font *om-default-font2*))
         (tablesize (om-make-dialog-item 'om-editable-text  
                                          (om-make-point 200 (- pos 5))
                                          (om-make-point 37 20)
                                         (format nil "~D" (nth 3 prefvals))  
                                         :font *om-default-font2*))
|#
         )
    (om-add-subviews dialog
                     flaglabel defflagsline 
                     ;tablelabel deftablestr 
                     ;startlabel tablestart sizelabel tablesize

      ;;; boutons
      (om-make-dialog-item 'om-button (om-make-point 20 pos) (om-make-point 80 20) "Restore"
                           :di-action (om-dialog-item-act item
                                        (om-set-dialog-item-text defflagsline (nth 0 (def-csound-options)))
                                        ;(om-set-dialog-item-text deftablestr (nth 1 (def-csound-options)))
                                        ;(om-set-dialog-item-text tablestart (integer-to-string (nth 2 (def-csound-options))))
                                        ;(om-set-dialog-item-text tablesize (integer-to-string (nth 3 (def-csound-options))))
                                        ))
      
      (om-make-dialog-item 'om-button (om-make-point 130 pos) (om-make-point 80 20) "Cancel"
                           :di-action (om-dialog-item-act item
                                        (om-return-from-modal-dialog dialog nil)))
      
      (om-make-dialog-item 'om-button (om-make-point 210 pos) (om-make-point 80 20) "OK"
                           :di-action (om-dialog-item-act item
                                        (setf (nth 0 rep-list) (om-dialog-item-text defflagsline))
                                        (om-return-from-modal-dialog dialog rep-list))
                                          ;(let ((argerror nil)
                                          ;    (starttxt (om-dialog-item-text tablestart))
                                          ;    (sizetxt (om-dialog-item-text tablesize)))
                                          ;;; csound flags
                                          ;(setf (nth 0 rep-list) (om-dialog-item-text defflagsline))
                                          ;;; def table
                                          ;(setf (nth 1 rep-list) (om-dialog-item-text deftablestr))
                                          ;;; table max
                                          ;(if (and (not (string= "" starttxt))
                                          ;         (integerp (read-from-string starttxt)))
                                          ;  (setf (nth 2 rep-list) (read-from-string starttxt))
                                          ;  (setf argerror t))
                                          ;;; table size
                                          ;(if (and (not (string= "" sizetxt))
                                          ;         (integerp (read-from-string sizetxt)))
                                          ;  (setf (nth 3 rep-list) (read-from-string sizetxt))
                                          ;  (setf argerror t))
                                          ;(if argerror
                                          ;  (om-message-dialog (format nil "Error in a Csound option.~% Preferences could not be recorded.")) 
                                          ;  (om-return-from-modal-dialog dialog rep-list))
                                          ;))
                           :default-button t :focus t)
    )
    (om-modal-dialog dialog)))


