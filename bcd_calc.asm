
.macro exit %encode
  li a0, %encode
  li a7, 93                  # exit with 0         
  ecall
.end_macro 

.macro print_int %src
  mv a0, %src
  li a7, 1
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

main:
  li t0 32       # space in ASCII
  li t3 0        # answer

  li s1   0x2f   # .. 0   the sym before 0 in ASCII
  li s2   0x3a   # 9 ..   the sym after 9 in ASCII
  li s3   0x2d   # sym  - 
  
  li s5,  0x30   # for numbers shifting
  li s6,  0x57   # for letters shifting
  li s7,  0      # num1
  li s8,  0      # num2
  li s9,  0      # flag for sign 
  li s10, 0      # flag for sign of num2

  number1:
    read_char t1
    beq t1, s3, sym_minus1 # flag1 = 1  t2 == - 
    beq t1, t0, number2    # if char is eq to space then start readind second num
    bgt t1, s2, exit       # greater than 9
                                            
    addi t1, t1, -0x30       
    slli s7, s7, 4         
    add  s7, s7, t1         
    
    j number1
  
  sym_minus1:
    li s9, 1
    j number1
    

    
  number2:
    read_char t2
    beq t2, s3, sym_minus2   # flag2 = 1  t2 == -
    beq t2, t0, add_sign     # if char is eq to space then add signs to nums
    bgt t2, s2, exit         # greater than 9
    
    addi t2, t2, -0x30
    slli s8, s8, 4
    add  s8, s8, t2
    
    j number2
    
  sym_minus2:
    li s10, 1
    j number2
  
  add_sign:
   li  t1, 0
   li  t2, 1 
   beq s9, t1, add_plus_1 
   beq s9, t2, add_minus_1
 
  add_minus_1:
    slli s7,  s7, 4     
    addi s7,  s7, 0xb 
    beq  s10, t1, add_plus_2 
    beq  s10, t2, add_minus_2 
    
  add_plus_1:
    slli s7,  s7, 4     
    addi s7,  s7, 0xa
    beq  s10, t1, add_plus_2 
    beq  s10, t2, add_minus_2 
    
    
  add_minus_2:
    slli s8, s8, 4     
    addi s8, s8, 0xb
    j operator
     
  add_plus_2:
    slli s8, s8, 4     
    addi s8, s8, 0xa
    j operator
    
        
  operator:
    li s1 0x2b # plus
    li s2 0x2d # minus
    li s3 0x26 # and
    li s4 0x7c # or
    li s5 0xa
    li s6 0xb
    
    
    read_char t5 # operand
    li  s10, 0 
    beq t5, s1, pre_sum
    beq t5, s2, pre_minus

 
    

# /////////////  for minus /////////////////
       
  pre_minus:
  li s5 0xa
  li s6 0xb
  
  andi t1, s7, 0xf              # get sign1
  andi t2, s8, 0xf              # get sign1
  
  beq  t2, s6, minus_make_pos      # if sign of second num is b then it needs to be turned to a
  beq  t2, s5, classic_minus   
  
  
  minus_make_pos:
    
    srli s8, s8, 4
    slli s8, s8, 4
    addi s8, s8, 0xa    # add sign
    
    andi t2, s8, 0xf        # get sign1 (+)
    beq  t2, s5, pre_sum    # just sum two nums
    
  classic_minus:
    srli s8, s8, 4
    slli s8, s8, 4
    addi s8, s8, 0xb    # add sign
    
    andi t2, s8, 0xf        # get sign1 (+)
    beq  t2, s5, pre_sum    # just sum two nums
     
    
    
   
    
