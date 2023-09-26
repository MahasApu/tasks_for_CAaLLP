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

main:
  call read_nums
  call dataArray
  j exit
  
dataArray:

  # TODO: first save regs, then allocate array below saved regs
  
  addi sp, sp, -20
  sw   ra, 0(sp)        # save ra on the stack
  sw   s0, 4(sp)
  sw   s1, 8(sp)
  sw   s2, 12(sp)
  sw   s4, 16(sp)
  
  mv s1, sp
  
  li   a1, -4
  mul  a1, a1, a0  # TODO: pass only a0
  add  sp, sp, a1  # adjust sp to allocate space for local variables and array 
  
  mv   t0, sp      # calculate the address of the array on the stack
  mv   s4, sp
  
  mv   s0, a0           # number for filling
  addi s2, a0, -1       # number for sieve 
  j fill_array

fill_array:
  beqz   s0, sieve_main  # number
  addi   t0, t0, 4       # change sp
  sw     s0, 0(t0)       # save cur number
  addi   s0, s0, -1      # dec number
  j fill_array
  
sieve_main:
  beqz s2, exit          # if num is zero
  addi t0, t0, -4        # change sp
  lw   s0, 0(t0)         # load num from stack 
  beqz s0, skip          # if zero - skip (dec num)
  print_int s0           
  
  li t2, 32
  print_char t2
  addi s2, s2, -1       # if num is not zero - dec num and print
  j sieve_algorithm

 
sieve_algorithm:
  mv t1, t0  # save sp
  mv t2, s0  # save num
  li t3, 2   # num multiplier
  
  sieve_algorithm_loop:
    # TODO: cmp t0, s4
    blt t0, s4, in_range # if num is less than current max num (counter)
    li  a1, -4
    mul a0, t2, a1
 
    add  t0, t0, a0          # move down the stack         
    sw   zero, 0(t0)
    addi t3, t3, 1
    j sieve_algorithm_loop
  
skip:
  addi s2, s2, -1
  j sieve_main 
   
in_range:
  mv t0, t1
  j sieve_main

exit_array:
  mv   sp, s1
  lw   ra, 0(sp)        # save ra on the stack
  lw   s0, 4(sp)
  lw   s1, 8(sp)
  lw   s2, 12(sp)
  lw   s4, 16(sp)
  addi sp, sp, 20
  jalr zero, ra, 0
  


# read_nums () = num unsigned
# args:    a1 -- read_char + mult( 10, a1 )
# res:     a0 -- num  

read_nums:
  addi   sp, sp, -16
  sw     ra, 0(sp) 
  sw     s0, 4(sp)
  sw     s1, 8(sp)
  sw     s2, 12(sp)
  
  li     s0, ' '
  li     a1, 0          #  result

l_while_read_decimal:

  read_char a0
  beq  a0,  s0, l_ret_read_decimal  # if space 
  addi a0,  a0, -48    # in dec
                       # temporary saving values of a0,a1 to s1,s2
  mv   s1,  a0         # move a0 value (read number) to s1
  mv   s2,  a1         # move a0 value to s1
  li   a0,  0xA        # move a1 value (cur res) to a0 for mult func

  call mult            # (a0 * a1) ret result to a0
  mv   a1,  a0         # mv current result of mult to a1
  mv   a0,  s1         # get back prev value of a0 (num)
  add  a1,  a1, a0     # sum cur result and prev value of a0
  j l_while_read_decimal 

l_ret_read_decimal:
  mv     a0, a1
  lw     ra, 0(sp)
  lw     s0, 4(sp)
  lw     s1, 8(sp)
  lw     s2, 12(sp)
  lw     s4, 16(sp)
  addi   sp, sp, 20
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
  addi   sp,   sp, -8
  sw     ra,   0(sp) 
  sw     s0,   4(sp)

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
  lw     s0,   4(sp)
  addi   sp,   sp, 8
  jalr   zero, ra, 0



# print_d (a) = a unsigned
# args:  a0  -- a
#        s1  -- a % 10        
# res:   rec digs printing of a

print_decimal:

  addi   sp, sp, -12
  sw     ra, 0(sp)
  sw     s0, 4(sp)
  sw     s1, 8(sp)
  
  bnez a0, print_number
  print_int a0
  j stop_print
  
 print_number:
  call print_d
  
 stop_print:
  lw   ra, 0(sp)
  lw   s0, 4(sp)
  lw   s1, 8(sp)
  addi sp, sp, 12
  ret
  
print_d:

  addi   sp, sp, -12
  sw     ra, 0(sp)
  sw     s0, 4(sp)
  sw     s1, 8(sp)
  
  bnez   a0, loop_print_d
  li     a0, '0'
  
  j end_print_d
  
loop_print_d:

    mv    s0, a0  
    call  mod10
    mv    s1, a0
    
    mv    a0, s0
    call  div10
    mv    a0, a0
    call  print_d
    li    a3, 0
    
    addi  a3, s1, 48
    print_char    a3
    li    a3, 0 

  
end_print_d:
  lw   ra, 0(sp)
  lw   s0, 4(sp)
  lw   s1, 8(sp)
  addi sp, sp, 12
  ret

# ////////////////////////////////////////////////

exit: 
  exit 0