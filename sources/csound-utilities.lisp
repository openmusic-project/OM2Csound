(in-package :om)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   CSOUND SPLIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmethod! csound-split ((sound sound) (nth number))
  :icon '(287)
  :indoc '("input file" "nth")
  :doc "splits a multichannel sound object into separate channels.
If <nth> is nil all channels will be splited into new files. Theses will be saved in the same directory of the original file.
If <nth> is a number this will correspond to channel number starting by 1.
<nth> can be also a list of existing channels in a multichannel's file."
  (if (not (= (sf-chan sound) 1))
  (let* ((file (filename sound))
         (name (pathname-name file))
         (type (pathname-type file))
         (directory (pathname-directory file))
         (csdfile (make-pathname :directory directory :name "tmp.csd"))
         (sr (sf-sr sound))
         (ch (sf-chan sound))
         (dur (sound-dur sound))
         (res (sf-res sound))
         (outfile-name (format nil "~A-~D.~A" name nth type))
         (outfile (make-pathname :directory directory :name outfile-name)))
    (WITH-OPEN-FILE (out csdfile :direction :output  :if-does-not-exist :create :if-exists :supersede)
      (format out "<CsoundSynthesizer>~%")
      (format out "<CsInstruments>~%")
      (format out "sr = ~D~%" (sf-sr sound))
      (format out "kr = ~D~%" (sf-sr sound))
      (format out "ksmps=1~%")
      ;(format out "nchnls=~D~%~%" (sf-chan sound))
      (format out "nchnls = 1~%~%")
      (format out "instr 1~%~%~%")

      (loop for i from 1 to (- ch 1)
            collect (format out "asig~D, " i))
      (format out "asig~D soundin p4~%" (sf-chan sound))
      (format out "out asig~D~%" nth)
      (format out "endin~%~%")
      (format out "</CsInstruments>~%")
      (format out "<CsScore>~%~%")
      (format out "i 1 0 ~D ~S~%~%" dur (namestring file))
      (format out "</CsScore>~%")
      (format out "</CsoundSynthesizer>"))
    ;(setf res (or *audio-res*
    ;                (om-sound-sample-size sound)
    ;                16))
    (let ((format (om-sound-format sound)))
    (om-cmd-line (format nil "~s ~A -~A -~A -o ~s ~s"
                          (namestring *CSOUND-PATH*)
                          *csound-defflags*
                          (case res (16 "s") (24 "3") (32 "l"))
                          (if (string-equal "AIFF" (subseq format 0 4)) "A" "W")
                          (namestring outfile)
                          (namestring csdfile))
                 *sys-console*))
    (delete-file csdfile)
    outfile)
    (om-beep-msg (format nil "~A is already a mono file !" (pathname-name (filename sound))))))


(defmethod! csound-split ((sound sound) (nth list))
  (loop for i in nth
        do (csound-split sound i)))

(defmethod! csound-split ((sound sound) (nth t))
  (let ((num (sf-chan sound)))
  (loop for i from 1 to num
        do (csound-split sound i))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   CSOUND MERGE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmethod mono-file-p ((sfs t)) nil)
(defmethod mono-file-p ((sfs null)) nil)
(defmethod mono-file-p ((sfs sound))
  (if (= (sf-chan sfs) 1) t nil))
(defmethod mono-file-p ((sfs list))
  (let ((res t))
  (loop for i in sfs
        do (if (not (mono-file-p i)) (setf res nil)))
  res))


(defmethod! csound-merge ((sfs list))
  :icon '(287)
  :indoc '("input files")
  :doc "Merges a list of mono sound objects into a multichannel sound object.
NOTE: All files must be mono files and have the same sr and res.
The location of the resulting sound file will be in the same directory of the first file of the list. "
  (if  (mono-file-p sfs)
      (let* ((lgt (length sfs))
             (paths (mapcar #'(lambda (x) (namestring (filename x))) sfs))
             (snd (car sfs)) ;first sf file
             (file (filename snd)) 
             (name (pathname-name file))
             (type (pathname-type file))
             (directory (pathname-directory file))
             (csdfile (make-pathname :directory directory :name "tmp.csd"))
             (sr (sf-sr snd))
             (res (sf-res snd))
             (durs (loop for i in sfs collect (sound-dur i)))
             (dur (list-max durs))
             (outfile-name (format nil "~A-mch~D.~A" name lgt type))
             (outfile (make-pathname :directory directory :name outfile-name)))
        (print (list "ssas" paths))
        (WITH-OPEN-FILE (out csdfile :direction :output  :if-does-not-exist :create :if-exists :supersede)
          (format out "<CsoundSynthesizer>~%")
          (format out "<CsInstruments>~%")
          (format out "sr = ~D~%" sr)
          (format out "kr = ~D~%" sr)
          (format out "ksmps=1~%")
          (format out "nchnls=~D~%~%" lgt)
          (format out "instr 1~%~%~%")

          (loop for i from 1 to lgt
                collect
                  (format out "asig~D soundin p~D~%" i (+ 3 i)))
          (format out "outc  ")
          (loop for i from 1 to (- lgt 1)
                collect (format out "asig~D, " i))
          (format out "asig~D~%" lgt)
              ;(format out "out asig~D~%" nth)
          (format out "endin~%~%")
          (format out "</CsInstruments>~%")
          (format out "<CsScore>~%~%")
          (format out "i 1 0 ~D \\ ~%" dur)
          (loop for p in paths
                collect (format out " ~S \\ ~%" p))
          (format out "</CsScore>~%")
          (format out "</CsoundSynthesizer>"))
        ;(setf res (or *audio-res*
        ;              (om-sound-sample-size snd)
        ;              16))
        (when (and res (not (member res '(16 24 32))))
          (print "WARNING: Csound normalize can only output 16, 24 or 32 bits/sample audio")
          (setf res 16))
        (let ((format (om-sound-format snd)))
          (om-cmd-line (format nil "~s ~A -~A -~A -o ~s ~s"
                               (namestring *CSOUND-PATH*)
                               *csound-defflags*
                               (case res (16 "s") (24 "3") (32 "l"))
                               (if (string-equal "AIFF" (subseq format 0 4)) "A" "W")
                               (namestring outfile)
                               (namestring csdfile)                               
                               )
                       *sys-console*)
          (delete-file csdfile)
          outfile))
    (om-beep-msg (format nil "List must be mono files only !"))))