# /////////////// for sum ///////////////////   
  pre_sum:
  andi t1, s7, 0xf              # get sign1
  andi t2, s8, 0xf              # get sign1
  beq  t1, t2, plus              # if a/a or b/b
  bne  t1, t2, change_sign_sum
 
  
  plus:
    andi t1, s7, 0xf 
    
    beq  t1, s5, plus_pos  # if sign is a
    beq  t1, s6, plus_neg  # if sign is b
    
    plus_pos:
      srli s7, s7, 4     # del a/b at the end
      srli s8, s8, 4     # del a/b at the end
      li   s2  0         #flag for sign
      j my_summ
      
    plus_neg:
      srli s7, s7, 4     # del a/b at the end
      srli s8, s8, 4     # del a/b at the end
      li   s2  1         # flag for sign  
      j my_summ 
    

    
            
  change_sign_sum:
    andi t1, s7, 0xf           # get sign1
    andi t2, s8, 0xf           # get sign2
    
    beq t1, s5, pos_branch     # num1 is pos and num2 is neg
    beq t1, s6, neg_branch     # num1 is neg and num2 is pos
    
    pos_branch:
      # if num1 is pos then num2 is neg. needs to be compared
      srli s7, s7, 4     # del a/b at the end   num1
      srli s8, s8, 4     # del a/b at the end   num2
      
      bge s7, s8, pos_1
      bgt s8, s7, neg_1
      pos_1:
        li s2, 0
        j my_diff
        
      neg_1:
	li s2, 1
	mv t1, s7
	mv s7, s8
	mv s8, t1
        j my_diff
    
    
     neg_branch:
      # if num1 is neg then num2 is pos. needs to be compared
      srli s7, s7, 4     # del a/b at the end   num1
      srli s8, s8, 4     # del a/b at the end   num2
      
      bgt s8, s7, pos_2
      bge s7, s8, neg_2
      
      pos_2:
	li s2, 0   # add sign
	
	mv t1, s7
	mv s7, s8
	mv s8, t1
        j my_diff
    
      neg_2:
	li s2, 1   # add sign

        j my_diff
        

             
 my_diff:
  # s2 - sign
    li t1  0                # counter - from 1 to 9 (8 digits)
    li t2  8
    
    mv t3  t5               # operator
    li t6  0                # result
    li s4  0                # overflow
    li s5  0xf              # for logical and to get answer in chars
    li s9  0x6             
    
    li s11 0x2d     # minus sym in ASCII
    li s10 0x0      # buffer for correction
    
    
    loop_main_diff:

      beq  t1, t2, final_minus       # if counter == 9 then print answer
      # bgt s5, s7, check_exit1      # if end of num
      # bgt s5, s8, check_exit2
      li   s0, 0x0
      li   s1, 0x0
      
      and  t4, s7, s5        # get the last digit in num
      and  t5, s8, s5 
      
      slli s5, s5, 4        # shift s5 = 0x0000000f left by 4 bits
      addi t1, t1, 1        # increment counter
      
      bnez t4, loop_inner_diff1
      bnez t5, loop_inner_diff2
      
      
      j loop_main_diff

     
      loop_inner_diff1:
      
     
        beqz t4, loop_inner_diff2      # to prevent endless cycle
        andi s0, t4, 0xf               # check the last digit
        bnez s0, loop_inner_diff2      # if not zero - print
        srli t4, t4, 4                 # else - shift rifht
        j loop_inner_diff1
        
     loop_inner_diff2:
        beqz t5, checker_diff      # to prevent endless cycle
        andi s1, t5, 0xf           # check the last digit
        bnez s1, checker_diff      # if not zero - print
        srli t5, t5, 4             # else - shift rifht
        j loop_inner_diff2
     
     
     checker_diff:
     
       # s0  the first
       # s1  the second
       
       li  s6 0x0  
       
       bge s1, s0, correction_diff
       
       sub s6, s0, s1
       sub s6, s6, s4
       
       # bgt  s6, s2, correction_diff
       li   s4, 0x0      # flag
       slli s9, s9, 4    # 0x6 0x60 0x600.....
       
       j loop_main_diff
       
     correction_diff:
     
       addi s0, s0, 0xA
       sub  s6, s0, s1
       sub  s6, s6, s4
       li   s4, 0x1
       
       add  s10, s10, s9 
       slli s9, s9, 4    # 0x6 0x60 0x600.....
       
       
       j loop_main_diff
     
