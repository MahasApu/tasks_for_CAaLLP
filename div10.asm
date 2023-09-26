.text

.macro exit %encode
  li a0, %encode
  li a7, 93
  ecall
.end_macro

.macro print_char %src
  mv a0, %src
  li a7, 11
  ecall
.end_macro 

.macro read_char %dst
  li a7, 12
  ecall
  mv %dst, a0
.end_macro

.macro print_int %src
  mv a0, %src
  li a7, 1
  ecall
.end_macro



# /////////////////////////////////////////////////

main:
  li t6 ' '
  call read_nums
  call print_d
  j exit
    


# read_nums () = num unsigned
# args:    a1 -- read_char + mult( 10, a1 )
# res:     a0 -- num  

read_nums:
  addi   sp, sp, -4
  sw     ra, 0(sp) 
  
  li     s0, ' '
  li     a1, 0          #  result

l_while_read_decimal:

  read_char a0
  beq  a0,  s0, l_ret_read_decimal  # if space (a1 = result)
  addi a0,  a0, -48    # in dec
                       # temporary saving values of a0,a1 to s1,s2
  mv   s1,  a0         # move a0 value (read number) to s1
  mv   s2,  a1         # move a0 value to s1
  mv   a0,  a1         # move a1 value (cur res) to a0 for mult func
  li   a1,  0xA        # a1 = 10
  call mult            # (a0 * a1) return result to a0
  mv   a1,  a0         # mv current result of mult to a1
  mv   a0,  s1         # get back prev value of a0 (num)
  add  a1,  a1, a0     # sum cur result and prev value of a0
  j l_while_read_decimal 

l_ret_read_decimal:
  mv     a0, a1
  lw     ra, 0(sp)
  addi   sp, sp, 4
  jalr   zero, ra, 0

# mult (a,b) = a*b unsigned
# args: a0 -- a
#       a1 -- b
#res:   a0 -- a*b   
    
mult:
  li     t0, 0
 m_loop:
  andi   t1, a1, 1
  beqz   t1, m_nonset
  add    t0, t0, a0
 m_nonset:
  slli   a0, a0, 1
  srli   a1, a1, 1
  bnez   a1, m_loop
  mv     a0, t0
  jalr   zero, ra, 0

 
           
                               
# div10 (a) = a//10 unsigned
# args: a0 -- a
#       s0 -- 10
#       s1 -- a0 * 1/4
#res:   a0 -- 1/2 * (1/4 - 1/2 * 1/10) -- rec call  
                            
div10:

  addi   sp, sp, -8
  sw     ra, 4(sp)
  sw     s1, 0(sp)  
  
  li     t1, 9
  bge    a0, t1, div_loop
  mv     a0, zero
  j end_div
  
div_loop:
    srli s1, a0, 2
    srli a0, a0, 1
    call div10
    sub  a0, s1, a0
    srli a0, a0, 1 
    
end_div:
  lw   ra, 4(sp)
  lw   s1, 0(sp)
  addi sp, sp, 8
  ret



# mod10 (a) = a%10
# args:  a0  -- a
#        a0  -- a -> a0 -- div10(a)        
# res:   a0 -- a0 - 10 * div10(a0)

mod10:
  addi   sp,   sp, -4
  sw     ra,   0(sp) 

  mv     s0,   a0
  call   div10
  li     a1,   0xA
  call   mult 
  bgt    a0,   s0, correction_mod10
  ble    a0,   s0, nothing
  
correction_mod10:
  addi,  a0,   a0, -10
nothing:
  sub    a0,   s0, a0
    
end_mod10:
  lw     ra,   0(sp)
  addi   sp,   sp, 4
  jalr   zero, ra, 0



# print_d (a) = a unsigned
# args:  a0  -- a
#        s1  -- a % 10        
# res:   rec printing dig of a

print_d:
  addi   sp, sp, -8
  sw     ra, 4(sp)
  sw     s1, 0(sp)
  
  bnez   a0, loop_print_d
  mv     a0, zero
  j end_print_d
  
loop_print_d:

    mv      s0, a0  
    call mod10
    mv      s1, a0
    
    mv      a0, s0
    call    div10
    mv      a0, a0
    call    print_d
    
    addi a3, s1, 48
    print_char a3
    li a3 0 

  
end_print_d:
  lw   ra, 4(sp)
  lw   s1, 0(sp)
  addi sp, sp, 8
  ret


# ////////////////////////////////////////////////

exit:
exit 0
  
     
  
  
  
