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

(cl:defpackage "SB-ADB"
  (:use "CL" "SB-ALIEN")
  (:export
   ;; classes, constructors and accessors
   "ADB" "WITH-ADB"
   "DATUM" "MAKE-DATUM" "DATUM-KEY" "DATUM-DATA" "DATUM-TIMES" "DATUM-POWER"
   "RESULT" "RESULT-KEY" "RESULT-DISTANCE" "RESULT-QPOS" "RESULT-IPOS"
   "RESULTS"
   ;; functions
   "OPEN" "CLOSE" "INSERT" "RETRIEVE" "QUERY" "LISZT")
  (:shadow "OPEN" "CLOSE"))
