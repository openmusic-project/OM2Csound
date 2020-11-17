;;;===================================================
;;; OM2Csound
;;; Control of Csound sound synthesis from OpenMusic
;;;
;;; CSOUND SYNTHESIS CALL
;;; J. Bresson, IRCAM 2005
;;;===================================================

(in-package :om)

(defmethod! CSOUND-SYNTH ((sco pathname) (orc pathname) &optional (out-name nil) normalize resolution)
  :icon '(410)
  (if (probe-file *CSOUND-PATH*)
      (let* ((rt-out (equal out-name :rt))
             (outpath (if rt-out nil
                        (handle-new-file-exists
                         (corrige-sound-filename 
                          (if out-name out-name (pathname-name sco)) *om-outfiles-folder*))))
             (tmppath (unless rt-out
                        (handle-new-file-exists 
                         (om-make-pathname :directory outpath :name (pathname-name outpath) :type "tmp"))))
             (csout (if (and (not rt-out) (or normalize *normalize*)) tmppath outpath)))
   
        (om-print "======================================" "OM2Csound ::")
        (om-print "CSOUND SYNTHESIS..." "OM2Csound ::")
        (om-print "======================================" "OM2Csound ::")
        (om-print (format nil "~%Orchestra: ~s~%Score: ~s~%Output: ~s" orc sco csout))
        
        (when (and (not rt-out) (probe-file outpath))
          (om-print (string+ "Removing existing file: " (namestring outpath)) "OM2Csound ::")
          (om-delete-file outpath))
           
        (om-cmd-line 
         (format nil "~s ~A ~s ~s ~A" 
                        (namestring *CSOUND-PATH*)
                        *csound-defflags*
                        (namestring orc)
                        (namestring sco)
                        (if rt-out "-odac"
                          (format nil "-o ~s" (namestring csout)))
                        )
         *sys-console*)
        
        (if (and (not rt-out) (null (probe-file csout)))
            (om-message-dialog "!!! Error in CSound synthesis !!!")
          
          (progn
            (om-print "END SYNTHESIS" "OM2Csound ::")
            (unless rt-out 
              (when (or normalize *normalize*)
                (let ((real-out (om-normalize tmppath outpath (or normalize *normalize-level*) resolution)))
                  (if real-out 
                      (add-tmp-file tmppath)
                    (rename-file tmppath outpath))))
              )))
        
        (when *delete-inter-file* (clean-tmp-files))
        (and outpath (probe-file outpath)))
    (om-beep-msg "CSOUND NOT FOUND")))



(defmethod! CSOUND-SYNTH ((sco t) (orc t) &optional out-name normalize resolution)
            (csound-synth (convert-input-to-csound sco "sco") (convert-input-to-csound orc "orc") 
                          out-name 
                          normalize resolution))


(defmethod convert-input-to-csound ((self string) &optional type)
  (pathname self))

(defmethod convert-input-to-csound ((self pathname) &optional type)
  self)

(defmethod convert-input-to-csound ((self list) &optional type)
  (let ((path (tmpfile (if type (string+ "temcsoundfile." type) "temcsoundfile"))))
    (WITH-OPEN-FILE (out path :direction :output :if-does-not-exist :create :if-exists :supersede)
      (loop for item in self do (write-line item out)))
    (push path *tmpparfiles*)
    path))
    

(defmethod convert-input-to-csound ((self textfile) &optional type)
   (let ((path (tmpfile (if type (string+ "temcsoundfile." type) "temcsoundfile"))))
     (when (buffer-text self)
       (om-buffer-write-file (buffer-text self) path :if-exists :supersede))
         (push path *tmpparfiles*)
         path))


