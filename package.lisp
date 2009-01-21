(cl:defpackage "SB-ADB"
  (:use "CL" "SB-ALIEN")
  (:export "ADB" "OPEN" "CLOSE" "QUERY" "WITH-ADB")
  (:shadow "OPEN" "CLOSE"))
