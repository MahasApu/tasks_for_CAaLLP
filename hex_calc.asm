.text

.macro exit %encode
  li a0, %encode
  li a7, 93                  # exit with 0         
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

.macro print_hex %src
  mv a0, %src
  li a7, 34
  ecall
.end_macro 

.macro print_int %src
  mv a0, %src
  li a7, 5
  ecall
.end_macro
  
  
main:
  li t0 32     # space in ASCII
  li s7 0 
  li s8 0
  li t6 0      # answer
  
  li s0, 4     # 4 bits for shifting
  li s1 0x2f   # .. 0   the sym before 0 in ASCII
  li s2 0x3a   # 9 ..   the sym after 9 in ASCII
  li s3 0x60   # .. a   the sym before a in ASCII
  li s4 0x7a   # z ..   the sym after z in ASCII
 
  
  li s5, 0x30  # for numbers shifting
  li s6, 0x57  # for letters shifting
  
  number1:
  
    read_char t1
    beq t0, t1, number2    # if char is eq to space then start readind second num
    bgt t1, s2, letter1    # if char is greater than 0x3a then start readind letters to num
                           # else 
                            
    sub t1, t1, s5         # 
    sll s7, s7, s0         #
    add s7, s7, t1         #
    
    j number1
    
  letter1:
  
     sub t1, t1, s6  
     sll s7, s7, s0
     add s7, s7, t1
     j number1
    
  number2:
   
    read_char t3
    
    beq t0, t3, operator
    bgt t3, s2, letter2
    
    
    sub t3, t3, s5
    sll s8, s8, s0
    add s8, s8, t3
    
    j number2
    
  letter2:
    sub t3, t3, s6
    sll s8, s8, s0
    add s8, s8, t3
    j number2
   
  operator:
    li s1 0x2b # plus
    li s2 0x2d # minus
    li s3 0x26 # and
    li s4 0x7c # or
    
    read_char t5
    beq t5, s1, plus
    beq t5, s2, minus_check
    beq t5, s3, andd
    beq t5, s4, orr
    
  plus:
    add t6, s7, s8
    j printer
    
  minus_check:
    bgt s7, s8, minus1
    bgt s8, s7, minus2
  minus1:
    sub t6, s7, s8
    j printer
  minus2:
    sub t6, s8, s7
    j printer
    
  andd:
    and t6, s7, s8
    j printer
  orr:
    or t6, s7, s8
    j printer
    
  printer:
    li t1 1                # counter - from 1 to 9 (8 digits)
    li t2 9
    li t3 0xf0000000       # for logical and to get answer in chars
    li s5 10
    mv t5 t6
    print_char s5
    
    loop:
    
      beq t1, t2, exit      # if counter == 9 then print answer
      and t4, t5, t3         # logical and
      
      srli t3, t3, 4        # shift t3 = 0xF right by 4 bits
      addi t1, t1, 1        # increment counter
      
      loop_inner:
        beqz t4, printer2     # to prevent endless cycle
        andi s0, t4, 0xF      # check the last digit
        
        bnez s0, printer2    # if not zero - print
        
        srli t4, t4, 4       # else - shift rifht
        j loop_inner
        
      j loop
      
    printer2:
    
    li s1 0xa 
    mv s7 t4

    # bgt s7, s1, 4
    blt s7, s1, num_print
    bge s7, s1, lett_print
    
    num_print:
      addi s6, s7, 0x30
      print_char s6
      j loop
  
    lett_print:
      addi s8, s7, 0x57
      print_char s8
      j loop
    
    

exit:
  exit 0 