final_minus:

print_hex s10
  sub  t6, s7, s8
  sub, t6, t6, s10
  j pre_print 
      
      
                           
                                                
                                                                                          
 my_summ:
    li t1  0                # counter - from 1 to 9 (8 digits)
    li t2  8
    mv t3  t5               # operator
    li t6  0                # result
    li s4  0                # overflow
    li s5  0xf      # for logical and to get answer in chars
    li s9  0x2d             # minus sym in ASCII
    li s11 0x9
    li s10 0x0      # buffer for correction
    li s9  0x6
    
    loop_main:

      beq  t1, t2, final_plus           # if counter == 9 then print answer
      # bgt s5, s7, check_exit1      # if end of num
      # bgt s5, s8, check_exit2
      li s0 0x0
      li s1 0x0
      
      and  t4, s7, s5        # get the last digit in num
      and  t5, s8, s5 
      
      slli s5, s5, 4        # shift s5 = 0x0000000f left by 4 bits
      addi t1, t1, 1        # increment counter
      
      bnez t4, loop_inner1
      bnez t5, loop_inner2
      
      
      j loop_main

     
      loop_inner1:
      
     
        beqz t4, loop_inner2      # to prevent endless cycle
        andi s0, t4, 0xf      # check the last digit
        bnez s0, loop_inner2    # if not zero - print
        srli t4, t4, 4       # else - shift rifht
        j loop_inner1
        
     loop_inner2:
        beqz t5, checker      # to prevent endless cycle
        andi s1, t5, 0xf      # check the last digit
        bnez s1, checker   # if not zero - print
        srli t5, t5, 4       # else - shift rifht
        j loop_inner2
     
     
     checker:
       li  s3 0x9
       li  s6 0x0
       add s6, s1, s0
       add s6, s6, s4
       
       
       bgt  s6, s3, correction
       li   s4 0x0        # flag
       slli s9, s9, 4    # 0x6 0x60 0x600.....
       
       j loop_main
       
     correction:
       li s4 0x1
       add s10, s10, s9 
       slli s9, s9, 4    # 0x6 0x60 0x600.....
       
       
       j loop_main
     
final_plus:
  add t6, s7, s8
  add, t6, t6, s10
  j pre_print 
      
     
       
    
   
pre_print:

    # print_hex t6
    li t2, 10
    print_char t2
    bnez s2, print_minus
    #beq t5, s1, sub_buffer   # check t5 = operator  
    #bne t5, s1, add_buffer 
    j printer
    
    print_minus:
      li t2, 10
      print_char t2
      li s1, 0x2d              # minus
 
      print_char s1
      j printer
     
        
printer:
    li t1 1                # counter - from 1 to 9 (8 digits)
    li t2 9
    li t3 0xf0000000       # for logical and to get answer in chars
    mv t5 t6
    
    li s0 0
    li s1 1
    
    loop:
    
      beq t1, t2, exit      # if counter == 9 then print answer
      and t4, t5, t3         # logical and
      
      srli t3, t3, 4        # shift t3 = 0xF right by 4 bits
      addi t1, t1, 1        # increment counter
      
      loop_inner:
      
        beqz t4, printer2     # to prevent endless cycle
        andi s2,  t4, 0xF      # check the last digit
        
        bnez s2, printer2    # if not zero - print
        
        srli t4, t4, 4       # else - shift rifht
        j loop_inner
        
      j loop
      
      
      
    printer2:
    
    li s1 0xa 
    mv s7 t4
    blt s7, s1, num_print
    
    num_print:
      addi s7, s7, 0x30
      print_char s7
      j loop
      
    
exit:
  exit 0
