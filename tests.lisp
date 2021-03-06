;;; libaudioDB-sb-alien
;;;
;;; Copyright (C) 2009, 2010 Christophe Rhodes
;;; Author: Christophe Rhodes
;;;
;;; This file is part of libaudioDB-sb-alien.
;;;
;;; libaudioDB-sb-alien is free software: you can redistribute it and/or
;;; modify it under the terms of the GNU General Public License
;;; as published by the Free Software Foundation, either version 3 of
;;; the License, or (at your option) any later version.
;;;
;;; libaudioDB-sb-alien is distributed in the hope that it will be
;;; useful, but WITHOUT ANY WARRANTY; without even the implied warranty
;;; of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with libaudioDB-sb-alien. If not, see <http://www.gnu.org/licenses/>.

(in-package "SB-ADB")

(load-shared-object #+darwin "libaudioDB.0.0.dylib" #+linux "libaudioDB.so.0.0")

(define-symbol-macro %default-query-args nil)
(defmacro with-default-query-args (args &body body &environment env)
  (let ((current-args (macroexpand '%default-query-args env)))
    `(symbol-macrolet ((%default-query-args ,(append args current-args)))
       ,@body)))

(defmacro with-query-result-assertions 
    ((query db &rest query-args) &body body &environment env)
  (let ((results (gensym "RESULTS"))
        (default-args (macroexpand '%default-query-args env)))
    `(let* ((,results (query ,query ,db ,@query-args ,@default-args))
            (length (length ,results)))
       (flet ((%present (list)
                (find-if (lambda (r)
                           (and
                            (string= (first list) (result-ikey r))
                            (< (abs (- (second list) (result-distance r))) 1e-4)
                            (= (third list) (result-qpos r))
                            (= (fourth list) (result-ipos r))))
                         ,results)))
         (declare (ignorable #'%present))
         (macrolet ((present (&rest forms)
                      `(and ,@(loop for f in forms collect `(%present ',f)))))
           ,@(loop for b in body collect `(assert ,b)))))))

(defmacro with-asserted-query-results ((query db &rest query-args) &body body)
  `(with-query-result-assertions (,query ,db ,@query-args)
     (= length ,(length body))
     (present ,@body)))

(defmacro assert-erroneous (form)
  `(handler-case ,form
     (error ())
     (:no-error (&rest values) 
       (error "No error: returned ~S" values))))

(declaim (optimize debug))

(defun test-0003 ()
  (let ((datum (make-datum "testfeature" '((1d0)))))
    (with-adb (db "testdb.0003" :direction :output :if-exists :supersede)
      (l2norm db)
      (insert datum db)
      (with-asserted-query-results
          (datum db :npoints 10 :accumulation :db :distance :dot-product)
        ("testfeature" 1 0 0)))))

(defun test-0004 ()
  (let ((feature (make-datum "testfeature" '((0d0 1d0) (1d0 0d0))))
        (query05 (make-datum "testquery" '((0d0 0.5d0))))
        (query50 (make-datum "testquery" '((0.5d0 0d0)))))
    (with-adb (db "testdb.0004" :direction :output :if-exists :supersede)
      (l2norm db)
      (insert feature db)
      (with-default-query-args (:accumulation :db :distance :dot-product)
        (with-asserted-query-results (query05 db :npoints 10)
          ("testfeature" 0.5 0 0) ("testfeature" 0 0 1))
        (with-asserted-query-results (query05 db :npoints 1)
          ("testfeature" 0.5 0 0))
        (with-asserted-query-results (query50 db :npoints 10)
          ("testfeature" 0.5 0 1) ("testfeature" 0 0 0))
        (with-asserted-query-results (query50 db :npoints 1)
          ("testfeature" 0.5 0 1))))))

(defun test-0010 ()
  (let ((feature01 (make-datum "testfeature01" '((0d0 1d0))))
        (feature10 (make-datum "testfeature10" '((1d0 0d0))))
        (query05 (make-datum "testquery" '((0d0 0.5d0))))
        (query50 (make-datum "testquery" '((0.5d0 0d0)))))
    (with-adb (db "testdb.0010" :direction :output :if-exists :supersede)
      (insert feature01 db)
      (insert feature10 db)
      (l2norm db)
      (with-default-query-args
          (:accumulation :per-track :ntracks 10 :npoints 10 :distance :euclidean-normed)
        (with-asserted-query-results (query05 db)
          ("testfeature01" 0 0 0) ("testfeature10" 2 0 0))
        (with-asserted-query-results (query05 db :radius 5)
          ("testfeature01" 0 0 0) ("testfeature10" 2 0 0))
        (with-asserted-query-results (query05 db :radius 1)
          ("testfeature01" 0 0 0))
        (with-asserted-query-results (query50 db)
          ("testfeature01" 2 0 0) ("testfeature10" 0 0 0))
        (with-asserted-query-results (query50 db :radius 5)
          ("testfeature01" 2 0 0) ("testfeature10" 0 0 0))
        (with-asserted-query-results (query50 db :radius 1)
          ("testfeature10" 0 0 0))))))

(defun test-0031 ()
  (let ((feature01 (make-datum "testfeature01" '((0d0 1d0))))
        (feature10 (make-datum "testfeature10" '((1d0 0d0))))
        (query05 (make-datum "testquery" '((0d0 0.5d0)))))
    (with-adb (db "testdb.0031" :direction :output :if-exists :supersede)
      (insert feature01 db)
      (insert feature10 db)
      (l2norm db)
      (with-default-query-args 
          (:accumulation :per-track :ntracks 10 :npoints 10 :distance :euclidean-normed)
        (with-asserted-query-results (query05 db)
          ("testfeature01" 0 0 0) ("testfeature10" 2 0 0))
        (with-asserted-query-results (query05 db :include-keys ()))
        (with-asserted-query-results (query05 db :include-keys '("testfeature01"))
          ("testfeature01" 0 0 0))
        (with-asserted-query-results (query05 db :include-keys '("testfeature10"))
          ("testfeature10" 2 0 0))
        (with-asserted-query-results (query05 db :include-keys '("testfeature10" "testfeature01"))
          ("testfeature01" 0 0 0) ("testfeature10" 2 0 0))

        (with-asserted-query-results (query05 db :exclude-keys '("testfeature10" "testfeature01")))        

        (with-asserted-query-results (query05 db :exclude-keys '("testfeature01"))
          ("testfeature10" 2 0 0))
        (with-asserted-query-results (query05 db :exclude-keys '("testfeature10"))
          ("testfeature01" 0 0 0))
        (with-asserted-query-results (query05 db :exclude-keys ())
          ("testfeature01" 0 0 0) ("testfeature10" 2 0 0))))))

(defun test-0036 ()
  (let ((feature01 (make-datum "testfeature01" '((0d0 1d0) (1d0 0d0))))
        (feature10 (make-datum "testfeature10" '((1d0 0d0) (0d0 1d0))))
        (query05 (make-datum "testquery" '((0d0 0.5d0))))
        (query50 (make-datum "testquery" '((0.5d0 0d0)))))
    (with-adb (db "testdb.0036" :direction :output :if-exists :supersede)
      (insert feature01 db)
      (insert feature10 db)
      (l2norm db)
      (with-default-query-args 
          (:accumulation :per-track :ntracks 10 :distance :euclidean-normed)
        (dolist (npoints '(10 2 5))
          (with-asserted-query-results (query05 db :npoints npoints)
            ("testfeature01" 0 0 0) ("testfeature01" 2 0 1)
            ("testfeature10" 0 0 1) ("testfeature10" 2 0 0)))
        (with-asserted-query-results (query05 db :npoints 1)
          ("testfeature01" 0 0 0) ("testfeature10" 0 0 1))
        (dolist (npoints '(10 2 5))
          (with-asserted-query-results (query50 db :npoints npoints)
            ("testfeature01" 0 0 1) ("testfeature01" 2 0 0)
            ("testfeature10" 0 0 0) ("testfeature10" 2 0 1)))
        (with-asserted-query-results (query50 db :npoints 1)
          ("testfeature01" 0 0 1) ("testfeature10" 0 0 0))))))

(defun test-0048 ()
  (let ((datum1 (make-datum "testfeature01" '((0d0 0.5d0) (0.5d0 0d0))
                            :times (coerce '(0d0 1d0 1d0 2d0) '(vector double-float))))
        (datum2 (make-datum "testfeature10" '((0.5d0 0d0) (0d0 0.5d0) (0.5d0 0d0))
                            :times (coerce '(0d0 2d0 2d0 3d0 3d0 4d0) '(vector double-float)))))
    (with-adb (db "testdb.0048" :direction :output :if-exists :supersede)
      (insert datum1 db)
      (insert datum2 db)
      (l2norm db)
      (assert-erroneous (retrieve "testfeature" db))
      (assert (equalp (retrieve "testfeature01" db) datum1))
      (assert (equalp (retrieve "testfeature10" db) datum2)))))

(defun run-tests ()
  (test-0003)
  (test-0004)
  (test-0010)
  (test-0031)
  (test-0036)
  (test-0048))
