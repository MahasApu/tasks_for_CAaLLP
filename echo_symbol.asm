.text
.macro exit %encode
  li a0, %encode
  li a7, 93
  ecall
.end_macro

.macro read_char %dst
  li a7, 12
  ecall
  mv %dst, a0
.end_macro

.macro print_char %src
  mv a0, %src
  li a7, 11
  ecall
.end_macro 

.macro next %sym
  addi %sym, %sym, 1  
.end_macro

main: 
  li t1, 10           # enter
  
  circle:
    read_char t0
    beq t0, t1, exit
    
    next t0          # increment in hex 
    print_char t1    # print enter
    print_char t0
    
    j circle
  
  
#  li t1, '0'
#  blt t0, t1, exit
#  li t1, '9'
#  bgt t0, t1, exit
  


exit:
  exit 0 
